# MariaDB Migration Reference

Load this file before writing any MariaDB script. It holds the script skeleton, guard syntax, batching, locking, and version-dependent features. Recipes for specific changes are in `migration-patterns.md`. Assume InnoDB unless the schema shows another engine. Aria and MyISAM tables are not transactional, so a rollback won't undo changes to them.

## Contents

1. DDL commits implicitly
2. Script skeleton
3. Existence guards
4. Row-count checks and backups
5. Batching large changes
6. Locking and online DDL
7. Version features
8. Gotchas

---

## 1. DDL commits implicitly

`ALTER TABLE`, `CREATE TABLE` (including `CREATE TABLE ... SELECT`), `DROP`, `RENAME`, `TRUNCATE`, `CREATE INDEX`, and `DROP INDEX` commit any open transaction before and after they run, and they cannot be rolled back. Design around this:

- Put DDL in its own phase, outside any transaction, with every statement guarded so the phase can be re-run after a partial failure.
- Put DML in a separate phase inside `START TRANSACTION ... COMMIT`, with an error handler.
- Create backup tables before the data transaction starts, because `CREATE TABLE` would commit it.
- In the run notes, say which phases can be undone by the rollback script and which can only be reversed by more DDL.

`CREATE TEMPORARY TABLE` does not commit implicitly.

## 2. Script skeleton

Procedural logic (`IF`, `WHILE`, variables, handlers) needs a compound statement. MariaDB 10.1.1+ runs `BEGIN NOT ATOMIC ... END` directly, without creating a procedure. Clients split on `;`, so wrap the block with `DELIMITER`. The `mariadb`/`mysql` CLI and HeidiSQL understand `DELIMITER`. DBeaver, DbUp, and Flyway handle it differently, so check the tool the user named.

```sql
/*
  Purpose : <what and why>
  Ticket  : <ABC-123>
  Target  : MariaDB <version> · run with mariadb CLI | HeidiSQL | DbUp | Flyway
  Author  : <name>
  Date    : <yyyy-mm-dd>
  Phases  : 2 of 3 - backfill
  Re-runnable: yes
*/

-- Phase 1: DDL. Commits implicitly. Cannot be rolled back.
SET SESSION lock_wait_timeout = 10;   -- seconds; fail fast on metadata locks
ALTER TABLE orders ADD COLUMN IF NOT EXISTS status VARCHAR(20) NULL, ALGORITHM=INSTANT;

-- Phase 2: data, inside one transaction
DELIMITER //
BEGIN NOT ATOMIC
    DECLARE v_expected INT DEFAULT NULL;   -- FILL IN from the pre-check before running
    DECLARE v_rows INT;
    DECLARE v_msg VARCHAR(255);

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    IF v_expected IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Set v_expected from the pre-check before running.';
    END IF;

    START TRANSACTION;

    UPDATE orders
    SET    status = CASE WHEN shipped_at IS NOT NULL THEN 'Completed' ELSE 'Pending' END
    WHERE  status IS NULL;
    SET v_rows = ROW_COUNT();             -- read immediately after the statement

    IF v_rows <> v_expected THEN
        SET v_msg = CONCAT('Expected ', v_expected, ' rows, got ', v_rows, '. Rolled back.');
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = v_msg;
    END IF;

    COMMIT;
END //
DELIMITER ;
```

`SIGNAL SQLSTATE '45000'` is caught by the `SQLEXCEPTION` handler, which rolls back and re-raises the error. `MESSAGE_TEXT` takes a literal or a variable, not an expression, so build messages in a variable.

## 3. Existence guards

Native `IF [NOT] EXISTS` clauses (pass with a warning instead of failing):

```sql
CREATE TABLE IF NOT EXISTS ...;
DROP TABLE IF EXISTS ...;
ALTER TABLE orders ADD COLUMN IF NOT EXISTS status VARCHAR(20) NULL;
ALTER TABLE orders DROP COLUMN IF EXISTS legacy_flag;
ALTER TABLE orders MODIFY COLUMN IF EXISTS status VARCHAR(30) NOT NULL DEFAULT 'Pending';
ALTER TABLE orders CHANGE COLUMN IF EXISTS old_name new_name VARCHAR(20) NULL;
ALTER TABLE orders RENAME COLUMN IF EXISTS old_name TO new_name;              -- 10.5.2+
ALTER TABLE orders ADD INDEX IF NOT EXISTS ix_orders_status (status);
ALTER TABLE orders ADD CONSTRAINT uq_orders_number UNIQUE KEY IF NOT EXISTS uq_orders_number (number);
ALTER TABLE orders ADD CONSTRAINT fk_orders_customers
    FOREIGN KEY IF NOT EXISTS (customer_id) REFERENCES customers (id);
ALTER TABLE orders DROP INDEX IF EXISTS ix_orders_status;
ALTER TABLE orders DROP FOREIGN KEY IF EXISTS fk_orders_customers;
ALTER TABLE orders DROP CONSTRAINT IF EXISTS ck_orders_status;
CREATE INDEX IF NOT EXISTS ix_orders_status ON orders (status);
```

There is no `IF NOT EXISTS` for `ADD CONSTRAINT ... CHECK` or for checking nullability or type. Use `information_schema` inside a compound statement:

```sql
DELIMITER //
BEGIN NOT ATOMIC
    IF NOT EXISTS (SELECT 1 FROM information_schema.TABLE_CONSTRAINTS
                   WHERE CONSTRAINT_SCHEMA = DATABASE() AND TABLE_NAME = 'orders'
                     AND CONSTRAINT_NAME = 'ck_orders_status' AND CONSTRAINT_TYPE = 'CHECK') THEN
        ALTER TABLE orders ADD CONSTRAINT ck_orders_status
            CHECK (status IN ('Pending', 'Completed', 'Cancelled'));
    END IF;

    IF EXISTS (SELECT 1 FROM information_schema.COLUMNS
               WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'orders'
                 AND COLUMN_NAME = 'status' AND IS_NULLABLE = 'YES') THEN
        ALTER TABLE orders MODIFY COLUMN status VARCHAR(20) NOT NULL DEFAULT 'Pending';
    END IF;
END //
DELIMITER ;
```

Always filter `information_schema` by `DATABASE()` (or the explicit schema name). Otherwise a same-named table in another database on the server matches.

## 4. Row-count checks and backups

MariaDB has no `OUTPUT` clause on `UPDATE`. Create the backup table in the DDL phase, then fill it inside the data transaction just before the change:

```sql
-- DDL phase
CREATE TABLE IF NOT EXISTS bkp_orders_20261029_abc123 (
    id BIGINT NOT NULL PRIMARY KEY,
    old_status VARCHAR(20) NULL,
    changed_at_utc DATETIME(6) NOT NULL
) ENGINE=InnoDB;

-- data phase, inside the transaction
INSERT IGNORE INTO bkp_orders_20261029_abc123 (id, old_status, changed_at_utc)
SELECT id, status, UTC_TIMESTAMP(6) FROM orders
WHERE  status = 'Pending' AND created_at < '2026-01-01';

UPDATE orders o
JOIN   bkp_orders_20261029_abc123 b ON b.id = o.id
SET    o.status = 'Cancelled'
WHERE  o.status = 'Pending';
SET v_rows = ROW_COUNT();
```

`INSERT IGNORE` keeps a re-run from failing on rows already backed up. Use it only on the backup table, never on real data, because it also hides type and constraint errors.

For a `DELETE`, back up full rows: `CREATE TABLE bkp_x LIKE x;` in the DDL phase (copies columns and indexes), then `INSERT INTO bkp_x SELECT * FROM x WHERE ...` in the transaction. `DELETE ... RETURNING` (10.0.5+) can show deleted rows in the client, but it can't insert them into a table.

## 5. Batching large changes

With `autocommit = 1`, each statement in a loop commits on its own, which keeps transactions short. Batch by key range on a numeric primary key:

```sql
DELIMITER //
BEGIN NOT ATOMIC
    DECLARE v_batch  INT DEFAULT 5000;
    DECLARE v_from   BIGINT;
    DECLARE v_max    BIGINT;
    DECLARE v_total  BIGINT DEFAULT 0;

    SELECT MIN(id) - 1, MAX(id) INTO v_from, v_max FROM orders;

    WHILE v_from < v_max DO
        UPDATE orders
        SET    status = CASE WHEN shipped_at IS NOT NULL THEN 'Completed' ELSE 'Pending' END
        WHERE  id > v_from AND id <= v_from + v_batch
          AND  status IS NULL;              -- keeps the loop re-runnable
        SET v_total = v_total + ROW_COUNT();
        SET v_from = v_from + v_batch;
        DO SLEEP(0.05);                     -- give replicas and other sessions room
    END WHILE;

    SELECT v_total AS rows_updated;
END //
DELIMITER ;
```

Alternative for non-numeric keys: single-table `UPDATE ... WHERE <not yet done> ORDER BY <pk> LIMIT n` in a loop until `ROW_COUNT() = 0`.

- `ROW_COUNT()` after `UPDATE` counts rows actually changed, not rows matched. A row set to the value it already has counts as 0. Write the `WHERE` so it only matches rows that still need the change.
- `ORDER BY ... LIMIT` is not allowed on multi-table `UPDATE`/`DELETE`. Batch those by key range.
- With statement-based or mixed binlog format, `UPDATE`/`DELETE ... LIMIT` without `ORDER BY` on a unique key is unsafe for replication. Always order by the primary key.
- **Galera cluster:** each transaction is certified across the cluster, and very large ones fail or stall the cluster (`wsrep_max_ws_rows`, `wsrep_max_ws_size`). Batch every large change. DDL runs in total-order isolation by default and blocks writes on all nodes while it runs. Ask whether the target is Galera when a change touches a big table.

## 6. Locking and online DDL

- Every `ALTER TABLE` needs an exclusive metadata lock, at least briefly. If a long transaction holds the table, the `ALTER` waits, and every new query on the table queues behind it. Set `SET SESSION lock_wait_timeout = 10;` or use `ALTER TABLE orders WAIT 10 ...` / `NOWAIT` (10.3+) so it fails fast instead.
- Specify `ALGORITHM` and `LOCK` explicitly. If the operation can't run that way, it fails instead of silently copying the table:
  - `ALGORITHM=INSTANT`: metadata-only. Adding a column is instant from 10.3 (last position only) and from 10.4 at any position. Dropping a column and reordering columns are instant from 10.4.
  - `ALGORITHM=NOCOPY`: no clustered-index rebuild.
  - `ALGORITHM=INPLACE, LOCK=NONE`: online rebuild that allows concurrent reads and writes (for example `ADD INDEX`).
  - From 11.2, most `ALGORITHM=COPY` operations also allow `LOCK=NONE`.
- Changing a column's type, or making it `NOT NULL`, usually rebuilds the table. Estimate the time from the table size, and offer `pt-online-schema-change` or `gh-ost` as options for the user's DBA on very large tables.
- Adding a foreign key with `foreign_key_checks = 1` validates existing rows and can't run as `INPLACE`. Never turn the checks off to make it faster, because orphan rows would then go undetected.

## 7. Version features

Ask for the version when you need anything newer than 10.6. Current long-term releases are 10.6, 10.11, 11.4, and 11.8.

| Feature | Minimum |
| --- | --- |
| `ADD/DROP COLUMN IF [NOT] EXISTS`, `DELETE ... RETURNING` | 10.0 |
| `BEGIN NOT ATOMIC` outside stored programs, `CREATE INDEX IF NOT EXISTS` | 10.1 |
| CTEs (including recursive), window functions, enforced `CHECK` constraints, `JSON_*` functions | 10.2 |
| Instant `ADD COLUMN` (last position), `WAIT`/`NOWAIT`, system-versioned tables, `UPDATE`/`DELETE` reading the same table in a subquery | 10.3 |
| Instant `ADD COLUMN` anywhere, instant `DROP COLUMN` | 10.4 |
| `RENAME COLUMN`, `RENAME INDEX`, `INSERT ... RETURNING` | 10.5 |
| `UUID` data type | 10.7 |
| `ALGORITHM=COPY, LOCK=NONE` for most operations | 11.2 |

## 8. Gotchas

- **`MODIFY`/`CHANGE COLUMN` replaces the full definition.** Restate `NULL`/`NOT NULL`, `DEFAULT`, `CHARACTER SET`, `COLLATE`, `COMMENT`, and `AUTO_INCREMENT`. Anything you leave out is dropped. Copy the current definition from `SHOW CREATE TABLE` output (ask the user for it) and change only what's needed.
- **Strict mode decides truncation.** With `STRICT_TRANS_TABLES` (default since 10.2.4), out-of-range or too-long values fail. Without it, they are truncated with only a warning. If you don't know the server's `sql_mode`, add a pre-check that finds values that won't fit (`WHERE CHAR_LENGTH(col) > 20`).
- **Table name case:** on Linux, table names are case-sensitive by default (`lower_case_table_names = 0`). Use the exact case from the schema.
- **Collations:** give new string columns the table's charset and collation explicitly (usually `utf8mb4` with the table's collation). Comparing or joining columns with different collations can fail with "Illegal mix of collations" or prevent index use.
- **Updating a table that the subquery reads** fails with error 1093 before 10.3. On older versions, wrap the subquery in a derived table or rewrite it as a `JOIN`.
- **`NOT IN` with a nullable subquery** returns no rows if any value is NULL. Use `NOT EXISTS`.
- **Unique indexes allow many NULLs.** If the business rule says "at most one NULL", the index alone won't enforce it.
- **Booleans are `TINYINT(1)`.** Compare with `= 1`/`= 0`, not `= TRUE` on columns that might hold other values.
- **`TIMESTAMP` columns** may have implicit `DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP`, so a data fix also changes them. Check `SHOW CREATE TABLE`. If the column must keep its value, set it to itself in the `UPDATE` (`SET updated_at = updated_at, ...`).
- **Triggers fire on your DML.** Ask for or look up `SHOW TRIGGERS LIKE 'orders';` output and decide whether they should run.
- **Zero dates** (`'0000-00-00'`) may exist in old data and fail under strict mode or `NO_ZERO_DATE`. Pre-check for them before converting date columns.

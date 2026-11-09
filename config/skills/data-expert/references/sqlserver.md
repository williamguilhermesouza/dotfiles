# SQL Server (T-SQL) Migration Reference

Load this file before writing any SQL Server script. It holds the script skeleton, guard syntax, batching, locking, and version- and edition-dependent features. Recipes for specific changes are in `migration-patterns.md`.

## Contents

1. Script skeleton
2. Batches, GO, and new columns
3. Existence guards
4. Row-count checks and backups
5. Batching large changes
6. Locking and online operations
7. Version and edition features
8. Gotchas

---

## 1. Script skeleton

Use this shape for a phase that changes data, or DDL plus data. SQL Server DDL is transactional (except for things like `CREATE DATABASE`, `ALTER DATABASE`, and full-text operations), so DDL and DML can share one transaction.

```sql
/*
  Purpose : <what and why>
  Ticket  : <ABC-123>
  Target  : SQL Server <version/edition> · run in SSMS (SQLCMD mode) | DbUp | Flyway
  Author  : <name>
  Date    : <yyyy-mm-dd>
  Phases  : 1 of 3 - expand
  Re-runnable: yes
*/
SET NOCOUNT ON;
SET XACT_ABORT ON;          -- any runtime error rolls back the whole transaction
SET LOCK_TIMEOUT 10000;     -- ms; fail with error 1222 instead of blocking the app

DECLARE @ExpectedRows int = NULL;   -- FILL IN from the pre-check before running
DECLARE @Rows int;

IF @ExpectedRows IS NULL
    THROW 50000, N'Set @ExpectedRows from the pre-check before running.', 1;

BEGIN TRY
    BEGIN TRANSACTION;

    -- step 1 ...
    -- step 2 ...
    SET @Rows = @@ROWCOUNT;   -- read immediately after the statement
    IF @Rows <> @ExpectedRows
        THROW 50001, N'Unexpected row count. Rolled back.', 1;

    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    THROW;
END CATCH;
```

Notes:

- `THROW` needs the previous statement terminated with `;`. Terminate every statement.
- `THROW` messages can't take expressions inline. To include values, build the message in a variable first: `DECLARE @Msg nvarchar(2048) = CONCAT(N'Expected ', @ExpectedRows, N', got ', @Rows); THROW 50001, @Msg, 1;`.
- Use `SYSUTCDATETIME()` for timestamps unless the schema clearly stores local time.
- Prefix Unicode literals with `N` when the column is `nchar`/`nvarchar`.

## 2. Batches, GO, and new columns

SQL Server compiles a whole batch before running it. A statement that references a column added earlier in the same batch fails with "Invalid column name", even when the `ALTER TABLE` would have run first. Deferred name resolution only covers tables that don't exist yet, not new columns on existing tables.

Two ways to handle it:

- **Dynamic SQL in one batch** (preferred when you need one transaction): run statements that touch the new column through `EXEC sys.sp_executesql N'...';`. Pass values as parameters, not by concatenation.
- **Separate batches with `GO`**: one batch per phase, each with its own guard and transaction. `GO` is a client batch separator understood by SSMS, sqlcmd, Azure Data Studio, DbUp, and Flyway, not by the server. A transaction does not protect you across `GO`: if batch 2 fails, batch 3 still runs. Put `:on error exit` at the top and tell the user to enable SQLCMD mode in SSMS (Query menu, SQLCMD Mode), or design each batch to be safe on its own.

## 3. Existence guards

```sql
-- table
IF OBJECT_ID(N'dbo.Orders', N'U') IS NULL  CREATE TABLE dbo.Orders (...);

-- column
IF COL_LENGTH(N'dbo.Orders', N'Status') IS NULL
    ALTER TABLE dbo.Orders ADD Status varchar(20) NULL;

-- index
IF NOT EXISTS (SELECT 1 FROM sys.indexes
               WHERE object_id = OBJECT_ID(N'dbo.Orders') AND name = N'IX_Orders_Status')
    CREATE INDEX IX_Orders_Status ON dbo.Orders (Status);

-- constraints (check, default, FK, PK/UQ)
IF OBJECT_ID(N'dbo.CK_Orders_Status', N'C')  IS NULL ...   -- check
IF OBJECT_ID(N'dbo.DF_Orders_Status', N'D')  IS NULL ...   -- default
IF OBJECT_ID(N'dbo.FK_Orders_Customers', N'F') IS NULL ... -- foreign key
IF OBJECT_ID(N'dbo.UQ_Orders_Number', N'UQ') IS NULL ...   -- unique constraint

-- nullability of an existing column
IF EXISTS (SELECT 1 FROM sys.columns
           WHERE object_id = OBJECT_ID(N'dbo.Orders') AND name = N'Status' AND is_nullable = 1)
    ALTER TABLE dbo.Orders ALTER COLUMN Status varchar(20) NOT NULL;

-- 2016+: DROP ... IF EXISTS
DROP INDEX IF EXISTS IX_Orders_Status ON dbo.Orders;
ALTER TABLE dbo.Orders DROP CONSTRAINT IF EXISTS DF_Orders_Status;
ALTER TABLE dbo.Orders DROP COLUMN IF EXISTS Status;
```

Constraint names are schema-scoped objects, so the `OBJECT_ID` lookup uses the schema name plus the constraint name, not the table name.

Dropping an unnamed default constraint (EF Core and many hand-written scripts create them without names):

```sql
DECLARE @df sysname, @sql nvarchar(400);
SELECT @df = dc.name
FROM sys.default_constraints dc
JOIN sys.columns c ON c.object_id = dc.parent_object_id AND c.column_id = dc.parent_column_id
WHERE dc.parent_object_id = OBJECT_ID(N'dbo.Orders') AND c.name = N'Status';
IF @df IS NOT NULL
BEGIN
    SET @sql = N'ALTER TABLE dbo.Orders DROP CONSTRAINT ' + QUOTENAME(@df) + N';';
    EXEC sys.sp_executesql @sql;
END;
```

## 4. Row-count checks and backups

Use `OUTPUT` to capture old values into a backup table in the same statement as the change:

```sql
IF OBJECT_ID(N'dbo.bkp_Orders_20261029_ABC123', N'U') IS NULL
    CREATE TABLE dbo.bkp_Orders_20261029_ABC123
        (Id bigint NOT NULL PRIMARY KEY, OldStatus varchar(20) NULL, ChangedAtUtc datetime2 NOT NULL);

UPDATE o
SET    o.Status = 'Cancelled'
OUTPUT deleted.Id, deleted.Status, SYSUTCDATETIME()
INTO   dbo.bkp_Orders_20261029_ABC123 (Id, OldStatus, ChangedAtUtc)
FROM   dbo.Orders AS o
WHERE  o.Status = 'Pending' AND o.CreatedAt < '2026-01-01';
SET @Rows = @@ROWCOUNT;
```

Keep the backup table plain: the table named in `OUTPUT ... INTO` can't have enabled triggers, foreign keys, or check constraints. `OUTPUT` without `INTO` fails if the table being changed has enabled triggers, so always use `INTO`.

For a `DELETE`, back up full rows (`OUTPUT deleted.*` into a table with the same columns, or `SELECT * INTO <backup> FROM ... WHERE ...` before deleting). The rollback reinserts them with `SET IDENTITY_INSERT dbo.X ON` if the key is an identity column.

The rollback for an update restores from the backup by key and then checks that the restored count equals the backup row count.

## 5. Batching large changes

Keep each batch below about 5,000 rows. Above that, SQL Server tries to escalate row locks to a table lock. Batch by key range when the key is numeric and dense. It reads each range once, instead of rescanning for remaining rows each time.

```sql
DECLARE @BatchSize int = 4000, @FromId bigint, @MaxId bigint, @Rows int, @Total int = 0;
SELECT @FromId = MIN(Id) - 1, @MaxId = MAX(Id) FROM dbo.Orders;

WHILE @FromId < @MaxId
BEGIN
    BEGIN TRANSACTION;
    UPDATE dbo.Orders
    SET    Status = CASE WHEN ShippedAt IS NOT NULL THEN 'Completed' ELSE 'Pending' END
    WHERE  Id > @FromId AND Id <= @FromId + @BatchSize
      AND  Status IS NULL;                 -- keeps the loop re-runnable
    SET @Total += @@ROWCOUNT;
    COMMIT TRANSACTION;

    SET @FromId += @BatchSize;
    WAITFOR DELAY '00:00:00.050';          -- let other sessions and log backups breathe
END;
PRINT CONCAT(N'Rows updated: ', @Total);
```

For non-numeric or sparse keys, loop on `UPDATE TOP (@BatchSize) ... WHERE <not yet done>` until `@@ROWCOUNT = 0`. Make sure the `WHERE` excludes rows already done, or the loop never ends.

Remind the user that batched changes generate transaction log. Under the full recovery model, log backups must keep up. On an availability group, watch the redo queue on secondaries.

## 6. Locking and online operations

- `SET LOCK_TIMEOUT <ms>` makes DDL fail fast instead of queuing behind a long transaction and blocking every query behind it.
- **Adding a column:** a nullable column without a default is metadata-only on every edition. Adding `NOT NULL` with a runtime-constant default is metadata-only on Enterprise, Developer, and Azure SQL (2012+). On Standard it rewrites every row while holding a schema lock.
- **Indexes:** `WITH (ONLINE = ON)` needs Enterprise, Developer, or Azure SQL. `RESUMABLE = ON` works for index rebuilds from 2017 and for index creation from 2019 (`MAX_DURATION` limits each run). `WAIT_AT_LOW_PRIORITY (MAX_DURATION = n MINUTES, ABORT_AFTER_WAIT = SELF)` (2014+) keeps an online operation from blocking others while it waits for its final lock.
- **Constraints on existing data:** `ALTER TABLE ... WITH NOCHECK ADD CONSTRAINT` is fast but leaves the constraint untrusted (`is_not_trusted = 1` in `sys.foreign_keys` / `sys.check_constraints`), so the optimizer ignores it. Validate later with `ALTER TABLE dbo.X WITH CHECK CHECK CONSTRAINT FK_...;`, which scans the table.
- **`ALTER COLUMN`** usually takes a schema-modification lock for the full duration and may rewrite every row. Exceptions are metadata-only changes, such as increasing `varchar(n)` length when no index includes the column.

## 7. Version and edition features

Ask for the version when you need anything newer than 2016 SP1. Also ask for the edition when an operation's online behavior depends on it.

| Feature | Minimum |
| --- | --- |
| `THROW`, `TRY_CONVERT`, `TRY_CAST`, `CONCAT`, `IIF`, `OFFSET/FETCH` | 2012 |
| `DROP ... IF EXISTS`, `STRING_SPLIT` (compat level 130), JSON functions, temporal tables | 2016 |
| `CREATE OR ALTER` | 2016 SP1 |
| `STRING_AGG`, `TRIM`, `CONCAT_WS`, `TRANSLATE`, resumable index rebuild | 2017 |
| Resumable online index creation, `OPTIMIZE_FOR_SEQUENTIAL_KEY`, UTF-8 collations | 2019 |
| `GREATEST`/`LEAST`, `IS [NOT] DISTINCT FROM`, `GENERATE_SERIES`, `DATE_BUCKET`, `STRING_SPLIT` ordinal, resumable `ADD CONSTRAINT` | 2022 |

For anything newer, check the Microsoft docs before using it.

## 8. Gotchas

- **`ALTER COLUMN` replaces the full definition.** Always restate `NULL`/`NOT NULL`. If you leave it out, the column can become nullable. Collation also resets to the database default unless you restate it.
- **Dependencies block column changes.** Indexes, statistics, constraints, computed columns, and schema-bound views or functions (`WITH SCHEMABINDING`) that use the column must be dropped and recreated around the change. Find them in `sys.index_columns`, `sys.stats_columns`, `sys.sql_expression_dependencies`, and `sys.computed_columns`.
- **`sp_rename` is not re-runnable.** Guard it with `COL_LENGTH` on both the old and new names. It does not update views, procedures, or functions that reference the old name, so search `sys.sql_modules` for the old name.
- **`ADD col NULL DEFAULT x` leaves existing rows NULL.** Only new rows get the default. Add `WITH VALUES` to fill existing rows, or backfill explicitly.
- **Triggers fire on your DML.** List them with `SELECT name, is_disabled FROM sys.triggers WHERE parent_id = OBJECT_ID(N'dbo.X');` and decide whether they should run. Avoid disabling them. If you must, re-enable them in the same script.
- **Temporal tables:** schema changes usually propagate to the history table automatically, but data fixes write history rows. Set `SYSTEM_VERSIONING = OFF` only if the user agrees to the gap in history.
- **CDC and replication:** schema changes on published or CDC-enabled tables may need extra steps. Ask if either is in use when `sys.tables.is_replicated = 1` or `is_tracked_by_cdc = 1` would matter.
- **`MERGE`** has a long history of bugs and concurrency surprises. For idempotent seed data, prefer `INSERT ... WHERE NOT EXISTS` followed by a separate `UPDATE`.
- **`NOT IN` with a nullable subquery** returns no rows if any value is NULL. Use `NOT EXISTS`.
- **Implicit conversions** in `WHERE` (for example `varchar` column against an `N'...'` literal) can turn seeks into scans. Match literal types to column types.
- **Identity gaps:** a rolled-back insert still consumes identity values. Never assume contiguous keys in checks.

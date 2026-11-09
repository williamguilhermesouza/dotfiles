# Migration Recipes

Load this file in Step 4 and read only the recipe that matches the change. Recipes are dialect-neutral. Take the exact syntax for guards, transactions, batching, and online options from `sqlserver.md` or `mariadb.md`.

Each recipe lists phases in order. A phase can be a separate script or a separate batch. When the old and new application versions must both work during the rollout (zero-downtime deploys), keep the phases apart and note which deploy each one belongs to.

## Contents

1. Add a NOT NULL column to a populated table
2. Rename a column or table
3. Change a column's type or length
4. Add a foreign key to existing data
5. Add a unique constraint
6. Data fix or backfill
7. Archive and delete rows
8. Move data to a new table (split or merge)
9. Drop a column or table
10. Add an index to a large table
11. Seed or reference data
12. Change stored enum or status values

---

## 1. Add a NOT NULL column to a populated table

1. **Expand:** add the column as nullable, with a named default if new rows should get one.
2. **Backfill:** set the value for existing rows, batched if the table is large, with `WHERE new_col IS NULL` so it can be re-run.
3. **Tighten:** pre-check that no NULLs remain, then make the column `NOT NULL`.

Shortcut: when every existing row gets the same constant value, adding the column as `NOT NULL DEFAULT <constant>` in one step is fine if it's metadata-only (SQL Server Enterprise/Azure; MariaDB `ALGORITHM=INSTANT`) or the table is small.

Rollback: drop the default constraint by name, then the column. The backfilled values are lost, which is usually fine because they were derived.

App note: the old app version doesn't write the column. Until it is retired, keep the default, or keep the column nullable and backfill again after the deploy.

## 2. Rename a column or table

**With downtime (simple):** rename in place (`sp_rename` on SQL Server; `RENAME COLUMN` on MariaDB 10.5.2+ or `CHANGE COLUMN` with the full definition before that), guarded on both names. Then search for the old name in views, procedures, functions, and triggers, and in the app code.

**Without downtime (expand/contract):**

1. Add the new column (recipe 1).
2. Keep both in sync while old and new app versions run: either the app writes both, or a temporary trigger copies writes from the old column to the new one.
3. Backfill the new column from the old one.
4. Deploy the app reading and writing only the new column.
5. In a later release, drop the old column and the sync trigger (recipe 9).

Rollback: rename back (in-place version) or drop the new column (expand/contract version, before step 5).

## 3. Change a column's type or length

1. **Pre-check that every value fits:** for narrowing, check `MAX(LEN(col))` / `MAX(CHAR_LENGTH(col))`. For type changes, count values that fail conversion (`TRY_CONVERT(...) IS NULL AND col IS NOT NULL` on SQL Server; compare `CAST` results or use a pattern check on MariaDB). Show the bad rows and ask what to do with them before going on.
2. List dependencies that block the change: indexes, constraints, computed or generated columns, views, triggers.
3. Small table or widening only: drop the dependencies, alter the column with the full definition (nullability, default, collation), and recreate the dependencies.
4. Large table, or an app that must stay online: add a new column with the new type, backfill it in batches, switch the app over, and drop the old column later (as in recipe 2).

Rollback: the reverse alter, which is only safe if the values still fit the old type. Say so if they might not.

## 4. Add a foreign key to existing data

1. **Pre-check orphans:** child rows whose key has no parent (`LEFT JOIN parent ... WHERE parent.id IS NULL AND child.fk IS NOT NULL`). Show the count and a sample.
2. Ask what to do with orphans: set the key to NULL (only if the column is nullable and the business allows it), point them to a placeholder parent, or archive and delete them (recipe 7). Never decide this yourself.
3. Make sure the child column is indexed. MariaDB creates the index automatically. SQL Server does not, and without it, deletes on the parent scan the child table.
4. Add the constraint with an explicit name and an explicit `ON DELETE` rule that matches the app's EF configuration (EF Core's default for required relationships is cascade).
5. On large SQL Server tables, add it `WITH NOCHECK` and then validate with `WITH CHECK CHECK CONSTRAINT` as a separate phase, so it ends up trusted.

Rollback: drop the constraint by name, then the index if this script created it. Restore orphan fixes from the backup table.

## 5. Add a unique constraint

1. **Pre-check duplicates:** `GROUP BY key_cols HAVING COUNT(*) > 1`, listing each group and its row ids. Apply the app's soft-delete filter if the uniqueness rule only covers active rows.
2. Agree on the survivor rule with the user: newest, oldest, most complete, or a manual list.
3. Check what references the losing rows (foreign keys, plus loose references the code uses without a constraint). Re-point the children to the survivor before deleting, or the delete fails or cascades.
4. Back up the losing rows, then delete or merge them.
5. Add the unique index or constraint.

NULL handling differs: SQL Server unique constraints allow only one NULL. For "unique when present", use a filtered unique index (`WHERE col IS NOT NULL`). MariaDB unique indexes allow many NULLs. For uniqueness among active rows only, use a filtered index on SQL Server (`WHERE IsDeleted = 0`). MariaDB has no filtered indexes, so discuss alternatives (for example a generated column that is NULL for deleted rows, with a unique index on it).

Rollback: drop the index. Restore deleted rows from the backup and re-point the children back if needed.

## 6. Data fix or backfill

1. Turn the business rule into a precise `WHERE` and confirm it with the user if there is any doubt.
2. Pre-check: count the target rows and show a sample with the current and the new value side by side.
3. Back up the keys and old values.
4. Update inside a transaction with the expected-count check, or in batches for large sets. Make the `WHERE` exclude rows already fixed.
5. Post-check: count of rows still matching the "broken" condition (expected 0) and a sample of fixed rows.
6. Set audit columns the app normally maintains (`UpdatedAt`, `UpdatedBy`) if the team expects that. Ask what value `UpdatedBy` should get for script changes.

Rollback: restore the old values from the backup table by key, guarded so that rows changed by the app after the fix are not overwritten without the user's agreement (compare the current value with the value the script set).

## 7. Archive and delete rows

1. Map the dependency tree: every table referencing the target, directly or through cascades. Delete children before parents, or confirm the cascade rules do what the user expects.
2. Create archive tables with the same columns (and a timestamp of when they were archived).
3. In batches: copy a batch to the archive, then delete the same keys, in one short transaction per batch.
4. Post-check: archived count equals deleted count, and nothing that should stay was removed.
5. Warn about space: deleting does not shrink data files. Don't suggest shrinking (SQL Server) or `OPTIMIZE TABLE` (MariaDB) without the DBA.

Rollback: reinsert from the archive tables, parents before children, with identity insert enabled where needed.

## 8. Move data to a new table (split or merge)

1. Create the new table with keys, constraints, and indexes.
2. Copy the data in batches, guarded with `NOT EXISTS` so a re-run doesn't duplicate rows.
3. Post-check: counts and a checksum-style comparison (for example, aggregate counts per group) between the source and the target.
4. While the app moves over, decide how to keep them in sync (app dual-write or a temporary trigger).
5. Drop the old columns or table in a later release (recipe 9).

Rollback: drop the new table (before the cutover). After the cutover, reverse the copy.

## 9. Drop a column or table

1. Confirm it is unused: search the app repo (code, raw SQL, EF configuration, reports) and the database (views, procedures, functions, triggers, synonyms). Report what you found.
2. Confirm the app version that stops using it is deployed everywhere. EF Core entities that still map the column break as soon as it is gone.
3. Back it up: copy the column with the keys to a backup table, or rename the table to `zz_<name>_<yyyymmdd>` instead of dropping it, and drop it in a later release.
4. Drop the dependent indexes, constraints, and defaults by name, then the column or table.

Rollback: re-add the column and restore it from the backup. Without a backup, the rollback can't recover the data, so say so at the top of the rollback script.

## 10. Add an index to a large table

1. Check for an existing index that already covers the need, or that could be extended.
2. Use online and resumable options where the edition and version allow. Otherwise, warn that writes are blocked for the whole build and estimate the duration from the table size.
3. Name it explicitly, and guard it with an existence check.
4. Note the extra write cost and disk space.

Rollback: drop the index by name.

## 11. Seed or reference data

- Insert with `WHERE NOT EXISTS` on the natural key. Update existing rows in a separate statement that only touches rows whose values differ.
- MariaDB alternative: `INSERT ... ON DUPLICATE KEY UPDATE`, but only with a unique key on the natural key. Remember that it also fires on any other unique key.
- Use fixed explicit ids only if the app relies on them (C# constants, enum-backed lookup tables). Then enable identity insert (SQL Server) or set the column explicitly (MariaDB).

Rollback: delete exactly the rows the script inserted, by natural key, and restore updated values from the backup.

## 12. Change stored enum or status values

1. Find how the app stores the value: as an integer (EF Core default) or a string (`HasConversion<string>()`). Read the C# enum to map each name to its number. Watch for explicit values (`Cancelled = 9`) and gaps.
2. Plan the order: the old app must still understand the values while the script runs. Usually you deploy the app that understands both, then run the script, then remove the old values in code.
3. Back up, update with a `CASE` mapping, and post-check that no old values remain.
4. Update check constraints that list allowed values, in the same phase.

Rollback: reverse the `CASE` mapping, or restore from the backup.

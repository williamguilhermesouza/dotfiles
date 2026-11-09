# Finding the Schema in a .NET Repository

Load this file when the user asks you to get the schema from a repository, or to check a script or query against the application. Use only read-only tools: file search, grep, file reads, and the read-only git commands listed in SKILL.md. Never build or run anything.

## Contents

1. Identify the provider and version
2. Where the schema lives
3. EF Core mapping details that change the SQL
4. Default EF Core mappings
5. Application behavior a script must respect
6. Recognizing migration tools
7. Using git history

---

## 1. Identify the provider and version

- **Packages** in `*.csproj` or `Directory.Packages.props`:
  - SQL Server: `Microsoft.EntityFrameworkCore.SqlServer`, `Microsoft.Data.SqlClient`, `System.Data.SqlClient`, `EntityFramework` (EF6).
  - MariaDB: `Pomelo.EntityFrameworkCore.MySql`, `MySqlConnector`, `MySql.Data`, `MySql.EntityFrameworkCore`.
- **Registration** (`Program.cs`, `Startup.cs`, or `AddInfrastructure`-style extension methods): `UseSqlServer(...)` vs `UseMySql(..., ServerVersion...)`. With Pomelo, `new MariaDbServerVersion(new Version(10, 11, 0))` or `ServerVersion.Parse("10.11.6-mariadb")` tells you the version the app targets. `ServerVersion.AutoDetect(...)` means the version is only known at runtime, so ask.
- **Connection strings** in `appsettings*.json`, `launchSettings.json`, or `docker-compose*.yml` show the database name and sometimes the server image tag (`mariadb:10.11`, `mcr.microsoft.com/mssql/server:2022-latest`). Never print credentials.

This is evidence only. The dialect still has to be confirmed by the user (SKILL.md Step 1).

## 2. Where the schema lives

Check these in order. The first is usually the most complete.

1. **EF Core model snapshot:** `Migrations/*ModelSnapshot.cs`. This is the full current model as EF sees it: table and column names, column types, max lengths, nullability, defaults, indexes, keys, and foreign keys with delete behavior. One snapshot per `DbContext`.
2. **Entity configuration:** `IEntityTypeConfiguration<T>` classes and `OnModelCreating` in each `DbContext`. They explain why the snapshot looks the way it does, and they hold behavior the snapshot doesn't show fully (query filters, value converters).
3. **Migration files:** `Migrations/<timestamp>_<Name>.cs`. These are the history of changes. Look for `migrationBuilder.Sql(...)` calls, which hold hand-written SQL such as triggers, views, or data fixes that the snapshot doesn't capture.
4. **SSDT database project:** `*.sqlproj` with `Tables/*.sql`, `Views/*.sql`, `Stored Procedures/*.sql`. If present, this is usually the authoritative DDL for SQL Server.
5. **Raw SQL scripts:** folders used by DbUp, Flyway, FluentMigrator, or a manual `scripts/`/`db/` folder (section 6).
6. **Entity classes:** data annotations (`[Table]`, `[Column]`, `[MaxLength]`, `[Required]`, `[Key]`, `[Precision]`). When `<Nullable>enable</Nullable>` is set, a non-nullable `string` property maps to a `NOT NULL` column.
7. **Dapper and ADO.NET code:** search for `QueryAsync<`, `ExecuteAsync(`, `SqlCommand`, `MySqlCommand`, `CommandType.StoredProcedure`, and string literals starting with `SELECT`, `UPDATE`, `INSERT`, `DELETE`. These show tables the EF model may not map and how the app filters them.

If two sources disagree (snapshot vs SSDT vs pasted DDL), report the drift and ask which matches the real database. The repo can't show changes made directly on the server.

## 3. EF Core mapping details that change the SQL

- `ToTable("x", "schema")` and `HasDefaultSchema("app")` set the real table name and schema.
- `HasColumnName`, `HasColumnType`, `HasMaxLength`, `HasPrecision`, `IsUnicode(false)` (varchar instead of nvarchar), `UseCollation`, and Pomelo's `HasCharSet`.
- `HasConversion(...)`: enums stored as strings, JSON stored in a text column, encrypted values, or custom types. A script that writes such a column must produce exactly the stored format. Encrypted columns can't be written from SQL at all, so say so.
- `HasQueryFilter(...)`: soft delete (`IsDeleted`, `DeletedAt`) and multi-tenancy (`TenantId`). The app never sees filtered rows, so scripts and queries usually need the same filter.
- `OwnsOne` / `OwnsMany`: owned types share the owner's table with prefixed columns (`ShippingAddress_Street`) unless mapped to their own table.
- Inheritance: TPH uses one table with a discriminator column (default name `Discriminator`, holding the class name unless configured). TPT uses one table per type joined by key. TPC uses one full table per concrete type.
- Shadow properties: columns with no C# property, such as FKs and audit fields configured only by name.
- `IsRowVersion()` / `IsConcurrencyToken()`: SQL Server `rowversion` changes automatically on update. App-managed tokens (a `Guid` or counter set in code) must be changed by your script too, or the next app save of that row can overwrite your change or fail.
- `HasDefaultValue` / `HasDefaultValueSql` / `ValueGeneratedOnAdd`: defaults that exist in the database, versus values the app sets in code. Only the first applies to rows your script inserts.
- `HasIndex(...).HasFilter(...)`: filtered indexes, including EF Core's automatic `[Col] IS NOT NULL` filter on SQL Server unique indexes over nullable columns.

## 4. Default EF Core mappings

Use these only to interpret the snapshot or configuration. Always prefer what the snapshot says.

| .NET type | SQL Server | MariaDB (Pomelo) |
| --- | --- | --- |
| `string` (no max length) | `nvarchar(max)` | `longtext` |
| `string` with max length n | `nvarchar(n)` | `varchar(n)` |
| `bool` | `bit` | `tinyint(1)` |
| `Guid` | `uniqueidentifier` | `char(36)` (default format) |
| `DateTime` | `datetime2` | `datetime(6)` |
| `decimal` (no precision) | `decimal(18,2)` | `decimal(65,30)` |
| `enum` | `int` | `int` |

Naming conventions: the table name comes from the `DbSet` property name (often plural), not the class name. Keys are `PK_<Table>`, foreign keys `FK_<Dependent>_<Principal>_<FkColumn>`, and indexes `IX_<Table>_<Columns>`. On SQL Server, EF Core creates default constraints without names, so a rollback has to look them up (see `sqlserver.md`, "Existence guards").

Required relationships default to `ON DELETE CASCADE`. Check `OnDelete(...)` in the configuration and the `onDelete:` values in the snapshot.

## 5. Application behavior a script must respect

Look for these and mention each one that affects the script:

- **`SaveChanges` overrides and interceptors** that set `CreatedAt`, `UpdatedAt`, `CreatedBy`, `TenantId`, or soft-delete flags. SQL bypasses them, so the script must set the same columns or the team must agree to skip them.
- **Domain events, outbox tables, and audit logs** written on save. A SQL data fix produces no events or audit rows. Warn when downstream systems (search indexes, caches, other services) rely on them.
- **Caching** (`IMemoryCache`, `IDistributedCache`, Redis). The app may serve stale data after the script until the entries expire or are cleared.
- **Automatic migrations at startup** (`Database.Migrate()`, `MigrateAsync()`). If the app uses EF migrations, a hand-written DDL script makes the model snapshot drift, and the next generated migration may try to repeat or undo the change. Recommend putting schema changes into an EF migration, or wrapping your SQL in `migrationBuilder.Sql(...)`.
- **Enums:** read the C# enum for every status or type column you touch. Note explicit numeric values and whether it is stored as a number or a string.
- **Stored procedures, views, and triggers** that reference the changed table, found in SSDT projects, `migrationBuilder.Sql` calls, or script folders.
- **Other writers:** background jobs, message consumers, and other services that write the same table. They affect locking during the script and may undo a data fix after it.

## 6. Recognizing migration tools

| Tool | How to recognize it | Script convention |
| --- | --- | --- |
| EF Core migrations | `Migrations/` with `*ModelSnapshot.cs`; `__EFMigrationsHistory` table | Changes belong in a migration class. Raw SQL goes in `migrationBuilder.Sql(...)`. |
| EF6 | `Migrations/Configuration.cs`, `.edmx`; `__MigrationHistory` table | As above, EF6 style |
| DbUp | `DeployChanges.To.SqlDatabase(...)` / `MySqlDatabase(...)`, embedded `.sql` files; `SchemaVersions` table | Scripts run once, ordered by name. Use the folder's existing numbering. `GO` works on SQL Server. |
| Flyway | `flyway.conf` / `flyway.toml`, `V<version>__<desc>.sql`; `flyway_schema_history` table | Versioned files are immutable once applied. A fix is a new version. |
| FluentMigrator | `[Migration(...)]` classes; `VersionInfo` table | Raw SQL through `Execute.Sql(...)` |
| SSDT | `*.sqlproj`, dacpac publish | State-based. Data changes go in post-deployment scripts. |

When a tool is in use, match its conventions and tell the user that the script must go through the tool, not be run by hand, unless they say otherwise.

## 7. Using git history

Read-only commands that help explain the current schema:

```pwsh
git log --oneline -- "src/Infrastructure/Migrations"     # schema change history
git log -S "ShippedAt" --oneline                         # commits that added or removed a name
git log -p --follow -- "src/Infrastructure/Configurations/OrderConfiguration.cs"
git blame -L 20,40 -- "src/Infrastructure/Configurations/OrderConfiguration.cs"
git show <commit> --stat
git grep -n "Orders" -- "*.sql" "*.cs"
```

Use history to answer questions like "when did this column become nullable?" or "was this status value ever used?". Don't check out old commits. Read them with `git show <commit>:<path>` instead.

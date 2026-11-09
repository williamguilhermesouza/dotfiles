# .NET / C# Exploration Guide

Load this file when the repo contains `*.sln`, `*.slnx`, `*.csproj`, `*.cs`, `global.json`, `Directory.Build.props`, `packages.config`, or `Web.config`. It lists what a senior .NET developer looks at, and why, when getting to know an unfamiliar .NET system. Use it as a checklist across the exploration method in SKILL.md, not as a strict order.

## Contents

1. Solution layout
2. Target frameworks and legacy signals
3. Startup, hosting, and dependency injection
4. Configuration and secrets
5. API surface and background work
6. Data access
7. Async patterns and cross-cutting concerns
8. Integrations and resilience
9. Authentication and authorization
10. Logging and observability
11. Tests
12. Build and CI
13. Legacy and risk signals
14. Useful commands

---

## 1. Solution layout

Why: the project graph shows the intended architecture (layers, bounded contexts, shared kernels) faster than any class.

- Open the `.sln`/`.slnx` and list the projects. Group them by role: hosts (Web, Worker, Functions), domain, application, infrastructure, shared, tests.
- Read project references in each `.csproj` (`<ProjectReference>`). Draw the dependency direction mentally and check whether it matches the claimed architecture (for example, Clean Architecture means Domain references nothing).
- Check `Directory.Build.props` and `Directory.Build.targets` at the repo root and in subfolders. They set shared properties (nullable, warnings as errors, analyzers, versions) that apply silently to every project.
- Check `Directory.Packages.props` for central package management. If present, versions live there, not in the `.csproj` files.
- Note `<OutputType>`, `<Sdk>` (`Microsoft.NET.Sdk.Web`, `Microsoft.NET.Sdk.Worker`, `Microsoft.NET.Sdk.Razor`), and `<IsPackable>` to tell hosts from libraries.

## 2. Target frameworks and legacy signals

Why: the target framework decides which APIs, hosting model, and libraries are possible, and mixed targets usually mean a migration in progress.

- Read `<TargetFramework>`/`<TargetFrameworks>` in every project: `net8.0`, `net9.0`, `netstandard2.0`, `net48`, etc.
- Check `global.json` for the pinned SDK version.
- Old-style `.csproj` files (long XML with `<Compile Include=...>` lists), `packages.config`, `Web.config`, `Global.asax`, and `App_Start/` mean .NET Framework.
- `netstandard2.0` libraries shared between Framework and modern .NET projects are a common bridge during migrations. Note which hosts consume them.
- Check whether the target version is still supported. Search the web for the current .NET support policy if unsure.

## 3. Startup, hosting, and dependency injection

Why: in modern .NET, `Program.cs` is the map of the whole application. Every service, middleware, and option is wired there or in extension methods called from there.

- Find the host entry: `Program.cs` (minimal hosting or `CreateHostBuilder`), `Startup.cs` (`ConfigureServices`/`Configure`), or `Global.asax` on .NET Framework.
- Follow extension methods like `services.AddInfrastructure(config)` into their definitions. Real wiring is often spread across `ServiceCollectionExtensions` classes.
- Record lifetimes: `AddSingleton`, `AddScoped`, `AddTransient`. Watch for a singleton that depends on a scoped service (captive dependency), especially `DbContext` captured in a singleton.
- Look for assembly scanning (Scrutor, `AddMediatR(typeof(...).Assembly)`, Autofac modules). Scanning hides registrations from simple search, so search for the scanning call too.
- Read the middleware pipeline order (`app.UseX()` calls). Order matters: exception handling, HTTPS, routing, CORS, authentication, authorization, endpoints.
- Check for multiple hosts in one solution (API plus Worker plus Functions) and what they share.

## 4. Configuration and secrets

Why: configuration often changes behavior more than code does, and it tells you which environments and external resources exist.

- List `appsettings.json` and every `appsettings.{Environment}.json`. Compare them to see what differs per environment.
- Check `Properties/launchSettings.json` for local profiles, URLs, and `ASPNETCORE_ENVIRONMENT`/`DOTNET_ENVIRONMENT` values.
- Find the Options pattern: `services.Configure<TOptions>(config.GetSection("X"))`, `IOptions<T>`, `IOptionsSnapshot<T>`, `IOptionsMonitor<T>`, and any `ValidateOnStart`.
- Identify secret sources: User Secrets (`<UserSecretsId>` in `.csproj`), environment variables, Azure Key Vault, AWS Secrets Manager or Parameter Store, Kubernetes secrets. Never print secret values in the conversation.
- Note feature flag systems (`Microsoft.FeatureManagement`, LaunchDarkly, custom flags in config) and which code paths they gate.
- Before running the app, check which connection strings and URLs the active environment uses (see "Running the System Safely" in SKILL.md).

## 5. API surface and background work

Why: these are the system's entry points. Everything else exists to serve them.

- **Controllers:** classes deriving from `ControllerBase`/`Controller` or marked `[ApiController]`. Note route prefixes, versioning (`Asp.Versioning`), and filters applied at class level.
- **Minimal APIs:** `app.MapGet/MapPost/MapGroup` calls, often split into endpoint classes or Carter modules.
- **gRPC:** `.proto` files, `MapGrpcService<T>`.
- **GraphQL:** Hot Chocolate or GraphQL.NET schema registration.
- **SignalR:** `MapHub<T>` for real-time features.
- **Background work:** `IHostedService`, `BackgroundService`, Hangfire, Quartz.NET, Azure Functions or AWS Lambda triggers. Find what each job does, how often, and whether it is safe to run on multiple instances.
- Check for OpenAPI generation (Swashbuckle, NSwag, `Microsoft.AspNetCore.OpenApi`). Running the app and opening the Swagger UI is often the fastest way to see the real route list.

## 6. Data access

Why: the data layer holds the system's core model and is usually where the hardest constraints live.

- **EF Core:** find each `DbContext`, its `DbSet<T>` properties, and `OnModelCreating` or `IEntityTypeConfiguration<T>` classes. Read the `Migrations/` folder history to see how the schema evolved. Check whether migrations run automatically at startup (`Database.Migrate()`).
- Note EF behavior settings: tracking vs `AsNoTracking`, lazy loading proxies, global query filters (soft delete, multi-tenancy), interceptors, and `SaveChanges` overrides that set audit fields or dispatch domain events.
- **Dapper or ADO.NET:** find raw SQL, stored procedure calls, and where connections are created. Check for string-concatenated SQL.
- **EF6 or LINQ to SQL** on .NET Framework: `.edmx` files and `ObjectContext` mean an older model.
- Identify each database, which services write to it, and whether other systems share it.
- Look for the repository and unit-of-work patterns and check whether they are used consistently or bypassed.
- Note caching (`IMemoryCache`, `IDistributedCache`, Redis via StackExchange.Redis) and how entries are invalidated.

## 7. Async patterns and cross-cutting concerns

Why: async misuse and hidden pipelines cause the bugs that are hardest to find by reading one class.

- Search for sync-over-async: `.Result`, `.Wait()`, `.GetAwaiter().GetResult()`. These risk deadlocks on .NET Framework and thread pool starvation everywhere.
- Search for `async void` outside event handlers, and fire-and-forget `Task.Run` without error handling.
- Check whether `CancellationToken` is passed from endpoints down to I/O calls.
- **MediatR or similar:** list `IRequestHandler` and `INotificationHandler` implementations and the `IPipelineBehavior` chain (validation, logging, transactions). The pipeline runs around every handler, so it shapes every flow you trace.
- **Validation:** FluentValidation validators, data annotations, or manual checks. Note where validation happens in the flow.
- **Filters and middleware:** action filters, exception filters, custom middleware for correlation IDs, tenancy, or error mapping.
- **Mapping:** AutoMapper profiles, Mapster, or manual mapping. Convention-based mapping hides field-level behavior, so check profiles when a value seems to appear from nowhere.

## 8. Integrations and resilience

Why: external dependencies are where production incidents start, and their failure handling tells you how mature the system is.

- **Messaging:** MassTransit, NServiceBus, Azure Service Bus, RabbitMQ.Client, Kafka (Confluent), AWS SQS/SNS. Find consumers, published message types, queue and topic names, retry and dead-letter settings, and whether an outbox pattern is used.
- **HTTP clients:** `IHttpClientFactory` registrations (`AddHttpClient<T>`), typed clients, Refit interfaces. Flag `new HttpClient()` created per call, which can exhaust sockets.
- **Resilience:** Polly policies or `Microsoft.Extensions.Http.Resilience` (retries, timeouts, circuit breakers). Note which calls have none.
- **Cloud SDKs:** Azure (`Azure.*`), AWS (`AWSSDK.*`) clients and the services they reach.
- For each integration, note the contract (DTOs, `.proto`, OpenAPI client) and who owns the other side.

## 9. Authentication and authorization

Why: identity decides who can reach each entry point, and misconfigured auth is a high-impact risk.

- Find `AddAuthentication` and its schemes: JWT bearer, cookies, OpenID Connect, API keys, Windows auth, ASP.NET Core Identity.
- Identify the identity provider (Entra ID / Azure AD, Auth0, Keycloak, IdentityServer / Duende, Cognito).
- List authorization policies (`AddAuthorization(options => options.AddPolicy(...))`), custom `IAuthorizationHandler`s, and role or claim checks.
- Check which endpoints have `[Authorize]`, `[AllowAnonymous]`, or `.RequireAuthorization()`, and whether there is a fallback policy that protects everything by default.
- Look for multi-tenancy rules and where the tenant is resolved.

## 10. Logging and observability

Why: logs and traces show how the team debugs production, and running the app with verbose logging is one of the best exploration tools.

- Identify the logging setup: `ILogger<T>` with Serilog, NLog, or the default providers. Read sink configuration (console, Seq, Application Insights, Elastic, CloudWatch).
- Check for structured logging (`{OrderId}` placeholders) vs string interpolation.
- Look for OpenTelemetry (`AddOpenTelemetry`), Application Insights, or custom metrics and traces.
- Find health checks (`AddHealthChecks`, `MapHealthChecks`) and what they probe.
- Note correlation ID propagation across HTTP and messaging.

## 11. Tests

Why: tests document intended behavior and show which parts the team trusts and which they avoid.

- Identify frameworks: xUnit, NUnit, MSTest, plus assertion and mocking libraries (FluentAssertions, Shouldly, Moq, NSubstitute, FakeItEasy).
- Classify test projects: unit, integration (`WebApplicationFactory<T>`, Testcontainers, in-memory or SQLite databases), contract, end-to-end, architecture tests (NetArchTest, ArchUnitNET).
- Read test names for the flows you are tracing. They often describe business rules more clearly than the code.
- Run `dotnet test` (after checking what integration tests connect to) and note failures, skipped tests (`[Fact(Skip=...)]`, `[Ignore]`), and slow suites.
- Note which important flows have no tests.

## 12. Build and CI

Why: the pipeline is the real definition of how the system is built, tested, and shipped.

- Read pipeline files: `.github/workflows/`, `azure-pipelines.yml`, `bitbucket-pipelines.yml`, `.gitlab-ci.yml`, `Jenkinsfile`, Cake or Nuke build scripts.
- Check `nuget.config` for private feeds that a local build will need.
- Read Dockerfiles for the runtime image, exposed ports, and environment variables.
- Note analyzers and quality gates: `<TreatWarningsAsErrors>`, StyleCop, SonarAnalyzer, `.editorconfig` rules.
- Identify deployment targets: App Service, AKS/EKS, ECS, Functions, Lambda, IIS.

## 13. Legacy and risk signals

Why: these mark the parts of the system that are expensive to change and likely to surprise newcomers.

- **WCF** services (`.svc`, `[ServiceContract]`) or clients (`Connected Services/`, generated proxies).
- **ASP.NET WebForms** (`.aspx`, `.ascx`, `ViewState`) or classic MVC 5 on .NET Framework.
- **Remoting, `BinaryFormatter`,** or `System.Web` dependencies that block migration to modern .NET.
- **God services:** classes with thousands of lines or constructors with many injected dependencies. Find them with file sizes and git hot spots.
- **Static state:** static mutable fields, service locator (`ServiceLocator`, `HttpContext.Current`, resolving from `IServiceProvider` inside business code).
- **Swallowed exceptions:** empty `catch` blocks or `catch (Exception)` that only logs and continues.
- **Duplicated paths:** two data access styles, two messaging libraries, or old and new versions of the same endpoint. These usually mark an unfinished migration. Check commit history to learn which direction it is going.
- **Outdated packages:** run `dotnet list package --outdated` and `dotnet list package --vulnerable` to see version drift and known vulnerabilities.

## 14. Useful commands

Run from the solution folder. All are read-only except build and test outputs in `bin/` and `obj/`.

```pwsh
dotnet --info                          # installed SDKs and runtimes
dotnet sln list                        # projects in the solution
dotnet list reference                  # project references (run per project)
dotnet list package --include-transitive
dotnet list package --outdated
dotnet list package --vulnerable
dotnet build                           # confirms the solution compiles
dotnet test --logger "console;verbosity=normal"
dotnet run --project src/Api --launch-profile Development   # check config first
dotnet ef migrations list --project src/Infrastructure      # requires dotnet-ef tool
```

When running the app for exploration, raise log verbosity through an environment variable instead of editing config, for example `$env:Logging__LogLevel__Default = "Debug"` before `dotnet run`.

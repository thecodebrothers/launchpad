---
name: launchpad-package
description: 'Implement dependency injection for Serverpod using the launchpad package. Use when: adding launchpad to a Serverpod server, wiring up GetIt/injectable in endpoints, setting up server context, sharing state across requests, or resolving dependencies inside Serverpod endpoint handlers.'
argument-hint: 'Describe the endpoint or feature you want to wire up with launchpad'
---

# Using the Launchpad Package

Launchpad provides dependency injection (via `get_it`) for Serverpod endpoints.
Each request gets its own `GetIt` container (request-scoped), while a separate
server-level container handles singletons shared across all requests.

## When to Use
- Adding DI to a new Serverpod server
- Wiring `injectable`-generated code into Serverpod endpoints
- Accessing request-scoped or server-scoped dependencies inside an `Endpoint`
- Sharing stateful objects (connections, caches) across requests on a single pod

---

## Step 1 — Add the dependency

In the server's `pubspec.yaml`:

```yaml
dependencies:
  launchpad: ^<latest>
  get_it: ^<latest>
  # injectable: ^<latest>   # optional
```

---

## Step 2 — Register global dependencies (server startup)

In `lib/server.dart` (or wherever you call `pod.start()`), call
`Launchpad.initServerContext` **before** `pod.start()`:

```dart
import 'package:launchpad/launchpad.dart';

void run(List<String> args) async {
  final pod = Serverpod(args, Protocol(), Endpoints());

  Launchpad.initServerContext(pod, (getIt) {
    // Singletons shared across all requests on this pod instance
    getIt.registerSingleton(DatabaseDriver());
    getIt.registerSingleton(ServerState());
    // With injectable: getIt.init() works here too
  });

  await pod.start();
}
```

> **Warning:** Server context is per-pod-instance. For cross-instance state use Redis or a shared DB — do NOT rely on in-memory singletons in a multi-pod deployment.

---

## Step 3 — Register per-request dependencies (optional global init)

Set `Launchpad.launchpadInit` once at startup for dependencies that should be
created fresh for every request:

```dart
// With injectable
Launchpad.launchpadInit = (getIt) => getIt.init();

// Without injectable
Launchpad.launchpadInit = (getIt) {
  getIt.registerFactory<HelloUseCase>(() => HelloUseCase());
};
```

---

## Step 4 — Wrap endpoint handlers with `Launchpad.launch`

Every endpoint method that needs DI must be wrapped in `Launchpad.launch`:

```dart
import 'package:launchpad/launchpad.dart';
import 'package:serverpod/serverpod.dart';

class HelloEndpoint extends Endpoint {
  Future<String> hello(Session session) => Launchpad.launch(
    session,
    (context) async {
      // Request-scoped dependency
      final useCase = context.get<HelloUseCase>();

      // Server-scoped dependency (singleton)
      final serverState = context.serverContext.get<ServerState>();

      serverState.counter += 1;
      return 'Visitor number ${serverState.counter}';
    },
  );
}
```

### Per-endpoint override (advanced)

Pass `initDependencies` to override the global init for a specific endpoint:

```dart
Launchpad.launch(
  session,
  (context) async { ... },
  initDependencies: (getIt) {
    getIt.registerFactory<SpecialService>(() => SpecialService());
  },
);
```

---

## Key API Reference

| Symbol | Purpose |
|--------|---------|
| `Launchpad.launchpadInit` | Static setter — global per-request DI initializer |
| `Launchpad.initServerContext(pod, init)` | Register server-wide singletons once at startup |
| `Launchpad.launch(session, handler, {initDependencies})` | Entry point for every endpoint request |
| `LaunchpadRequestContext.get<T>()` | Resolve a request-scoped dependency |
| `LaunchpadRequestContext.serverContext` | Access the server-level `GetIt` container |
| `LaunchpadServerContext.get<T>()` | Resolve a server-scoped singleton |
| `Session.launchpad` | Extension — access the `GetIt` instance directly from `session` |

---

## Decision Guide

| Need | Solution |
|------|---------|
| Fresh object per request | `getIt.registerFactory` inside `launchpadInit` |
| Shared singleton for this pod | `getIt.registerSingleton` inside `initServerContext` |
| injectable codegen | Call `getIt.init()` inside `launchpadInit` |
| Override DI for one endpoint | Pass `initDependencies:` to `Launchpad.launch` |

---

## Checklist

- [ ] `Launchpad.initServerContext` called before `pod.start()`
- [ ] `Launchpad.launchpadInit` set if using global per-request DI
- [ ] Every endpoint that uses DI is wrapped with `Launchpad.launch`
- [ ] Server-scoped types accessed via `context.serverContext.get<T>()`
- [ ] Request-scoped types accessed via `context.get<T>()`
- [ ] Not relying on in-memory server state across multiple pod instances

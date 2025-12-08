# Launchpad 🚀

## Missing dependency injection for serverpod
Let your pod launch with everything onboard!
* This is BETA *

### How to use is it?

First add your dependencies init function - if you are using `injectable` then this will be your generated `getIt.init()` function
```dart
    // with injectable 
    Launchpad.launchpadInit = (getIt) => getIt.init();
    // or without 
    Launchpad.launchpadInit = (getIt) {
        getIt.registerFactory<String>(() => 'Hello world');
    };
```

Then in endpoints wrap every request with Launchpad.launch:
```dart
class HeloEndpoint extends Endpoint {
  Future<void> helloWorld(
    Session session, {
    required String name,
  }) =>
      Launchpad.launch(
        session,
        (context) async {
          final useCase = context.get<HelloUseCase>();
          return useCase(name: name);
        },
      );
}
```

## Server context
You can share some dependencies and their state into endpoints through server context!
For example: share db connections and driver state across your server. Simpler example below:

First: init server context and register your dependencies
```dart
  Launchpad.initServerContext(pod, (getIt) {
    // Register any global dependencies here.
    // e.g., getIt.registerSingleton<YourService>(YourServiceImplementation());
    getIt.registerSingleton(ServerState());
  });
```
Second: access your server context with launchpad context:
```dart
class HelloEndpoint extends Endpoint {
  Future<String> hello(Session session) => Launchpad.launch(
    session,
    (context) async {
      final serverState = context.serverContext.get<ServerState>();
      
      serverState.counter += 1;
      
      return 'Hello from Serverpod! You are visitor number ${serverState.counter}.';
    },
  );
}

class ServerState {
  int counter = 0;
}
```

Result: you have shared state:
```
flutter: Server responded: Hello from Serverpod! You are visitor number 17.
flutter: Server responded: Hello from Serverpod! You are visitor number 18.
flutter: Server responded: Hello from Serverpod! You are visitor number 19.
flutter: Server responded: Hello from Serverpod! You are visitor number 20.
flutter: Server responded: Hello from Serverpod! You are visitor number 21.
flutter: Server responded: Hello from Serverpod! You are visitor number 22.
flutter: Server responded: Hello from Serverpod! You are visitor number 23.
flutter: Server responded: Hello from Serverpod! You are visitor number 24.
flutter: Server responded: Hello from Serverpod! You are visitor number 25.
```

Warning!: Example case is not the best representation of sharing state on serverpod - it is much better to use REDIS for that - remember that Launchpad works for only one pod - it will not share the state between your server instances!


## TODO:
 - Example
 - Tests
 - Stream support

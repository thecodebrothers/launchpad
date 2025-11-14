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

## TODO:
 - Example
 - Tests
 - Stream support

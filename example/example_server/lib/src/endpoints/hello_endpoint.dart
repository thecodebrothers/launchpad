import 'package:example_server/src/server/server_state.dart';
import 'package:launchpad/launchpad.dart';
import 'package:serverpod/serverpod.dart';

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

import 'dart:io';

import 'package:example_server/src/server/server_state.dart';
import 'package:launchpad/launchpad.dart';
import 'package:serverpod/serverpod.dart';

import 'package:example_server/src/web/routes/root.dart';

import 'src/generated/protocol.dart';
import 'src/generated/endpoints.dart';

// This is the starting point of your Serverpod server. In most cases, you will
// only need to make additions to this file if you add future calls,  are
// configuring Relic (Serverpod's web-server), or need custom setup work.

void run(List<String> args) async {
  // Initialize Serverpod and connect it with your generated code.
  final pod = Serverpod(args, Protocol(), Endpoints());

  // Setup a default page at the web root.
  pod.webServer.addRoute(RootRoute(), '/');
  pod.webServer.addRoute(RootRoute(), '/index.html');
  // Serve all files in the web/static relative directory under /.
  // Serverpod 4's relic router rejects attaching a route at a tail path
  // ('/**'), so the catch-all static handler is registered as the fallback.
  final root = Directory(Uri(path: 'web/static').toFilePath());
  pod.webServer.fallbackRoute = StaticRoute.directory(root);

  Launchpad.initServerContext(pod, (getIt) {
    // Register any global dependencies here.
    // e.g., getIt.registerSingleton<YourService>(YourServiceImplementation());
    getIt.registerSingleton(ServerState());
  });

  // Start the server.
  await pod.start();
}

import 'package:get_it/get_it.dart';
import 'package:serverpod/server.dart';

class Launchpad {
  Launchpad._();

  static void Function(GetIt getItContext)? launchpadInit;

  static Future<T> launch<T>(
    Session session,
    Future<T> Function(LaunchpadRequestContext context) handleRequest, {
    void Function(GetIt getItContext)? initDependencies,
  }) {
    final get = session.registerLaunchpadDependencies(init: initDependencies);

    final context = LaunchpadRequestContext(session, get);

    return handleRequest(context);
  }
}

class LaunchpadRequestContext {
  LaunchpadRequestContext(this.session, this._getIt);

  final Session session;
  final GetIt _getIt;

  T get<T extends Object>() {
    return _getIt.get<T>();
  }
}

extension LaunchpadSessionExtensions on Session {
  GetIt registerLaunchpadDependencies({
    void Function(GetIt getItContext)? init,
  }) {
    final get = GetIt.asNewInstance();

    if (init != null) {
      init(get);
    } else {
      Launchpad.launchpadInit?.call(get);
    }
    get.registerSingleton(this);

    userObject = get;
    return get;
  }

  GetIt get launchpad {
    final alreadyRegistered = userObject;
    if (alreadyRegistered != null && alreadyRegistered is GetIt) {
      return alreadyRegistered;
    }

    return registerLaunchpadDependencies();
  }
}

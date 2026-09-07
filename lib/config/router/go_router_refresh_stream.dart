import 'dart:async';
import 'package:flutter/foundation.dart';

/// Convierte un Stream (el de cambios de auth de Supabase) en un
/// Listenable para que GoRouter reaccione y reevalúe sus redirects.
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen(
      (_) => notifyListeners(),
    );
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
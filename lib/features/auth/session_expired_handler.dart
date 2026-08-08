import 'package:go_router/go_router.dart';

/// Wired from [App] so API 401 responses can clear auth and open the login screen.
class SessionExpiredHandler {
  SessionExpiredHandler._();
  static final SessionExpiredHandler instance = SessionExpiredHandler._();

  Future<void> Function()? _onExpired;
  GoRouter? _router;
  bool _busy = false;

  void configure({
    required Future<void> Function() onExpired,
    required GoRouter router,
  }) {
    _onExpired = onExpired;
    _router = router;
  }

  /// Call when an authenticated API returns 401 (session expired / invalid).
  Future<void> handle() async {
    if (_busy) return;
    _busy = true;
    try {
      await _onExpired?.call();
      _router?.go('/login');
    } finally {
      _busy = false;
    }
  }
}

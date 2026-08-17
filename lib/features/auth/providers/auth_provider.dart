import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../session_expired_handler.dart';
import '../../../shared/models/user.dart';
import '../../../shared/services/auth_api.dart';
import '../../../shared/services/clubs_api.dart';
import '../../../shared/utils/api_error_message.dart';

const _sessionFlagKey = 'auth_session_active';
const _emailKey = 'auth_email';
const _demoKey = 'auth_demo_mode';
const selectedClubPrefsKey = 'selected_club_id';

/// Shared AuthApi (owns Dio + Bearer token store).
final authApiProvider = FutureProvider<AuthApi>((ref) async {
  return AuthApi.create(
    onSessionExpired: () => SessionExpiredHandler.instance.handle(),
  );
});

final clubsApiProvider = Provider<ClubsApi>((ref) {
  final authApi = ref.watch(authApiProvider).valueOrNull;
  if (authApi == null) {
    throw StateError('AuthApi is not ready yet');
  }
  return ClubsApi(authApi.dio);
});

class AuthState {
  const AuthState({
    this.user,
    this.isLoading = false,
    this.error,
    this.initialized = false,
  });

  final User? user;
  final bool isLoading;
  final String? error;
  final bool initialized;

  bool get isAuthenticated => user != null;

  AuthState copyWith({
    User? user,
    bool? isLoading,
    String? error,
    bool? initialized,
    bool clearUser = false,
    bool clearError = false,
  }) {
    return AuthState(
      user: clearUser ? null : (user ?? this.user),
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      initialized: initialized ?? this.initialized,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier(this._ref) : super(const AuthState()) {
    _bootstrap();
  }

  final Ref _ref;

  Future<AuthApi> get _api async => _ref.read(authApiProvider.future);

  Future<void> _bootstrap() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final hadSession = prefs.getBool(_sessionFlagKey) ?? false;
      if (!hadSession) {
        state = state.copyWith(initialized: true, clearUser: true);
        return;
      }

      if (prefs.getBool(_demoKey) ?? false) {
        state = state.copyWith(
          user: const User(
            id: 'demo',
            email: 'coach@teamhive.app',
            firstName: 'Alex',
            lastName: 'Coach',
          ),
          initialized: true,
          clearError: true,
        );
        return;
      }

      final api = await _api;
      if (!api.tokenStore.hasTokens) {
        await _clearLocalSession();
        state = state.copyWith(initialized: true, clearUser: true);
        return;
      }

      // Prefer refresh when access is expired before hitting /me.
      if (api.tokenStore.isAccessExpired) {
        try {
          await api.refresh();
        } catch (_) {
          // Fall through — /me may still work if access is briefly valid.
        }
      }

      final user = await api.currentUser();
      state = state.copyWith(user: user, initialized: true, clearError: true);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[Auth] bootstrap failed: $e');
      }
      await _clearLocalSession();
      try {
        final api = await _api;
        await api.clearTokens();
      } catch (_) {}
      state = state.copyWith(initialized: true, clearUser: true);
    }
  }

  Future<void> enterDemo() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_sessionFlagKey, true);
    await prefs.setBool(_demoKey, true);
    await prefs.setString(_emailKey, 'coach@teamhive.app');
    state = state.copyWith(
      user: const User(
        id: 'demo',
        email: 'coach@teamhive.app',
        firstName: 'Alex',
        lastName: 'Coach',
      ),
      initialized: true,
      clearError: true,
      isLoading: false,
    );
  }

  Future<bool> login({
    required String email,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final api = await _api;
      final user = await api.login(email: email, password: password);
      await _markSession(email: email, demo: false);
      state = state.copyWith(
        user: user,
        isLoading: false,
        initialized: true,
        clearError: true,
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: apiErrorMessage(e, fallback: 'Login failed. Check your credentials.'),
      );
      return false;
    }
  }

  Future<bool> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    String? phone,
    String locale = 'en',
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final api = await _api;
      final user = await api.register(
        email: email,
        password: password,
        firstName: firstName,
        lastName: lastName,
        locale: locale,
      );
      await _markSession(email: email, demo: false);
      state = state.copyWith(
        user: user,
        isLoading: false,
        initialized: true,
        clearError: true,
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: apiErrorMessage(e, fallback: 'Registration failed. Please try again.'),
      );
      return false;
    }
  }

  /// Clears remote session (best-effort), tokens, and local auth flags.
  Future<void> logout() async {
    final wasDemo = state.user?.id == 'demo';

    // Wipe local auth first so UI / redirects can't race a half-logged-out state.
    await _clearLocalSession();
    state = state.copyWith(clearUser: true, clearError: true, isLoading: false);

    try {
      final api = await _api;
      if (!wasDemo) {
        try {
          await api.logout();
        } catch (e) {
          if (kDebugMode) debugPrint('[Auth] remote logout failed: $e');
        }
      }
      await api.clearTokens();
    } catch (e) {
      if (kDebugMode) debugPrint('[Auth] logout cleanup failed: $e');
    }
  }

  Future<void> _markSession({required String email, required bool demo}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_sessionFlagKey, true);
    await prefs.setString(_emailKey, email);
    if (demo) {
      await prefs.setBool(_demoKey, true);
    } else {
      await prefs.remove(_demoKey);
    }
  }

  Future<void> _clearLocalSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_sessionFlagKey);
    await prefs.remove(_emailKey);
    await prefs.remove(_demoKey);
    await prefs.remove(selectedClubPrefsKey);
  }
}

final authNotifierProvider =
    StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref);
});

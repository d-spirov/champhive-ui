import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../session_expired_handler.dart';
import '../../../shared/models/user.dart';
import '../../../shared/services/auth_api.dart';
import '../../../shared/services/biometric_credentials_service.dart';
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

final biometricCredentialsProvider = Provider<BiometricCredentialsService>(
  (ref) => BiometricCredentialsService(),
);

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

  BiometricCredentialsService get _biometrics =>
      _ref.read(biometricCredentialsProvider);

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
      await _biometrics.saveCredentials(email: email, password: password);
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
      await _biometrics.saveCredentials(email: email, password: password);
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

  Future<User?> refreshCurrentUser() async {
    if (state.user?.id == 'demo') return state.user;
    try {
      final api = await _api;
      final user = await api.currentUser();
      state = state.copyWith(user: user, clearError: true);
      return user;
    } catch (e) {
      state = state.copyWith(
        error: apiErrorMessage(e, fallback: 'Could not refresh profile'),
      );
      return null;
    }
  }

  Future<bool> updateProfile({
    String? firstName,
    String? lastName,
    String? locale,
  }) async {
    if (state.user?.id == 'demo') {
      state = state.copyWith(
        error: 'Sign in to edit your account',
      );
      return false;
    }
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final api = await _api;
      final user = await api.updateMe(
        firstName: firstName,
        lastName: lastName,
        locale: locale,
      );
      state = state.copyWith(user: user, isLoading: false, clearError: true);
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: apiErrorMessage(e, fallback: 'Could not update profile'),
      );
      return false;
    }
  }

  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    if (state.user?.id == 'demo') {
      state = state.copyWith(error: 'Sign in to change password');
      return false;
    }
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final api = await _api;
      final user = await api.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );
      final email = state.user?.email ?? await _biometrics.getStoredEmailQuiet();
      if (email != null && email.isNotEmpty) {
        await _biometrics.saveCredentials(
          email: email,
          password: newPassword,
        );
      }
      state = state.copyWith(user: user, isLoading: false, clearError: true);
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: apiErrorMessage(e, fallback: 'Could not change password'),
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
    // Keep Face ID credentials for the next login.
  }
}

final authNotifierProvider =
    StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref);
});

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'features/auth/providers/auth_provider.dart';
import 'features/auth/session_expired_handler.dart';
import 'features/auth/screens/login_screen.dart';
import 'features/auth/screens/register_screen.dart';
import 'features/auth/screens/splash_screen.dart';
import 'features/calendar/screens/calendar_screen.dart';
import 'features/clubs/screens/club_details_screen.dart';
import 'features/home/screens/home_dashboard_screen.dart';
import 'features/messages/screens/messages_screen.dart';
import 'features/more/screens/more_screen.dart';
import 'features/players/screens/player_profile_screen.dart';
import 'features/players/screens/players_list_screen.dart';
import 'features/shell/main_shell.dart';
import 'features/stats/screens/statistics_screen.dart';
import 'features/teams/screens/team_details_screen.dart';
import 'features/teams/screens/teams_screen.dart';
import 'l10n/app_localizations.dart';
import 'shared/providers/theme_mode_provider.dart';
import 'shared/theme/app_theme.dart';

class App extends ConsumerStatefulWidget {
  const App({super.key});

  @override
  ConsumerState<App> createState() => _AppState();
}

class _AppState extends ConsumerState<App> {
  late final _AuthRouterRefresh _authRefresh;
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    _authRefresh = _AuthRouterRefresh(ref);
    _router = GoRouter(
      initialLocation: '/',
      refreshListenable: _authRefresh,
      redirect: _redirect,
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const SplashScreen(),
        ),
        GoRoute(
          path: '/login',
          builder: (context, state) => const LoginScreen(),
        ),
        GoRoute(
          path: '/register',
          builder: (context, state) => const RegisterScreen(),
        ),
        StatefulShellRoute.indexedStack(
          builder: (context, state, navigationShell) {
            return MainShell(navigationShell: navigationShell);
          },
          branches: [
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/home',
                  builder: (context, state) => const HomeDashboardScreen(),
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/calendar',
                  builder: (context, state) => const CalendarScreen(),
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/teams',
                  builder: (context, state) => const TeamsScreen(),
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/messages',
                  builder: (context, state) => const MessagesScreen(),
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/more',
                  builder: (context, state) => const MoreScreen(),
                ),
              ],
            ),
          ],
        ),
        GoRoute(
          path: '/clubs/:clubId',
          builder: (context, state) => ClubDetailsScreen(
            clubId: state.pathParameters['clubId']!,
          ),
        ),
        GoRoute(
          path: '/teams/:teamId',
          builder: (context, state) => TeamDetailsScreen(
            teamId: state.pathParameters['teamId']!,
          ),
        ),
        GoRoute(
          path: '/players',
          builder: (context, state) => const PlayersListScreen(),
        ),
        GoRoute(
          path: '/players/:playerId',
          builder: (context, state) => PlayerProfileScreen(
            playerId: state.pathParameters['playerId']!,
          ),
        ),
        GoRoute(
          path: '/statistics',
          builder: (context, state) => const StatisticsScreen(),
        ),
      ],
    );

    SessionExpiredHandler.instance.configure(
      onExpired: () => ref.read(authNotifierProvider.notifier).logout(),
      router: _router,
    );
  }

  @override
  void dispose() {
    _authRefresh.dispose();
    _router.dispose();
    super.dispose();
  }

  String? _redirect(BuildContext context, GoRouterState state) {
    final auth = ref.read(authNotifierProvider);
    final loc = state.matchedLocation;
    final isPublic = loc == '/' || loc == '/login' || loc == '/register';

    if (!auth.initialized) {
      return loc == '/' ? null : '/';
    }

    if (!auth.isAuthenticated && !isPublic) {
      return '/login';
    }

    if (auth.isAuthenticated &&
        (loc == '/' || loc == '/login' || loc == '/register')) {
      return '/home';
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(authApiProvider);
    final themeOverride = ref.watch(themeModeProvider);

    return MaterialApp.router(
      title: 'TeamHive',
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeOverride ?? ThemeMode.system,
      routerConfig: _router,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      debugShowCheckedModeBanner: false,
    );
  }
}

/// Notifies [GoRouter] when auth state changes so [redirect] re-runs.
class _AuthRouterRefresh extends ChangeNotifier {
  _AuthRouterRefresh(this._ref) {
    _sub = _ref.listenManual<AuthState>(authNotifierProvider, (previous, next) {
      notifyListeners();
    });
  }

  final WidgetRef _ref;
  late final ProviderSubscription<AuthState> _sub;

  @override
  void dispose() {
    _sub.close();
    super.dispose();
  }
}

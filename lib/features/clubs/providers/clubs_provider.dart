import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../shared/models/club.dart';
import '../../auth/providers/auth_provider.dart';

const _selectedClubKey = selectedClubPrefsKey;

final myClubsProvider = FutureProvider.autoDispose<List<ClubSummary>>((ref) async {
  final auth = ref.watch(authNotifierProvider);
  if (!auth.isAuthenticated || auth.user?.id == 'demo') {
    return const [];
  }

  // Wait until AuthApi (cookie jar + CSRF) is ready.
  await ref.watch(authApiProvider.future);
  final api = ref.watch(clubsApiProvider);
  return api.listMyClubs();
});

final selectedClubIdProvider =
    StateNotifierProvider<SelectedClubNotifier, String?>((ref) {
  return SelectedClubNotifier(ref);
});

class SelectedClubNotifier extends StateNotifier<String?> {
  SelectedClubNotifier(this._ref) : super(null) {
    _load();
    _ref.listen(myClubsProvider, (previous, next) {
      next.whenData(_ensureValidSelection);
    });
  }

  final Ref _ref;

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getString(_selectedClubKey);
  }

  Future<void> select(String clubId) async {
    state = clubId;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_selectedClubKey, clubId);
  }

  Future<void> clear() async {
    state = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_selectedClubKey);
  }

  void _ensureValidSelection(List<ClubSummary> clubs) {
    if (clubs.isEmpty) return;
    final current = state;
    if (current != null && clubs.any((c) => c.id == current)) return;
    // ignore: discarded_futures
    select(clubs.first.id);
  }
}

final selectedClubProvider = Provider.autoDispose<ClubSummary?>((ref) {
  final clubId = ref.watch(selectedClubIdProvider);
  final clubs = ref.watch(myClubsProvider).valueOrNull ?? const <ClubSummary>[];
  if (clubs.isEmpty) return null;
  if (clubId == null) return clubs.first;
  for (final club in clubs) {
    if (club.id == clubId) return club;
  }
  return clubs.first;
});

final clubDetailProvider =
    FutureProvider.autoDispose.family<Club, String>((ref, clubId) async {
  await ref.watch(authApiProvider.future);
  final api = ref.watch(clubsApiProvider);
  return api.getClub(clubId);
});

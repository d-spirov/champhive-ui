import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../l10n/app_localizations.dart';
import '../../../shared/l10n/date_l10n.dart';
import '../../../shared/utils/api_error_message.dart';
import '../../clubs/providers/clubs_provider.dart';
import '../../events/providers/events_provider.dart';
import '../../players/providers/players_provider.dart';
import '../providers/teams_provider.dart';

class AddTeamMemberScreen extends ConsumerStatefulWidget {
  const AddTeamMemberScreen({super.key, required this.teamId});

  final String teamId;

  @override
  ConsumerState<AddTeamMemberScreen> createState() =>
      _AddTeamMemberScreenState();
}

class _AddTeamMemberScreenState extends ConsumerState<AddTeamMemberScreen> {
  final _firstCtrl = TextEditingController();
  final _lastCtrl = TextEditingController();
  final _shirtCtrl = TextEditingController();
  DateTime? _dob;
  String? _gender;
  bool _saving = false;
  String? _error;

  @override
  void dispose() {
    _firstCtrl.dispose();
    _lastCtrl.dispose();
    _shirtCtrl.dispose();
    super.dispose();
  }

  String _isoDate(DateTime d) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${d.year}-${two(d.month)}-${two(d.day)}';
  }

  Future<void> _pickDob() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _dob ?? DateTime(now.year - 12, 1, 1),
      firstDate: DateTime(now.year - 80),
      lastDate: now,
    );
    if (picked != null) setState(() => _dob = picked);
  }

  Future<String?> _seasonId(String clubId) async {
    final roster = ref.read(teamRosterProvider(widget.teamId)).valueOrNull;
    final fromRoster = roster?.seasonId?.trim();
    if (fromRoster != null && fromRoster.isNotEmpty) return fromRoster;
    final seasons = await ref
        .read(teamsApiProvider)
        .listSeasons(clubId: clubId);
    if (seasons.isEmpty) return null;
    final today = DateTime.now();
    for (final season in seasons) {
      if (season.contains(today)) return season.id;
    }
    return seasons.first.id;
  }

  Future<void> _save({bool confirmDuplicate = false}) async {
    final l10n = AppLocalizations.of(context)!;
    final clubId = ref.read(selectedClubIdProvider);
    if (clubId == null || clubId.isEmpty) {
      setState(() => _error = l10n.selectClubFirst);
      return;
    }
    final first = _firstCtrl.text.trim();
    final last = _lastCtrl.text.trim();
    if (first.isEmpty) {
      setState(() => _error = l10n.pleaseEnterFirstName);
      return;
    }
    if (last.isEmpty) {
      setState(() => _error = l10n.pleaseEnterLastName);
      return;
    }
    final dob = _dob;
    if (dob == null) {
      setState(() => _error = l10n.dateOfBirthRequired);
      return;
    }
    final shirtRaw = _shirtCtrl.text.trim();
    final shirt = shirtRaw.isEmpty ? null : int.tryParse(shirtRaw);
    if (shirtRaw.isNotEmpty && shirt == null) {
      setState(() => _error = l10n.couldNotAddMember);
      return;
    }

    setState(() {
      _saving = true;
      _error = null;
    });

    try {
      final team = ref.read(clubTeamProvider(widget.teamId));
      final api = ref.read(playersApiProvider);
      final member = await api.createMember(
        clubId: clubId,
        firstName: first,
        lastName: last,
        dateOfBirth: _isoDate(dob),
        gender: _gender,
        shirtNumber: shirt,
        sectionId: team?.sectionId,
        confirmDuplicate: confirmDuplicate,
      );
      final seasonId = await _seasonId(clubId);
      if (seasonId == null || seasonId.isEmpty) {
        throw StateError(l10n.couldNotAddMember);
      }
      try {
        await api.enrollMember(
          clubId: clubId,
          memberId: member.id,
          teamId: widget.teamId,
          seasonId: seasonId,
        );
      } catch (e) {
        if (apiErrorCode(e) != 'already_enrolled') rethrow;
      }
      ref.invalidate(teamRosterProvider(widget.teamId));
      ref.invalidate(clubPlayersProvider);
      ref.invalidate(attendanceSessionProvider);
      ref.invalidate(occurrenceAttendanceReportProvider);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.memberAddedNamed(member.name))),
      );
      if (context.canPop()) {
        context.pop(true);
      } else {
        context.go('/teams/${widget.teamId}');
      }
    } catch (e) {
      if (!mounted) return;
      if (!confirmDuplicate &&
          e is DioException &&
          apiErrorCode(e) == 'duplicate_member_suspected') {
        setState(() => _saving = false);
        final anyway = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(l10n.addMember),
            content: Text(l10n.duplicateMemberSuspected),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text(l10n.cancel),
              ),
              FilledButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: Text(l10n.addAnyway),
              ),
            ],
          ),
        );
        if (anyway == true && mounted) {
          await _save(confirmDuplicate: true);
        }
        return;
      }
      setState(() {
        _saving = false;
        _error = apiErrorMessage(e, fallback: l10n.couldNotAddMember);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final team = ref.watch(clubTeamProvider(widget.teamId));
    final title = team?.name ?? l10n.addMember;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.addMember)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
        children: [
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 16),
          TextField(
            controller: _firstCtrl,
            textCapitalization: TextCapitalization.words,
            textInputAction: TextInputAction.next,
            decoration: InputDecoration(labelText: l10n.firstName),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _lastCtrl,
            textCapitalization: TextCapitalization.words,
            textInputAction: TextInputAction.next,
            decoration: InputDecoration(labelText: l10n.lastName),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: _pickDob,
            icon: const Icon(Icons.cake_outlined),
            label: Text(
              _dob == null ? l10n.dateOfBirth : appYMMMd(context).format(_dob!),
            ),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String?>(
            // ignore: deprecated_member_use
            value: _gender,
            decoration: InputDecoration(labelText: l10n.gender),
            items: [
              DropdownMenuItem(
                value: null,
                child: Text(l10n.genderUnspecified),
              ),
              DropdownMenuItem(value: 'male', child: Text(l10n.genderMale)),
              DropdownMenuItem(value: 'female', child: Text(l10n.genderFemale)),
            ],
            onChanged: (v) => setState(() => _gender = v),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _shirtCtrl,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: InputDecoration(labelText: l10n.shirtNumber),
          ),
          if (_error != null) ...[
            const SizedBox(height: 16),
            Text(
              _error!,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ],
          const SizedBox(height: 24),
          FilledButton(
            onPressed: _saving ? null : () => _save(),
            child: _saving
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(l10n.save),
          ),
        ],
      ),
    );
  }
}

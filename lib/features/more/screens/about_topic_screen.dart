import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../l10n/app_localizations.dart';
import '../../../shared/theme/app_theme.dart';
import 'about_screen.dart';

enum AboutTopic { mission, teams, privacy }

class AboutTopicScreen extends StatelessWidget {
  const AboutTopicScreen({super.key, required this.topic});

  final AboutTopic topic;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final navy = isDark ? AppColors.darkText : AppColors.primaryNavy;
    final spec = _spec(l10n);

    return Stack(
      fit: StackFit.expand,
      children: [
        const AboutBackdrop(),
        Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            centerTitle: true,
            title: Text(
              spec.title,
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w700,
                fontSize: 18,
                color: navy,
              ),
            ),
          ),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
            children: [
              Center(
                child: CircleAvatar(
                  radius: 36,
                  backgroundColor: isDark
                      ? AppColors.primaryNavy
                      : AppColors.primaryLight,
                  child: Icon(spec.icon, size: 32, color: AppColors.primary),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                spec.title,
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w800,
                  fontSize: 24,
                  letterSpacing: -0.4,
                  color: navy,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                spec.subtitle,
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w500,
                  fontSize: 15,
                  height: 1.4,
                  color: AppColors.primaryBright,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                spec.body,
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 15,
                  height: 1.55,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  _TopicSpec _spec(AppLocalizations l10n) {
    return switch (topic) {
      AboutTopic.mission => _TopicSpec(
        icon: Icons.groups_rounded,
        title: l10n.aboutMissionTitle,
        subtitle: l10n.aboutMissionSubtitle,
        body: l10n.aboutMissionBody,
      ),
      AboutTopic.teams => _TopicSpec(
        icon: Icons.verified_user_outlined,
        title: l10n.aboutTeamsTitle,
        subtitle: l10n.aboutTeamsSubtitle,
        body: l10n.aboutTeamsBody,
      ),
      AboutTopic.privacy => _TopicSpec(
        icon: Icons.lock_outline_rounded,
        title: l10n.aboutPrivacyTitle,
        subtitle: l10n.aboutPrivacySubtitle,
        body: l10n.aboutPrivacyBody,
      ),
    };
  }
}

class _TopicSpec {
  const _TopicSpec({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.body,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String body;
}

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../l10n/app_localizations.dart';
import '../../../shared/theme/app_theme.dart';
import '../../../shared/widgets/team_hive_logo.dart';
import '../../../shared/widgets/ui_bits.dart';

const kAppVersion = '1.0.0';
const kCodeantechUrl = 'https://codeantech.com';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final navy = isDark ? AppColors.darkText : AppColors.primaryNavy;
    final muted = Theme.of(context).colorScheme.onSurfaceVariant;

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
              l10n.aboutApp,
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w700,
                fontSize: 18,
                color: navy,
              ),
            ),
          ),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
            children: [
              const _AppMark(),
              const SizedBox(height: 16),
              Text(
                'ChampHive',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w800,
                  fontSize: 28,
                  letterSpacing: -0.6,
                  color: navy,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                l10n.aboutTagline,
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w500,
                  fontSize: 15,
                  color: AppColors.primaryBright,
                ),
              ),
              const SizedBox(height: 14),
              Center(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppColors.primaryNavy.withValues(alpha: 0.55)
                        : AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 6,
                    ),
                    child: Text(
                      l10n.aboutVersion(kAppVersion),
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                        color: isDark
                            ? AppColors.darkPrimary
                            : AppColors.primary,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                l10n.aboutIntro,
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  height: 1.5,
                  color: muted,
                ),
              ),
              const SizedBox(height: 24),
              AppCard(
                child: Column(
                  children: [
                    _AboutLinkTile(
                      icon: Icons.groups_rounded,
                      title: l10n.aboutMissionTitle,
                      subtitle: l10n.aboutMissionSubtitle,
                      onTap: () => context.push('/about/mission'),
                    ),
                    const Divider(height: 1, indent: 72),
                    _AboutLinkTile(
                      icon: Icons.verified_user_outlined,
                      title: l10n.aboutTeamsTitle,
                      subtitle: l10n.aboutTeamsSubtitle,
                      onTap: () => context.push('/about/teams'),
                    ),
                    const Divider(height: 1, indent: 72),
                    _AboutLinkTile(
                      icon: Icons.lock_outline_rounded,
                      title: l10n.aboutPrivacyTitle,
                      subtitle: l10n.aboutPrivacySubtitle,
                      onTap: () => context.push('/about/privacy'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              const _CodeantechCard(),
              const SizedBox(height: 24),
              Text(
                l10n.aboutCopyright(DateTime.now().year.toString()),
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: muted.withValues(alpha: 0.85),
                ),
              ),
              const SizedBox(height: 16),
              const _SportsFooter(),
            ],
          ),
        ),
      ],
    );
  }
}

class AboutBackdrop extends StatelessWidget {
  const AboutBackdrop({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final base = isDark ? AppColors.darkBg : const Color(0xFFF7FAFF);
    final blob = isDark
        ? AppColors.primary.withValues(alpha: 0.18)
        : const Color(0xFFBFDBFE).withValues(alpha: 0.55);

    return ColoredBox(
      color: base,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Positioned(top: -80, left: -70, child: _Wash(color: blob, size: 220)),
          Positioned(top: 40, right: -90, child: _Wash(color: blob, size: 260)),
          Positioned(
            bottom: 80,
            left: -40,
            child: _Wash(
              color: blob.withValues(alpha: isDark ? 0.12 : 0.28),
              size: 180,
            ),
          ),
          const Opacity(
            opacity: 0.11,
            child: CustomPaint(
              painter: AboutHexMeshPainter(),
              child: SizedBox.expand(),
            ),
          ),
        ],
      ),
    );
  }
}

class _Wash extends StatelessWidget {
  const _Wash({required this.color, required this.size});

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(colors: [color, color.withValues(alpha: 0)]),
        ),
      ),
    );
  }
}

class AboutHexMeshPainter extends CustomPainter {
  const AboutHexMeshPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.1
      ..color = AppColors.primaryBright;
    const radius = 20.0;
    final horiz = radius * 1.7320508;
    final vert = radius * 1.5;
    for (var row = -1; row < (size.height / vert) + 2; row++) {
      for (var col = -1; col < (size.width / horiz) + 2; col++) {
        final dx = col * horiz + (row.isOdd ? horiz / 2 : 0);
        final dy = row * vert;
        final path = Path();
        for (var i = 0; i < 6; i++) {
          final angle = (math.pi / 3 * i) - (math.pi / 6);
          final x = dx + radius * math.cos(angle);
          final y = dy + radius * math.sin(angle);
          if (i == 0) {
            path.moveTo(x, y);
          } else {
            path.lineTo(x, y);
          }
        }
        path.close();
        canvas.drawPath(path, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _AppMark extends StatelessWidget {
  const _AppMark();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: AppGradients.heroCard,
          boxShadow: AppTheme.mediumShadow,
        ),
        child: const SizedBox(
          width: 88,
          height: 88,
          child: Center(
            child: TeamHiveLogo(
              size: 64,
              solidWhiteMark: true,
              showShadow: false,
            ),
          ),
        ),
      ),
    );
  }
}

class _AboutLinkTile extends StatelessWidget {
  const _AboutLinkTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      leading: CircleAvatar(
        backgroundColor: isDark
            ? AppColors.primaryNavy
            : AppColors.primaryLight,
        child: Icon(icon, color: AppColors.primary),
      ),
      title: Text(
        title,
        style: GoogleFonts.inter(
          fontWeight: FontWeight.w700,
          fontSize: 15,
          color: isDark ? AppColors.darkText : AppColors.primaryNavy,
        ),
      ),
      subtitle: Text(subtitle),
      trailing: Icon(
        Icons.chevron_right_rounded,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
    );
  }
}

class _CodeantechCard extends StatelessWidget {
  const _CodeantechCard();

  Future<void> _openSite(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final uri = Uri.parse(kCodeantechUrl);
    final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!context.mounted) return;
    if (!ok) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.aboutCouldNotOpenWebsite)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final muted = Theme.of(context).colorScheme.onSurfaceVariant;

    return AppCard(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _CodeantechMark(),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text.rich(
                  TextSpan(
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      color: isDark ? AppColors.darkText : AppColors.lightText,
                    ),
                    children: [
                      TextSpan(text: '${l10n.aboutMadeWith} '),
                      const WidgetSpan(
                        alignment: PlaceholderAlignment.middle,
                        child: Icon(
                          Icons.favorite,
                          size: 14,
                          color: AppColors.primary,
                        ),
                      ),
                      TextSpan(text: ' ${l10n.aboutMadeBy}'),
                    ],
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  l10n.aboutCodeantechBlurb,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    height: 1.45,
                    color: muted,
                  ),
                ),
                const SizedBox(height: 10),
                InkWell(
                  onTap: () => _openSite(context),
                  child: Row(
                    children: [
                      Icon(
                        Icons.public_rounded,
                        size: 16,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          kCodeantechUrl,
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CodeantechMark extends StatelessWidget {
  const _CodeantechMark();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 72,
      child: Column(
        children: [
          const CustomPaint(
            size: Size.square(34),
            painter: _RainbowRingPainter(),
          ),
          const SizedBox(height: 6),
          Text(
            'codeantech',
            style: GoogleFonts.inter(
              fontWeight: FontWeight.w800,
              fontSize: 10,
              letterSpacing: -0.2,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}

class _RainbowRingPainter extends CustomPainter {
  const _RainbowRingPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.18
      ..strokeCap = StrokeCap.round
      ..shader = const SweepGradient(
        colors: [
          Color(0xFF22D3EE),
          Color(0xFF3B82F6),
          Color(0xFFA855F7),
          Color(0xFFEC4899),
          Color(0xFFF59E0B),
          Color(0xFF22C55E),
          Color(0xFF22D3EE),
        ],
      ).createShader(rect);
    canvas.drawCircle(
      Offset(size.width / 2, size.height / 2),
      size.width * 0.32,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _SportsFooter extends StatelessWidget {
  const _SportsFooter();

  @override
  Widget build(BuildContext context) {
    final color = AppColors.primaryBright.withValues(alpha: 0.28);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Icon(Icons.sports_soccer_rounded, color: color, size: 22),
        Icon(Icons.sports_basketball_rounded, color: color, size: 22),
        Icon(Icons.sports_volleyball_rounded, color: color, size: 22),
        Icon(Icons.sports_rounded, color: color, size: 22),
      ],
    );
  }
}

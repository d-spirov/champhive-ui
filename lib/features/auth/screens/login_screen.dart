import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../providers/auth_provider.dart';
import '../../../core/theme/sport_theme_config.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/theme/app_theme.dart';
import '../../../shared/widgets/team_hive_logo.dart';
import '../../../shared/widgets/ui_bits.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  bool _biometricAttempted = false;
  bool _showFaceId = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadFaceIdAvailability();
      Future.delayed(const Duration(milliseconds: 600), _tryBiometricLogin);
    });
  }

  Future<void> _loadFaceIdAvailability() async {
    final service = ref.read(biometricCredentialsProvider);
    final show =
        await service.hasStoredCredentials && await service.canUseBiometrics;
    if (mounted) setState(() => _showFaceId = show);
  }

  Future<void> _tryBiometricLogin({bool force = false}) async {
    if (!force && _biometricAttempted) return;
    if (!mounted) return;
    _biometricAttempted = true;
    final reason = AppLocalizations.of(context)!.faceIdSignInPrompt;
    final service = ref.read(biometricCredentialsProvider);
    if (!await service.hasStoredCredentials) return;
    if (!await service.canUseBiometrics) return;
    if (!mounted) return;

    final credentials = await service.getCredentialsWithBiometrics(
      localizedReason: reason,
    );
    if (!mounted || credentials == null) return;
    await _loginWithCredentials(
      email: credentials.email,
      password: credentials.password,
    );
  }

  Future<void> _loginWithCredentials({
    required String email,
    required String password,
  }) async {
    final ok = await ref
        .read(authNotifierProvider.notifier)
        .login(email: email, password: password);
    if (!mounted) return;
    if (ok) {
      context.go('/home');
      return;
    }
    final error = ref.read(authNotifierProvider).error;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(error ?? AppLocalizations.of(context)!.loginFailed),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: AppColors.loginNavyDeep,
        body: Stack(
          fit: StackFit.expand,
          children: [
            const ColoredBox(color: AppColors.loginNavyDeep),
            Image.asset(
              kLoginHeroImage,
              fit: BoxFit.cover,
              alignment: const Alignment(0, 0.18),
              errorBuilder: (_, _, _) =>
                  const ColoredBox(color: AppColors.loginNavyDeep),
            ),
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: [0.0, 0.22, 0.38, 0.58, 0.78, 1.0],
                  colors: [
                    Color(0xE6070B18),
                    Color(0x99070B18),
                    Color(0x22070B18),
                    Color(0x33070B18),
                    Color(0xE6070B18),
                    Color(0xFF070B18),
                  ],
                ),
              ),
            ),
            const Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: 280,
              child: IgnorePointer(
                child: Opacity(
                  opacity: 0.22,
                  child: CustomPaint(
                    painter: _HexMeshPainter(),
                    child: SizedBox.expand(),
                  ),
                ),
              ),
            ),
            SafeArea(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 28),
                    child: Column(
                      children: [
                        const SizedBox(height: 10),
                        const TeamHiveLogo(
                          size: 88,
                          showWordmark: true,
                          showShadow: true,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          l10n.tagline,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.inter(
                            color: Colors.white.withValues(alpha: 0.88),
                            fontSize: 15,
                            height: 1.35,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          width: 36,
                          height: 2,
                          decoration: BoxDecoration(
                            color: AppColors.primaryBright,
                            borderRadius: BorderRadius.circular(99),
                          ),
                        ),
                        const Spacer(),
                        _PillButton(
                          label: l10n.continueWithGoogle,
                          icon: const _GoogleGlyph(),
                          filled: true,
                          onPressed: () => _comingSoon('Google Sign-In'),
                        ),
                        const SizedBox(height: 12),
                        _PillButton(
                          label: l10n.continueWithApple,
                          icon: const Icon(
                            Icons.apple,
                            size: 22,
                            color: Color(0xFF0F172A),
                          ),
                          filled: true,
                          onPressed: () => _comingSoon('Apple Sign-In'),
                        ),
                        const SizedBox(height: 16),
                        _OrDivider(label: l10n.orDivider),
                        const SizedBox(height: 16),
                        _PillButton(
                          label: l10n.signInWithEmail,
                          icon: const Icon(
                            Icons.mail_outline_rounded,
                            size: 20,
                            color: AppColors.primaryBright,
                          ),
                          filled: false,
                          borderColor: AppColors.primaryBright,
                          onPressed: () => _openEmailLogin(context),
                        ),
                        if (_showFaceId) ...[
                          const SizedBox(height: 12),
                          _PillButton(
                            label: l10n.signInWithFaceId,
                            icon: const Icon(
                              Icons.face_retouching_natural,
                              size: 20,
                              color: Colors.white,
                            ),
                            filled: false,
                            onPressed: () => _tryBiometricLogin(force: true),
                          ),
                        ],
                        const SizedBox(height: 18),
                        TextButton(
                          onPressed: () => context.go('/register'),
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 8),
                          ),
                          child: Text.rich(
                            TextSpan(
                              text: l10n.newToChampHive,
                              style: GoogleFonts.inter(
                                color: Colors.white.withValues(alpha: 0.86),
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                              ),
                              children: [
                                TextSpan(
                                  text: l10n.createAccount,
                                  style: GoogleFonts.inter(
                                    color: AppColors.primaryBright,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _comingSoon(String label) {
    final l10n = AppLocalizations.of(context)!;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(l10n.comingSoonNamed(label))));
  }

  Future<void> _openEmailLogin(BuildContext context) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.viewInsetsOf(sheetContext).bottom,
          ),
          child: const _EmailLoginSheet(),
        );
      },
    );
  }
}

class _EmailLoginSheet extends ConsumerStatefulWidget {
  const _EmailLoginSheet();

  @override
  ConsumerState<_EmailLoginSheet> createState() => _EmailLoginSheetState();
}

class _EmailLoginSheetState extends ConsumerState<_EmailLoginSheet> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscure = true;

  @override
  void initState() {
    super.initState();
    _prefillRememberedEmail();
  }

  Future<void> _prefillRememberedEmail() async {
    final email = await ref
        .read(biometricCredentialsProvider)
        .getStoredEmailQuiet();
    if (!mounted || email == null || email.isEmpty) return;
    _emailController.text = email;
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final ok = await ref
        .read(authNotifierProvider.notifier)
        .login(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );
    if (!mounted) return;
    if (ok) {
      Navigator.of(context).pop();
      context.go('/home');
      return;
    }
    final error = ref.read(authNotifierProvider).error;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(error ?? AppLocalizations.of(context)!.loginFailed),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final auth = ref.watch(authNotifierProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surface = isDark ? AppColors.darkCard : Colors.white;
    final textColor = isDark ? AppColors.darkText : AppColors.lightText;

    return Container(
      decoration: BoxDecoration(
        color: surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.35),
            blurRadius: 24,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 20),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.withValues(alpha: 0.35),
                      borderRadius: BorderRadius.circular(99),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  l10n.signInWithEmail,
                  style: GoogleFonts.inter(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.3,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 22),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  autofillHints: const [AutofillHints.email],
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                    labelText: l10n.email,
                    prefixIcon: const Icon(Icons.mail_outline_rounded),
                  ),
                  validator: (v) {
                    final value = v?.trim() ?? '';
                    if (value.isEmpty) return l10n.pleaseEnterEmail;
                    if (!value.contains('@')) return l10n.pleaseEnterValidEmail;
                    return null;
                  },
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscure,
                  autofillHints: const [AutofillHints.password],
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => _submit(),
                  decoration: InputDecoration(
                    labelText: l10n.password,
                    prefixIcon: const Icon(Icons.lock_outline_rounded),
                    suffixIcon: IconButton(
                      onPressed: () => setState(() => _obscure = !_obscure),
                      icon: Icon(
                        _obscure
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                      ),
                    ),
                  ),
                  validator: (v) => (v == null || v.isEmpty)
                      ? l10n.pleaseEnterPassword
                      : null,
                ),
                const SizedBox(height: 22),
                GradientButton(
                  onPressed: auth.isLoading ? null : _submit,
                  child: auth.isLoading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(l10n.logIn),
                ),
                const SizedBox(height: 4),
                TextButton(
                  onPressed: auth.isLoading
                      ? null
                      : () async {
                          Navigator.pop(context);
                          await ref
                              .read(authNotifierProvider.notifier)
                              .enterDemo();
                          if (context.mounted) context.go('/home');
                        },
                  child: Text(l10n.exploreDemo),
                ),
                TextButton(
                  onPressed: auth.isLoading
                      ? null
                      : () => Navigator.pop(context),
                  child: Text(l10n.cancel),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PillButton extends StatelessWidget {
  const _PillButton({
    required this.label,
    required this.icon,
    required this.filled,
    required this.onPressed,
    this.borderColor,
  });

  final String label;
  final Widget icon;
  final bool filled;
  final VoidCallback onPressed;
  final Color? borderColor;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(AppTheme.radiusPill);
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: Material(
        color: filled ? Colors.white : Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: radius,
          side: filled
              ? BorderSide.none
              : BorderSide(
                  color: borderColor ?? Colors.white.withValues(alpha: 0.85),
                ),
        ),
        child: InkWell(
          onTap: onPressed,
          borderRadius: radius,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(width: 24, height: 24, child: Center(child: icon)),
              const SizedBox(width: 10),
              Text(
                label,
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                  color: filled ? const Color(0xFF0F172A) : Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GoogleGlyph extends StatelessWidget {
  const _GoogleGlyph();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(size: const Size.square(20), painter: _GoogleGPainter());
  }
}

class _GoogleGPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final stroke = size.width * 0.18;
    final rect =
        Offset(stroke / 2, stroke / 2) &
        Size(size.width - stroke, size.height - stroke);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.butt;

    paint.color = const Color(0xFF4285F4);
    canvas.drawArc(rect, -0.4, 1.6, false, paint);
    paint.color = const Color(0xFF34A853);
    canvas.drawArc(rect, 1.2, 1.0, false, paint);
    paint.color = const Color(0xFFFBBC05);
    canvas.drawArc(rect, 2.2, 0.9, false, paint);
    paint.color = const Color(0xFFEA4335);
    canvas.drawArc(rect, 3.1, 1.1, false, paint);

    final bar = Paint()
      ..color = const Color(0xFF4285F4)
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.square;
    canvas.drawLine(
      Offset(size.width * 0.52, size.height * 0.5),
      Offset(size.width * 0.92, size.height * 0.5),
      bar,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _OrDivider extends StatelessWidget {
  const _OrDivider({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final line = Expanded(
      child: Container(height: 1, color: Colors.white.withValues(alpha: 0.22)),
    );
    return Row(
      children: [
        line,
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            label,
            style: GoogleFonts.inter(
              color: Colors.white.withValues(alpha: 0.55),
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.2,
            ),
          ),
        ),
        line,
      ],
    );
  }
}

class _HexMeshPainter extends CustomPainter {
  const _HexMeshPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = Colors.white.withValues(alpha: 0.55);
    const radius = 22.0;
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

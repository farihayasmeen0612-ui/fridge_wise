import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors_extension.dart';
import '../../../../core/theme/theme_notifier.dart';

/// Welcome Screen for FridgeWise.
/// Serves as the initial screen introducing the app with an elegant minimal line-art
/// refrigerator illustration, natural sage/ivory palette, and streamlined onboarding actions.
class WelcomeScreen extends ConsumerWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Palette tokens tailored for natural kitchen aesthetic
    final bgWarmIvory = isDark ? const Color(0xFF121915) : const Color(0xFFF7F8F0);
    final primaryForest = isDark ? const Color(0xFF79C99A) : const Color(0xFF176343);
    final softSage = isDark ? const Color(0xFF1D2821) : const Color(0xFFE1EBDF);
    final lightMint = isDark ? const Color(0xFF183022) : const Color(0xFFDDF2E3);
    final textHeading = isDark ? const Color(0xFFF1F5F0) : const Color(0xFF176343);
    final textSecondary = isDark ? const Color(0xFFB1BDB3) : const Color(0xFF526154);

    return Scaffold(
      backgroundColor: bgWarmIvory,
      body: SafeArea(
        child: Stack(
          children: [
            // Subtle restrained organic background accents
            Positioned(
              top: -40,
              left: -40,
              child: IgnorePointer(
                child: Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: softSage.withValues(alpha: isDark ? 0.2 : 0.4),
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 80,
              right: -50,
              child: IgnorePointer(
                child: Container(
                  width: 160,
                  height: 160,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: lightMint.withValues(alpha: isDark ? 0.15 : 0.35),
                  ),
                ),
              ),
            ),

            // Main Layout Content
            Column(
              children: [
                // Top Section: Compact light/dark theme toggle in upper-right corner
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: _WelcomeThemeToggle(
                      isDark: isDark,
                      onToggle: () {
                        ref.read(themeNotifierProvider.notifier).setThemeMode(
                              isDark ? ThemeMode.light : ThemeMode.dark,
                            );
                      },
                    ),
                  ),
                ),

                // Middle & Bottom Content in responsive scrollview
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final isShortScreen = constraints.maxHeight < 620;

                      return SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            minHeight: constraints.maxHeight - 16,
                            maxWidth: 420,
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const SizedBox(height: 4),

                              // Central Content: App Identity + Illustration + Headline + Supporting description
                              Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  // App Name centered horizontally immediately above the illustration
                                  Text(
                                    'FridgeWise',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: isShortScreen ? 22 : 25,
                                      fontWeight: FontWeight.w700,
                                      color: primaryForest,
                                      letterSpacing: -0.4,
                                    ),
                                  ),
                                  SizedBox(height: isShortScreen ? 10 : 16),

                                  // Main Refrigerator Illustration with soft aura backdrop
                                  Container(
                                    width: isShortScreen ? 210 : 240,
                                    height: isShortScreen ? 185 : 215,
                                    alignment: Alignment.center,
                                    child: Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        CustomPaint(
                                          size: Size(
                                            isShortScreen ? 210 : 240,
                                            isShortScreen ? 185 : 215,
                                          ),
                                          painter: _FridgeAuraPainter(
                                            isDark: isDark,
                                            primaryColor: primaryForest,
                                            sageColor: softSage,
                                          ),
                                        ),
                                        Image.asset(
                                          'assets/images/refrigerator_illustration.png',
                                          width: isShortScreen ? 185 : 210,
                                          height: isShortScreen ? 185 : 210,
                                          fit: BoxFit.contain,
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(height: isShortScreen ? 14 : 20),

                                  // Exact Headline
                                  Text(
                                    'Fresh food, less waste.',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: isShortScreen ? 26 : 30,
                                      fontWeight: FontWeight.w800,
                                      color: textHeading,
                                      letterSpacing: -0.6,
                                      height: 1.2,
                                    ),
                                  ),
                                  const SizedBox(height: 12),

                                  // Exact Supporting Description
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                                    child: Text(
                                      'Keep track of your food, stay ahead of expiry dates, and make the most of every ingredient.',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w400,
                                        color: textSecondary,
                                        height: 1.45,
                                        letterSpacing: -0.1,
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              // Bottom Actions
                              Padding(
                                padding: const EdgeInsets.only(top: 24.0, bottom: 12.0),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    // Primary Action: Get Started Button
                                    SizedBox(
                                      height: 52,
                                      child: Material(
                                        color: isDark ? primaryForest : primaryForest,
                                        borderRadius: BorderRadius.circular(16),
                                        elevation: 0,
                                        child: InkWell(
                                          onTap: () => context.push('/auth/register'),
                                          borderRadius: BorderRadius.circular(16),
                                          child: Center(
                                            child: Text(
                                              'Get Started',
                                              style: TextStyle(
                                                color: isDark
                                                    ? const Color(0xFF092616)
                                                    : Colors.white,
                                                fontSize: 16,
                                                fontWeight: FontWeight.w700,
                                                letterSpacing: 0.2,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 16),

                                    // Secondary Action: I already have an account — Sign In
                                    InkWell(
                                      onTap: () => context.push('/auth/login'),
                                      borderRadius: BorderRadius.circular(8),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                                        child: Text.rich(
                                          TextSpan(
                                            text: 'I already have an account — ',
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500,
                                              color: textSecondary,
                                            ),
                                            children: [
                                              TextSpan(
                                                text: 'Sign In',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.w700,
                                                  color: primaryForest,
                                                ),
                                              ),
                                            ],
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Compact light/dark theme toggle matching the login screen aesthetic.
class _WelcomeThemeToggle extends StatelessWidget {
  const _WelcomeThemeToggle({
    required this.isDark,
    required this.onToggle,
  });

  final bool isDark;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final colorScheme = Theme.of(context).colorScheme;

    return Semantics(
      button: true,
      label: isDark ? 'Switch to light theme' : 'Switch to dark theme',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onToggle,
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: colors.surfaceElevated,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: colors.cardBorder),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Light mode / Sun indicator
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: !isDark ? colorScheme.surface : Colors.transparent,
                    shape: BoxShape.circle,
                    boxShadow: !isDark
                        ? [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.08),
                              blurRadius: 4,
                              offset: const Offset(0, 1),
                            ),
                          ]
                        : null,
                  ),
                  child: Icon(
                    Icons.light_mode_rounded,
                    size: 16,
                    color: !isDark ? colorScheme.primary : colors.textMuted,
                  ),
                ),
                const SizedBox(width: 4),
                // Dark mode / Moon indicator
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: isDark ? colorScheme.surface : Colors.transparent,
                    shape: BoxShape.circle,
                    boxShadow: isDark
                        ? [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.25),
                              blurRadius: 4,
                              offset: const Offset(0, 1),
                            ),
                          ]
                        : null,
                  ),
                  child: Icon(
                    Icons.dark_mode_rounded,
                    size: 16,
                    color: isDark ? colorScheme.primary : colors.textMuted,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Decorative vector painter rendering a subtle circular backdrop and botanical accents
/// behind the main refrigerator illustration.
class _FridgeAuraPainter extends CustomPainter {
  const _FridgeAuraPainter({
    required this.isDark,
    required this.primaryColor,
    required this.sageColor,
  });

  final bool isDark;
  final Color primaryColor;
  final Color sageColor;

  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width / 2;
    final centerY = size.height / 2;

    final fillPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = sageColor.withValues(alpha: isDark ? 0.35 : 0.55);

    // Soft circular aura behind refrigerator
    canvas.drawCircle(Offset(centerX, centerY), size.width * 0.38, fillPaint);

    // Subtle decorative sparkles / botanical accents around illustration
    _drawSparkle(canvas, Offset(size.width * 0.12, size.height * 0.18), 6, primaryColor.withValues(alpha: 0.45));
    _drawSparkle(canvas, Offset(size.width * 0.90, size.height * 0.16), 7, primaryColor.withValues(alpha: 0.5));
    _drawSparkle(canvas, Offset(size.width * 0.94, size.height * 0.35), 4, primaryColor.withValues(alpha: 0.35));
    _drawFloatingLeaf(canvas, Offset(size.width * 0.10, size.height * 0.85), primaryColor.withValues(alpha: 0.45));
  }

  void _drawSparkle(Canvas canvas, Offset center, double radius, Color color) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.3
      ..strokeCap = StrokeCap.round;

    final path = Path()
      ..moveTo(center.dx, center.dy - radius)
      ..quadraticBezierTo(center.dx, center.dy, center.dx + radius, center.dy)
      ..quadraticBezierTo(center.dx, center.dy, center.dx, center.dy + radius)
      ..quadraticBezierTo(center.dx, center.dy, center.dx - radius, center.dy)
      ..quadraticBezierTo(center.dx, center.dy, center.dx, center.dy - radius);

    canvas.drawPath(path, paint);
  }

  void _drawFloatingLeaf(Canvas canvas, Offset center, Color color) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.3
      ..strokeCap = StrokeCap.round;

    final path = Path()
      ..moveTo(center.dx - 8, center.dy + 8)
      ..quadraticBezierTo(center.dx - 4, center.dy - 6, center.dx + 8, center.dy - 8)
      ..quadraticBezierTo(center.dx + 4, center.dy + 6, center.dx - 8, center.dy + 8);

    canvas.drawPath(path, paint);
    canvas.drawLine(
      Offset(center.dx - 8, center.dy + 8),
      Offset(center.dx + 4, center.dy - 4),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _FridgeAuraPainter oldDelegate) {
    return oldDelegate.isDark != isDark ||
        oldDelegate.primaryColor != primaryColor ||
        oldDelegate.sageColor != sageColor;
  }
}

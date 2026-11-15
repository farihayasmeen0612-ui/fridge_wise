import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/presentation/components/fridge_logo.dart';
import '../../../../core/presentation/components/theme_toggle_button.dart';
import '../../data/auth_provider.dart';

/// Redesigned Create Account / Registration Screen for FridgeWise.
/// Matches the visual target design of the Sign In screen:
/// - Botanical forest green background with delicate edge line-art (leaves, tomato, organic wave)
/// - Centered refrigerator logo with leaf on door and bold white FridgeWise app name
/// - Floating warm off-white card (#F4F5ED) with 36dp rounded corners on all sides
/// - In-field hint text without redundant external labels
/// - Four input fields: Full Name, Email Address, Password, Confirm Password
/// - Forest green primary button and theme toggle in top-right corner
class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    final name = _nameController.text.trim();
    final email = _emailController.text.trim().toLowerCase();
    final password = _passwordController.text;

    setState(() => _isLoading = true);
    try {
      final res = await ref.read(authProvider.notifier).signUp(
            name,
            email,
            password,
          );

      if (mounted) {
        setState(() => _isLoading = false);
        if (res.session != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Account created! Welcome to FridgeWise.'),
              backgroundColor: Color(0xFF23563E),
              behavior: SnackBarBehavior.floating,
            ),
          );
          context.go('/dashboard');
        } else {
          // Attempt immediate sign-in in case auto-confirm is active
          try {
            await ref.read(authProvider.notifier).signIn(email, password);
            if (mounted) {
              context.go('/dashboard');
              return;
            }
          } catch (_) {
            // Email confirmation is still required by the Supabase project
          }

          if (mounted) {
            await showDialog(
              context: context,
              barrierDismissible: false,
              builder: (ctx) => AlertDialog(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                title: const Row(
                  children: [
                    Icon(Icons.mark_email_unread_rounded, color: Color(0xFF23563E)),
                    SizedBox(width: 10),
                    Text('Verify Your Email', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                  ],
                ),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'We sent a verification link to:',
                      style: TextStyle(fontSize: 13),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      email,
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 14),
                    const Text(
                      'IMPORTANT: Please check your inbox (and Spam folder) and click the confirmation link before signing in.\n\nTo bypass email verification, turn off "Confirm email" in your Supabase Auth settings.',
                      style: TextStyle(fontSize: 12, height: 1.45, color: Colors.black87),
                    ),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () async {
                      try {
                        await ref.read(authProvider.notifier).resendConfirmationEmail(email);
                        if (ctx.mounted) {
                          ScaffoldMessenger.of(ctx).showSnackBar(
                            const SnackBar(content: Text('Verification email resent! Check your inbox.')),
                          );
                        }
                      } catch (err) {
                        if (ctx.mounted) {
                          ScaffoldMessenger.of(ctx).showSnackBar(
                            SnackBar(content: Text('Failed to resend: $err')),
                          );
                        }
                      }
                    },
                    child: const Text('Resend Email'),
                  ),
                  FilledButton(
                    style: FilledButton.styleFrom(backgroundColor: const Color(0xFF23563E)),
                    onPressed: () {
                      Navigator.of(ctx).pop();
                      context.go('/auth/login');
                    },
                    child: const Text('Go to Login'),
                  ),
                ],
              ),
            );
          }
        }
      }
    } on AuthException catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.message),
            backgroundColor: const Color(0xFFDC2626),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Registration failed: ${e.toString()}'),
            backgroundColor: const Color(0xFFDC2626),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final safeBottom = MediaQuery.of(context).padding.bottom;
    final isKeyboardOpen = MediaQuery.of(context).viewInsets.bottom > 0;

    // Palette Tokens matching the approved Sign In design
    // Light Theme
    const lightHeaderGreen = Color(0xFF26543C); // Rich botanical forest green
    const lightPanelIvory = Color(0xFFF4F5ED);  // Warm off-white card
    const lightPrimaryBtn = Color(0xFF23563E);  // Forest green button
    const lightInputBg = Color(0xFFEAEFE7);     // Soft light sage-tinted input
    const lightInputBorder = Color(0xFFD6E0D4);  // Subtle input border
    const lightTextPrimary = Color(0xFF1B3327);  // Deep forest charcoal
    const lightTextSecondary = Color(0xFF52665A);// Muted sage slate
    const lightAccentMint = Color(0xFFDDF2E3);   // Light mint accent

    // Dark Theme Coordinated Palette
    const darkHeaderGreen = Color(0xFF14231A);  // Dark evergreen
    const darkPanelSurface = Color(0xFF1D2821); // Charcoal-green panel
    const darkPrimaryBtn = Color(0xFF79C99A);   // Mint primary button
    const darkInputBg = Color(0xFF16211A);      // Dark input background
    const darkInputBorder = Color(0xFF2B3830);   // Dark input border
    const darkTextPrimary = Color(0xFFF1F5F0);   // Off-white text
    const darkTextSecondary = Color(0xFFB1BDB3); // Muted sage text
    const darkAccentMint = Color(0xFF79C99A);    // Mint accent

    // Active theme colors
    final headerGreen = isDark ? darkHeaderGreen : lightHeaderGreen;
    final panelBg = isDark ? darkPanelSurface : lightPanelIvory;
    final primaryBtnColor = isDark ? darkPrimaryBtn : lightPrimaryBtn;
    final primaryBtnTextColor = isDark ? const Color(0xFF092616) : Colors.white;
    final inputBg = isDark ? darkInputBg : lightInputBg;
    final inputBorderColor = isDark ? darkInputBorder : lightInputBorder;
    final focusBorderColor = isDark ? darkAccentMint : lightPrimaryBtn;
    final textPrimary = isDark ? darkTextPrimary : lightTextPrimary;
    final textSecondary = isDark ? darkTextSecondary : lightTextSecondary;
    final logoColor = isDark ? darkAccentMint : lightAccentMint;
    final appNameColor = isDark ? darkTextPrimary : Colors.white;

    return Scaffold(
      backgroundColor: headerGreen,
      body: Stack(
        children: [
          // Subtle low-contrast decorative botanical line-art over full background
          Positioned.fill(
            child: CustomPaint(
              painter: _BotanicalHeaderPainter(isDark: isDark),
            ),
          ),

          SafeArea(
            bottom: false,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final screenHeight = constraints.maxHeight;

                // Responsive header height:
                // Accommodates 4 form fields while remaining visually balanced
                final double headerHeight;
                if (isKeyboardOpen || screenHeight < 640) {
                  headerHeight = 140.0;
                } else {
                  headerHeight = (screenHeight * 0.28).clamp(160.0, 240.0);
                }

                return SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: Column(
                      children: [
                        // 1. Upper Botanical Green Header
                        SizedBox(
                          height: headerHeight,
                          child: Stack(
                            children: [
                              // Compact Upper-Right Theme Toggle
                              Positioned(
                                top: 10,
                                right: 20,
                                child: const ThemeToggleButton(onGreenHeader: true),
                              ),

                              // Centered Refrigerator Logo and App Name
                              Center(
                                child: Padding(
                                  padding: const EdgeInsets.only(top: 14),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      FridgeWiseLogo(
                                        size: 64,
                                        strokeColor: logoColor,
                                        leafAccentColor: logoColor,
                                      ),
                                      const SizedBox(height: 12),
                                      Text(
                                        'FridgeWise',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: 28,
                                          fontWeight: FontWeight.w700,
                                          color: appNameColor,
                                          letterSpacing: -0.4,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // 2. Floating Warm-Ivory Form Card
                        Container(
                          margin: EdgeInsets.fromLTRB(
                            20,
                            0,
                            20,
                            math.max(20.0, safeBottom + 8),
                          ),
                          decoration: BoxDecoration(
                            color: panelBg,
                            borderRadius: BorderRadius.circular(36),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(
                                  alpha: isDark ? 0.40 : 0.08,
                                ),
                                blurRadius: 22,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 440),
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(24, 30, 24, 30),
                              child: Form(
                                key: _formKey,
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    // 1. Clear "Create Account" Heading
                                    Text(
                                      'Create Account',
                                      style: TextStyle(
                                        fontSize: 26,
                                        fontWeight: FontWeight.w700,
                                        color: textPrimary,
                                        letterSpacing: -0.4,
                                      ),
                                    ),
                                    const SizedBox(height: 22),

                                    // 2. Full Name Input Field
                                    TextFormField(
                                      controller: _nameController,
                                      keyboardType: TextInputType.name,
                                      textInputAction: TextInputAction.next,
                                      style: TextStyle(fontSize: 15, color: textPrimary),
                                      validator: (val) {
                                        if (val == null || val.trim().isEmpty) {
                                          return 'Please enter your name';
                                        }
                                        return null;
                                      },
                                      decoration: _inputDecoration(
                                        hintText: 'Enter your full name',
                                        prefixIcon: Icons.person_outline_rounded,
                                        inputBg: inputBg,
                                        borderColor: inputBorderColor,
                                        focusColor: focusBorderColor,
                                        iconColor: primaryBtnColor,
                                      ),
                                    ),
                                    const SizedBox(height: 16),

                                    // 3. Email Address Input Field
                                    TextFormField(
                                      controller: _emailController,
                                      keyboardType: TextInputType.emailAddress,
                                      textInputAction: TextInputAction.next,
                                      style: TextStyle(fontSize: 15, color: textPrimary),
                                      validator: (val) {
                                        if (val == null || val.trim().isEmpty) {
                                          return 'Please enter your email';
                                        }
                                        if (!val.contains('@')) {
                                          return 'Enter a valid email address';
                                        }
                                        return null;
                                      },
                                      decoration: _inputDecoration(
                                        hintText: 'Enter your email address',
                                        prefixIcon: Icons.mail_outline_rounded,
                                        inputBg: inputBg,
                                        borderColor: inputBorderColor,
                                        focusColor: focusBorderColor,
                                        iconColor: primaryBtnColor,
                                      ),
                                    ),
                                    const SizedBox(height: 16),

                                    // 4. Password Input Field with Independent Show/Hide Toggle
                                    TextFormField(
                                      controller: _passwordController,
                                      obscureText: _obscurePassword,
                                      textInputAction: TextInputAction.next,
                                      style: TextStyle(fontSize: 15, color: textPrimary),
                                      validator: (val) {
                                        if (val == null || val.length < 6) {
                                          return 'Password must be at least 6 characters';
                                        }
                                        return null;
                                      },
                                      decoration: _inputDecoration(
                                        hintText: 'Create a password',
                                        prefixIcon: Icons.lock_outline_rounded,
                                        inputBg: inputBg,
                                        borderColor: inputBorderColor,
                                        focusColor: focusBorderColor,
                                        iconColor: primaryBtnColor,
                                        suffixIcon: IconButton(
                                          icon: Icon(
                                            _obscurePassword
                                                ? Icons.visibility_outlined
                                                : Icons.visibility_off_outlined,
                                            size: 20,
                                            color: const Color(0xFF55695D),
                                          ),
                                          onPressed: () {
                                            setState(() {
                                              _obscurePassword = !_obscurePassword;
                                            });
                                          },
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 16),

                                    // 5. Confirm Password Input Field with Independent Show/Hide Toggle
                                    TextFormField(
                                      controller: _confirmPasswordController,
                                      obscureText: _obscureConfirmPassword,
                                      textInputAction: TextInputAction.done,
                                      style: TextStyle(fontSize: 15, color: textPrimary),
                                      validator: (val) {
                                        if (val == null || val.isEmpty) {
                                          return 'Please confirm your password';
                                        }
                                        if (val != _passwordController.text) {
                                          return 'Passwords do not match';
                                        }
                                        return null;
                                      },
                                      decoration: _inputDecoration(
                                        hintText: 'Re-enter your password',
                                        prefixIcon: Icons.lock_outline_rounded,
                                        inputBg: inputBg,
                                        borderColor: inputBorderColor,
                                        focusColor: focusBorderColor,
                                        iconColor: primaryBtnColor,
                                        suffixIcon: IconButton(
                                          icon: Icon(
                                            _obscureConfirmPassword
                                                ? Icons.visibility_outlined
                                                : Icons.visibility_off_outlined,
                                            size: 20,
                                            color: const Color(0xFF55695D),
                                          ),
                                          onPressed: () {
                                            setState(() {
                                              _obscureConfirmPassword = !_obscureConfirmPassword;
                                            });
                                          },
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 24),

                                    // 6. Prominent Full-Width "Create Account" Button
                                    SizedBox(
                                      height: 52,
                                      child: Material(
                                        color: primaryBtnColor,
                                        borderRadius: BorderRadius.circular(18),
                                        elevation: 0,
                                        child: InkWell(
                                          onTap: _isLoading ? null : _handleRegister,
                                          borderRadius: BorderRadius.circular(18),
                                          child: Center(
                                            child: _isLoading
                                                ? SizedBox(
                                                    width: 20,
                                                    height: 20,
                                                    child: CircularProgressIndicator(
                                                      strokeWidth: 2.2,
                                                      valueColor: AlwaysStoppedAnimation<Color>(
                                                        primaryBtnTextColor,
                                                      ),
                                                    ),
                                                  )
                                                : Text(
                                                    'Create Account',
                                                    style: TextStyle(
                                                      color: primaryBtnTextColor,
                                                      fontSize: 16,
                                                      fontWeight: FontWeight.w700,
                                                      letterSpacing: 0.2,
                                                    ),
                                                  ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 24),

                                    // 7. Bottom Account Prompt
                                    Wrap(
                                      alignment: WrapAlignment.center,
                                      crossAxisAlignment: WrapCrossAlignment.center,
                                      children: [
                                        Text(
                                          'Already have an account? ',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: textSecondary,
                                          ),
                                        ),
                                        GestureDetector(
                                          onTap: () {
                                            if (context.canPop()) {
                                              context.pop();
                                            } else {
                                              context.go('/auth/login');
                                            }
                                          },
                                          child: Text(
                                            'Sign In',
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w700,
                                              color: primaryBtnColor,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
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
              },
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String hintText,
    required IconData prefixIcon,
    required Color inputBg,
    required Color borderColor,
    required Color focusColor,
    required Color iconColor,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: const TextStyle(
        color: Color(0xFF708075),
        fontSize: 15,
        fontWeight: FontWeight.w400,
      ),
      filled: true,
      fillColor: inputBg,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      prefixIcon: Icon(prefixIcon, size: 22, color: iconColor),
      suffixIcon: suffixIcon,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: borderColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: borderColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: focusColor, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFFDC2626)),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFFDC2626), width: 1.5),
      ),
    );
  }
}

/// Subtle, low-contrast botanical line-art details matching the reference background.
class _BotanicalHeaderPainter extends CustomPainter {
  const _BotanicalHeaderPainter({required this.isDark});

  final bool isDark;

  @override
  void paint(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..color = Colors.white.withValues(alpha: isDark ? 0.07 : 0.12)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.3
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final fillPaint = Paint()
      ..color = Colors.white.withValues(alpha: isDark ? 0.025 : 0.04)
      ..style = PaintingStyle.fill;

    // 1. Top-Left Delicate Botanical Branch
    final branchLeft = Path()
      ..moveTo(-15, 20)
      ..quadraticBezierTo(20, 25, 55, 60);
    canvas.drawPath(branchLeft, linePaint);

    // Leaf 1 on Left Branch
    final leftLeaf1 = Path()
      ..moveTo(20, 25)
      ..quadraticBezierTo(18, 10, 32, 8)
      ..quadraticBezierTo(32, 22, 20, 25)
      ..close();
    canvas.drawPath(leftLeaf1, fillPaint);
    canvas.drawPath(leftLeaf1, linePaint);

    // Leaf 2 on Left Branch
    final leftLeaf2 = Path()
      ..moveTo(38, 42)
      ..quadraticBezierTo(50, 32, 58, 40)
      ..quadraticBezierTo(48, 52, 38, 42)
      ..close();
    canvas.drawPath(leftLeaf2, fillPaint);
    canvas.drawPath(leftLeaf2, linePaint);

    // Leaf 3 hanging lower on Left
    final leftLeaf3 = Path()
      ..moveTo(12, 60)
      ..quadraticBezierTo(18, 76, 32, 80)
      ..quadraticBezierTo(22, 90, 12, 60)
      ..close();
    canvas.drawPath(leftLeaf3, fillPaint);
    canvas.drawPath(leftLeaf3, linePaint);

    // 2. Top-Right Subtle Leaf Sprig (near theme toggle)
    final rightLeaf1 = Path()
      ..moveTo(size.width - 25, 65)
      ..quadraticBezierTo(size.width - 15, 52, size.width - 8, 54)
      ..quadraticBezierTo(size.width - 12, 68, size.width - 25, 65)
      ..close();
    canvas.drawPath(rightLeaf1, fillPaint);
    canvas.drawPath(rightLeaf1, linePaint);

    // 3. Mid-Right Leaf & Tomato Outline (Smart Fridge theme detail from reference)
    // Floating Leaf next to tomato
    final midLeaf = Path()
      ..moveTo(size.width - 80, size.height * 0.16)
      ..quadraticBezierTo(size.width - 68, size.height * 0.13, size.width - 60, size.height * 0.15)
      ..quadraticBezierTo(size.width - 66, size.height * 0.19, size.width - 80, size.height * 0.16)
      ..close();
    canvas.drawPath(midLeaf, fillPaint);
    canvas.drawPath(midLeaf, linePaint);

    // Tomato Body Outline
    final tomatoCenter = Offset(size.width - 18, size.height * 0.22);
    final tomatoPath = Path()
      ..addOval(Rect.fromCenter(center: tomatoCenter, width: 72, height: 64));
    canvas.drawPath(tomatoPath, linePaint);

    // Tomato Calyx / Star Sepals & Stem
    final calyxCenter = Offset(size.width - 20, size.height * 0.22 - 30);
    final calyx = Path()
      ..moveTo(calyxCenter.dx, calyxCenter.dy)
      ..lineTo(calyxCenter.dx - 10, calyxCenter.dy - 6)
      ..lineTo(calyxCenter.dx - 3, calyxCenter.dy)
      ..lineTo(calyxCenter.dx - 8, calyxCenter.dy + 8)
      ..lineTo(calyxCenter.dx, calyxCenter.dy + 2)
      ..lineTo(calyxCenter.dx + 8, calyxCenter.dy + 8)
      ..lineTo(calyxCenter.dx + 3, calyxCenter.dy)
      ..lineTo(calyxCenter.dx + 10, calyxCenter.dy - 6)
      ..close();
    canvas.drawPath(calyx, linePaint);

    final stem = Path()
      ..moveTo(calyxCenter.dx, calyxCenter.dy - 2)
      ..quadraticBezierTo(calyxCenter.dx - 2, calyxCenter.dy - 12, calyxCenter.dx + 5, calyxCenter.dy - 16);
    canvas.drawPath(stem, linePaint);

    // 4. Mid-Left Delicate Leaf along edge
    final midLeftLeaf = Path()
      ..moveTo(-5, size.height * 0.30)
      ..quadraticBezierTo(18, size.height * 0.26, 24, size.height * 0.31)
      ..quadraticBezierTo(12, size.height * 0.36, -5, size.height * 0.30)
      ..close();
    canvas.drawPath(midLeftLeaf, fillPaint);
    canvas.drawPath(midLeftLeaf, linePaint);
  }

  @override
  bool shouldRepaint(covariant _BotanicalHeaderPainter oldDelegate) {
    return oldDelegate.isDark != isDark;
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/presentation/components/app_button.dart';
import '../../../../core/presentation/components/app_text_field.dart';
import '../../../../core/theme/app_colors_extension.dart';
import '../../data/auth_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController(text: 'alex@smartfridge.local');
  final _passwordController = TextEditingController(text: 'kitchen123');
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleSignIn() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    await ref.read(authProvider.notifier).signIn(
          _emailController.text.trim(),
          _passwordController.text,
        );

    if (mounted) {
      setState(() => _isLoading = false);
      context.go('/dashboard');
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Brand Icon & Identity
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          color: colors.freshnessContainer,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: colors.freshnessBorder),
                        ),
                        child: Icon(
                          Icons.kitchen_rounded,
                          size: 30,
                          color: colors.freshnessSuccess,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Welcome to Smart Fridge',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: colorScheme.onSurface,
                        letterSpacing: -0.4,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Automated food intake, shelf-life monitoring, and zero-waste cooking suggestions.',
                      style: TextStyle(
                        fontSize: 14,
                        color: colors.textSecondary,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Demo / Simulation Disclaimer Banner
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: colors.surfaceElevated,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: colors.cardBorder),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.info_outline_rounded, size: 16, color: colors.secondaryAction),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Demo Mode: Local simulated authentication active.',
                              style: TextStyle(fontSize: 12, color: colors.textSecondary),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 28),

                    // Email Field
                    AppTextField(
                      label: 'Email Address',
                      controller: _emailController,
                      hintText: 'name@example.com',
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      prefixIcon: Icons.email_outlined,
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) return 'Enter your email address';
                        if (!val.contains('@')) return 'Enter a valid email address';
                        return null;
                      },
                    ),
                    const SizedBox(height: 18),

                    // Password Field
                    AppTextField(
                      label: 'Password',
                      controller: _passwordController,
                      hintText: 'Enter your password',
                      isPassword: true,
                      textInputAction: TextInputAction.done,
                      prefixIcon: Icons.lock_outline_rounded,
                      validator: (val) {
                        if (val == null || val.isEmpty) return 'Enter your password';
                        if (val.length < 6) return 'Password must be at least 6 characters';
                        return null;
                      },
                    ),
                    const SizedBox(height: 8),

                    // Forgot Password Link
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () => context.push('/auth/forgot-password'),
                        child: Text(
                          'Forgot Password?',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: colorScheme.primary,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Sign In Button
                    AppButton(
                      label: 'Sign In',
                      onPressed: _handleSignIn,
                      isLoading: _isLoading,
                      isFullWidth: true,
                    ),
                    const SizedBox(height: 24),

                    // Switch to Register
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Don't have an account? ",
                          style: TextStyle(fontSize: 14, color: colors.textSecondary),
                        ),
                        GestureDetector(
                          onTap: () => context.push('/auth/register'),
                          child: Text(
                            'Create Account',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: colorScheme.primary,
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
      ),
    );
  }
}

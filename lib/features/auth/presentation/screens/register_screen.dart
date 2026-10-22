import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/presentation/components/app_button.dart';
import '../../../../core/presentation/components/app_text_field.dart';
import '../../../../core/theme/app_colors_extension.dart';
import '../../data/auth_provider.dart';

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

    setState(() => _isLoading = true);
    await ref.read(authProvider.notifier).signUp(
          _nameController.text.trim(),
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
      appBar: AppBar(
        title: const Text('Create Account'),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Start Managing Food Smarter',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: colorScheme.onSurface,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Connect your fridge, track fresh produce, and receive timely expiry reminders.',
                      style: TextStyle(fontSize: 14, color: colors.textSecondary, height: 1.4),
                    ),
                    const SizedBox(height: 24),

                    AppTextField(
                      label: 'Full Name',
                      controller: _nameController,
                      hintText: 'e.g., Alex Johnson',
                      textInputAction: TextInputAction.next,
                      prefixIcon: Icons.person_outline_rounded,
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) return 'Please enter your name';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    AppTextField(
                      label: 'Email Address',
                      controller: _emailController,
                      hintText: 'name@example.com',
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      prefixIcon: Icons.email_outlined,
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) return 'Please enter your email';
                        if (!val.contains('@')) return 'Enter a valid email address';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    AppTextField(
                      label: 'Password',
                      controller: _passwordController,
                      hintText: 'Minimum 6 characters',
                      isPassword: true,
                      textInputAction: TextInputAction.next,
                      prefixIcon: Icons.lock_outline_rounded,
                      validator: (val) {
                        if (val == null || val.length < 6) {
                          return 'Password must be at least 6 characters';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    AppTextField(
                      label: 'Confirm Password',
                      controller: _confirmPasswordController,
                      hintText: 'Re-enter your password',
                      isPassword: true,
                      textInputAction: TextInputAction.done,
                      prefixIcon: Icons.lock_clock_outlined,
                      validator: (val) {
                        if (val != _passwordController.text) {
                          return 'Passwords do not match';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 28),

                    AppButton(
                      label: 'Create Account',
                      onPressed: _handleRegister,
                      isLoading: _isLoading,
                      isFullWidth: true,
                    ),
                    const SizedBox(height: 20),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Already have an account? ',
                          style: TextStyle(fontSize: 14, color: colors.textSecondary),
                        ),
                        GestureDetector(
                          onTap: () => context.pop(),
                          child: Text(
                            'Sign In',
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

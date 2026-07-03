import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'auth_provider.dart';
import 'widgets/auth_field.dart';
import '../../../core/utils/validators.dart';
import '../../../core/utils/extensions.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/widgets/glass_components.dart';
import '../../../router/app_router.dart';

class SignupPage extends ConsumerStatefulWidget {
  const SignupPage({super.key});

  @override
  ConsumerState<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends ConsumerState<SignupPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _onSignup() async {
    if (!_formKey.currentState!.validate()) return;
    await ref.read(authProvider.notifier).signup(
      _nameController.text.trim(),
      _emailController.text.trim(),
      _passwordController.text,
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(authProvider);
    final cs = context.colorScheme;
    final a = context.aurora;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: ResponsiveUtils.isSmall(context) ? 24 : 48,
            ),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 88,
                    height: 88,
                    decoration: BoxDecoration(
                      gradient: a.primaryAurora,
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: [
                        BoxShadow(
                          color: a.electricBlue.withAlpha(50),
                          blurRadius: 24,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.cloud_rounded,
                      color: Colors.white,
                      size: 44,
                    ),
                  ).animate().fadeIn(duration: 500.ms).scaleXY(
                    begin: 0.8,
                    end: 1.0,
                    duration: 500.ms,
                  ),
                  const SizedBox(height: 28),
                  Text(
                    'Create Account',
                    style: context.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                    ),
                  ).animate().fadeIn(duration: 400.ms, delay: 100.ms),
                  const SizedBox(height: 8),
                  Text(
                    'Start hosting your images for free',
                    style: TextStyle(
                      color: cs.onSurfaceVariant,
                      fontSize: 15,
                    ),
                  ).animate().fadeIn(duration: 400.ms, delay: 200.ms),
                  const SizedBox(height: 40),
                  _AnimatedField(
                    delay: 200,
                    child: AuthField(
                      label: 'Full Name',
                      hint: 'Your name',
                      controller: _nameController,
                      validator: Validators.name,
                      textInputAction: TextInputAction.next,
                      prefixIcon: const Icon(Icons.person_outlined),
                    ),
                  ),
                  const SizedBox(height: 18),
                  _AnimatedField(
                    delay: 250,
                    child: AuthField(
                      label: 'Email Address',
                      hint: 'you@example.com',
                      controller: _emailController,
                      validator: Validators.email,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      prefixIcon: const Icon(Icons.email_outlined),
                    ),
                  ),
                  const SizedBox(height: 18),
                  _AnimatedField(
                    delay: 300,
                    child: AuthField(
                      label: 'Password',
                      hint: 'Min 6 characters',
                      controller: _passwordController,
                      validator: Validators.password,
                      obscureText: _obscurePassword,
                      textInputAction: TextInputAction.next,
                      prefixIcon: const Icon(Icons.lock_outlined),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                        ),
                        onPressed: () =>
                            setState(() => _obscurePassword = !_obscurePassword),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  _AnimatedField(
                    delay: 350,
                    child: AuthField(
                      label: 'Confirm Password',
                      hint: 'Confirm your password',
                      controller: _confirmController,
                      validator: (v) =>
                          Validators.confirmPassword(v, _passwordController.text),
                      obscureText: _obscureConfirm,
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) => _onSignup(),
                      prefixIcon: const Icon(Icons.lock_outlined),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureConfirm
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                        ),
                        onPressed: () =>
                            setState(() => _obscureConfirm = !_obscureConfirm),
                      ),
                    ),
                  ),
                  if (state.error != null) ...[
                    const SizedBox(height: 16),
                    GlassCard(
                      gradient: cs.error.withAlpha(20),
                      borderColor: cs.error.withAlpha(50),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      child: Row(
                        children: [
                          Icon(Icons.error_outline, color: cs.error, size: 20),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              state.error!.replaceAll('AppException: ', ''),
                              style: TextStyle(color: cs.error, fontSize: 13),
                            ),
                          ),
                        ],
                      ),
                    ).animate().fadeIn(duration: 300.ms),
                  ],
                  const SizedBox(height: 24),
                  GlassButton(
                    label: 'Create Account',
                    icon: Icons.person_add_rounded,
                    onPressed:
                        state.status == AuthStatus.loading ? null : _onSignup,
                    loading: state.status == AuthStatus.loading,
                  ).animate().fadeIn(duration: 400.ms, delay: 400.ms).slideY(
                    begin: 0.02,
                    end: 0,
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Already have an account? ',
                        style: TextStyle(color: cs.onSurfaceVariant),
                      ),
                      GestureDetector(
                        onTap: () => context.go(Routes.login),
                        child: ShaderMask(
                          shaderCallback: (bounds) =>
                              a.accentGlow.createShader(bounds),
                          child: Text(
                            'Sign In',
                            style: TextStyle(
                              color: cs.primary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ).animate().fadeIn(duration: 400.ms, delay: 450.ms),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AnimatedField extends StatelessWidget {
  final int delay;
  final Widget child;

  const _AnimatedField({required this.delay, required this.child});

  @override
  Widget build(BuildContext context) {
    return child.animate().fadeIn(
      duration: 400.ms,
      delay: delay.ms,
    ).slideX(begin: -0.02, end: 0);
  }
}
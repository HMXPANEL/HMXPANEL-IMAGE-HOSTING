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
import '../../../core/constants/app_constants.dart';
import '../../../router/app_router.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  late AnimationController _shakeCtrl;

  @override
  void initState() {
    super.initState();
    _shakeCtrl = AnimationController(vsync: this, duration: 500.ms);
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _shakeCtrl.dispose();
    super.dispose();
  }

  Future<void> _onLogin() async {
    if (!_formKey.currentState!.validate()) return;
    await ref.read(authProvider.notifier).login(
      _emailController.text.trim(),
      _passwordController.text,
    );
    if (ref.read(authProvider).error != null) {
      _shakeCtrl.reset();
      _shakeCtrl.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(authProvider);
    final cs = context.colorScheme;
    final a = context.aurora;
    final rv = context.rv;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: context.isSmall ? AppSpacing.xl - 8 : AppSpacing.xxl,
            ),
            child: AnimatedBuilder(
              animation: _shakeCtrl,
              builder: (_, child) => Transform.translate(
                offset: Offset(
                  _shakeCtrl.value > 0
                      ? (DateTime.now().millisecondsSinceEpoch % 10 < 5 ? 8.0 : -8.0) *
                          _shakeCtrl.value
                      : 0,
                  0,
                ),
                child: child,
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
                      'Welcome Back',
                      style: context.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                      ),
                    ).animate().fadeIn(duration: 400.ms, delay: 100.ms),
                    const SizedBox(height: 8),
                    Text(
                      'Sign in to continue to ${AppConstants.appName}',
                      style: TextStyle(
                        color: cs.onSurfaceVariant,
                        fontSize: 15,
                      ),
                    ).animate().fadeIn(duration: 400.ms, delay: 200.ms),
                    const SizedBox(height: 40),
                    AuthField(
                      label: 'Email Address',
                      hint: 'you@example.com',
                      controller: _emailController,
                      validator: Validators.email,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      prefixIcon: const Icon(Icons.email_outlined),
                    ).animate().fadeIn(duration: 400.ms, delay: 250.ms).slideX(begin: -0.02, end: 0),
                    const SizedBox(height: 18),
                    AuthField(
                      label: 'Password',
                      hint: 'Enter your password',
                      controller: _passwordController,
                      validator: Validators.password,
                      obscureText: _obscurePassword,
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) => _onLogin(),
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
                    ).animate().fadeIn(duration: 400.ms, delay: 300.ms).slideX(begin: -0.02, end: 0),
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
                      ).animate().fadeIn(duration: 300.ms).shake(duration: 400.ms),
                    ],
                    const SizedBox(height: 24),
                    GlassButton(
                      label: 'Sign In',
                      icon: Icons.arrow_forward_rounded,
                      onPressed:
                          state.status == AuthStatus.loading ? null : _onLogin,
                      loading: state.status == AuthStatus.loading,
                    ).animate().fadeIn(duration: 400.ms, delay: 350.ms).slideY(begin: 0.02, end: 0),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Don't have an account? ",
                          style: TextStyle(color: cs.onSurfaceVariant),
                        ),
                        GestureDetector(
                          onTap: () => context.go(Routes.signup),
                          child: ShaderMask(
                            shaderCallback: (bounds) => a.accentGlow.createShader(bounds),
                            child: Text(
                              'Sign Up',
                              style: TextStyle(
                                color: cs.primary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ).animate().fadeIn(duration: 400.ms, delay: 400.ms),
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
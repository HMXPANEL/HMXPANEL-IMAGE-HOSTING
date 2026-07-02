import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../features/auth/presentation/login_page.dart';
import '../features/auth/presentation/signup_page.dart';
import '../features/auth/presentation/auth_provider.dart';
import '../features/home/presentation/home_page.dart';

class Routes {
  Routes._();
  static const login = '/login';
  static const signup = '/signup';
  static const home = '/home';
}

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);

  return GoRouter(
    initialLocation: Routes.login,
    debugLogDiagnostics: false,
    redirect: (context, state) {
      final isLoggedIn = authState.status == AuthStatus.authenticated;
      final isAuthRoute = state.matchedLocation == Routes.login ||
          state.matchedLocation == Routes.signup;

      if (!isLoggedIn && !isAuthRoute) return Routes.login;
      if (isLoggedIn && isAuthRoute) return Routes.home;
      return null;
    },
    routes: [
      GoRoute(
        path: Routes.login,
        name: 'login',
        builder: (_, __) => const LoginPage(),
      ),
      GoRoute(
        path: Routes.signup,
        name: 'signup',
        builder: (_, __) => const SignupPage(),
      ),
      GoRoute(
        path: Routes.home,
        name: 'home',
        builder: (_, __) => const HomePage(),
      ),
    ],
    errorBuilder: (_, __) => const Scaffold(
      body: Center(child: Text('Page not found')),
    ),
  );
});

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/user_model.dart';
import '../data/auth_repository.dart';

enum AuthStatus { uninitialized, authenticated, unauthenticated, loading, error }

class AuthState {
  final AuthStatus status;
  final AppUser? user;
  final String? error;

  const AuthState({
    this.status = AuthStatus.uninitialized,
    this.user,
    this.error,
  });

  AuthState copyWith({AuthStatus? status, AppUser? user, String? error}) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      error: error,
    );
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final repository = ref.read(authRepositoryProvider);
  return AuthNotifier(repository);
});

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _repository;

  AuthNotifier(this._repository) : super(const AuthState()) {
    _repository.authStateChanges.listen(_onAuthStateChanged);
  }

  void _onAuthStateChanged(AppUser? user) {
    if (user != null) {
      state = state.copyWith(
        status: AuthStatus.authenticated,
        user: user,
        error: null,
      );
    } else {
      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        user: null,
        error: null,
      );
    }
  }

  Future<void> login(String email, String password) async {
    state = state.copyWith(status: AuthStatus.loading, error: null);
    try {
      await _repository.signInWithEmailPassword(email, password);
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        error: e.toString(),
      );
    }
  }

  Future<void> signup(String name, String email, String password) async {
    state = state.copyWith(status: AuthStatus.loading, error: null);
    try {
      await _repository.createAccount(name, email, password);
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        error: e.toString(),
      );
    }
  }

  Future<void> logout() async {
    await _repository.signOut();
    state = const AuthState(status: AuthStatus.unauthenticated);
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

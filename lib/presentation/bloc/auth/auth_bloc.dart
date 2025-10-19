import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'auth_event.dart';
import 'auth_state.dart';

/// 🌟 WORLD-CLASS AUTH BLOC
///
/// Features:
/// - Email/Password authentication
/// - Social login
/// - User state management
/// - Error handling
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final FirebaseAuth _firebaseAuth;

  AuthBloc({required FirebaseAuth firebaseAuth})
    : _firebaseAuth = firebaseAuth,
      super(AuthInitial()) {
    on<AuthLoginRequested>(_onLoginRequested);
    on<AuthGoogleLoginRequested>(_onGoogleLoginRequested);
    on<AuthAppleLoginRequested>(_onAppleLoginRequested);
    on<AuthLogoutRequested>(_onLogoutRequested);
    on<AuthCheckRequested>(_onAuthCheckRequested);
  }

  Future<void> _onLoginRequested(
    AuthLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    try {
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: event.email,
        password: event.password,
      );

      if (credential.user != null) {
        emit(AuthSuccess(user: credential.user!));
      } else {
        emit(AuthFailure(message: 'Login failed'));
      }
    } on FirebaseAuthException catch (e) {
      emit(AuthFailure(message: e.message ?? 'Login failed'));
    } catch (e) {
      emit(AuthFailure(message: 'An unexpected error occurred'));
    }
  }

  Future<void> _onGoogleLoginRequested(
    AuthGoogleLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    try {
      // TODO: Implement Google Sign-In
      emit(AuthFailure(message: 'Google Sign-In not implemented yet'));
    } catch (e) {
      emit(AuthFailure(message: 'Google Sign-In failed'));
    }
  }

  Future<void> _onAppleLoginRequested(
    AuthAppleLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    try {
      // TODO: Implement Apple Sign-In
      emit(AuthFailure(message: 'Apple Sign-In not implemented yet'));
    } catch (e) {
      emit(AuthFailure(message: 'Apple Sign-In failed'));
    }
  }

  Future<void> _onLogoutRequested(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    try {
      await _firebaseAuth.signOut();
      emit(AuthInitial());
    } catch (e) {
      emit(AuthFailure(message: 'Logout failed'));
    }
  }

  Future<void> _onAuthCheckRequested(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    final user = _firebaseAuth.currentUser;

    if (user != null) {
      emit(AuthSuccess(user: user));
    } else {
      emit(AuthInitial());
    }
  }
}

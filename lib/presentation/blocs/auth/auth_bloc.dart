import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../../domain/entities/user_entity.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  AuthBloc() : super(AuthInitial()) {
    on<AuthCheckRequested>(_onAuthCheckRequested);
    on<AuthLoginRequested>(_onAuthLoginRequested);
    on<AuthRegisterRequested>(_onAuthRegisterRequested);
    on<AuthLogoutRequested>(_onAuthLogoutRequested);
    on<AuthGoogleSignInRequested>(_onAuthGoogleSignInRequested);
    on<AuthResetPasswordRequested>(_onAuthResetPasswordRequested);
  }

  Future<void> _onAuthCheckRequested(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final user = _firebaseAuth.currentUser;
      if (user != null) {
        emit(await _createAuthenticatedState(user));
      } else {
        emit(AuthUnauthenticated());
      }
    } catch (e) {
      emit(AuthUnauthenticated());
    }
  }

  Future<void> _onAuthLoginRequested(
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
        emit(await _createAuthenticatedState(credential.user!));
      } else {
        emit(AuthError('Login failed'));
      }
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onAuthRegisterRequested(
    AuthRegisterRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: event.email,
        password: event.password,
      );
      if (credential.user != null) {
        await credential.user!.updateDisplayName(event.displayName);
        emit(await _createAuthenticatedState(credential.user!));
      } else {
        emit(AuthError('Registration failed'));
      }
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onAuthLogoutRequested(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      await _firebaseAuth.signOut();
      emit(AuthUnauthenticated());
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onAuthGoogleSignInRequested(
    AuthGoogleSignInRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn();
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

      if (googleUser == null) {
        emit(AuthUnauthenticated());
        return;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential = await _firebaseAuth
          .signInWithCredential(credential);

      if (userCredential.user != null) {
        emit(await _createAuthenticatedState(userCredential.user!));
      } else {
        emit(AuthError('Google Sign In failed'));
      }
    } catch (e) {
      emit(AuthError('Google Sign In error: ${e.toString()}'));
    }
  }

  Future<void> _onAuthResetPasswordRequested(
    AuthResetPasswordRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: event.email);
      emit(AuthUnauthenticated());
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  UserEntity _convertToUserEntity(User firebaseUser) {
    return UserEntity(
      uid: firebaseUser.uid,
      email: firebaseUser.email ?? '',
      displayName: firebaseUser.displayName,
      photoUrl: firebaseUser.photoURL,
      phoneNumber: firebaseUser.phoneNumber,
      isEmailVerified: firebaseUser.emailVerified,
      createdAt: firebaseUser.metadata.creationTime ?? DateTime.now(),
      trustScore: 5.0, // Default trust score
    );
  }

  Future<AuthAuthenticated> _createAuthenticatedState(User firebaseUser) async {
    final baseUser = _convertToUserEntity(firebaseUser);
    Map<String, dynamic>? profileData;

    try {
      final doc = await _firestore
          .collection('users')
          .doc(firebaseUser.uid)
          .get();
      if (doc.exists) {
        profileData = doc.data();
      }
    } catch (_) {
      profileData = null;
    }

    final enrichedUser = profileData == null
        ? baseUser
        : baseUser.copyWith(
            displayName: profileData['displayName'] ?? baseUser.displayName,
            photoUrl: profileData['photoUrl'] ?? baseUser.photoUrl,
            phoneNumber: profileData['phoneNumber'] ?? baseUser.phoneNumber,
            bio: profileData['bio'] ?? baseUser.bio,
            address: profileData['address'] ?? baseUser.address,
            city: profileData['city'] ?? baseUser.city,
            location: profileData['location'] ?? baseUser.location,
            latitude:
                (profileData['latitude'] as num?)?.toDouble() ??
                baseUser.latitude,
            longitude:
                (profileData['longitude'] as num?)?.toDouble() ??
                baseUser.longitude,
            updatedAt: profileData['updatedAt'] is Timestamp
                ? (profileData['updatedAt'] as Timestamp).toDate()
                : baseUser.updatedAt,
            trustScore:
                (profileData['trustScore'] as num?)?.toDouble() ??
                baseUser.trustScore,
            stats:
                (profileData['stats'] as Map?)?.cast<String, dynamic>() ??
                baseUser.stats,
            social:
                (profileData['social'] as Map?)?.cast<String, dynamic>() ??
                baseUser.social,
          );

    final stats = profileData?['stats'] as Map?;
    final social = profileData?['social'] as Map?;

    return AuthAuthenticated(
      enrichedUser,
      profileData: profileData,
      stats: stats?.cast<String, dynamic>(),
      social: social?.cast<String, dynamic>(),
    );
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:injectable/injectable.dart';
import '../../core/errors/exceptions.dart';
import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> signInWithEmailAndPassword({
    required String email,
    required String password,
  });

  Future<UserModel> registerWithEmailAndPassword({
    required String email,
    required String password,
    required String displayName,
  });

  Future<void> signOut();
  Future<UserModel?> getCurrentUser();
  Future<bool> isSignedIn();
  Future<void> sendEmailVerification();
  
  Future<UserModel> signInWithGoogle();
  Future<String> signInWithPhone(String phoneNumber);
  Future<UserModel> verifyOtp({required String verificationId, required String smsCode});
  Future<void> resetPassword(String email);
}

@LazySingleton(as: AuthRemoteDataSource)
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final FirebaseAuth firebaseAuth;
  final FirebaseFirestore firestore;
  final GoogleSignIn googleSignIn;

  AuthRemoteDataSourceImpl({
    required this.firebaseAuth,
    required this.firestore,
    required this.googleSignIn,
  });

  @override
  Future<UserModel> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user == null) {
        throw const AuthException('User not found');
      }

      // Try to load profile from Firestore
      try {
        final doc = await firestore.collection('users').doc(userCredential.user!.uid).get();
        if (doc.exists) {
          return UserModel.fromFirestore(doc);
        } else {
          // Profile doesn't exist in Firestore, create it
          print('📝 Creating Firestore profile for existing user: ${userCredential.user!.uid}');
          final userModel = UserModel.fromFirebaseUser(userCredential.user!);
          await firestore
              .collection('users')
              .doc(userCredential.user!.uid)
              .set(userModel.toFirestore());
          return userModel;
        }
      } catch (e) {
        // If Firestore operation fails, still return Firebase Auth user
        print('⚠️ Failed to load/create Firestore profile: $e');
        return UserModel.fromFirebaseUser(userCredential.user!);
      }
    } on FirebaseAuthException catch (e) {
      throw _handleFirebaseAuthException(e);
    } catch (e) {
      throw AuthException(e.toString());
    }
  }

  @override
  Future<UserModel> registerWithEmailAndPassword({
    required String email,
    required String password,
    required String displayName,
  }) async {
    try {
      final userCredential = await firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user == null) {
        throw const AuthException('Failed to create user');
      }

      // Update display name
      await userCredential.user!.updateDisplayName(displayName);
      await userCredential.user!.reload();
      final updatedUser = firebaseAuth.currentUser!;

      // Create user document in Firestore
      final userModel = UserModel.fromFirebaseUser(updatedUser);
      await firestore.collection('users').doc(updatedUser.uid).set(
            userModel.toFirestore(),
          );

      return userModel;
    } on FirebaseAuthException catch (e) {
      throw _handleFirebaseAuthException(e);
    } catch (e) {
      throw AuthException(e.toString());
    }
  }

  @override
  Future<void> signOut() async {
    try {
      // Sign out from Google if signed in
      final googleCurrentUser = await googleSignIn.isSignedIn();
      if (googleCurrentUser) {
        await googleSignIn.signOut();
      }
      // Sign out from Firebase
      await firebaseAuth.signOut();
    } catch (e) {
      throw AuthException(e.toString());
    }
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    try {
      final user = firebaseAuth.currentUser;
      if (user == null) return null;
      
      // Try to load profile from Firestore
      try {
        final doc = await firestore.collection('users').doc(user.uid).get();
        if (doc.exists) {
          return UserModel.fromFirestore(doc);
        } else {
          // Profile doesn't exist in Firestore, create it
          print('📝 Creating Firestore profile for current user: ${user.uid}');
          final userModel = UserModel.fromFirebaseUser(user);
          await firestore
              .collection('users')
              .doc(user.uid)
              .set(userModel.toFirestore());
          return userModel;
        }
      } catch (e) {
        // If Firestore operation fails, still return Firebase Auth user
        print('⚠️ Failed to load/create Firestore profile: $e');
        return UserModel.fromFirebaseUser(user);
      }
    } catch (e) {
      throw AuthException(e.toString());
    }
  }

  @override
  Future<bool> isSignedIn() async {
    try {
      return firebaseAuth.currentUser != null;
    } catch (e) {
      throw AuthException(e.toString());
    }
  }

  @override
  Future<void> sendEmailVerification() async {
    try {
      final user = firebaseAuth.currentUser;
      if (user == null) throw const AuthException('No user signed in');
      await user.sendEmailVerification();
    } catch (e) {
      throw AuthException(e.toString());
    }
  }

  @override
  Future<UserModel> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      if (googleUser == null) {
        throw const AuthException('Google sign in aborted');
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential =
          await firebaseAuth.signInWithCredential(credential);

      if (userCredential.user == null) {
        throw const AuthException('Failed to sign in with Google');
      }

      // Create or update user in Firestore
      final userModel = UserModel.fromFirebaseUser(userCredential.user!);
      await firestore
          .collection('users')
          .doc(userCredential.user!.uid)
          .set(userModel.toFirestore(), SetOptions(merge: true));

      return userModel;
    } on FirebaseAuthException catch (e) {
      throw _handleFirebaseAuthException(e);
    } catch (e) {
      throw AuthException(e.toString());
    }
  }

  @override
  Future<String> signInWithPhone(String phoneNumber) async {
    try {
      String verificationId = '';
      await firebaseAuth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {
          // Auto-verification (Android only)
          await firebaseAuth.signInWithCredential(credential);
        },
        verificationFailed: (FirebaseAuthException e) {
          throw _handleFirebaseAuthException(e);
        },
        codeSent: (String verId, int? resendToken) {
          verificationId = verId;
        },
        codeAutoRetrievalTimeout: (String verId) {
          verificationId = verId;
        },
        timeout: const Duration(seconds: 60),
      );

      // Wait a bit to ensure codeSent callback is triggered
      await Future.delayed(const Duration(seconds: 1));
      
      if (verificationId.isEmpty) {
        throw const AuthException('Failed to send verification code');
      }

      return verificationId;
    } on FirebaseAuthException catch (e) {
      throw _handleFirebaseAuthException(e);
    } catch (e) {
      throw AuthException(e.toString());
    }
  }

  @override
  Future<UserModel> verifyOtp({
    required String verificationId,
    required String smsCode,
  }) async {
    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );

      final userCredential =
          await firebaseAuth.signInWithCredential(credential);

      if (userCredential.user == null) {
        throw const AuthException('Failed to verify OTP');
      }

      // Create or update user in Firestore
      final userModel = UserModel.fromFirebaseUser(userCredential.user!);
      await firestore
          .collection('users')
          .doc(userCredential.user!.uid)
          .set(userModel.toFirestore(), SetOptions(merge: true));

      return userModel;
    } on FirebaseAuthException catch (e) {
      throw _handleFirebaseAuthException(e);
    } catch (e) {
      throw AuthException(e.toString());
    }
  }

  @override
  Future<void> resetPassword(String email) async {
    try {
      await firebaseAuth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw _handleFirebaseAuthException(e);
    } catch (e) {
      throw AuthException(e.toString());
    }
  }

  AuthException _handleFirebaseAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return const UserNotFoundException();
      case 'wrong-password':
        return const InvalidCredentialsException();
      case 'email-already-in-use':
        return const EmailAlreadyInUseException();
      case 'weak-password':
        return const WeakPasswordException();
      case 'invalid-email':
        return const AuthException('Invalid email address');
      case 'user-disabled':
        return const AuthException('User account has been disabled');
      default:
        return AuthException(e.message ?? 'Authentication failed');
    }
  }
}

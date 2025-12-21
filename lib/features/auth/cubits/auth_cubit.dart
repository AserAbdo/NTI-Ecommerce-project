import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  AuthCubit() : super(AuthInitial());

  Future<void> checkAuthStatus() async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser != null) {
        print('🔍 Checking auth status for user: ${currentUser.uid}');

        final userDoc = await _firestore
            .collection('users')
            .doc(currentUser.uid)
            .get();

        if (userDoc.exists && userDoc.data() != null) {
          final user = UserModel.fromJson(userDoc.data()!);
          print('✅ User authenticated: ${user.email}');
          emit(AuthAuthenticated(user));
        } else {
          print('⚠️ User exists in Auth but not in Firestore');
          emit(AuthUnauthenticated());
        }
      } else {
        print('ℹ️ No authenticated user found');
        emit(AuthUnauthenticated());
      }
    } catch (e) {
      print('❌ Error checking auth status: $e');
      emit(AuthUnauthenticated());
    }
  }

  Future<void> signUp({
    required String name,
    required String email,
    required String phone,
    String? address,
    required String password,
  }) async {
    try {
      emit(AuthLoading());
      print('📝 Starting signup process for: $email');

      // Step 1: Create user in Firebase Authentication
      print('🔐 Creating user in Firebase Auth...');
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user == null) {
        throw Exception('Failed to create user in Firebase Auth');
      }

      print('✅ User created in Firebase Auth: ${userCredential.user!.uid}');

      // Step 2: Create user model
      final user = UserModel(
        id: userCredential.user!.uid,
        name: name,
        email: email,
        phone: phone,
        address: address,
      );

      print('📄 User model created: ${user.toJson()}');

      // Step 3: Save user to Firestore
      print('💾 Saving user to Firestore...');

      await _firestore
          .collection('users')
          .doc(user.id)
          .set(user.toJson(), SetOptions(merge: false));

      print('✅ User saved to Firestore successfully');

      emit(AuthAuthenticated(user));
      print('🎉 Signup completed successfully for: $email');
    } on FirebaseAuthException catch (e) {
      print('❌ Firebase Auth error during signup: ${e.code} - ${e.message}');

      // If auth succeeded but Firestore failed, delete the auth user
      if (_auth.currentUser != null) {
        print('🧹 Cleaning up auth user due to Firestore error...');
        try {
          await _auth.currentUser!.delete();
        } catch (deleteError) {
          print('⚠️ Failed to delete auth user: $deleteError');
        }
      }

      emit(AuthError(_getAuthErrorMessage(e.code)));
    } on FirebaseException catch (e) {
      print('❌ Firestore error during signup: ${e.code} - ${e.message}');
      print('📋 Full error: $e');

      // Clean up auth user since Firestore failed
      if (_auth.currentUser != null) {
        print('🧹 Cleaning up auth user due to Firestore error...');
        try {
          await _auth.currentUser!.delete();
        } catch (deleteError) {
          print('⚠️ Failed to delete auth user: $deleteError');
        }
      }

      emit(AuthError(_getFirestoreErrorMessage(e.code)));
    } catch (e) {
      print('❌ Unexpected error during signup: $e');
      print('📋 Error type: ${e.runtimeType}');

      // If auth succeeded but Firestore failed, delete the auth user
      if (_auth.currentUser != null) {
        print('🧹 Cleaning up auth user due to unexpected error...');
        try {
          await _auth.currentUser!.delete();
        } catch (deleteError) {
          print('⚠️ Failed to delete auth user: $deleteError');
        }
      }

      emit(AuthError('Failed to save user data. Please try again.'));
    }
  }

  Future<void> login({required String email, required String password}) async {
    try {
      emit(AuthLoading());
      print('🔑 Starting login process for: $email');

      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      print('✅ User authenticated: ${userCredential.user!.uid}');

      final userDoc = await _firestore
          .collection('users')
          .doc(userCredential.user!.uid)
          .get();

      if (userDoc.exists && userDoc.data() != null) {
        final user = UserModel.fromJson(userDoc.data()!);
        print('✅ User data retrieved from Firestore');
        emit(AuthAuthenticated(user));
      } else {
        print('❌ User data not found in Firestore');
        emit(AuthError('User data not found. Please contact support.'));
      }
    } on FirebaseAuthException catch (e) {
      print('❌ Firebase Auth error during login: ${e.code} - ${e.message}');
      emit(AuthError(_getAuthErrorMessage(e.code)));
    } catch (e) {
      print('❌ Unexpected error during login: $e');
      emit(AuthError('An error occurred. Please try again.'));
    }
  }

  Future<void> logout() async {
    print('👋 Logging out user');
    await _auth.signOut();
    emit(AuthUnauthenticated());
  }

  String _getAuthErrorMessage(String code) {
    switch (code) {
      case 'user-not-found':
        return 'No user found with this email.';
      case 'wrong-password':
        return 'Wrong password.';
      case 'invalid-email':
        return 'Invalid email address.';
      case 'email-already-in-use':
        return 'Email already registered.';
      case 'weak-password':
        return 'Password is too weak.';
      default:
        return 'Authentication failed. Please try again.';
    }
  }

  String _getFirestoreErrorMessage(String code) {
    switch (code) {
      case 'permission-denied':
        return 'Permission denied. Please check Firestore security rules.';
      case 'unavailable':
        return 'Firestore service is currently unavailable. Please try again.';
      case 'not-found':
        return 'Database not found.';
      case 'already-exists':
        return 'User already exists.';
      default:
        return 'Database error: $code. Please try again.';
    }
  }
}

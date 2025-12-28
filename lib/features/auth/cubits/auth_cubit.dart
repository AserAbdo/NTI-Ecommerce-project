import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';
import 'auth_state.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../data/di/service_locator.dart';
import '../../../services/local_notification_service.dart';

/// AuthCubit using Repository Pattern with Dependency Injection
/// All Firebase operations are delegated to AuthRepository
class AuthCubit extends Cubit<AuthState> {
  final AuthRepository _authRepository;

  AuthCubit({AuthRepository? authRepository})
    : _authRepository =
          authRepository ?? ServiceLocator.instance.authRepository,
      super(AuthInitial());

  /// Check if user is already authenticated
  Future<void> checkAuthStatus() async {
    try {
      final user = await _authRepository.getCurrentUser();

      if (user != null) {
        if (kDebugMode) debugPrint('✅ User authenticated: ${user.email}');
        emit(AuthAuthenticated(user));
      } else {
        if (kDebugMode) debugPrint('ℹ️ No authenticated user found');
        emit(AuthUnauthenticated());
      }
    } catch (e) {
      if (kDebugMode) debugPrint('❌ Error checking auth status: $e');
      emit(AuthUnauthenticated());
    }
  }

  /// Register a new user
  Future<void> signUp({
    required String name,
    required String email,
    required String phone,
    required String address,
    required String password,
  }) async {
    try {
      emit(AuthLoading());
      if (kDebugMode) debugPrint('📝 Starting signup process for: $email');

      // Repository handles validation, Firebase Auth, Firestore, and coupon
      final user = await _authRepository.signUp(
        name: name,
        email: email,
        phone: phone,
        address: address,
        password: password,
      );

      // Show welcome notification about coupon
      await LocalNotificationService.showWelcomeCouponNotification();
      if (kDebugMode) debugPrint('🔔 Welcome notification sent');

      emit(AuthAuthenticated(user));
      if (kDebugMode)
        debugPrint('🎉 Signup completed successfully for: $email');
    } on ValidationException catch (e) {
      // Validation errors from repository
      if (kDebugMode) debugPrint('⚠️ Validation error: ${e.message}');
      emit(AuthError(e.message));
    } on FirebaseAuthException catch (e) {
      if (kDebugMode) debugPrint('❌ Firebase Auth error: ${e.code}');
      emit(AuthError(_getAuthErrorMessage(e.code)));
    } on FirebaseException catch (e) {
      if (kDebugMode) debugPrint('❌ Firebase error: ${e.code}');
      emit(AuthError(_getFirestoreErrorMessage(e.code)));
    } catch (e) {
      if (kDebugMode) debugPrint('❌ Unexpected error during signup: $e');
      emit(AuthError('Failed to create account. Please try again.'));
    }
  }

  /// Login with email and password
  Future<void> login({required String email, required String password}) async {
    try {
      emit(AuthLoading());
      if (kDebugMode) debugPrint('🔑 Starting login process for: $email');

      final user = await _authRepository.signIn(
        email: email,
        password: password,
      );

      if (kDebugMode) debugPrint('✅ Login successful for: ${user.email}');
      emit(AuthAuthenticated(user));
    } on ValidationException catch (e) {
      if (kDebugMode) debugPrint('⚠️ Validation error: ${e.message}');
      emit(AuthError(e.message));
    } on FirebaseAuthException catch (e) {
      if (kDebugMode) debugPrint('❌ Firebase Auth error: ${e.code}');
      emit(AuthError(_getAuthErrorMessage(e.code)));
    } catch (e) {
      if (kDebugMode) debugPrint('❌ Unexpected error during login: $e');
      emit(AuthError('An error occurred. Please try again.'));
    }
  }

  /// Logout current user
  Future<void> logout() async {
    try {
      if (kDebugMode) debugPrint('👋 Logging out user');
      await _authRepository.signOut();
      emit(AuthUnauthenticated());
    } catch (e) {
      if (kDebugMode) debugPrint('❌ Error during logout: $e');
      emit(AuthUnauthenticated());
    }
  }

  /// Get cached user for offline mode
  Future<UserModel?> getCachedUser() async {
    return await _authRepository.getCachedUser();
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
      case 'invalid-credential':
        return 'Invalid email or password.';
      default:
        return 'Authentication failed. Please try again.';
    }
  }

  String _getFirestoreErrorMessage(String code) {
    switch (code) {
      case 'permission-denied':
        return 'Permission denied. Please try again later.';
      case 'unavailable':
        return 'Service temporarily unavailable. Please try again.';
      case 'not-found':
        return 'User data not found.';
      case 'already-exists':
        return 'User already exists.';
      default:
        return 'An error occurred. Please try again.';
    }
  }
}

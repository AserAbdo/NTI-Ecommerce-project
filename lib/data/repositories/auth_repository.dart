import '../datasources/local_data_source.dart';
import '../datasources/remote_data_source.dart';
import '../../features/auth/models/user_model.dart';
import '../../features/coupons/models/coupon_model.dart';
import '../../core/utils/validators.dart';

/// Repository for Authentication - handles auth flow with validation and caching
class AuthRepository {
  final RemoteDataSource _remoteDataSource;
  final LocalDataSource _localDataSource;

  AuthRepository({
    required RemoteDataSource remoteDataSource,
    required LocalDataSource localDataSource,
  }) : _remoteDataSource = remoteDataSource,
       _localDataSource = localDataSource;

  /// Sign up with validation
  Future<UserModel> signUp({
    required String name,
    required String email,
    required String phone,
    required String address,
    required String password,
  }) async {
    // Validate inputs
    _validateSignUpInputs(name, email, phone, address, password);

    // Create user in Firebase Auth
    final userCredential = await _remoteDataSource.signUp(email, password);

    if (userCredential.user == null) {
      throw Exception('Failed to create user account');
    }

    // Create user model
    final user = UserModel(
      id: userCredential.user!.uid,
      name: name.trim(),
      email: email.trim(),
      phone: phone.trim(),
      address: address.trim(),
    );

    try {
      // Save user to Firestore
      await _remoteDataSource.saveUser(user);

      // Cache user locally
      await _localDataSource.cacheUser(user);

      // Add welcome coupon
      final welcomeCoupon = CouponModel.createWelcomeCoupon();
      await _remoteDataSource.addCoupon(user.id, welcomeCoupon);

      return user;
    } catch (e) {
      // Cleanup: delete auth user if Firestore save fails
      await userCredential.user?.delete();
      rethrow;
    }
  }

  /// Sign in with validation
  Future<UserModel> signIn({
    required String email,
    required String password,
  }) async {
    // Validate inputs
    final emailError = Validators.validateEmail(email);
    if (emailError != null) throw ValidationException(emailError);

    final passwordError = Validators.validatePassword(password);
    if (passwordError != null) throw ValidationException(passwordError);

    // Sign in
    final userCredential = await _remoteDataSource.signIn(email, password);

    // Get user data from Firestore
    final user = await _remoteDataSource.getUser(userCredential.user!.uid);
    if (user == null) {
      throw Exception('User data not found');
    }

    // Cache user locally
    await _localDataSource.cacheUser(user);

    return user;
  }

  /// Sign out
  Future<void> signOut() async {
    await _remoteDataSource.signOut();
    await _localDataSource.clearUserCache();
  }

  /// Check current auth status
  Future<UserModel?> getCurrentUser() async {
    final currentUser = _remoteDataSource.currentUser;
    if (currentUser == null) return null;

    // Try remote first
    try {
      final user = await _remoteDataSource.getUser(currentUser.uid);
      if (user != null) {
        await _localDataSource.cacheUser(user);
        return user;
      }
    } catch (e) {
      // Fallback to cached user
      return await _localDataSource.getCachedUser();
    }
    return null;
  }

  /// Get cached user (for offline mode)
  Future<UserModel?> getCachedUser() async {
    return await _localDataSource.getCachedUser();
  }

  /// Validate sign up inputs
  void _validateSignUpInputs(
    String name,
    String email,
    String phone,
    String address,
    String password,
  ) {
    final nameError = Validators.validateName(name);
    if (nameError != null) throw ValidationException(nameError);

    final emailError = Validators.validateEmail(email);
    if (emailError != null) throw ValidationException(emailError);

    final phoneError = Validators.validatePhone(phone);
    if (phoneError != null) throw ValidationException(phoneError);

    final addressError = Validators.validateAddress(address);
    if (addressError != null) throw ValidationException(addressError);

    final passwordError = Validators.validatePassword(password);
    if (passwordError != null) throw ValidationException(passwordError);
  }
}

/// Custom exception for validation errors
class ValidationException implements Exception {
  final String message;
  ValidationException(this.message);

  @override
  String toString() => message;
}

import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/coupon_model.dart';

/// Service for managing user coupons
class CouponService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Add a welcome coupon to a new user's collection
  static Future<void> addWelcomeCoupon(String userId) async {
    try {
      final coupon = CouponModel.createWelcomeCoupon();

      await _firestore
          .collection('users')
          .doc(userId)
          .collection('coupons')
          .doc(coupon.id)
          .set(coupon.toJson());

      print('✅ Welcome coupon added for user: $userId');
    } catch (e) {
      print('❌ Error adding welcome coupon: $e');
      rethrow;
    }
  }

  /// Get all coupons for a user
  static Future<List<CouponModel>> getUserCoupons(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('coupons')
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => CouponModel.fromJson(doc.data()))
          .toList();
    } catch (e) {
      print('❌ Error getting user coupons: $e');
      return [];
    }
  }

  /// Get stream of user coupons for real-time updates
  static Stream<List<CouponModel>> getUserCouponsStream(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('coupons')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => CouponModel.fromJson(doc.data()))
              .toList(),
        );
  }

  /// Validate and get a coupon by code
  static Future<CouponModel?> validateCoupon(String userId, String code) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('coupons')
          .where('code', isEqualTo: code.toLowerCase())
          .get();

      if (snapshot.docs.isEmpty) {
        return null;
      }

      final coupon = CouponModel.fromJson(snapshot.docs.first.data());

      if (coupon.isValid) {
        return coupon;
      }

      return null;
    } catch (e) {
      print('❌ Error validating coupon: $e');
      return null;
    }
  }

  /// Mark a coupon as used
  static Future<bool> useCoupon(String userId, String couponId) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('coupons')
          .doc(couponId)
          .update({'isUsed': true, 'usedAt': DateTime.now().toIso8601String()});

      print('✅ Coupon marked as used: $couponId');
      return true;
    } catch (e) {
      print('❌ Error marking coupon as used: $e');
      return false;
    }
  }

  /// Get count of active coupons for a user
  static Future<int> getActiveCouponsCount(String userId) async {
    try {
      final coupons = await getUserCoupons(userId);
      return coupons.where((c) => c.isValid).length;
    } catch (e) {
      print('❌ Error getting active coupons count: $e');
      return 0;
    }
  }

  /// Get active coupons count as stream
  static Stream<int> getActiveCouponsCountStream(String userId) {
    return getUserCouponsStream(
      userId,
    ).map((coupons) => coupons.where((c) => c.isValid).length);
  }
}

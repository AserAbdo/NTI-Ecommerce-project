/// Coupon model for the e-commerce app
/// Represents a discount coupon with usage tracking
class CouponModel {
  final String id;
  final String code;
  final double discountPercentage;
  final bool isUsed;
  final DateTime? usedAt;
  final DateTime createdAt;
  final DateTime? expiresAt;

  const CouponModel({
    required this.id,
    required this.code,
    required this.discountPercentage,
    this.isUsed = false,
    this.usedAt,
    required this.createdAt,
    this.expiresAt,
  });

  /// Check if coupon is expired
  bool get isExpired {
    if (expiresAt == null) return false;
    return DateTime.now().isAfter(expiresAt!);
  }

  /// Check if coupon is still valid (not used and not expired)
  bool get isValid => !isUsed && !isExpired;

  /// Get status text for display
  String get statusText {
    if (isUsed) return 'Used';
    if (isExpired) return 'Expired';
    return 'Active';
  }

  /// Create from Firestore document
  factory CouponModel.fromJson(Map<String, dynamic> json) {
    return CouponModel(
      id: json['id'] as String? ?? '',
      code: json['code'] as String? ?? '',
      discountPercentage:
          (json['discountPercentage'] as num?)?.toDouble() ?? 0.0,
      isUsed: json['isUsed'] as bool? ?? false,
      usedAt: json['usedAt'] != null
          ? DateTime.tryParse(json['usedAt'].toString())
          : null,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
      expiresAt: json['expiresAt'] != null
          ? DateTime.tryParse(json['expiresAt'].toString())
          : null,
    );
  }

  /// Convert to map for Firestore
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'code': code,
      'discountPercentage': discountPercentage,
      'isUsed': isUsed,
      'usedAt': usedAt?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'expiresAt': expiresAt?.toIso8601String(),
    };
  }

  /// Create a copy with updated fields
  CouponModel copyWith({
    String? id,
    String? code,
    double? discountPercentage,
    bool? isUsed,
    DateTime? usedAt,
    DateTime? createdAt,
    DateTime? expiresAt,
  }) {
    return CouponModel(
      id: id ?? this.id,
      code: code ?? this.code,
      discountPercentage: discountPercentage ?? this.discountPercentage,
      isUsed: isUsed ?? this.isUsed,
      usedAt: usedAt ?? this.usedAt,
      createdAt: createdAt ?? this.createdAt,
      expiresAt: expiresAt ?? this.expiresAt,
    );
  }

  /// Default welcome coupon for new users
  static CouponModel createWelcomeCoupon() {
    return CouponModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      code: 'elzoz2026',
      discountPercentage: 50.0,
      isUsed: false,
      createdAt: DateTime.now(),
      // Coupon expires in 30 days
      expiresAt: DateTime.now().add(const Duration(days: 30)),
    );
  }

  @override
  String toString() {
    return 'CouponModel(id: $id, code: $code, discount: $discountPercentage%, isUsed: $isUsed, isExpired: $isExpired)';
  }
}

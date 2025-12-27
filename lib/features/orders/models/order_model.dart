import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import '../../cart/models/cart_item_model.dart';
import 'shipping_address_model.dart';

class OrderModel extends Equatable {
  // Order Identification
  final String orderId;
  final String orderNumber;

  // Customer Information
  final String userId;
  final String customerName;
  final String customerEmail;
  final String customerPhone;

  // Order Status
  final String
  status; // pending, confirmed, processing, shipped, delivered, cancelled
  final String paymentStatus; // pending, paid, failed, refunded
  final String paymentMethod; // credit_card, cash_on_delivery, paypal

  // Items
  final List<CartItemModel> items;

  // Pricing
  final double subtotal;
  final double tax;
  final double shippingFee;
  final double discount;
  final double totalPrice;
  final String currency;

  // Shipping
  final ShippingAddressModel shippingAddress;
  final DateTime? estimatedDeliveryDate;
  final DateTime? actualDeliveryDate;
  final String? trackingNumber;

  // Notes
  final String? customerNotes;
  final String? adminNotes;

  // Timestamps
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? paidAt;
  final DateTime? shippedAt;
  final DateTime? deliveredAt;
  final DateTime? cancelledAt;

  const OrderModel({
    required this.orderId,
    required this.orderNumber,
    required this.userId,
    required this.customerName,
    required this.customerEmail,
    required this.customerPhone,
    this.status = 'pending',
    this.paymentStatus = 'pending',
    this.paymentMethod = 'cash_on_delivery',
    required this.items,
    required this.subtotal,
    required this.tax,
    required this.shippingFee,
    this.discount = 0.0,
    required this.totalPrice,
    this.currency = 'EGP',
    required this.shippingAddress,
    this.estimatedDeliveryDate,
    this.actualDeliveryDate,
    this.trackingNumber,
    this.customerNotes,
    this.adminNotes,
    this.createdAt,
    this.updatedAt,
    this.paidAt,
    this.shippedAt,
    this.deliveredAt,
    this.cancelledAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'orderId': orderId,
      'orderNumber': orderNumber,
      'userId': userId,
      'customerName': customerName,
      'customerEmail': customerEmail,
      'customerPhone': customerPhone,
      'status': status,
      'paymentStatus': paymentStatus,
      'paymentMethod': paymentMethod,
      'items': items.map((item) => item.toJson()).toList(),
      'subtotal': subtotal,
      'tax': tax,
      'shippingFee': shippingFee,
      'discount': discount,
      'totalPrice': totalPrice,
      'currency': currency,
      'shippingAddress': shippingAddress.toJson(),
      'estimatedDeliveryDate': estimatedDeliveryDate != null
          ? Timestamp.fromDate(estimatedDeliveryDate!)
          : null,
      'actualDeliveryDate': actualDeliveryDate != null
          ? Timestamp.fromDate(actualDeliveryDate!)
          : null,
      'trackingNumber': trackingNumber,
      'customerNotes': customerNotes,
      'adminNotes': adminNotes,
      'createdAt': createdAt != null
          ? Timestamp.fromDate(createdAt!)
          : FieldValue.serverTimestamp(),
      'updatedAt': updatedAt != null
          ? Timestamp.fromDate(updatedAt!)
          : FieldValue.serverTimestamp(),
      'paidAt': paidAt != null ? Timestamp.fromDate(paidAt!) : null,
      'shippedAt': shippedAt != null ? Timestamp.fromDate(shippedAt!) : null,
      'deliveredAt': deliveredAt != null
          ? Timestamp.fromDate(deliveredAt!)
          : null,
      'cancelledAt': cancelledAt != null
          ? Timestamp.fromDate(cancelledAt!)
          : null,
    };
  }

  static List<CartItemModel> _parseItems(dynamic itemsData) {
    if (itemsData == null) return [];

    if (itemsData is List) {
      return itemsData
          .map((item) {
            if (item is Map<String, dynamic>) {
              return CartItemModel.fromJson(item);
            } else if (item is Map) {
              // Convert Map to Map<String, dynamic>
              return CartItemModel.fromJson(Map<String, dynamic>.from(item));
            }
            return null;
          })
          .whereType<CartItemModel>()
          .toList();
    }

    return [];
  }

  static ShippingAddressModel _parseShippingAddress(dynamic addressData) {
    if (addressData == null) {
      return ShippingAddressModel(
        fullName: '',
        phone: '',
        street: '',
        city: '',
        state: '',
        postalCode: '',
      );
    }

    if (addressData is Map<String, dynamic>) {
      return ShippingAddressModel.fromJson(addressData);
    } else if (addressData is Map) {
      // Convert Map to Map<String, dynamic>
      return ShippingAddressModel.fromJson(
        Map<String, dynamic>.from(addressData),
      );
    }

    // If it's a string or other type, return default
    return ShippingAddressModel(
      fullName: '',
      phone: '',
      street: '',
      city: '',
      state: '',
      postalCode: '',
    );
  }

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      orderId: json['orderId'] as String? ?? '',
      orderNumber: json['orderNumber'] as String? ?? '',
      userId: json['userId'] as String? ?? '',
      customerName: json['customerName'] as String? ?? '',
      customerEmail: json['customerEmail'] as String? ?? '',
      customerPhone: json['customerPhone'] as String? ?? '',
      status: json['status'] as String? ?? 'pending',
      paymentStatus: json['paymentStatus'] as String? ?? 'pending',
      paymentMethod: json['paymentMethod'] as String? ?? 'cash_on_delivery',
      items: _parseItems(json['items']),
      subtotal: (json['subtotal'] as num?)?.toDouble() ?? 0.0,
      tax: (json['tax'] as num?)?.toDouble() ?? 0.0,
      shippingFee: (json['shippingFee'] as num?)?.toDouble() ?? 0.0,
      discount: (json['discount'] as num?)?.toDouble() ?? 0.0,
      totalPrice: (json['totalPrice'] as num?)?.toDouble() ?? 0.0,
      currency: json['currency'] as String? ?? 'EGP',
      shippingAddress: _parseShippingAddress(json['shippingAddress']),
      estimatedDeliveryDate: json['estimatedDeliveryDate'] != null
          ? (json['estimatedDeliveryDate'] as Timestamp).toDate()
          : null,
      actualDeliveryDate: json['actualDeliveryDate'] != null
          ? (json['actualDeliveryDate'] as Timestamp).toDate()
          : null,
      trackingNumber: json['trackingNumber'] as String?,
      customerNotes: json['customerNotes'] as String?,
      adminNotes: json['adminNotes'] as String?,
      createdAt: json['createdAt'] != null
          ? (json['createdAt'] as Timestamp).toDate()
          : null,
      updatedAt: json['updatedAt'] != null
          ? (json['updatedAt'] as Timestamp).toDate()
          : null,
      paidAt: json['paidAt'] != null
          ? (json['paidAt'] as Timestamp).toDate()
          : null,
      shippedAt: json['shippedAt'] != null
          ? (json['shippedAt'] as Timestamp).toDate()
          : null,
      deliveredAt: json['deliveredAt'] != null
          ? (json['deliveredAt'] as Timestamp).toDate()
          : null,
      cancelledAt: json['cancelledAt'] != null
          ? (json['cancelledAt'] as Timestamp).toDate()
          : null,
    );
  }

  OrderModel copyWith({
    String? orderId,
    String? orderNumber,
    String? userId,
    String? customerName,
    String? customerEmail,
    String? customerPhone,
    String? status,
    String? paymentStatus,
    String? paymentMethod,
    List<CartItemModel>? items,
    double? subtotal,
    double? tax,
    double? shippingFee,
    double? discount,
    double? totalPrice,
    String? currency,
    ShippingAddressModel? shippingAddress,
    DateTime? estimatedDeliveryDate,
    DateTime? actualDeliveryDate,
    String? trackingNumber,
    String? customerNotes,
    String? adminNotes,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? paidAt,
    DateTime? shippedAt,
    DateTime? deliveredAt,
    DateTime? cancelledAt,
  }) {
    return OrderModel(
      orderId: orderId ?? this.orderId,
      orderNumber: orderNumber ?? this.orderNumber,
      userId: userId ?? this.userId,
      customerName: customerName ?? this.customerName,
      customerEmail: customerEmail ?? this.customerEmail,
      customerPhone: customerPhone ?? this.customerPhone,
      status: status ?? this.status,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      items: items ?? this.items,
      subtotal: subtotal ?? this.subtotal,
      tax: tax ?? this.tax,
      shippingFee: shippingFee ?? this.shippingFee,
      discount: discount ?? this.discount,
      totalPrice: totalPrice ?? this.totalPrice,
      currency: currency ?? this.currency,
      shippingAddress: shippingAddress ?? this.shippingAddress,
      estimatedDeliveryDate:
          estimatedDeliveryDate ?? this.estimatedDeliveryDate,
      actualDeliveryDate: actualDeliveryDate ?? this.actualDeliveryDate,
      trackingNumber: trackingNumber ?? this.trackingNumber,
      customerNotes: customerNotes ?? this.customerNotes,
      adminNotes: adminNotes ?? this.adminNotes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      paidAt: paidAt ?? this.paidAt,
      shippedAt: shippedAt ?? this.shippedAt,
      deliveredAt: deliveredAt ?? this.deliveredAt,
      cancelledAt: cancelledAt ?? this.cancelledAt,
    );
  }

  @override
  List<Object?> get props => [
    orderId,
    orderNumber,
    userId,
    customerName,
    customerEmail,
    customerPhone,
    status,
    paymentStatus,
    paymentMethod,
    items,
    subtotal,
    tax,
    shippingFee,
    discount,
    totalPrice,
    currency,
    shippingAddress,
    estimatedDeliveryDate,
    actualDeliveryDate,
    trackingNumber,
    customerNotes,
    adminNotes,
    createdAt,
    updatedAt,
    paidAt,
    shippedAt,
    deliveredAt,
    cancelledAt,
  ];

  int get itemCount => items.fold<int>(0, (sum, item) => sum + item.quantity);

  bool get canBeCancelled =>
      status.toLowerCase() == 'pending' || status.toLowerCase() == 'confirmed';

  bool get isDelivered => status.toLowerCase() == 'delivered';

  bool get isCancelled => status.toLowerCase() == 'cancelled';

  bool get isPaid => paymentStatus.toLowerCase() == 'paid';
}

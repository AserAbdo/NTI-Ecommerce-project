import 'package:equatable/equatable.dart';

class CartItemModel extends Equatable {
  final String productId;
  final String name;
  final double price;
  final String imageUrl;
  final int quantity;
  final String description;

  const CartItemModel({
    required this.productId,
    required this.name,
    required this.price,
    required this.imageUrl,
    required this.quantity,
    this.description = '',
  });

  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    return CartItemModel(
      productId: json['productId'] as String? ?? '',
      name: json['name'] as String? ?? 'Unknown Product',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      imageUrl: json['imageUrl'] ?? json['image'] as String? ?? '',
      quantity: json['quantity'] as int? ?? 1,
      description: json['description'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'productId': productId,
    'name': name,
    'price': price,
    'image': imageUrl,
    'quantity': quantity,
    'description': description,
  };

  CartItemModel copyWith({
    String? productId,
    String? name,
    double? price,
    String? imageUrl,
    int? quantity,
    String? description,
  }) {
    return CartItemModel(
      productId: productId ?? this.productId,
      name: name ?? this.name,
      price: price ?? this.price,
      imageUrl: imageUrl ?? this.imageUrl,
      quantity: quantity ?? this.quantity,
      description: description ?? this.description,
    );
  }

  @override
  List<Object?> get props => [
    productId,
    name,
    price,
    imageUrl,
    quantity,
    description,
  ];
}

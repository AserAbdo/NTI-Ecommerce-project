import 'package:equatable/equatable.dart';
import 'review_model.dart';

class ProductModel extends Equatable {
  bool get inStock => stock > 0;
  final String id;
  final String name;
  final String description;
  final double price;
  final String category;
  final String imageUrl;
  final int stock;
  final List<ReviewModel> reviews;

  const ProductModel({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.category,
    required this.imageUrl,
    required this.stock,
    this.reviews = const [],
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) => ProductModel(
    id: json['id'] as String,
    name: json['name'] as String,
    description: json['description'] as String,
    price: (json['price'] as num).toDouble(),
    category: json['category'] as String,
    imageUrl: json['imageUrl'] as String,
    stock: json['stock'] as int,
    reviews: (json['reviews'] as List<dynamic>? ?? [])
        .map((e) => ReviewModel.fromJson(e as Map<String, dynamic>))
        .toList(),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'price': price,
    'category': category,
    'imageUrl': imageUrl,
    'stock': stock,
    'reviews': reviews.map((e) => e.toJson()).toList(),
  };

  @override
  List<Object?> get props => [
    id,
    name,
    description,
    price,
    category,
    imageUrl,
    stock,
    reviews,
  ];
}

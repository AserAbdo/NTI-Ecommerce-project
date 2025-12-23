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
  final double rating;
  final int reviewsCount;
  final double? oldPrice;
  final double? newPrice;

  const ProductModel({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.category,
    required this.imageUrl,
    required this.stock,
    this.reviews = const [],
    this.rating = 0.0,
    this.reviewsCount = 0,
    this.oldPrice,
    this.newPrice,
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
    rating: (json['rating'] ?? 0.0) is int
        ? (json['rating'] ?? 0).toDouble()
        : (json['rating'] ?? 0.0) as double,
    reviewsCount: (json['reviewsCount'] ?? 0) as int,
    oldPrice: (json['oldPrice'] as num?)?.toDouble(),
    newPrice: (json['newPrice'] as num?)?.toDouble(),
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
    'rating': rating,
    'reviewsCount': reviewsCount,
    if (oldPrice != null) 'oldPrice': oldPrice,
    if (newPrice != null) 'newPrice': newPrice,
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
    rating,
    reviewsCount,
    oldPrice,
    newPrice,
  ];
}

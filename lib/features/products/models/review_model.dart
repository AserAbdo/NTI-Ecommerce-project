import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class ReviewModel extends Equatable {
  final String userId;
  final String userName;
  final String comment;
  final double rating;
  final DateTime createdAt;

  const ReviewModel({
    required this.userId,
    required this.userName,
    required this.comment,
    required this.rating,
    required this.createdAt,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) => ReviewModel(
    userId: json['userId'] as String,
    userName: json['userName'] as String,
    comment: json['comment'] as String,
    rating: (json['rating'] as num).toDouble(),
    createdAt: _parseDate(json['createdAt']),
  );

  static DateTime _parseDate(dynamic value) {
    if (value is Timestamp) {
      return value.toDate();
    } else if (value is String) {
      return DateTime.parse(value);
    } else if (value is DateTime) {
      return value;
    } else {
      throw Exception('Invalid date type for review: $value');
    }
  }

  Map<String, dynamic> toJson() => {
    'userId': userId,
    'userName': userName,
    'comment': comment,
    'rating': rating,
    'createdAt': createdAt.toIso8601String(),
  };

  @override
  List<Object?> get props => [userId, userName, comment, rating, createdAt];
}

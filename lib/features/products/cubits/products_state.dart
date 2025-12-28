import 'package:equatable/equatable.dart';
import '../models/product_model.dart';

/// Base state class for Products
abstract class ProductsState extends Equatable {
  const ProductsState();

  @override
  List<Object?> get props => [];
}

/// Initial state before any data is loaded
class ProductsInitial extends ProductsState {
  const ProductsInitial();
}

/// Loading state while fetching products
class ProductsLoading extends ProductsState {
  const ProductsLoading();
}

/// Success state with loaded products
class ProductsLoaded extends ProductsState {
  final List<ProductModel> products;
  final bool hasMore;
  final String? currentCategory;
  final bool isFromCache;

  const ProductsLoaded({
    required this.products,
    this.hasMore = false,
    this.currentCategory,
    this.isFromCache = false,
  });

  @override
  List<Object?> get props => [products, hasMore, currentCategory, isFromCache];

  ProductsLoaded copyWith({
    List<ProductModel>? products,
    bool? hasMore,
    String? currentCategory,
    bool? isFromCache,
  }) {
    return ProductsLoaded(
      products: products ?? this.products,
      hasMore: hasMore ?? this.hasMore,
      currentCategory: currentCategory ?? this.currentCategory,
      isFromCache: isFromCache ?? this.isFromCache,
    );
  }
}

/// Error state when something goes wrong
class ProductsError extends ProductsState {
  final String message;
  final bool canRetry;

  const ProductsError({required this.message, this.canRetry = true});

  @override
  List<Object?> get props => [message, canRetry];
}

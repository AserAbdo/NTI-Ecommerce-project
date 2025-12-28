import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../services/firebase_service.dart';
import '../models/product_model.dart';

abstract class ProductsState {}

class ProductsInitial extends ProductsState {}

class ProductsLoading extends ProductsState {}

class ProductsLoaded extends ProductsState {
  final List<ProductModel> products;
  final bool hasMore;

  ProductsLoaded(this.products, {this.hasMore = false});
}

class ProductsError extends ProductsState {
  final String message;
  ProductsError(this.message);
}

class ProductsCubit extends Cubit<ProductsState> {
  ProductsCubit() : super(ProductsInitial());

  List<ProductModel> _allProducts = [];
  String? _currentCategory;
  static const int _pageSize = 10;

  Future<void> loadProducts() async {
    emit(ProductsLoading());
    _currentCategory = null;

    try {
      final snapshot = await FirebaseService.firestore
          .collection('products')
          .limit(_pageSize)
          .get();

      final products = snapshot.docs
          .map((doc) => ProductModel.fromJson({...doc.data(), 'id': doc.id}))
          .toList();

      _allProducts = products;
      emit(ProductsLoaded(products, hasMore: products.length >= _pageSize));
    } catch (e) {
      emit(ProductsError(e.toString()));
    }
  }

  Future<void> loadMoreProducts() async {
    final currentState = state;
    if (currentState is! ProductsLoaded || !currentState.hasMore) return;

    try {
      Query query = FirebaseService.firestore.collection('products');

      if (_currentCategory != null && _currentCategory != 'All') {
        query = query.where('category', isEqualTo: _currentCategory);
      }

      // Skip already loaded products
      final snapshot = await query.limit(_pageSize + _allProducts.length).get();

      final allDocs = snapshot.docs.skip(_allProducts.length).toList();

      if (allDocs.isEmpty) {
        emit(ProductsLoaded(_allProducts, hasMore: false));
        return;
      }

      final newProducts = allDocs
          .map(
            (doc) => ProductModel.fromJson({
              ...(doc.data() as Map<String, dynamic>),
              'id': doc.id,
            }),
          )
          .toList();

      _allProducts = [..._allProducts, ...newProducts];
      emit(
        ProductsLoaded(_allProducts, hasMore: newProducts.length >= _pageSize),
      );
    } catch (e) {
      emit(ProductsError(e.toString()));
    }
  }

  Future<void> filterByCategory(String? category) async {
    emit(ProductsLoading());
    _currentCategory = category;

    try {
      Query query = FirebaseService.firestore.collection('products');

      if (category != null && category != 'All') {
        query = query.where('category', isEqualTo: category);
      }

      final snapshot = await query.limit(_pageSize).get();

      final products = snapshot.docs
          .map(
            (doc) => ProductModel.fromJson({
              ...(doc.data() as Map<String, dynamic>),
              'id': doc.id,
            }),
          )
          .toList();

      _allProducts = products;
      emit(ProductsLoaded(products, hasMore: products.length >= _pageSize));
    } catch (e) {
      emit(ProductsError(e.toString()));
    }
  }

  Future<void> fetchProducts() async {
    await loadProducts();
  }

  Future<void> fetchProductsByCategory(String category) async {
    await filterByCategory(category == 'All' ? null : category);
  }

  void searchProducts(String query) {
    if (query.trim().isEmpty) {
      emit(
        ProductsLoaded(_allProducts, hasMore: _allProducts.length >= _pageSize),
      );
      return;
    }

    final q = query.toLowerCase();
    final filtered = _allProducts.where((p) {
      return p.name.toLowerCase().contains(q) ||
          p.description.toLowerCase().contains(q);
    }).toList();

    emit(ProductsLoaded(filtered, hasMore: false));
  }

  void setProducts(List<ProductModel> products) {
    _allProducts = products;
    emit(ProductsLoaded(_allProducts, hasMore: false));
  }
}

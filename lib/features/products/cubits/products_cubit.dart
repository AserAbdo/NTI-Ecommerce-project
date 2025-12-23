import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../services/firebase_service.dart';
import '../models/product_model.dart';

abstract class ProductsState {}

class ProductsInitial extends ProductsState {}

class ProductsLoading extends ProductsState {}

class ProductsLoaded extends ProductsState {
  final List<ProductModel> products;
  ProductsLoaded(this.products);
}

class ProductsError extends ProductsState {
  final String? message;
  ProductsError(this.message);
}

class ProductsCubit extends Cubit<ProductsState> {
  ProductsCubit() : super(ProductsInitial());

  List<ProductModel> _allProducts = [];

  Future<void> fetchProducts() async {
    emit(ProductsLoading());
    try {
      final snapshot = await FirebaseService.firestore
          .collection('products')
          .get();
      final products = snapshot.docs
          .map((doc) => ProductModel.fromJson(doc.data()))
          .toList();
      _allProducts = products;
      emit(ProductsLoaded(products));
    } catch (e) {
      emit(ProductsError(e.toString()));
    }
  }

  Future<void> fetchProductsByCategory(String category) async {
    emit(ProductsLoading());
    try {
      if (category == 'All') {
        await fetchProducts();
        return;
      }
      final snapshot = await FirebaseService.firestore
          .collection('products')
          .where('category', isEqualTo: category)
          .get();
      final products = snapshot.docs
          .map((doc) => ProductModel.fromJson(doc.data()))
          .toList();
      emit(ProductsLoaded(products));
    } catch (e) {
      emit(ProductsError(e.toString()));
    }
  }

  void searchProducts(String query) {
    if (query.trim().isEmpty) {
      emit(ProductsLoaded(_allProducts));
      return;
    }
    final q = query.toLowerCase();
    final filtered = _allProducts.where((p) {
      return p.name.toLowerCase().contains(q) ||
          p.description.toLowerCase().contains(q);
    }).toList();
    emit(ProductsLoaded(filtered));
  }

  // For seeding products in demo
  void setProducts(List<ProductModel> products) {
    _allProducts = products;
    emit(ProductsLoaded(_allProducts));
  }
}

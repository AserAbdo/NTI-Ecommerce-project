import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../services/firebase_service.dart';
import '../models/product_model.dart';

abstract class ProductsState {}

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
  ProductsCubit() : super(ProductsLoading());

  // Replace with your actual data source
  List<ProductModel> _allProducts = [];

  void fetchProducts() async {
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

  void searchProducts(String query) {
    if (state is ProductsLoaded) {
      final all = _allProducts;
      final filtered = all
          .where((p) => p.name.toLowerCase().contains(query.toLowerCase()))
          .toList();
      emit(ProductsLoaded(filtered));
    }
  }

  // For seeding products in demo
  void setProducts(List<ProductModel> products) {
    _allProducts = products;
    emit(ProductsLoaded(_allProducts));
  }
}

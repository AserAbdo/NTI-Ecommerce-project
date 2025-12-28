import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/theme/theme_cubit.dart';
import '../../features/auth/cubits/auth_cubit.dart';
import '../../features/cart/cubits/cart_cubit.dart';
import '../../features/favorites/cubits/favorites_cubit.dart';
import '../../features/orders/cubits/orders_cubit.dart';
import '../../features/products/cubits/products_cubit.dart';

/// Configuration for all BLoC providers
class BlocProvidersConfig {
  BlocProvidersConfig._();

  /// Get all BLoC providers for the app
  static List<BlocProvider> getProviders() {
    return [
      // Theme management
      BlocProvider(
        create: (context) => ThemeCubit(),
        lazy: false, // Load immediately for theme
      ),

      // Authentication
      BlocProvider(
        create: (context) => AuthCubit(),
        lazy: false, // Load immediately to check auth state
      ),

      // Products catalog
      BlocProvider(create: (context) => ProductsCubit()),

      // Shopping cart
      BlocProvider(create: (context) => CartCubit()),

      // Orders management
      BlocProvider(create: (context) => OrdersCubit()),

      // Favorites (starts with guest, updates on login)
      BlocProvider(create: (context) => FavoritesCubit(userId: 'guest')),
    ];
  }
}

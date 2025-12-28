import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/app/app_router.dart';
import '../../core/constants/app_routes.dart';
import '../../core/constants/app_strings.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/theme_cubit.dart';
import '../../core/theme/theme_state.dart';
import '../../features/auth/cubits/auth_cubit.dart';
import '../../features/cart/cubits/cart_cubit.dart';
import '../../features/favorites/cubits/favorites_cubit.dart';
import '../../features/home/cubits/carousel_cubit.dart';
import '../../features/orders/cubits/orders_cubit.dart';
import '../../features/products/cubits/products_cubit.dart';

/// Root widget of the NTI E-Commerce application
class NTIApp extends StatelessWidget {
  const NTIApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<ThemeCubit>(create: (context) => ThemeCubit()),
        BlocProvider<AuthCubit>(create: (context) => AuthCubit()),
        BlocProvider<ProductsCubit>(create: (context) => ProductsCubit()),
        BlocProvider<CartCubit>(create: (context) => CartCubit()),
        BlocProvider<OrdersCubit>(create: (context) => OrdersCubit()),
        BlocProvider<CarouselCubit>(create: (context) => CarouselCubit()),
        BlocProvider<FavoritesCubit>(
          create: (context) => FavoritesCubit(userId: 'guest'),
        ),
      ],
      child: BlocBuilder<ThemeCubit, ThemeState>(
        builder: (context, themeState) {
          return MaterialApp(
            title: AppStrings.appName,
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeState.themeMode,
            initialRoute: AppRoutes.splash,
            onGenerateRoute: AppRouter.onGenerateRoute,
          );
        },
      ),
    );
  }
}

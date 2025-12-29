import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/app/app_router.dart';
import '../../core/constants/app_routes.dart';
import '../../core/constants/app_strings.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/theme_cubit.dart';
import '../../core/theme/theme_state.dart';
import '../../core/widgets/network_aware_widget.dart';
import '../../features/auth/cubits/auth_cubit.dart';
import '../../features/auth/cubits/auth_state.dart';
import '../../features/cart/cubits/cart_cubit.dart';
import '../../features/favorites/cubits/favorites_cubit.dart';
import '../../features/home/cubits/carousel_cubit.dart';
import '../../features/orders/cubits/orders_cubit.dart';
import '../../features/products/cubits/products_cubit.dart';
import '../../features/profile/cubits/profile_stats_cubit.dart';

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
        BlocProvider<ProfileStatsCubit>(
          create: (context) => ProfileStatsCubit(),
        ),
      ],
      child: BlocBuilder<ThemeCubit, ThemeState>(
        builder: (context, themeState) {
          final isDark =
              themeState.themeMode == ThemeMode.dark ||
              (themeState.themeMode == ThemeMode.system &&
                  WidgetsBinding
                          .instance
                          .platformDispatcher
                          .platformBrightness ==
                      Brightness.dark);

          return AnnotatedRegion<SystemUiOverlayStyle>(
            value: SystemUiOverlayStyle(
              statusBarColor: Colors.transparent,
              statusBarIconBrightness: Brightness.light,
              statusBarBrightness: isDark ? Brightness.light : Brightness.dark,
              systemNavigationBarColor: Colors.transparent,
              systemNavigationBarIconBrightness: isDark
                  ? Brightness.light
                  : Brightness.dark,
              systemNavigationBarContrastEnforced: false,
            ),
            child: MaterialApp(
              title: AppStrings.appName,
              debugShowCheckedModeBanner: false,
              theme: AppTheme.lightTheme,
              darkTheme: AppTheme.darkTheme,
              themeMode: themeState.themeMode,
              initialRoute: AppRoutes.splash,
              onGenerateRoute: AppRouter.onGenerateRoute,
              builder: (context, child) {
                // Wrap with listeners for auth state changes
                return BlocListener<AuthCubit, AuthState>(
                  listener: (context, authState) {
                    _onAuthStateChanged(context, authState);
                  },
                  child: NetworkAwareWidget(
                    child: child ?? const SizedBox.shrink(),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  /// Handle auth state changes to sync cubits
  void _onAuthStateChanged(BuildContext context, AuthState authState) {
    if (authState is AuthAuthenticated) {
      final userId = authState.user.id;

      // Update FavoritesCubit with user ID
      context.read<FavoritesCubit>().updateUserId(userId);

      // Load user's cart
      context.read<CartCubit>().loadCart(userId);

      // Load user's orders
      context.read<OrdersCubit>().fetchUserOrders(userId);

      // Load profile stats
      context.read<ProfileStatsCubit>().loadStats(userId);
    } else if (authState is AuthUnauthenticated) {
      // Clear user-specific data
      context.read<FavoritesCubit>().updateUserId('guest');
      context.read<FavoritesCubit>().clear();
      context.read<ProfileStatsCubit>().clearStats();
    }
  }
}

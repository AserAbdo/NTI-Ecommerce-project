import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nti_project/firebase_options.dart';
import 'core/constants/app_strings.dart';
import 'core/constants/app_routes.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/cubits/auth_cubit.dart';
import 'features/auth/cubits/auth_state.dart';
import 'features/auth/screens/splash_screen.dart';
import 'features/auth/screens/login_screen.dart';
import 'features/auth/screens/signup_screen.dart';
import 'features/main/screens/main_screen.dart';
import 'features/products/screens/home_screen.dart';
import 'features/cart/cubits/cart_cubit.dart';
import 'features/cart/screens/cart_screen.dart';
import 'features/favorites/cubits/favorites_cubit.dart';
import 'features/orders/screens/checkout_screen.dart';
import 'features/orders/screens/order_confirmation_screen.dart';
import 'features/orders/models/order_model.dart';
import 'features/cart/cubits/cart_state.dart';
import 'features/products/screens/product_details_screen.dart';
import 'features/products/models/product_model.dart';
import 'features/products/cubits/products_cubit.dart';
import 'services/hive_service.dart';
// Import your cache manager
import 'features/cache/cache_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  
  // Initialize Hive for search history
  await HiveService.initialize();
  
  // Pre-warm the cache manager (optional but recommended)
  // This ensures it's ready before first use
  CustomCacheManager();
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => AuthCubit()),
        BlocProvider(create: (context) => CartCubit()),
        BlocProvider(create: (context) => ProductsCubit()),
        BlocProvider(
          create: (context) {
            final authState = context.read<AuthCubit>().state;
            if (authState is AuthAuthenticated) {
              return FavoritesCubit(userId: authState.user.id);
            }
            return FavoritesCubit(userId: 'guest');
          },
        ),
      ],
      child: MaterialApp(
        title: AppStrings.appName,
        theme: AppTheme.lightTheme,
        debugShowCheckedModeBanner: false,
        initialRoute: AppRoutes.splash,
        onGenerateRoute: (settings) {
          switch (settings.name) {
            case AppRoutes.splash:
              return MaterialPageRoute(builder: (_) => const SplashScreen());
            case AppRoutes.login:
              return MaterialPageRoute(builder: (_) => const LoginScreen());
            case AppRoutes.signup:
              return MaterialPageRoute(builder: (_) => const SignupScreen());
            case AppRoutes.main:
              return MaterialPageRoute(builder: (_) => const MainScreen());
            case AppRoutes.home:
              return MaterialPageRoute(builder: (_) => const HomeScreen());
            case AppRoutes.productDetails:
              final product = settings.arguments as ProductModel;
              return MaterialPageRoute(
                builder: (_) => ProductDetailsScreen(product: product),
              );
            case AppRoutes.cart:
              return MaterialPageRoute(builder: (_) => const CartScreen());
            case AppRoutes.checkout:
              final cartState = settings.arguments as CartLoaded;
              return MaterialPageRoute(
                builder: (_) => CheckoutScreen(cartState: cartState),
              );
            case AppRoutes.orderConfirmation:
              final order = settings.arguments as OrderModel;
              return MaterialPageRoute(
                builder: (_) => OrderConfirmationScreen(order: order),
              );
            default:
              return MaterialPageRoute(builder: (_) => const SplashScreen());
          }
        },
      ),
    );
  }
}
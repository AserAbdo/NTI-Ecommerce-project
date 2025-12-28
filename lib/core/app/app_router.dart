import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/constants/app_routes.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/signup_screen.dart';
import '../../features/auth/screens/splash_screen.dart';
import '../../features/onboarding/screens/onboarding_screen.dart';
import '../../features/orders/models/checkout_arguments.dart';
import '../../features/cart/screens/cart_screen.dart';
import '../../features/chatbot/cubits/chat_cubit.dart';
import '../../features/chatbot/screens/chat_screen.dart';
import '../../features/chatbot/screens/main_chat_screen.dart';
import '../../features/main/screens/main_screen.dart';
import '../../features/orders/models/order_model.dart';
import '../../features/orders/screens/checkout_screen.dart';
import '../../features/orders/screens/mock_payment_screen.dart';
import '../../features/orders/screens/order_confirmation_screen.dart';
import '../../features/products/models/product_model.dart';
import '../../features/products/screens/home_screen.dart';
import '../../features/products/screens/product_details_screen.dart';
import '../../features/admin/screens/admin_dashboard_screen.dart';

/// Handles all app routing and navigation
class AppRouter {
  AppRouter._();

  /// Generate route based on route name
  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      // ==================== Auth Routes ====================
      case AppRoutes.splash:
        return _buildRoute(const SplashScreen());

      case AppRoutes.onboarding:
        return _buildRoute(const OnboardingScreen());

      case AppRoutes.login:
        return _buildRoute(const LoginScreen());

      case AppRoutes.signup:
        return _buildRoute(const SignupScreen());

      // ==================== Main Routes ====================
      case AppRoutes.main:
        return _buildRoute(const MainScreen());

      case AppRoutes.home:
        return _buildRoute(const HomeScreen());

      // ==================== Product Routes ====================
      case AppRoutes.productDetails:
        return _buildProductDetailsRoute(settings);

      // ==================== Cart Routes ====================
      case AppRoutes.cart:
        return _buildRoute(const CartScreen());

      // ==================== Order Routes ====================
      case AppRoutes.checkout:
        return _buildCheckoutRoute(settings);

      case AppRoutes.mockPayment:
        return _buildMockPaymentRoute(settings);

      case AppRoutes.orderConfirmation:
        return _buildOrderConfirmationRoute(settings);

      // ==================== Chatbot Routes ====================
      case AppRoutes.mainChatBot:
        return _buildMainChatBotRoute();

      case AppRoutes.chatBot:
        return _buildChatBotRoute();

      // ==================== Admin Routes ====================
      case AppRoutes.admin:
        return _buildAdminRoute();

      // ==================== Default Route ====================
      default:
        return _buildRoute(const SplashScreen());
    }
  }

  // ==================== Route Builders ====================

  /// Build a standard MaterialPageRoute
  static MaterialPageRoute _buildRoute(Widget screen) {
    return MaterialPageRoute(builder: (_) => screen);
  }

  /// Build product details route with product argument
  static MaterialPageRoute _buildProductDetailsRoute(RouteSettings settings) {
    final product = settings.arguments as ProductModel;
    return _buildRoute(ProductDetailsScreen(product: product));
  }

  /// Build checkout route with cart state and optional coupon argument
  static MaterialPageRoute _buildCheckoutRoute(RouteSettings settings) {
    final args = settings.arguments as CheckoutArguments;
    return _buildRoute(
      CheckoutScreen(
        cartState: args.cartState,
        appliedCoupon: args.appliedCoupon,
      ),
    );
  }

  /// Build mock payment route with order argument
  static MaterialPageRoute _buildMockPaymentRoute(RouteSettings settings) {
    final order = settings.arguments as OrderModel;
    return _buildRoute(MockPaymentScreen(order: order));
  }

  /// Build order confirmation route with order argument
  static MaterialPageRoute _buildOrderConfirmationRoute(
    RouteSettings settings,
  ) {
    final order = settings.arguments as OrderModel;
    return _buildRoute(OrderConfirmationScreen(order: order));
  }

  /// Build main chatbot route with ChatCubit provider
  static MaterialPageRoute _buildMainChatBotRoute() {
    return _buildRoute(
      BlocProvider(
        create: (context) => ChatCubit(),
        child: const MainChatbotScreen(),
      ),
    );
  }

  /// Build chatbot route with ChatCubit provider
  static MaterialPageRoute _buildChatBotRoute() {
    return _buildRoute(
      BlocProvider(create: (context) => ChatCubit(), child: const ChatScreen()),
    );
  }

  /// Build admin dashboard route
  static MaterialPageRoute _buildAdminRoute() {
    return _buildRoute(const AdminDashboardScreen());
  }
}

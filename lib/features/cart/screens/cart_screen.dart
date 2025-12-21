import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_routes.dart';
import '../../../core/utils/responsive_helper.dart';
import '../../../core/widgets/custom_button.dart';
// import '../../../core/widgets/empty_state_widget.dart'; // Implement or replace as needed
import '../../auth/cubits/auth_cubit.dart';
import '../../auth/cubits/auth_state.dart';
import '../cubits/cart_cubit.dart';
import '../cubits/cart_state.dart';
import '../models/cart_item_model.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({Key? key}) : super(key: key);

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  String? _userId;

  @override
  void initState() {
    super.initState();
    final authState = context.read<AuthCubit>().state;
    if (authState is AuthAuthenticated) {
      _userId = authState.user.id;
      context.read<CartCubit>().loadCart(_userId!);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_userId == null) {
      return const Scaffold(
        body: Center(child: Text('Please login to view your cart')),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppStrings.cart,
          style: TextStyle(
            fontSize: ResponsiveHelper.getSubtitleFontSize(context),
          ),
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: BlocBuilder<CartCubit, CartState>(
        builder: (context, state) {
          if (state is CartLoading || state is CartInitial) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is CartError) {
            return Center(child: Text(state.message));
          }
          if (state is CartLoaded) {
            if (state.items.isEmpty) {
              return Center(child: Text('Your cart is empty'));
            }
            return Column(
              children: [
                Expanded(
                  child: ListView.separated(
                    padding: EdgeInsets.all(
                      ResponsiveHelper.getHorizontalPadding(context),
                    ),
                    itemBuilder: (context, index) {
                      final item = state.items[index];
                      return _CartItemTile(
                        item: item,
                        onIncrease: () {
                          context.read<CartCubit>().updateQuantity(
                            _userId!,
                            item.productId,
                            item.quantity + 1,
                          );
                          context.read<CartCubit>().loadCart(_userId!);
                        },
                        onDecrease: () {
                          context.read<CartCubit>().updateQuantity(
                            _userId!,
                            item.productId,
                            item.quantity - 1,
                          );
                          context.read<CartCubit>().loadCart(_userId!);
                        },
                        onRemove: () {
                          context.read<CartCubit>().removeFromCart(
                            _userId!,
                            item.productId,
                          );
                          context.read<CartCubit>().loadCart(_userId!);
                        },
                      );
                    },
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemCount: state.items.length,
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(
                    ResponsiveHelper.getHorizontalPadding(context),
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 8,
                        offset: const Offset(0, -2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Total:',
                            style: TextStyle(
                              fontSize: ResponsiveHelper.getSubtitleFontSize(
                                context,
                              ),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '${state.totalPrice.toStringAsFixed(0)} ${AppStrings.egp}',
                            style: TextStyle(
                              fontSize: ResponsiveHelper.getSubtitleFontSize(
                                context,
                              ),
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: ResponsiveHelper.getSpacing(context, 12),
                      ),
                      CustomButton(
                        text: 'Proceed to Checkout',
                        onPressed: () {
                          Navigator.pushNamed(
                            context,
                            AppRoutes.checkout,
                            arguments: state,
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            );
          }
          return const SizedBox();
        },
      ),
    );
  }
}

class _CartItemTile extends StatelessWidget {
  final CartItemModel item;
  final VoidCallback onIncrease;
  final VoidCallback onDecrease;
  final VoidCallback onRemove;

  const _CartItemTile({
    Key? key,
    required this.item,
    required this.onIncrease,
    required this.onDecrease,
    required this.onRemove,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final total = item.price * item.quantity;
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Image
          ClipRRect(
            borderRadius: const BorderRadius.horizontal(
              left: Radius.circular(12),
            ),
            child: Image.network(
              item.imageUrl,
              width: 90,
              height: 90,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                width: 90,
                height: 90,
                color: Colors.grey,
                child: const Icon(Icons.image),
              ),
            ),
          ),
          const SizedBox(width: 8),
          // Info
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${item.price.toStringAsFixed(0)} ${AppStrings.egp} x ${item.quantity} = ${total.toStringAsFixed(0)} ${AppStrings.egp}',
                    style: const TextStyle(fontSize: 12),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Quantity controls
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove_circle_outline),
                            onPressed: onDecrease,
                          ),
                          Text(
                            '${item.quantity}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          IconButton(
                            icon: const Icon(Icons.add_circle_outline),
                            onPressed: onIncrease,
                          ),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.delete_outline,
                          color: Colors.red,
                        ),
                        onPressed: onRemove,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

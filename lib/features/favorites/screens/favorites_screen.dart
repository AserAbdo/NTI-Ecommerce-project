import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/utils/responsive_helper.dart';
import '../../../core/widgets/empty_state_widget.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // TODO: Implement favorites cubit and load from Firestore
    final hasFavorites = false;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppStrings.myFavorites,
          style: TextStyle(
            fontSize: ResponsiveHelper.getSubtitleFontSize(context),
          ),
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
      ),
      body: hasFavorites
          ? _buildFavoritesList()
          : EmptyStateWidget(
              message: AppStrings.noFavorites,
              icon: Icons.favorite_border,
              buttonText: AppStrings.startShopping,
              onButtonPressed: () {
                // Switch to home tab if needed
              },
            ),
    );
  }

  Widget _buildFavoritesList() {
    // TODO: Build favorites grid similar to home screen
    return const Center(child: Text('Favorites coming soon'));
  }
}

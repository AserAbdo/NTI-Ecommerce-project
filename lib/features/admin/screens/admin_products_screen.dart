import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/constants/app_colors.dart';
import '../controllers/admin_controller.dart';
import '../widgets/admin_widgets.dart';

class AdminProductsScreen extends StatefulWidget {
  const AdminProductsScreen({super.key});

  @override
  State<AdminProductsScreen> createState() => _AdminProductsScreenState();
}

class _AdminProductsScreenState extends State<AdminProductsScreen> {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Stack(
      children: [
        // Products List
        StreamBuilder<QuerySnapshot>(
          stream: AdminController.getProductsStream(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return AdminErrorState(
                error: snapshot.error.toString(),
                isDark: isDark,
              );
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final products = snapshot.data?.docs ?? [];

            if (products.isEmpty) {
              return AdminEmptyState(
                icon: Icons.inventory_2_rounded,
                title: 'No products yet',
                subtitle: 'Tap the button below to add your first product',
                isDark: isDark,
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
              itemCount: products.length,
              itemBuilder: (context, index) {
                final doc = products[index];
                final data = doc.data() as Map<String, dynamic>;

                return _ProductCard(
                  id: doc.id,
                  data: data,
                  onEdit: () =>
                      _showProductDialog(context, docId: doc.id, data: data),
                  onDelete: () => _deleteProduct(doc.id),
                  isDark: isDark,
                );
              },
            );
          },
        ),

        // Floating Add Button
        Positioned(
          right: 20,
          bottom: 20,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primary,
                  AppColors.primary.withValues(alpha: 0.8),
                ],
              ),
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.4),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(18),
                onTap: () => _showProductDialog(context),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 14,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(Icons.add_rounded, color: Colors.white, size: 22),
                      SizedBox(width: 8),
                      Text(
                        'Add Product',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _deleteProduct(String productId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.warning_rounded, color: Colors.red),
            SizedBox(width: 12),
            Text('Delete Product?'),
          ],
        ),
        content: const Text('This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Cancel', style: TextStyle(color: Colors.grey[600])),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await AdminController.deleteProduct(productId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.delete_rounded, color: Colors.white),
                SizedBox(width: 12),
                Text('Product deleted'),
              ],
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.all(16),
          ),
        );
      }
    }
  }

  void _showProductDialog(
    BuildContext context, {
    String? docId,
    Map<String, dynamic>? data,
  }) {
    final isEdit = docId != null;
    final nameController = TextEditingController(text: data?['name'] ?? '');
    final descController = TextEditingController(
      text: data?['description'] ?? '',
    );
    final priceController = TextEditingController(
      text: data?['price']?.toString() ?? '',
    );
    final oldPriceController = TextEditingController(
      text: data?['oldPrice']?.toString() ?? '',
    );
    final stockController = TextEditingController(
      text: data?['stock']?.toString() ?? '',
    );
    final imageUrlController = TextEditingController(
      text: data?['imageUrl'] ?? '',
    );

    // Predefined categories
    final List<String> categories = [
      'Electronics',
      'Fashion',
      'Home',
      'Beauty',
      'Grocery',
    ];

    // Selected category (default to first or existing value)
    String selectedCategory = data?['category'] ?? categories.first;
    // Ensure the saved category is in our list, otherwise use first
    if (!categories.contains(selectedCategory)) {
      selectedCategory = categories.first;
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        height: MediaQuery.of(context).size.height * 0.9,
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E2E) : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 50,
              height: 5,
              decoration: BoxDecoration(
                color: isDark ? Colors.grey[700] : Colors.grey[300],
                borderRadius: BorderRadius.circular(10),
              ),
            ),

            // Header
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(
                      isEdit ? Icons.edit_rounded : Icons.add_rounded,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isEdit ? 'Edit Product' : 'Add Product',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                        Text(
                          isEdit
                              ? 'Update product details'
                              : 'Create a new product',
                          style: TextStyle(
                            fontSize: 14,
                            color: isDark ? Colors.grey[400] : Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(ctx),
                    icon: Icon(
                      Icons.close_rounded,
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),

            Divider(
              color: isDark ? Colors.grey[800] : Colors.grey[200],
              height: 1,
            ),

            // Form
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    _buildTextField(
                      'Product Name',
                      nameController,
                      Icons.shopping_bag_rounded,
                      isDark,
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      'Description',
                      descController,
                      Icons.description_rounded,
                      isDark,
                      maxLines: 3,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _buildTextField(
                            'Price',
                            priceController,
                            Icons.attach_money_rounded,
                            isDark,
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildTextField(
                            'Old Price',
                            oldPriceController,
                            Icons.money_off_rounded,
                            isDark,
                            keyboardType: TextInputType.number,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _buildTextField(
                            'Stock',
                            stockController,
                            Icons.inventory_rounded,
                            isDark,
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: StatefulBuilder(
                            builder: (context, setDropdownState) {
                              return Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                ),
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? Colors.white.withValues(alpha: 0.05)
                                      : Colors.grey[100],
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<String>(
                                    value: selectedCategory,
                                    isExpanded: true,
                                    icon: Icon(
                                      Icons.keyboard_arrow_down_rounded,
                                      color: isDark
                                          ? Colors.grey[400]
                                          : Colors.grey[600],
                                    ),
                                    dropdownColor: isDark
                                        ? const Color(0xFF2D2D3F)
                                        : Colors.white,
                                    hint: Text(
                                      'Category',
                                      style: TextStyle(
                                        color: isDark
                                            ? Colors.grey[400]
                                            : Colors.grey[600],
                                      ),
                                    ),
                                    items: categories.map((category) {
                                      IconData icon;
                                      switch (category) {
                                        case 'Electronics':
                                          icon = Icons.devices_rounded;
                                          break;
                                        case 'Fashion':
                                          icon = Icons.checkroom_rounded;
                                          break;
                                        case 'Home':
                                          icon = Icons.home_rounded;
                                          break;
                                        case 'Beauty':
                                          icon = Icons.spa_rounded;
                                          break;
                                        case 'Grocery':
                                          icon = Icons.shopping_basket_rounded;
                                          break;
                                        default:
                                          icon = Icons.category_rounded;
                                      }
                                      return DropdownMenuItem<String>(
                                        value: category,
                                        child: Row(
                                          children: [
                                            Icon(
                                              icon,
                                              size: 20,
                                              color: AppColors.primary,
                                            ),
                                            const SizedBox(width: 10),
                                            Text(
                                              category,
                                              style: TextStyle(
                                                color: isDark
                                                    ? Colors.white
                                                    : Colors.black87,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    }).toList(),
                                    onChanged: (value) {
                                      if (value != null) {
                                        setDropdownState(() {
                                          selectedCategory = value;
                                        });
                                      }
                                    },
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      'Image URL',
                      imageUrlController,
                      Icons.image_rounded,
                      isDark,
                    ),
                    const SizedBox(height: 32),

                    // Submit Button
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: () async {
                          final productData = {
                            'name': nameController.text.trim(),
                            'description': descController.text.trim(),
                            'price': double.tryParse(priceController.text) ?? 0,
                            'oldPrice': double.tryParse(
                              oldPriceController.text,
                            ),
                            'stock': int.tryParse(stockController.text) ?? 0,
                            'imageUrl': imageUrlController.text.trim(),
                            'category': selectedCategory,
                            'rating': data?['rating'] ?? 0.0,
                            'reviewsCount': data?['reviewsCount'] ?? 0,
                            'updatedAt': FieldValue.serverTimestamp(),
                          };

                          if (isEdit) {
                            await AdminController.updateProduct(
                              docId,
                              productData,
                            );
                          } else {
                            await AdminController.createProduct(productData);
                          }

                          if (mounted) {
                            Navigator.pop(ctx);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Row(
                                  children: [
                                    Icon(
                                      isEdit
                                          ? Icons.check_circle
                                          : Icons.add_circle,
                                      color: Colors.white,
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      isEdit
                                          ? 'Product updated'
                                          : 'Product added',
                                    ),
                                  ],
                                ),
                                backgroundColor: AppColors.success,
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                margin: const EdgeInsets.all(16),
                              ),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          isEdit ? 'Update Product' : 'Add Product',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller,
    IconData icon,
    bool isDark, {
    int maxLines = 1,
    TextInputType? keyboardType,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      style: TextStyle(color: isDark ? Colors.white : Colors.black87),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          color: isDark ? Colors.grey[400] : Colors.grey[600],
        ),
        prefixIcon: Icon(icon, color: AppColors.primary),
        filled: true,
        fillColor: isDark
            ? Colors.white.withValues(alpha: 0.05)
            : Colors.grey[100],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: AppColors.primary, width: 2),
        ),
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  final String id;
  final Map<String, dynamic> data;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final bool isDark;

  const _ProductCard({
    required this.id,
    required this.data,
    required this.onEdit,
    required this.onDelete,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final name = data['name'] ?? 'Unnamed';
    final price = (data['price'] ?? 0).toDouble();
    final stock = data['stock'] ?? 0;
    final imageUrl = data['imageUrl'] ?? '';
    final category = data['category'] ?? 'No category';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E2E) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.3)
                : Colors.black.withValues(alpha: 0.06),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Product Image
            Hero(
              tag: 'product_$id',
              child: ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: CachedNetworkImage(
                  imageUrl: imageUrl,
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                  placeholder: (_, _) => Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: isDark ? Colors.grey[800] : Colors.grey[200],
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(
                      Icons.image_rounded,
                      color: isDark ? Colors.grey[600] : Colors.grey[400],
                    ),
                  ),
                  errorWidget: (_, _, _) => Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: isDark ? Colors.grey[800] : Colors.grey[200],
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(
                      Icons.broken_image_rounded,
                      color: isDark ? Colors.grey[600] : Colors.grey[400],
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(width: 16),

            // Product Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      category,
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text(
                        'EGP ${price.toStringAsFixed(0)}',
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 15,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: stock > 0
                              ? Colors.green.withValues(alpha: 0.1)
                              : Colors.red.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              stock > 0
                                  ? Icons.check_circle_rounded
                                  : Icons.error_rounded,
                              size: 14,
                              color: stock > 0 ? Colors.green : Colors.red,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              stock > 0 ? 'In Stock: $stock' : 'Out of Stock',
                              style: TextStyle(
                                fontSize: 11,
                                color: stock > 0 ? Colors.green : Colors.red,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Action Buttons
            Column(
              children: [
                _buildActionButton(
                  Icons.edit_rounded,
                  AppColors.primary.withValues(alpha: 0.1),
                  AppColors.primary,
                  onEdit,
                ),
                const SizedBox(height: 8),
                _buildActionButton(
                  Icons.delete_rounded,
                  Colors.red.withValues(alpha: 0.1),
                  Colors.red,
                  onDelete,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(
    IconData icon,
    Color bgColor,
    Color iconColor,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: iconColor, size: 20),
      ),
    );
  }
}

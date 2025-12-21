import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_service.dart';

class SeedService {
  static final FirebaseFirestore _firestore = FirebaseService.firestore;

  /// Seeds the products collection with sample data
  /// Call this ONCE from a debug button or initial setup
  static Future<void> seedProducts() async {
    final productsCollection = _firestore.collection('products');

    final products = [
      // Electronics (5 products)
      {
        'id': 'prod_001',
        'name': 'iPhone 15 Pro Max',
        'description':
            'Latest Apple smartphone with A17 Pro chip, titanium design, and advanced camera system',
        'price': 52000,
        'category': 'Electronics',
        'imageUrl': 'https://picsum.photos/seed/iphone15/400/400',
        'stock': 25,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      },
      {
        'id': 'prod_002',
        'name': 'Samsung Galaxy S24 Ultra',
        'description':
            'Premium Android flagship with AI features, S Pen, and 200MP camera',
        'price': 48000,
        'category': 'Electronics',
        'imageUrl': 'https://picsum.photos/seed/galaxys24/400/400',
        'stock': 30,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      },
      {
        'id': 'prod_003',
        'name': 'Sony WH-1000XM5',
        'description':
            'Wireless noise-canceling headphones with premium sound quality',
        'price': 15000,
        'category': 'Electronics',
        'imageUrl': 'https://picsum.photos/seed/sonyheadphones/400/400',
        'stock': 50,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      },
      {
        'id': 'prod_004',
        'name': 'Apple Watch Series 9',
        'description': 'Advanced fitness and health tracking smartwatch',
        'price': 18000,
        'category': 'Electronics',
        'imageUrl': 'https://picsum.photos/seed/applewatch9/400/400',
        'stock': 40,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      },
      {
        'id': 'prod_005',
        'name': 'iPad Air M2',
        'description':
            'Powerful tablet with M2 chip, 11-inch Liquid Retina display',
        'price': 28000,
        'category': 'Electronics',
        'imageUrl': 'https://picsum.photos/seed/ipadair/400/400',
        'stock': 20,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      },

      // Fashion (5 products)
      {
        'id': 'prod_006',
        'name': 'Nike Air Max 270',
        'description':
            'Comfortable running shoes with air cushioning technology',
        'price': 3500,
        'category': 'Fashion',
        'imageUrl': 'https://picsum.photos/seed/nikeairmax/400/400',
        'stock': 100,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      },
      {
        'id': 'prod_007',
        'name': 'Adidas Ultraboost',
        'description': 'Premium running shoes with responsive boost cushioning',
        'price': 4200,
        'category': 'Fashion',
        'imageUrl': 'https://picsum.photos/seed/ultraboost/400/400',
        'stock': 80,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      },
      {
        'id': 'prod_008',
        'name': 'Levi\'s 501 Jeans',
        'description': 'Classic straight-fit denim jeans, authentic style',
        'price': 2800,
        'category': 'Fashion',
        'imageUrl': 'https://picsum.photos/seed/levis501/400/400',
        'stock': 120,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      },
      {
        'id': 'prod_009',
        'name': 'Ray-Ban Aviator',
        'description': 'Iconic sunglasses with metal frame and UV protection',
        'price': 1500,
        'category': 'Fashion',
        'imageUrl': 'https://picsum.photos/seed/rayban/400/400',
        'stock': 60,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      },
      {
        'id': 'prod_010',
        'name': 'Zara Leather Jacket',
        'description': 'Premium genuine leather jacket, modern design',
        'price': 5500,
        'category': 'Fashion',
        'imageUrl': 'https://picsum.photos/seed/zarajacket/400/400',
        'stock': 35,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      },

      // Home (3 products)
      {
        'id': 'prod_011',
        'name': 'Dyson V15 Vacuum',
        'description':
            'Cordless vacuum cleaner with laser detection technology',
        'price': 22000,
        'category': 'Home',
        'imageUrl': 'https://picsum.photos/seed/dysonv15/400/400',
        'stock': 15,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      },
      {
        'id': 'prod_012',
        'name': 'Nespresso Coffee Machine',
        'description': 'Premium espresso and coffee maker with milk frother',
        'price': 8500,
        'category': 'Home',
        'imageUrl': 'https://picsum.photos/seed/nespresso/400/400',
        'stock': 25,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      },
      {
        'id': 'prod_013',
        'name': 'IKEA Minimalist Desk',
        'description':
            'Modern white desk with cable management, perfect for home office',
        'price': 3200,
        'category': 'Home',
        'imageUrl': 'https://picsum.photos/seed/ikeadesk/400/400',
        'stock': 40,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      },

      // Beauty (2 products)
      {
        'id': 'prod_014',
        'name': 'Dior Sauvage Perfume',
        'description': 'Men\'s luxury fragrance, 100ml eau de toilette',
        'price': 4800,
        'category': 'Beauty',
        'imageUrl': 'https://picsum.photos/seed/diorsauvage/400/400',
        'stock': 70,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      },
      {
        'id': 'prod_015',
        'name': 'Fenty Beauty Foundation',
        'description':
            'Pro Filt\'r Soft Matte foundation, full coverage, 40 shades',
        'price': 1800,
        'category': 'Beauty',
        'imageUrl': 'https://picsum.photos/seed/fentybeauty/400/400',
        'stock': 90,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      },
    ];

    // Add products to Firestore
    try {
      for (final product in products) {
        final productId = product['id'] as String;
        await productsCollection.doc(productId).set(product);
        print('✅ Added product: ${product['name']}');
      }
      print('🎉 Successfully seeded ${products.length} products!');
    } catch (e) {
      print('❌ Error seeding products: $e');
      rethrow;
    }
  }

  /// Check if products collection is empty
  static Future<bool> isProductsEmpty() async {
    final snapshot = await _firestore.collection('products').limit(1).get();
    return snapshot.docs.isEmpty;
  }

  /// Delete all products (for testing/reset)
  static Future<void> clearProducts() async {
    final snapshot = await _firestore.collection('products').get();
    for (final doc in snapshot.docs) {
      await doc.reference.delete();
    }
    print('🗑️ Cleared all products');
  }
}

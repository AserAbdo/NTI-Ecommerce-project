import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_service.dart';

import 'dart:math';

class SeedService {
  static final FirebaseFirestore _firestore = FirebaseService.firestore;
  static final Random _random = Random();

  static Future<void> seedProducts() async {
    final products = [
      {
        'id': 'p1',
        'name': 'iPhone 13',
        'description': 'Apple smartphone with A15 Bionic chip and dual camera.',
        'oldPrice': 28999.0,
        'newPrice': 26000.0,
        'category': 'Electronics',
        'imageUrl':
            'https://images.pexels.com/photos/788946/pexels-photo-788946.jpeg',
        'rating': 4.8,
        'reviewsCount': 156,
      },
      {
        'id': 'p2',
        'name': 'GTX 1650',
        'description': 'NVIDIA GTX 1650 4GB GDDR6 graphics card.',
        'oldPrice': 9500.0,
        'newPrice': 8500.0,
        'category': 'Electronics',
        'imageUrl':
            'https://images.pexels.com/photos/2582937/pexels-photo-2582937.jpeg',
        'rating': 4.6,
        'reviewsCount': 89,
      },
      {
        'id': 'p3',
        'name': 'RAM 16GB',
        'description': '16GB DDR4 desktop memory module.',
        'oldPrice': 1999.0,
        'newPrice': 1700.0,
        'category': 'Electronics',
        'imageUrl':
            'https://images.pexels.com/photos/2582928/pexels-photo-2582928.jpeg',
        'rating': 4.7,
        'reviewsCount': 124,
      },
      {
        'id': 'p4',
        'name': 'Intel Core i5',
        'description': 'Intel Core i5 desktop processor (10th Gen).',
        'oldPrice': 5200.0,
        'newPrice': 4800.0,
        'category': 'Electronics',
        'imageUrl':
            'https://images.pexels.com/photos/2582930/pexels-photo-2582930.jpeg',
        'rating': 4.9,
        'reviewsCount': 203,
      },
      {
        'id': 'p5',
        'name': 'Wireless Earbuds',
        'description': 'Bluetooth earbuds with charging case.',
        'oldPrice': 1099.0,
        'newPrice': 899.0,
        'category': 'Electronics',
        'imageUrl':
            'https://images.pexels.com/photos/3825517/pexels-photo-3825517.jpeg',
        'rating': 4.5,
        'reviewsCount': 178,
      },
      {
        'id': 'p6',
        'name': 'Smart TV 55"',
        'description': '4K smart TV with HDR and apps.',
        'oldPrice': 9999.0,
        'newPrice': 8999.0,
        'category': 'Electronics',
        'imageUrl':
            'https://images.pexels.com/photos/1201996/pexels-photo-1201996.jpeg',
        'rating': 4.7,
        'reviewsCount': 142,
      },
      {
        'id': 'p7',
        'name': 'Sneakers',
        'description': 'Comfortable everyday sneakers with breathable mesh.',
        'oldPrice': 699.0,
        'newPrice': 499.0,
        'category': 'Fashion',
        'imageUrl':
            'https://images.pexels.com/photos/2529148/pexels-photo-2529148.jpeg',
        'rating': 4.4,
        'reviewsCount': 95,
      },
      {
        'id': 'p8',
        'name': 'Handbag',
        'description': 'Medium-sized handbag with adjustable strap.',
        'oldPrice': 1799.0,
        'newPrice': 1299.0,
        'category': 'Fashion',
        'imageUrl':
            'https://images.pexels.com/photos/1152077/pexels-photo-1152077.jpeg',
        'rating': 4.6,
        'reviewsCount': 67,
      },
      {
        'id': 'p9',
        'name': 'Cookware Set',
        'description': '10-piece stainless steel cookware set.',
        'oldPrice': 2499.0,
        'newPrice': 1999.0,
        'category': 'Home',
        'imageUrl':
            'https://images.pexels.com/photos/4226881/pexels-photo-4226881.jpeg',
        'rating': 4.8,
        'reviewsCount': 112,
      },
      {
        'id': 'p10',
        'name': 'Memory Foam Pillow',
        'description': 'Ergonomic pillow with memory foam for neck support.',
        'newPrice': 299.0,
        'category': 'Home',
        'imageUrl':
            'https://images.pexels.com/photos/1034584/pexels-photo-1034584.jpeg',
        'rating': 4.3,
        'reviewsCount': 58,
      },
      {
        'id': 'p11',
        'name': 'Face Serum',
        'description': 'Lightweight serum with hyaluronic acid.',
        'newPrice': 249.0,
        'category': 'Beauty',
        'imageUrl':
            'https://images.pexels.com/photos/3735612/pexels-photo-3735612.jpeg',
        'rating': 4.5,
        'reviewsCount': 134,
      },
      {
        'id': 'p12',
        'name': 'Lipstick Set',
        'description': 'Set of 4 long-lasting matte lipsticks.',
        'newPrice': 199.0,
        'category': 'Beauty',
        'imageUrl':
            'https://images.pexels.com/photos/2113855/pexels-photo-2113855.jpeg',
        'rating': 4.6,
        'reviewsCount': 89,
      },
      {
        'id': 'p13',
        'name': 'Laptop Backpack',
        'description':
            'Water-resistant backpack with padded laptop compartment.',
        'oldPrice': 799.0,
        'newPrice': 599.0,
        'category': 'Fashion',
        'imageUrl':
            'https://images.pexels.com/photos/2905238/pexels-photo-2905238.jpeg',
        'rating': 4.7,
        'reviewsCount': 76,
      },
      {
        'id': 'p14',
        'name': 'Smart Watch',
        'description': 'Fitness tracker with heart rate monitor.',
        'oldPrice': 1999.0,
        'newPrice': 1499.0,
        'category': 'Electronics',
        'imageUrl':
            'https://images.pexels.com/photos/437037/pexels-photo-437037.jpeg',
        'rating': 4.5,
        'reviewsCount': 198,
      },
      {
        'id': 'p15',
        'name': 'Coffee Maker',
        'description': 'Programmable drip coffee maker, 12-cup capacity.',
        'newPrice': 899.0,
        'category': 'Home',
        'imageUrl':
            'https://images.pexels.com/photos/324028/pexels-photo-324028.jpeg',
        'rating': 4.4,
        'reviewsCount': 102,
      },
      // Winter Men's Clothing
      {
        'id': 'p16',
        'name': 'Winter Jacket',
        'description': 'Warm padded jacket with hood for cold weather.',
        'oldPrice': 2499.0,
        'newPrice': 1899.0,
        'category': 'Fashion',
        'imageUrl':
            'https://images.pexels.com/photos/1183266/pexels-photo-1183266.jpeg',
        'rating': 4.7,
        'reviewsCount': 145,
      },
      {
        'id': 'p17',
        'name': 'Wool Sweater',
        'description': 'Cozy wool blend sweater for winter.',
        'oldPrice': 999.0,
        'newPrice': 799.0,
        'category': 'Fashion',
        'imageUrl':
            'https://images.pexels.com/photos/1183266/pexels-photo-1183266.jpeg',
        'rating': 4.6,
        'reviewsCount': 87,
      },
      {
        'id': 'p18',
        'name': 'Leather Boots',
        'description': 'Waterproof leather boots with warm lining.',
        'oldPrice': 1899.0,
        'newPrice': 1499.0,
        'category': 'Fashion',
        'imageUrl':
            'https://images.pexels.com/photos/1598505/pexels-photo-1598505.jpeg',
        'rating': 4.8,
        'reviewsCount': 123,
      },
      {
        'id': 'p19',
        'name': 'Wool Scarf',
        'description': 'Soft wool scarf for extra warmth.',
        'oldPrice': 399.0,
        'newPrice': 299.0,
        'category': 'Fashion',
        'imageUrl':
            'https://images.pexels.com/photos/1183266/pexels-photo-1183266.jpeg',
        'rating': 4.5,
        'reviewsCount': 54,
      },
      {
        'id': 'p20',
        'name': 'Thermal Shirt',
        'description': 'Long sleeve thermal base layer shirt.',
        'oldPrice': 549.0,
        'newPrice': 399.0,
        'category': 'Fashion',
        'imageUrl':
            'https://images.pexels.com/photos/1183266/pexels-photo-1183266.jpeg',
        'rating': 4.4,
        'reviewsCount': 68,
      },
      {
        'id': 'p21',
        'name': 'Fleece Hoodie',
        'description': 'Soft fleece hoodie with front pocket.',
        'oldPrice': 899.0,
        'newPrice': 699.0,
        'category': 'Fashion',
        'imageUrl':
            'https://images.pexels.com/photos/1183266/pexels-photo-1183266.jpeg',
        'rating': 4.6,
        'reviewsCount': 91,
      },
      {
        'id': 'p22',
        'name': 'Winter Gloves',
        'description': 'Insulated gloves with touchscreen fingers.',
        'oldPrice': 349.0,
        'newPrice': 249.0,
        'category': 'Fashion',
        'imageUrl':
            'https://images.pexels.com/photos/1183266/pexels-photo-1183266.jpeg',
        'rating': 4.3,
        'reviewsCount': 42,
      },
      {
        'id': 'p23',
        'name': 'Beanie Hat',
        'description': 'Warm knit beanie for cold days.',
        'oldPrice': 299.0,
        'newPrice': 199.0,
        'category': 'Fashion',
        'imageUrl':
            'https://images.pexels.com/photos/1183266/pexels-photo-1183266.jpeg',
        'rating': 4.4,
        'reviewsCount': 36,
      },
      // Supermarket Products
      {
        'id': 'p24',
        'name': 'Olive Oil 1L',
        'description': 'Extra virgin olive oil, cold pressed.',
        'oldPrice': 179.0,
        'newPrice': 149.0,
        'category': 'Grocery',
        'imageUrl':
            'https://images.pexels.com/photos/33783/olive-oil-salad-dressing-cooking-olive.jpg',
        'rating': 4.7,
        'reviewsCount': 156,
        'stock': 0, // Out of stock
      },
      {
        'id': 'p25',
        'name': 'Pasta 500g',
        'description': 'Italian durum wheat pasta.',
        'oldPrice': 55.0,
        'newPrice': 45.0,
        'category': 'Grocery',
        'imageUrl':
            'https://images.pexels.com/photos/1437267/pexels-photo-1437267.jpeg',
        'rating': 4.5,
        'reviewsCount': 98,
      },
      {
        'id': 'p26',
        'name': 'Rice 5kg',
        'description': 'Premium long grain white rice.',
        'oldPrice': 229.0,
        'newPrice': 199.0,
        'category': 'Grocery',
        'imageUrl':
            'https://images.pexels.com/photos/1393382/pexels-photo-1393382.jpeg',
        'rating': 4.6,
        'reviewsCount': 187,
      },
      {
        'id': 'p27',
        'name': 'Honey 500g',
        'description': 'Pure natural honey.',
        'oldPrice': 159.0,
        'newPrice': 129.0,
        'category': 'Grocery',
        'imageUrl':
            'https://images.pexels.com/photos/33783/olive-oil-salad-dressing-cooking-olive.jpg',
        'rating': 4.8,
        'reviewsCount': 142,
      },
      {
        'id': 'p28',
        'name': 'Coffee 250g',
        'description': 'Premium ground coffee beans.',
        'oldPrice': 219.0,
        'newPrice': 179.0,
        'category': 'Grocery',
        'imageUrl':
            'https://images.pexels.com/photos/324028/pexels-photo-324028.jpeg',
        'rating': 4.7,
        'reviewsCount': 234,
      },
      {
        'id': 'p29',
        'name': 'Tea Box 100',
        'description': 'Black tea bags, 100 count.',
        'oldPrice': 109.0,
        'newPrice': 89.0,
        'category': 'Grocery',
        'imageUrl':
            'https://images.pexels.com/photos/33783/olive-oil-salad-dressing-cooking-olive.jpg',
        'rating': 4.4,
        'reviewsCount': 76,
        'stock': 0, // Out of stock
      },
      {
        'id': 'p30',
        'name': 'Milk 1L',
        'description': 'Fresh whole milk.',
        'newPrice': 35.0,
        'category': 'Grocery',
        'imageUrl':
            'https://images.pexels.com/photos/33783/olive-oil-salad-dressing-cooking-olive.jpg',
        'rating': 4.3,
        'reviewsCount': 45,
        'stock': 0, // Out of stock
      },
      {
        'id': 'p31',
        'name': 'Eggs 12pcs',
        'description': 'Fresh farm eggs, 12 pieces.',
        'newPrice': 49.0,
        'category': 'Grocery',
        'imageUrl':
            'https://images.pexels.com/photos/33783/olive-oil-salad-dressing-cooking-olive.jpg',
        'rating': 4.5,
        'reviewsCount': 67,
      },
      {
        'id': 'p32',
        'name': 'Bread Loaf',
        'description': 'Fresh whole wheat bread.',
        'newPrice': 25.0,
        'category': 'Grocery',
        'imageUrl':
            'https://images.pexels.com/photos/1775043/pexels-photo-1775043.jpeg',
        'rating': 4.2,
        'reviewsCount': 34,
      },
      {
        'id': 'p33',
        'name': 'Cheese 500g',
        'description': 'Cheddar cheese block.',
        'oldPrice': 189.0,
        'newPrice': 159.0,
        'category': 'Grocery',
        'imageUrl':
            'https://images.pexels.com/photos/33783/olive-oil-salad-dressing-cooking-olive.jpg',
        'rating': 4.6,
        'reviewsCount': 89,
      },
      {
        'id': 'p34',
        'name': 'Tomato Sauce',
        'description': 'Italian tomato pasta sauce.',
        'oldPrice': 49.0,
        'newPrice': 39.0,
        'category': 'Grocery',
        'imageUrl':
            'https://images.pexels.com/photos/33783/olive-oil-salad-dressing-cooking-olive.jpg',
        'rating': 4.4,
        'reviewsCount': 52,
      },
      {
        'id': 'p35',
        'name': 'Sugar 1kg',
        'description': 'White granulated sugar.',
        'newPrice': 45.0,
        'category': 'Grocery',
        'imageUrl':
            'https://images.pexels.com/photos/33783/olive-oil-salad-dressing-cooking-olive.jpg',
        'rating': 4.1,
        'reviewsCount': 28,
      },
    ];

    final reviewerNames = [
      'Sara M.',
      'Ahmed K.',
      'Fatima A.',
      'Omar H.',
      'Layla S.',
      'Hassan M.',
      'Nour E.',
      'Karim F.',
      'Yasmin R.',
      'Ali T.',
      'Mona S.',
      'Youssef A.',
      'Hana B.',
      'Khaled M.',
      'Rana F.',
    ];

    final reviewComments = [
      // 5-star comments
      'Excellent quality! Highly recommend to everyone.',
      'Amazing product! Exceeded all my expectations.',
      'Best purchase I\'ve made this year. Absolutely love it!',
      'Outstanding quality and fast delivery. Will buy again!',
      'Perfect! Exactly what I was looking for.',
      'Superb quality! Worth every penny.',
      'Incredible value for money. Highly satisfied!',
      'Fantastic product! My family loves it too.',

      // 4-star comments
      'Great value for money. Very satisfied overall.',
      'Good quality product. Delivery was quick.',
      'Really nice! Just as described in the listing.',
      'Very happy with this purchase. Recommended!',
      'Good product, works perfectly. Happy customer!',
      'Nice quality and good price. Would buy again.',
      'Solid product. Does exactly what it should.',

      // 3-4 star comments
      'Good product but could be better in some aspects.',
      'Decent quality. Price is fair for what you get.',
      'It\'s okay. Does the job but nothing special.',
      'Satisfactory purchase. Meets basic expectations.',
      'Average quality but acceptable for the price.',

      // Detailed positive comments
      'The quality is amazing! Fast delivery and well packaged. Highly recommend this seller.',
      'Love it! Exactly as described. The product quality exceeded my expectations.',
      'Perfect for my needs. Great quality and the price is very reasonable.',
      'Excellent purchase! The product arrived quickly and in perfect condition.',
      'Very impressed with the quality! Will definitely order again.',
      'Great product! My second time ordering and still very satisfied.',
      'Wonderful quality! Better than I expected for this price.',
      'Absolutely love this! Great value and excellent quality.',
      'Perfect! Fast shipping and product is exactly as shown.',
      'Highly recommend! Quality is top-notch and price is great.',
    ];

    try {
      for (var productData in products) {
        final productId = productData['id'] as String;

        // Calculate price from newPrice (or oldPrice if no newPrice)
        final price = productData['newPrice'] ?? productData['oldPrice'];

        // Add stock (some products already have stock set to 0)
        if (!productData.containsKey('stock')) {
          productData['stock'] = 50 + _random.nextInt(100);
        }

        // Ensure rating and reviewsCount exist
        if (!productData.containsKey('rating')) {
          productData['rating'] = 4.0 + (_random.nextDouble() * 0.9);
        }
        if (!productData.containsKey('reviewsCount')) {
          productData['reviewsCount'] = 20 + _random.nextInt(150);
        }

        // Add price for compatibility
        productData['price'] = price as double;

        await _firestore.collection('products').doc(productId).set(productData);

        // Generate 4-7 reviews for each product
        final numReviews = 4 + _random.nextInt(4);
        for (var i = 0; i < numReviews; i++) {
          // Rating distribution: more 4-5 stars, fewer 3 stars
          final ratingRoll = _random.nextInt(10);
          final rating = ratingRoll < 6
              ? 5.0 // 60% chance of 5 stars
              : ratingRoll < 9
              ? 4.0 // 30% chance of 4 stars
              : 3.0; // 10% chance of 3 stars

          final reviewerName =
              reviewerNames[_random.nextInt(reviewerNames.length)];
          final comment =
              reviewComments[_random.nextInt(reviewComments.length)];

          // Generate a fake userId
          final userId = 'user_${_random.nextInt(1000)}';

          // Random date within the last 60 days
          final daysAgo = _random.nextInt(60);
          final reviewDate = DateTime.now().subtract(Duration(days: daysAgo));

          await _firestore
              .collection('products')
              .doc(productId)
              .collection('reviews')
              .add({
                'userId': userId,
                'userName': reviewerName,
                'rating': rating,
                'comment': comment,
                'createdAt': Timestamp.fromDate(reviewDate),
              });
        }
      }

      print('✅ Successfully seeded ${products.length} products with reviews!');
    } catch (e) {
      print('❌ Error seeding products: $e');
      rethrow;
    }
  }
}

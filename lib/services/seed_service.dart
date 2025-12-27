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
            'https://m.media-amazon.com/images/I/611VmwpD8SL._AC_UF894,1000_QL80_.jpg',
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
            'https://kolshzin.com/wp-content/uploads/2024/12/Kingston-16GB-2x8-DDR4-3200MTs-CL16-FURY-Beast.webp',
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
            'https://egyptlaptop.com/images/detailed/85/Intel_Core_i5.webp',
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
            'https://r2media.horizondm.com/catalog/product/cache/eb4305db09fb6492bb059b8131f647e3/_/-/_-_2024-12-10t113723.171.jpg',
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
            'https://i5.walmartimages.com/seo/Htcenly-Running-Shoes-Men-Fashion-Sneakers-Casual-Walking-Shoes-Sport-Athletic-Shoes-Lightweight-Breathable-Comfortable_4114141f-7d26-4dd7-933d-babc24080395.516ad145e1a1d8d82a801ac48231950d.jpeg',
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
            'https://www.lavieworld.com/cdn/shop/articles/c39b09efe9334781f0a52b1832bf5836_1080x.jpg?v=1693886031',
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
            'https://sheffieldegypt.com/cdn/shop/files/1315089_01_2400x2400_f1be18e6-b9fe-4ab1-8e2e-5e5f638cdc77.webp?v=1763559429&width=533',
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
            'https://media.homecentre.com/i/homecentre/161294207-161294207-HC110219_01-2100.jpg?v=2',
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
            'https://www.garnier.ca/-/media/project/loreal/brand-sites/garnier/usa/ca/about-our-brands/skin-care/2023/vit-c-day-cream/en/3600542444149-1.jpg?w=500&rev=7897717a298547d5be46b83f33f565f7&hash=23EE5F72FBE562E4EA0CFD530F35E0BA',
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
            'https://milabeaute.com/cdn/shop/files/SET_C.jpg?v=1754394048&width=2048',
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
            'https://www.matein.com/cdn/shop/files/gray_8947aa57-8302-4a8c-a725-0aca30f68b4e.jpg?v=1745403853',
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
            'https://smartkoshk.com/cdn/shop/files/1_8aee8fe7-7293-47cb-b6df-4217a82e127e.png?v=1755009087',
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
            'https://img.bstn.com/eyJidWNrZXQiOiJic3RuLWltYWdlLXNlcnZlciIsImtleSI6ImNhdGFsb2cvcHJvZHVjdC8yMjI3TS02MS8yMjI3TS02MS0wMS5qcGciLCJlZGl0cyI6eyJyZXNpemUiOnsiZml0IjoiY29udGFpbiIsIndpZHRoIjo1ODAsImhlaWdodCI6NzI1LCJiYWNrZ3JvdW5kIjp7InIiOjI1NSwiZyI6MjU1LCJiIjoyNTUsImFscGhhIjoxfX19fQ==',
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
            'https://www.themerchantfox.co.uk/cdn/shop/files/fox_21_nov22193458-Main.jpg?v=1742208389&width=2048',
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
            'https://jakameneg.b-cdn.net/wp-content/uploads/2025/04/SK38CS14M003-Black-001-1-scaled.jpg',
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
            'https://us.dentsgloves.com/cdn/shop/files/mens-heritage-tartan-check-cashmere-scarf-tassels-royal-stewart-loop.jpg?v=1765185448',
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
            'https://www.harveysupplies.co.uk/images/resizedImages/1_a3674868bbef1f0ac4bf899251d312f8_1000_1000.jpg',
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
            'https://huntingkitshop.co.uk/images/detailed/13/JHOODFLSRGEN2CAM-001.jpg',
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
            'https://i5.walmartimages.com/seo/Men-s-Thinsulate-Thick-Water-Resistant-Fully-Fleeced-Lined-Adult-Winter-Snow-Ski-Black-Men-Glove-Male_71f91c52-4d0b-44a4-ac76-c4fe6001a658_1.842641624183fecd7bbdcc631ddcc5d4.jpeg',
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
            'https://evolutionknitwear.com/wp-content/uploads/2020/10/EK1605W_Black_01.jpg',
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
            'https://www.gaston.cz/wcd/eshop/files/305/278/images/large/EVO%201l%20FJK.jpg',
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
            'https://pastaregina.com/wp-content/uploads/2023/02/02-Rice.jpg',
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
            'https://f.nooncdn.com/p/pnsku/N28716824A/45/_/1764242500/dcf54894-a3d7-4c0e-b616-bd40d7616374.jpg?width=800',
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
            'https://herostore.com.eg/wp-content/uploads/2022/01/6221024992575_H1C1_Hero_Cirtus_365g-600x600.png',
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
            'https://backend.abuauf.com/wp-content/uploads/2024/08/2000505000000.webp',
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
            'https://www.men-masr.com/cdn/shop/files/El_Arosa_Black_Tea.avif?v=1766325884&width=1445',
        'rating': 4.4,
        'reviewsCount': 76,
        'stock': 0, // Out of stock
      },
      {
        'id': 'p30',
        'name': 'Milk 1.5L',
        'description': 'Fresh whole milk.',
        'newPrice': 35.0,
        'category': 'Grocery',
        'imageUrl':
            'https://cittamart.com/wp-content/uploads/2023/10/Juhayna-Milk-Long-Life-Full-Cream-1.5-L-1.webp',
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
            'https://cdn.salla.sa/vwaxy/Um32tKe2OdYfursReYPQP6tt7cYHDHyl0PdB92Dt.png',
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
            'https://cittamart.com/wp-content/uploads/2023/12/Rich-Bake-Normal-Petit-Pain-6-pcs-4.webp',
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
            'https://cdn.mafrservices.com/sys-master-root/hce/h3e/12784615358494/51792_main.jpg',
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
            'https://gourmetegypt.com/media/catalog/product/6/2/6221033101289.jpg?optimize=high&bg-color=255,255,255&fit=bounds&height=&width=',
        'rating': 4.4,
        'reviewsCount': 52,
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

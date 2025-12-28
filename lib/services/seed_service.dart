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
        'description':
            'Experience the power of Apple\'s iPhone 13 featuring the lightning-fast A15 Bionic chip with 5-core GPU. Capture stunning photos with the advanced dual-camera system including Night mode, Photographic Styles, and Cinematic mode. Enjoy all-day battery life, 5G connectivity, and the beautiful 6.1-inch Super Retina XDR display with Ceramic Shield protection.',
        'oldPrice': 28999.0,
        'newPrice': 26000.0,
        'category': 'Electronics',
        'imageUrl':
            'https://api-rayashop.freetls.fastly.net/media/catalog/product/cache/4e49ac3a70c0b98a165f3fa6633ffee1/m/l/mlpf3aaa_fsxr05slkflufdmm.jpg?format=webp&width=700',
        'rating': 4.8,
        'reviewsCount': 156,
      },
      {
        'id': 'p2',
        'name': 'GTX 1650',
        'description':
            'Elevate your gaming experience with the NVIDIA GeForce GTX 1650 graphics card. Powered by NVIDIA Turing architecture with 4GB GDDR6 memory, this GPU delivers smooth gameplay at 1080p resolution. Features advanced shading technologies, DirectX 12 support, and efficient power consumption. Perfect for esports titles and modern AAA games at high settings.',
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
        'description':
            'Boost your system performance with this high-speed 16GB DDR4 RAM module running at 3200MHz. Engineered for reliability and speed, this memory kit features low-latency CL16 timings and optimized heat spreader design. Perfect for gaming, content creation, and multitasking. Compatible with Intel and AMD platforms, ensuring seamless performance upgrades.',
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
        'description':
            'Unleash powerful performance with the Intel Core i5 10th Generation processor. Featuring 6 cores and 12 threads with boost speeds up to 4.8GHz, this CPU delivers exceptional responsiveness for gaming, streaming, and productivity. Built on 14nm architecture with Intel Turbo Boost Technology 2.0, integrated UHD Graphics 630, and support for DDR4 memory up to 2666MHz.',
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
        'description':
            'Immerse yourself in premium sound with these truly wireless Bluetooth 5.0 earbuds. Featuring active noise cancellation, touch controls, and IPX5 water resistance for workouts. Enjoy up to 8 hours of playtime on a single charge, with an additional 24 hours from the compact charging case. Crystal-clear calls with built-in microphones and instant pairing technology.',
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
        'description':
            'Transform your living room with this stunning 55-inch 4K Ultra HD Smart TV. Experience breathtaking picture quality with HDR10+ support, vibrant colors, and deep blacks. Built-in WiFi provides access to popular streaming apps including Netflix, YouTube, and Prime Video. Features multiple HDMI ports, USB connectivity, and voice control compatibility for seamless entertainment.',
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
        'description':
            'Step into comfort with these premium athletic sneakers featuring breathable mesh upper and cushioned insole. Designed for all-day wear with lightweight construction, flexible rubber outsole for superior traction, and stylish design that transitions seamlessly from gym to street. Available in versatile colors with reinforced toe cap and padded collar for ankle support.',
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
        'description':
            'Elevate your style with this elegant medium-sized handbag crafted from premium vegan leather. Features multiple interior compartments including a zippered pocket for valuables, adjustable shoulder strap for versatile carrying options, and magnetic snap closure. The spacious main compartment holds all your essentials while maintaining a sleek silhouette. Perfect for work, shopping, or evening outings.',
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
        'description':
            'Master your culinary skills with this professional-grade 10-piece stainless steel cookware set. Includes essential pots and pans with tri-ply construction for even heat distribution, stay-cool handles, and tempered glass lids. Dishwasher safe, oven safe up to 500°F, and compatible with all cooktops including induction. Non-reactive surface preserves food flavors and nutrients.',
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
        'description':
            'Experience restful sleep with this ergonomically designed memory foam pillow that contours to your head and neck. Premium CertiPUR-US certified foam provides optimal support while reducing pressure points. Breathable bamboo cover is hypoallergenic, removable, and machine washable. Ideal for all sleeping positions - back, side, or stomach sleepers. Helps alleviate neck pain and improves sleep quality.',
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
        'description':
            'Revitalize your skin with this advanced lightweight serum enriched with hyaluronic acid and vitamin C. Deeply hydrates, brightens complexion, and reduces the appearance of fine lines and wrinkles. Fast-absorbing formula penetrates deep into skin layers, suitable for all skin types. Dermatologist-tested, paraben-free, and cruelty-free. Apply morning and evening for radiant, youthful-looking skin.',
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
        'description':
            'Complete your makeup collection with this stunning set of 4 long-lasting matte lipsticks in versatile shades. Rich, highly pigmented formula glides on smoothly for full coverage in one swipe. Enriched with vitamin E and natural oils to keep lips moisturized and comfortable all day. Transfer-resistant, smudge-proof, and fade-resistant formula. Includes classic reds, pinks, nudes, and berry tones.',
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
            'Protect your tech in style with this water-resistant laptop backpack featuring a dedicated padded compartment for laptops up to 15.6 inches. Multiple organizational pockets keep accessories, documents, and personal items neatly arranged. Ergonomic padded shoulder straps and breathable back panel ensure all-day comfort. USB charging port, anti-theft hidden pocket, and durable YKK zippers. Perfect for students, professionals, and travelers.',
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
        'description':
            'Stay connected and track your fitness goals with this feature-packed smartwatch. Monitors heart rate, blood oxygen, sleep quality, and daily activity with precision sensors. Receive notifications for calls, messages, and apps directly on your wrist. Water-resistant design suitable for swimming, 7-day battery life, and customizable watch faces. Compatible with iOS and Android devices. Includes multiple sport modes and GPS tracking.',
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
        'description':
            'Brew the perfect cup every time with this programmable 12-cup drip coffee maker. Features 24-hour programmable timer, auto shut-off, and pause-and-serve function. Permanent gold-tone filter eliminates the need for paper filters, while the anti-drip system prevents messes. Large water reservoir with visible water level indicator, warming plate keeps coffee hot for hours. Sleek stainless steel design complements any kitchen.',
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
        'description':
            'Brave the cold in style with this premium winter jacket featuring thick padding insulation and water-resistant outer shell. Detachable hood with faux fur trim, multiple zippered pockets for secure storage, and adjustable cuffs to seal out the cold. Ribbed hem provides extra warmth, while the modern fit flatters your silhouette. Perfect for temperatures down to -20°C. Available in classic colors.',
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
        'description':
            'Stay warm and sophisticated in this premium wool blend sweater crafted from 60% merino wool and 40% acrylic. Classic crew neck design with ribbed cuffs and hem for a perfect fit. Soft, breathable fabric regulates temperature while preventing itchiness. Machine washable for easy care. Timeless style works perfectly for casual outings or layering under jackets. Pill-resistant and maintains shape after washing.',
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
        'description':
            'Conquer winter weather with these rugged waterproof leather boots featuring genuine full-grain leather upper and warm fleece lining. Durable rubber lug sole provides excellent traction on ice and snow. Cushioned insole offers all-day comfort, while the lace-up design ensures a secure fit. Reinforced toe and heel for added durability. Perfect for hiking, work, or everyday winter wear. Timeless style meets functionality.',
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
        'description':
            'Wrap yourself in luxury with this ultra-soft 100% merino wool scarf. Generously sized at 180cm x 30cm for versatile styling options - wear it draped, wrapped, or knotted. Natural wool fibers provide exceptional warmth without bulk, while the breathable material prevents overheating. Classic design complements any winter outfit. Dry clean only to maintain premium quality. Makes an excellent gift.',
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
        'description':
            'Experience superior warmth with this advanced thermal base layer shirt featuring moisture-wicking technology. Soft brushed interior traps heat while allowing skin to breathe, perfect for layering under sweaters or jackets. Flatlock seams prevent chafing during active wear. Stretchy fabric moves with you for unrestricted mobility. Odor-resistant treatment keeps you fresh. Ideal for outdoor activities, sports, or everyday winter wear.',
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
        'description':
            'Embrace cozy comfort with this ultra-soft fleece hoodie made from premium anti-pill fleece fabric. Features a spacious kangaroo front pocket, adjustable drawstring hood, and ribbed cuffs for warmth retention. Relaxed fit allows easy layering over t-shirts. Durable construction withstands frequent washing while maintaining softness. Perfect for lounging, outdoor activities, or casual everyday wear. Machine washable.',
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
        'description':
            'Keep your hands warm and connected with these insulated winter gloves featuring Thinsulate technology and touchscreen-compatible fingertips. Water-resistant outer shell protects against snow and rain, while the soft fleece lining provides exceptional warmth. Elastic wrist with adjustable strap ensures a snug fit and prevents cold air entry. Non-slip palm grip for secure handling. Perfect for driving, texting, or outdoor activities.',
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
        'description':
            'Complete your winter look with this classic knit beanie hat crafted from soft acrylic yarn. Stretchy ribbed design fits most head sizes comfortably while providing excellent warmth coverage. Cuffed style can be worn folded or unfolded for different looks. Lightweight yet warm, perfect for daily commutes, outdoor sports, or casual outings. Machine washable and maintains shape. Available in versatile colors to match any outfit.',
        'oldPrice': 299.0,
        'newPrice': 199.0,
        'category': 'Fashion',
        'imageUrl':
            'https://evolutionknitwear.com/wp-content/uploads/2020/10/EK1605W_Black_01.jpg',
        'rating': 4.4,
        'reviewsCount': 89,
      },
      // Supermarket Products
      {
        'id': 'p24',
        'name': 'Olive Oil',
        'description':
            'Elevate your cooking with this premium extra virgin olive oil, cold-pressed from the finest Mediterranean olives. Rich in antioxidants and heart-healthy monounsaturated fats, this golden oil delivers authentic flavor and aroma. Perfect for salad dressings, marinades, sautéing, and dipping bread. First cold press ensures maximum nutritional value and superior taste. Packaged in dark glass bottle to preserve freshness and quality.',
        'oldPrice': 179.0,
        'newPrice': 149.0,
        'category': 'Grocery',
        'imageUrl':
            'https://www.gaston.cz/wcd/eshop/files/305/278/images/large/EVO%201l%20FJK.jpg',
        'rating': 4.7,
        'reviewsCount': 156,
        'stock': 0,
      },
      {
        'id': 'p25',
        'name': 'Pasta',
        'description':
            'Bring authentic Italian cuisine to your table with this premium durum wheat pasta. Made from 100% semolina flour using traditional bronze die extrusion for perfect sauce adhesion. Cooks to al dente perfection in just 8-10 minutes. Versatile shape works beautifully with any sauce from simple marinara to rich carbonara. High protein content and low glycemic index. No artificial colors or preservatives.',
        'oldPrice': 55.0,
        'newPrice': 45.0,
        'category': 'Grocery',
        'imageUrl':
            'https://www.osmanmarket.com/us/136/pidwebp600/8645/f132996023956271589130-1.png',
        'rating': 4.5,
        'reviewsCount': 98,
      },
      {
        'id': 'p26',
        'name': 'Rice',
        'description':
            'Enjoy perfectly fluffy rice every time with this premium long-grain white rice. Carefully selected grains are aged to perfection for optimal texture and flavor. Non-sticky consistency makes it ideal for biryani, pilaf, fried rice, or as a side dish. Rich in essential nutrients and easy to digest. Naturally gluten-free. Each grain cooks separately for restaurant-quality results. Resealable packaging maintains freshness.',
        'oldPrice': 229.0,
        'newPrice': 199.0,
        'category': 'Grocery',
        'imageUrl':
            'https://cdn.mafrservices.com/sys-master-root/h3d/h24/61655063461918/334177_main.jpg',
        'rating': 4.6,
        'reviewsCount': 187,
      },
      {
        'id': 'p27',
        'name': 'Honey 500g',
        'description':
            'Savor the natural sweetness of this 100% pure, raw honey harvested from wildflower meadows. Unfiltered and unpasteurized to preserve beneficial enzymes, antioxidants, and pollen. Rich, golden color with complex floral notes. Perfect for sweetening tea, spreading on toast, or using in baking and cooking. Natural antibacterial properties support immune health. No added sugars or artificial ingredients. Crystallization is natural and reversible.',
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
        'description':
            'Awaken your senses with this premium ground coffee crafted from 100% Arabica beans sourced from high-altitude plantations. Medium roast profile delivers balanced flavor with notes of chocolate, caramel, and subtle fruit undertones. Freshly ground for optimal aroma and taste. Perfect for drip coffee makers, French press, or pour-over brewing. Resealable bag with one-way valve preserves freshness. Fair trade certified.',
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
        'description':
            'Experience the rich tradition of premium black tea with this convenient 100-count tea bag box. Carefully selected Ceylon tea leaves deliver robust flavor and invigorating aroma. Each individually wrapped tea bag ensures freshness and convenience. Perfect for morning wake-up or afternoon refreshment. Rich in antioxidants and natural caffeine. Brew for 3-5 minutes for optimal strength. No artificial flavors or additives.',
        'oldPrice': 109.0,
        'newPrice': 89.0,
        'category': 'Grocery',
        'imageUrl':
            'https://www.men-masr.com/cdn/shop/files/El_Arosa_Black_Tea.avif?v=1766325884&width=1445',
        'rating': 4.4,
        'reviewsCount': 76,
        'stock': 0,
      },
      {
        'id': 'p30',
        'name': 'Milk 1.5L',
        'description':
            'Start your day right with this fresh, creamy whole milk packed with essential nutrients. Rich in calcium, protein, and vitamins A and D for strong bones and overall health. Pasteurized and homogenized for safety and smooth texture. Perfect for drinking, cereal, coffee, baking, or cooking. Sourced from local dairy farms committed to quality and animal welfare. No artificial hormones or antibiotics. Refrigerate after opening.',
        'newPrice': 35.0,
        'category': 'Grocery',
        'imageUrl':
            'https://cittamart.com/wp-content/uploads/2023/10/Juhayna-Milk-Long-Life-Full-Cream-1.5-L-1.webp',
        'rating': 4.3,
        'reviewsCount': 45,
        'stock': 0,
      },
      {
        'id': 'p31',
        'name': 'Eggs',
        'description':
            'Enjoy farm-fresh eggs from free-range hens raised on natural feed. Each carton contains 12 large, Grade A eggs with rich, golden yolks and firm whites. Excellent source of high-quality protein, vitamins, and minerals. Perfect for breakfast, baking, or cooking. Versatile ingredient for omelets, scrambled eggs, cakes, and more. Carefully inspected for quality and freshness. Store refrigerated for best results.',
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
        'description':
            'Savor the wholesome goodness of this freshly baked whole wheat bread made from 100% whole grain flour. Soft, fluffy texture with a golden crust and nutty flavor. Rich in dietary fiber, vitamins, and minerals for sustained energy. No artificial preservatives, colors, or flavors. Perfect for sandwiches, toast, or enjoying with your favorite spreads. Baked daily for maximum freshness. Contains essential nutrients for a healthy diet.',
        'newPrice': 25.0,
        'category': 'Grocery',
        'imageUrl':
            'https://cittamart.com/wp-content/uploads/2023/12/Rich-Bake-Normal-Petit-Pain-6-pcs-4.webp',
        'rating': 4.2,
        'reviewsCount': 34,
      },
      {
        'id': 'p33',
        'name': 'Cheese',
        'description':
            'Indulge in the rich, creamy flavor of this premium cheddar cheese block aged to perfection. Made from 100% real milk with no artificial ingredients. Sharp, tangy taste with smooth, firm texture ideal for slicing, grating, or melting. Perfect for sandwiches, burgers, mac and cheese, or cheese boards. Excellent source of calcium and protein. Vacuum-sealed packaging maintains freshness. Refrigerate after opening.',
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
        'description':
            'Transform your pasta dishes with this authentic Italian tomato sauce made from sun-ripened tomatoes, fresh herbs, and extra virgin olive oil. Slow-cooked to develop rich, complex flavors with perfect balance of sweetness and acidity. No added sugar, artificial colors, or preservatives. Ready to heat and serve or use as a base for your own culinary creations. Versatile sauce perfect for pasta, pizza, or meat dishes.',
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

        // Generate 4-7 reviews for each product and store as array
        final numReviews = 4 + _random.nextInt(4);
        final reviews = <Map<String, dynamic>>[];

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

          reviews.add({
            'userId': userId,
            'userName': reviewerName,
            'rating': rating,
            'comment': comment,
            'createdAt': Timestamp.fromDate(reviewDate),
          });
        }

        // Add reviews array to product data
        productData['reviews'] = reviews;

        // Save product with reviews as an array field
        await _firestore.collection('products').doc(productId).set(productData);
      }

      print('✅ Successfully seeded ${products.length} products with reviews!');
    } catch (e) {
      print('❌ Error seeding products: $e');
      rethrow;
    }
  }
}

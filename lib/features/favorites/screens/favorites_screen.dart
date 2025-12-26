import 'package:flutter/material.dart';

class FavoritesScreen extends StatefulWidget {

  @override
  _FavoritesScreenState createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  final List<Map<String, dynamic>> products = [
    {'name': 'Nike Air Max Pegasus 39', 'price': 120.00, 'rating': 4.5, 'image': 'https://via.placeholder.com/150/FF0000/FFFFFF?text=Shoe', 'liked': true},
    {'name': 'Sony WH-1000XM4 Noise Canceling', 'price': 348.00, 'rating': 4.8, 'image': 'https://via.placeholder.com/150/000000/FFFFFF?text=Headphones', 'stock': true, 'liked': true},
    {'name': 'Premium Cotton Classic T-Shirt', 'price': 25.00, 'oldPrice': 35.00, 'rating': 4.0, 'image': 'https://via.placeholder.com/150/FFFFFF/000000?text=Shirt', 'sale': true, 'liked': true},
    {'name': 'Genuine Leather Bifold Wallet', 'price': 45.00, 'rating': 4.7, 'image': 'https://via.placeholder.com/150/8B4513/FFFFFF?text=Wallet', 'liked': true},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Favorites'),
        actions: [
          IconButton(icon: Icon(Icons.filter_list), onPressed: () {}),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('${products.length} items saved', style: TextStyle(color: Colors.grey)),
                TextButton(onPressed: () {}, child: Text('Select All')),
              ],
            ),
          ),
          Expanded(
            child: GridView.builder(
              padding: EdgeInsets.symmetric(horizontal: 16),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.75,
              ),
              itemCount: products.length,
              itemBuilder: (context, index) {
                final product = products[index];
                return Card(
                  clipBehavior: Clip.antiAlias,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Stack(
                        children: [
                          Container(
                            height: 140,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                image: NetworkImage(product['image']),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          Positioned(
                            top: 8,
                            right: 8,
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  product['liked'] = !product['liked'];
                                });
                              },
                              child: Container(
                                padding: EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  product['liked'] ? Icons.favorite : Icons.favorite_border,
                                  color: Colors.red,
                                  size: 20,
                                ),
                              ),
                            ),
                          ),
                          if (product['sale'] == true)
                            Positioned(
                              top: 8,
                              left: 8,
                              child: Container(
                                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.green,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text('SALE', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                              ),
                            ),
                          if (product['stock'] == true)
                            Positioned(
                              top: 8,
                              left: 8,
                              child: Container(
                                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.grey,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text('LOW STOCK', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                              ),
                            ),
                        ],
                      ),
                      Padding(
                        padding: EdgeInsets.all(8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(product['name'], maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 12)),
                            SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(Icons.star, color: Colors.orange, size: 14),
                                Text(' ${product['rating']}', style: TextStyle(fontSize: 12)),
                              ],
                            ),
                            SizedBox(height: 4),
                            Row(
                              children: [
                                Text('\$${product['price'].toStringAsFixed(2)}', style: TextStyle(fontWeight: FontWeight.bold)),
                                if (product['oldPrice'] != null) ...[
                                  SizedBox(width: 4),
                                  Text('\$${product['oldPrice']}', style: TextStyle(decoration: TextDecoration.lineThrough, color: Colors.grey, fontSize: 12)),
                                ],
                              ],
                            ),
                            SizedBox(height: 8),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: () {},
                                child: Text('ADD', style: TextStyle(fontSize: 12)),
                                style: ElevatedButton.styleFrom(
                                  padding: EdgeInsets.symmetric(vertical: 8),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
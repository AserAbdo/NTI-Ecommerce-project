import 'package:flutter/material.dart';

class MyOrdersScreen extends StatelessWidget {
  final List<Map<String, dynamic>> orders = [
    {
      'id': 'ORD-7729-XJ',
      'date': 'Today, 10:22 AM',
      'amount': 84.99,
      'status': 'Processing',
      'color': Colors.blue,
    },
    {
      'id': 'ORD-5521-BV',
      'date': 'Oct 12, 2023',
      'amount': 1299.00,
      'status': 'Shipped',
      'color': Colors.purple,
    },
    {
      'id': 'ORD-3321-MC',
      'date': 'Sep 28, 2024',
      'amount': 45.50,
      'status': 'Delivered',
      'color': Colors.green,
    },
    {
      'id': 'ORD-1102-PP',
      'date': 'Dec 5, 2023',
      'amount': 210.00,
      'status': 'Delivered',
      'color': Colors.green,
    },
    {
      'id': 'ORD-0092-AA',
      'date': 'Aug 03, 2023',
      'amount': 32.00,
      'status': 'Cancelled',
      'color': Colors.red,
    },
  ];

  MyOrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('My Orders'), centerTitle: true),
      body: ListView.builder(
        padding: EdgeInsets.all(16),
        itemCount: orders.length,
        itemBuilder: (context, index) {
          final order = orders[index];
          return Card(
            margin: EdgeInsets.only(bottom: 12),
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Order #${order['id']}',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        order['status'],
                        style: TextStyle(color: order['color']),
                      ),
                    ],
                  ),
                  SizedBox(height: 4),
                  Text(
                    order['date'],
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                  SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Total Amount',
                            style: TextStyle(color: Colors.grey, fontSize: 12),
                          ),
                          Text(
                            '\$${order['amount'].toStringAsFixed(2)}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      TextButton(onPressed: () {}, child: Text('Details')),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

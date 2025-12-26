import 'package:flutter/material.dart';

class AddressesScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Addresses'),
        actions: [TextButton(onPressed: () {}, child: Text('Edit'))],
      ),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          Text('DEFAULT ADDRESS', style: TextStyle(color: Colors.grey, fontSize: 12)),
          SizedBox(height: 8),
          _buildAddressCard('Home', 'Jane Doe\n123 Market St, Apt 4B\nSan Francisco, CA 94103\n(415) 555-0123', true, Icons.home),
          SizedBox(height: 16),
          Text('SAVED ADDRESSES', style: TextStyle(color: Colors.grey, fontSize: 12)),
          SizedBox(height: 8),
          _buildAddressCard('Office', 'Jane Doe\n888 Tech Park Blvd, Suite 100\nSan Jose, CA 95110\n(408) 555-0199', false, Icons.business),
          _buildAddressCard('Mom\'s House', 'Jane Doe\n456 Oak Lane\nAustin, TX 78701\n(512) 555-2865', false, Icons.house),
          _buildAddressCard('Vacation Home', 'Jane Doe', false, Icons.beach_access),
          SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () {},
            icon: Icon(Icons.add),
            label: Text('Add New Address'),
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.all(16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddressCard(String title, String address, bool isDefault, IconData icon) {
    return Card(
      margin: EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(icon, color: Colors.blue),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
                      if (isDefault) ...[
                        SizedBox(width: 8),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text('DEFAULT', style: TextStyle(color: Colors.blue, fontSize: 10)),
                        ),
                      ],
                    ],
                  ),
                  SizedBox(height: 4),
                  Text(address, style: TextStyle(color: Colors.grey, fontSize: 12)),
                ],
              ),
            ),
            Icon(Icons.edit, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
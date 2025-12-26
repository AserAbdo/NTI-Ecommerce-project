import 'package:flutter/material.dart';
import 'package:nti_project/features/favorites/screens/favorites_screen.dart';
import 'package:nti_project/features/profile/screens/address_screen.dart';
import 'package:nti_project/features/orders/screens/my_order_screen.dart';

class AccountScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text('Profile', style: TextStyle(color: Colors.black)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 20),
            Stack(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundImage: NetworkImage('https://ui-avatars.com/api/?name=Ahmed+Mohammed&size=200'),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.check, color: Colors.white, size: 16),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            Text('Ahmed Mohammed', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            Text('ahmed@example.com', style: TextStyle(color: Colors.grey)),
            SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildStatCard(Icons.inbox, '2', 'To Receive'),
                _buildStatCard(Icons.favorite, '15', 'Favorites', color: Colors.red),
                _buildStatCard(Icons.local_offer, '3', 'Coupons', color: Colors.orange),
              ],
            ),
            SizedBox(height: 20),
            _buildSection('Account Settings', [
              _buildMenuItem(Icons.shopping_bag, 'My Orders', () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => MyOrdersScreen()));
              }),
              _buildMenuItem(Icons.location_on, 'My Addresses', () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => AddressesScreen()));
              }),
            ]),
            _buildSection('General', [
              _buildMenuItem(Icons.favorite, 'Favorites', () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => FavoritesScreen()));
              }),
            ]),
            SizedBox(height: 20),
            TextButton.icon(
              onPressed: () {},
              icon: Icon(Icons.logout, color: Colors.red),
              label: Text('Log Out', style: TextStyle(color: Colors.red)),
            ),
            SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(IconData icon, String count, String label, {Color color = Colors.blue}) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8)],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          SizedBox(height: 8),
          Text(count, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          Text(label, style: TextStyle(color: Colors.grey, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Text(title, style: TextStyle(color: Colors.grey, fontSize: 14)),
        ),
        Container(
          color: Colors.white,
          child: Column(children: items),
        ),
      ],
    );
  }

  Widget _buildMenuItem(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: Colors.blue),
      title: Text(title),
      trailing: Icon(Icons.chevron_right, color: Colors.grey),
      onTap: onTap,
    );
  }
}
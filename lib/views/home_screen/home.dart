import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:myapp/controllers/cart_controller.dart';
import 'package:myapp/controllers/profile_controller.dart';
import 'package:myapp/views/cart_screen/cart_screen.dart';
import 'package:myapp/views/category_screen/category_screen.dart';
import 'package:myapp/views/home_screen/home_screen.dart';
import 'package:myapp/views/profile_screen/profile_screen.dart';
import 'package:badges/badges.dart' as badges;

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int _selectedIndex = 0;
  final CartController _cartController = Get.put(CartController());

  @override
  void initState() {
    super.initState();
    Get.put(ProfileController());
  }

  static const List<Widget> _widgetOptions = <Widget>[
    HomeScreen(),
    CategoryScreen(),
    CartScreen(),
    ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: _widgetOptions.elementAt(_selectedIndex)),
      bottomNavigationBar: Obx(() => BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          const BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          const BottomNavigationBarItem(
            icon: Icon(Icons.category),
            label: 'Category',
          ),
          BottomNavigationBarItem(
            icon: badges.Badge(
              badgeContent: Text(
                _cartController.totalItems.value.toString(),
                style: const TextStyle(color: Colors.white, fontSize: 10),
              ),
              showBadge: _cartController.totalItems.value > 0,
              position: badges.BadgePosition.topEnd(top: -12, end: -12),
              child: const Icon(Icons.shopping_cart),
            ),
            label: 'Cart',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.account_circle),
            label: 'Account',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.amber[800],
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
      ),)
    );
  }
}

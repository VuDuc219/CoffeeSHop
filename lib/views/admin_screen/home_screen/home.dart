import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:myapp/controllers/admin_home_controller.dart';
import 'package:myapp/views/admin_screen/home_screen/home_screen.dart';
import 'package:myapp/views/admin_screen/mgmt_product_screen/mgmt_product_screen.dart';
import 'package:myapp/views/admin_screen/profile_screen/profile_screen.dart';

class AdminHome extends StatelessWidget {
  const AdminHome({super.key});

  @override
  Widget build(BuildContext context) {
    var controller = Get.put(AdminHomeController());

    var navScreens = [
      const AdminHomeScreen(),
      const MgmtProductScreen(),
      const AdminProfileScreen(),
    ];

    var navBarItems = [
      const BottomNavigationBarItem(
        icon: Icon(Icons.home_outlined),
        label: "Home",
      ),
      const BottomNavigationBarItem(
        icon: Icon(Icons.shopping_bag_outlined),
        label: "Products",
      ),
      const BottomNavigationBarItem(
        icon: Icon(Icons.person_outline),
        label: "Profile",
      ),
    ];

    return Scaffold(
      body: Obx(
        () => IndexedStack(
          index: controller.navIndex.value,
          children: navScreens,
        ),
      ),
      bottomNavigationBar: Obx(
        () => BottomNavigationBar(
          items: navBarItems,
          currentIndex: controller.navIndex.value,
          onTap: (index) => controller.navIndex.value = index,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: Colors.brown,
          unselectedItemColor: Colors.grey,
        ),
      ),
    );
  }
}

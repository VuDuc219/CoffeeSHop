import 'package:badges/badges.dart' as badges;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:myapp/consts/consts.dart';
import 'package:myapp/controllers/home_controller.dart';
import 'package:myapp/controllers/notification_controller.dart';
import 'package:myapp/services/firestore_services.dart';
import 'package:myapp/views/category_screen/item_details.dart';
import 'package:myapp/views/home_screen/best_sellers_screen.dart';
import 'package:myapp/views/home_screen/search_screen.dart';
import 'package:myapp/views/home_screen/special_screen.dart';
import 'package:myapp/views/notification_screen/notification_screen.dart';
import 'package:myapp/views/widgets_common/home_button.dart';
import 'package:myapp/views/widgets_common/loading_indicator.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();

  OutlineInputBorder _buildBorder(Color color) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: color, width: 1),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(HomeController());
    final notificationController = Get.find<NotificationController>();
    final primaryColor = Theme.of(context).primaryColor;

    return Container(
      padding: const EdgeInsets.all(12),
      color: const Color(0xFF6A4C3A), // Brown background color
      width: context.screenWidth,
      height: context.screenHeight,
      child: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Obx(() {
                return controller.username.value.isEmpty
                    ? const SizedBox.shrink()
                    : Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: const EdgeInsets.only(top: 8, bottom: 12),
                          child: Text(
                            "Hello ${controller.username.value}",
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      );
              }),

              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    // Search box
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'Search anything...',
                          hintStyle: TextStyle(color: Colors.grey[400]),
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.search, color: Colors.grey),
                            onPressed: () {
                              if (_searchController.text.isNotEmpty) {
                                Get.to(() => SearchScreen(title: _searchController.text));
                              }
                            },
                          ),
                          filled: true,
                          fillColor: Colors.grey[100],
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 10,
                          ),
                          border: _buildBorder(Colors.grey.shade300),
                          enabledBorder: _buildBorder(Colors.grey.shade300),
                          focusedBorder: _buildBorder(primaryColor),
                        ),
                        onSubmitted: (value) {
                          if (value.isNotEmpty) {
                            Get.to(() => SearchScreen(title: value));
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    // Notification icon with badge
                    Obx(() => badges.Badge(
                          showBadge: notificationController.totalNotifications > 0,
                          badgeContent: Text(
                            notificationController.totalNotifications.toString(),
                            style: const TextStyle(color: Colors.white, fontSize: 10),
                          ),
                          position: badges.BadgePosition.topEnd(top: -5, end: -5),
                          child: IconButton(
                            icon: const Icon(
                              Icons.notifications_outlined,
                              color: Colors.grey,
                            ),
                            onPressed: () {
                              Get.to(() => const NotificationScreen());
                            },
                          ),
                        )),
                  ],
                ),
              ),

              // Banner Swiper
              10.heightBox,
              VxSwiper.builder(
                autoPlay: true,
                height: 180,
                viewportFraction: 1.0,
                itemCount: slidersList.length,
                itemBuilder: (context, index) {
                  return Image.asset(
                        slidersList[index],
                        fit: BoxFit.fill,
                        width: context.screenWidth,
                      ).box.rounded
                      .clip(Clip.antiAlias)
                      .margin(const EdgeInsets.symmetric(horizontal: 8))
                      .make();
                },
              ),

              // Home Buttons
              10.heightBox,
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  homeButton(
                    width: context.screenWidth / 2.5,
                    height: context.screenHeight * 0.15,
                    icon: icTodaysSpecial,
                    title: "Today's Special",
                    onPress: () {
                      Get.to(() => const SpecialScreen());
                    },
                  ),
                  homeButton(
                    width: context.screenWidth / 2.5,
                    height: context.screenHeight * 0.15,
                    icon: icBestSellers,
                    title: "Best Sellers",
                    onPress: () {
                      Get.to(() => const BestSellersScreen());
                    },
                  ),
                ],
              ),

              // Featured Products Section
              20.heightBox,
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Featured Products",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white, // Changed color for visibility
                  ),
                ),
              ),
              10.heightBox,
              FutureBuilder(
                future: FirestoreServices.getFeaturedProducts(),
                builder: (BuildContext context,
                    AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (!snapshot.hasData) {
                    return Center(child: loadingIndicator());
                  } else if (snapshot.data!.docs.isEmpty) {
                    return "No featured products".text.white.makeCentered();
                  } else {
                    var featuredData = snapshot.data!.docs;
                    return SizedBox(
                      height: 220, // Height of the product list
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: featuredData.length,
                        itemBuilder: (context, index) {
                          var doc = featuredData[index];
                          var product = doc.data() as Map<String, dynamic>;
                          product['id'] = doc.id; // Add this line
                          return Container(
                            margin: const EdgeInsets.only(right: 12),
                            width: 160,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Product Image
                                Image.network(
                                  product['p_imgs'][0],
                                  width: 150,
                                  height: 150,
                                  fit: BoxFit.cover,
                                ),
                                10.heightBox,
                                // Product Name
                                Text(
                                  product['p_name'],
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors
                                        .white, // Changed color for visibility
                                  ),
                                ),
                                5.heightBox,
                                // Product Price
                                Text(
                                  "${product['p_price'][0]}",
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.white70,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ).onTap(() {
                            Get.to(() => ItemDetails(data: product));
                          });
                        },
                      ),
                    );
                  }
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}

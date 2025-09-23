import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:myapp/consts/consts.dart';
import 'package:myapp/controllers/home_controller.dart';
import 'package:myapp/views/widgets_common/home_button.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  OutlineInputBorder _buildBorder(Color color) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: color, width: 1),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(HomeController());
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
                        decoration: InputDecoration(
                          hintText: 'Search anything...',
                          hintStyle: TextStyle(color: Colors.grey[400]),
                          suffixIcon: const Icon(
                            Icons.search,
                            color: Colors.grey,
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
                      ),
                    ),
                    const SizedBox(width: 10),
                    // Notification icon
                    IconButton(
                      icon: const Icon(
                        Icons.notifications_outlined,
                        color: Colors.grey,
                      ),
                      onPressed: () {
                        // Notification action
                      },
                    ),
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
                    onPress: () {},
                  ),
                  homeButton(
                    width: context.screenWidth / 2.5,
                    height: context.screenHeight * 0.15,
                    icon: icBestSellers,
                    title: "Best Sellers",
                    onPress: () {},
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
              SizedBox(
                height: 220, // Height of the product list
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: featuredProducts.length,
                  itemBuilder: (context, index) {
                    final product = featuredProducts[index];
                    return Container(
                      margin: const EdgeInsets.only(right: 12),
                      width: 160,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Product Image
                          Container(
                            height: 140,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              image: DecorationImage(
                                image: AssetImage(product['image']! as String),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          10.heightBox,
                          // Product Name
                          Text(
                            product['name']! as String,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color:
                                  Colors.white, // Changed color for visibility
                            ),
                          ),
                          5.heightBox,
                          // Product Price
                          Text(
                            product['price']! as String,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.white70,
                              fontWeight: FontWeight.bold,
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
        ),
      ),
    );
  }
}

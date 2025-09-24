import 'package:badges/badges.dart' as badges;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:myapp/consts/consts.dart';
import 'package:myapp/controllers/auth_controller.dart';
import 'package:myapp/controllers/cart_controller.dart';
import 'package:myapp/controllers/profile_controller.dart';
import 'package:myapp/views/auth_screen/login_screen.dart';
import 'package:myapp/views/chat_screen/chat_screen.dart';
import 'package:myapp/views/orders_screen/orders_screen.dart';
import 'package:myapp/views/profile_screen/components/details_card.dart';
import 'package:myapp/views/wishlist_screen/wishlist_screen.dart';
import 'package:velocity_x/velocity_x.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late final AuthController authController;
  late final ProfileController profileController;
  late final CartController cartController;

  @override
  void initState() {
    super.initState();
    authController = Get.find<AuthController>();
    profileController = Get.find<ProfileController>();
    cartController = Get.find<CartController>();
    profileController.loadUserData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: Obx(() {
          if (profileController.isLoading.value &&
              profileController.userName.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation(Colors.brown),
              ),
            );
          }

          return Column(
            children: [
              _buildProfileHeader(context, profileController),
              const SizedBox(height: 20),
              _buildDetailsCards(context, profileController, cartController),
              const SizedBox(height: 30),
              _buildMenuOptions(context, authController, profileController),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildProfileHeader(
      BuildContext context, ProfileController controller) {
    return Container(
      padding: const EdgeInsets.all(20),
      color: Colors.brown,
      child: Row(
        children: [
          Obx(() {
            final imageUrl = controller.profileImageUrl.value;
            return CircleAvatar(
              radius: 40,
              backgroundColor: Colors.white24,
              backgroundImage:
                  imageUrl.isNotEmpty ? NetworkImage(imageUrl) : null,
              child: imageUrl.isEmpty
                  ? const Icon(Icons.person, size: 50, color: Colors.white)
                  : null,
            );
          }),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Obx(() => Text(
                      controller.userName.value,
                      style: const TextStyle(
                          fontFamily: bold, fontSize: 18, color: Colors.white),
                    )),
                const SizedBox(height: 5),
                Obx(() => Text(
                      controller.userEmail.value,
                      style: const TextStyle(
                          fontFamily: regular, color: Colors.white70),
                    )),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.white),
            tooltip: 'Edit Profile',
            onPressed: () => _showEditProfileDialog(context, controller),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsCards(
    BuildContext context,
    ProfileController pController,
    CartController cController,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Obx(() => detailsCard(
                count: cController.products.length.toString(),
                title: "In your cart",
                width: context.screenWidth / 3.5,
              )),
          Obx(() => detailsCard(
                count: pController.wishlistCount.value.toString(),
                title: "In your wishlist",
                width: context.screenWidth / 3.5,
              )),
          Obx(() => detailsCard(
                count: pController.orderCount.value.toString(),
                title: "You ordered",
                width: context.screenWidth / 3.5,
              )),
        ],
      ),
    );
  }

  Widget _buildMenuOptions(BuildContext context, AuthController authController,
      ProfileController profileController) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
          boxShadow: [
            BoxShadow(
                color: Colors.black12, blurRadius: 10, offset: Offset(0, -5)),
          ],
        ),
        child: ListView(
          children: [
            const SizedBox(height: 20),
            ListTile(
              leading:
                  const Icon(Icons.list_alt_outlined, color: darkFontGrey),
              title: const Text("My Orders",
                  style: TextStyle(fontFamily: semibold, color: darkFontGrey)),
              onTap: () => Get.to(() => const OrdersScreen()),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.favorite_outline, color: darkFontGrey),
              title: const Text("My Wishlist",
                  style: TextStyle(fontFamily: semibold, color: darkFontGrey)),
              onTap: () => Get.to(() => const WishlistScreen()),
            ),
            const Divider(),
            ListTile(
              leading: Obx(() {
                final unreadCount = profileController.unreadMessageCount.value;
                return badges.Badge(
                  badgeContent: Text(
                    unreadCount.toString(),
                    style: const TextStyle(color: Colors.white),
                  ),
                  showBadge: unreadCount > 0,
                  position: badges.BadgePosition.topEnd(top: -10, end: -12),
                  child: const Icon(Icons.message_outlined, color: darkFontGrey),
                );
              }),
              title: const Text("Messages",
                  style: TextStyle(fontFamily: semibold, color: darkFontGrey)),
              onTap: () {
                // Optimistic update
                profileController.unreadMessageCount.value = 0;

                // Background database update
                profileController.markMessagesAsRead();

                Get.to(() => ChatScreen(
                      friendName: "admin",
                      friendId: "QsoApR4yrPSCqZLOxcagt26k38n2",
                    ));
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout, color: darkFontGrey),
              title: const Text("Log out",
                  style: TextStyle(fontFamily: semibold, color: darkFontGrey)),
              onTap: () async {
                Get.delete<ProfileController>();
                Get.delete<CartController>();
                await authController.signOutMethod();
                Get.offAll(() => const LoginScreen());
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showEditProfileDialog(
      BuildContext context, ProfileController controller) {
    final nameController =
        TextEditingController(text: controller.userName.value);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Profile'),
          content: Obx(() => Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  GestureDetector(
                    onTap: () {
                      if (!controller.isLoading.value) {
                        controller.pickImage();
                      }
                    },
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        CircleAvatar(
                          radius: 40,
                          backgroundColor: Colors.grey.shade300,
                          backgroundImage:
                              controller.profileImageUrl.value.isNotEmpty
                                  ? NetworkImage(
                                      controller.profileImageUrl.value)
                                  : null,
                          child: controller.profileImageUrl.value.isEmpty
                              ? const Icon(Icons.person,
                                  size: 50, color: Colors.white)
                              : null,
                        ),
                        if (controller.isLoading.value)
                          const CircularProgressIndicator(),
                        if (!controller.isLoading.value)
                          const Positioned(
                            bottom: 0,
                            right: 0,
                            child: CircleAvatar(
                              radius: 13,
                              backgroundColor: Colors.black54,
                              child: Icon(Icons.camera_alt,
                                  color: Colors.white, size: 16),
                            ),
                          )
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: nameController,
                    decoration:
                        const InputDecoration(labelText: 'User Name'),
                  ),
                ],
              )),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                await controller.updateProfile(
                    newName: nameController.text);
                Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }
}

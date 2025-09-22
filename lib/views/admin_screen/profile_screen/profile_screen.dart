import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:myapp/controllers/auth_controller.dart';
import 'package:myapp/controllers/profile_controller.dart';
import 'package:myapp/views/auth_screen/login_screen.dart';
import 'package:myapp/views/admin_screen/chat_screen/admin_messages_screen.dart';

class AdminProfileScreen extends StatelessWidget {
  const AdminProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ProfileController controller = Get.find<ProfileController>();

    if (controller.userName.value.isEmpty) {
      controller.loadUserData();
    }

    return Obx(() {
      if (controller.isLoading.value) {
        return const Scaffold(
          body: Center(
            child: CircularProgressIndicator(color: Colors.brown),
          ),
        );
      }

      return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Colors.brown,
          elevation: 0,
          title: const Text(
            "Admin Profile",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.logout, color: Colors.white),
              onPressed: () async {
                // FIXED: Corrected method name and removed unnecessary context
                await Get.find<AuthController>().signOutMethod();
                Get.offAll(() => const LoginScreen());
              },
              tooltip: 'Logout',
            ),
          ],
        ),
        body: Container(
          color: Colors.grey[200],
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
            child: Column(
              children: [
                Row(
                  children: [
                    Obx(() => CircleAvatar(
                          radius: 40,
                          backgroundColor: Colors.brown.shade100,
                          backgroundImage: controller.profileImageUrl.value.isNotEmpty
                              ? NetworkImage(controller.profileImageUrl.value)
                              : null,
                          child: controller.profileImageUrl.value.isEmpty
                              ? const Icon(Icons.person, size: 50, color: Colors.brown)
                              : null,
                        )),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Obx(() => Text(
                                controller.userName.value,
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              )),
                          const SizedBox(height: 4),
                          Obx(() => Text(
                                controller.userEmail.value,
                                style: TextStyle(fontSize: 15, color: Colors.grey[700]),
                              )),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 30),
                _buildMenuList(context),
              ],
            ),
          ),
        ),
      );
    });
  }

  Widget _buildMenuList(BuildContext context) {
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 2,
              blurRadius: 8,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: ListView(
            padding: const EdgeInsets.symmetric(vertical: 10),
            children: [
              ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                leading: const Icon(Icons.mark_chat_read_rounded, color: Colors.brown),
                title: const Text("All User Messages", style: TextStyle(fontWeight: FontWeight.w500)),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  Get.to(() => AdminMessagesScreen());
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

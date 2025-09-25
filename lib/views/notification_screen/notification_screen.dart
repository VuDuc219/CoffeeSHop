import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:myapp/consts/consts.dart';
import 'package:myapp/controllers/notification_controller.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Get the instance of the NotificationController
    final NotificationController controller =
        Get.find<NotificationController>();

    return Scaffold(
      backgroundColor: const Color(0xFFf5f5f5), // A light grey background
      appBar: AppBar(
        title: const Text(
          "Notifications",
          style: TextStyle(fontFamily: semibold, color: Colors.white),
        ),
        backgroundColor: const Color(0xFF6f4e37), // Consistent brown theme
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
      ),
      body: Obx(() {
        // Use Obx to automatically rebuild the widget when the notifications list changes
        if (controller.notifications.isEmpty) {
          // Show a message if there are no notifications
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.notifications_off_outlined,
                  size: 80,
                  color: Colors.grey,
                ),
                SizedBox(height: 16),
                Text(
                  "You have no new notifications",
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey,
                    fontFamily: semibold,
                  ),
                ),
              ],
            ),
          );
        } else {
          // Display the list of notifications
          return ListView.builder(
            padding: const EdgeInsets.all(8.0),
            itemCount: controller.notifications.length,
            itemBuilder: (context, index) {
              final notification = controller.notifications[index];

              // Determine the icon based on the notification type
              IconData iconData = notification.type == 'cart'
                  ? Icons.shopping_cart_outlined
                  : Icons.message_outlined;

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 10,
                    horizontal: 16,
                  ),
                  leading: CircleAvatar(
                    backgroundColor: const Color(0xFF6f4e37).withOpacity(0.1),
                    child: Icon(iconData, color: const Color(0xFF6f4e37)),
                  ),
                  title: Text(
                    notification.title,
                    style: const TextStyle(fontFamily: bold, fontSize: 16),
                  ),
                  subtitle: Text(
                    notification.subtitle,
                    style: const TextStyle(color: Colors.black54),
                  ),
                  onTap: () {
                    // Execute the onTap function defined in the NotificationModel
                    notification.onTap();
                  },
                  trailing: const Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: Colors.grey,
                  ),
                ),
              );
            },
          );
        }
      }),
    );
  }
}

import 'package:get/get.dart';
import 'package:myapp/consts/firebase_consts.dart';
import 'package:myapp/controllers/cart_controller.dart';
import 'package:myapp/controllers/messages_controller.dart';
import 'package:myapp/views/cart_screen/cart_screen.dart';
import 'package:myapp/views/chat_screen/chat_screen.dart';

class NotificationModel {
  final String title;
  final String subtitle;
  final Function onTap;
  final String type;
  NotificationModel({
    required this.title,
    required this.subtitle,
    required this.onTap,
    required this.type,
  });
}

class NotificationController extends GetxController {
  final notifications = <NotificationModel>[].obs;

  int get totalNotifications => notifications.length;

  final MessagesController _messagesController = Get.find<MessagesController>();
  final CartController _cartController = Get.find<CartController>();

  @override
  void onInit() {
    super.onInit();

    // Listeners for reactive changes
    ever(_messagesController.unreadCount, (_) => _updateMessageNotification());
    ever(_cartController.products, (_) => _updateCartNotification());

    // Initial check
    _updateMessageNotification();
    _updateCartNotification();
  }

  void _updateMessageNotification() {
    // Remove any existing message notification to avoid duplicates
    notifications.removeWhere((notification) => notification.type == 'message');

    if (_messagesController.unreadCount.value > 0) {
      const String adminId = "QsoApR4yrPSCqZLOxcagt26k38n2";
      final String currentUserId = auth.currentUser!.uid;

      // Create the consistent chat document ID
      final chatDocId = currentUserId.compareTo(adminId) > 0
          ? '$currentUserId-$adminId'
          : '$adminId-$currentUserId';

      notifications.add(
        NotificationModel(
          title: "You have a new message",
          subtitle:
              "You have ${_messagesController.unreadCount.value} unread message(s). Tap to view.",
          onTap: () {
            notifications.removeWhere((n) => n.type == 'message');

            _messagesController.markMessagesAsRead(chatDocId);

            Get.to(() => ChatScreen(friendName: "admin", friendId: adminId));
          },
          type: 'message',
        ),
      );
    }
  }

  void _updateCartNotification() {
    notifications.removeWhere((notification) => notification.type == 'cart');

    if (_cartController.products.isNotEmpty) {
      notifications.add(
        NotificationModel(
          title: "Items in your cart",
          subtitle:
              "You have ${_cartController.products.length} item(s) waiting. Tap to checkout.",
          onTap: () => Get.to(() => const CartScreen()),
          type: 'cart',
        ),
      );
    }
  }
}

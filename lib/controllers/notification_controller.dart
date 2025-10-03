import 'package:get/get.dart';
import 'package:myapp/controllers/cart_controller.dart';
import 'package:myapp/controllers/profile_controller.dart';
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

  final ProfileController _profileController = Get.find<ProfileController>();
  final CartController _cartController = Get.find<CartController>();

  @override
  void onInit() {
    super.onInit();

    ever(
      _profileController.unreadMessageCount,
      (_) => _updateMessageNotification(),
    );
    ever(_cartController.products, (_) => _updateCartNotification());

    _updateMessageNotification();
    _updateCartNotification();
  }

  void _updateMessageNotification() {
    notifications.removeWhere((notification) => notification.type == 'message');

    if (_profileController.unreadMessageCount.value > 0) {
      const String adminId = "QsoApR4yrPSCqZLOxcagt26k38n2";

      notifications.add(
        NotificationModel(
          title: "You have a new message",
          subtitle:
              "You have ${_profileController.unreadMessageCount.value} unread message(s). Tap to view.",
          onTap: () {
            notifications.removeWhere((n) => n.type == 'message');

            _profileController.markMessagesAsRead();

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

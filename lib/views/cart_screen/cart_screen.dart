import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:myapp/consts/consts.dart';
import 'package:myapp/controllers/cart_controller.dart';
import 'package:myapp/views/cart_screen/shipping_screen.dart'; // Import the new screen

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final CartController controller = Get.find<CartController>();

    return Scaffold(
      backgroundColor: const Color(0xff27221f),
      appBar: AppBar(
        iconTheme: const IconThemeData(
          color: Colors.white, // Set back button color to white
        ),
        title: const Text(
          'Shopping Cart',
          style: TextStyle(fontFamily: semibold, color: Colors.white),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Obx(() {
        if (controller.products.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset('assets/images/empty_cart.png', width: 150),
                const SizedBox(height: 20),
                const Text(
                  'Your cart is empty',
                  style: TextStyle(
                    fontSize: 18,
                    fontFamily: semibold,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Looks like you haven\'t added anything to your cart yet.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white60),
                ),
              ],
            ),
          );
        }

        return Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: controller.products.length,
                itemBuilder: (context, index) {
                  var item = controller.products[index];
                  final itemData = item.data() as Map<String, dynamic>? ?? {};
                  final tprice = (itemData['tprice'] as num? ?? 0).toInt();
                  final qty = (itemData['qty'] as num? ?? 1).toInt();
                  final unitPrice = (qty > 0) ? tprice ~/ qty : 0;
                  final productId = itemData['product_id'];

                  return Card(
                    elevation: 4,
                    color: const Color(0xff39322d),
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: ListTile(
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.network(
                          itemData['img'] ?? '',
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => const Icon(Icons.error, color: Colors.white70),
                        ),
                      ),
                      title: Text(
                        itemData['title'] ?? 'No Title',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontFamily: bold, fontSize: 16, color: Colors.white),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Size: ${itemData['size'] ?? 'N/A'}',
                            style: const TextStyle(color: Colors.white70), // Set size color
                          ),
                          Text(
                            '$tprice VND',
                            style: const TextStyle(
                              fontFamily: semibold,
                              color: golden,
                            ),
                          ),
                        ],
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove_circle_outline, color: Colors.white70),
                            onPressed: () {
                              controller.updateQuantity(
                                docId: item.id,
                                newQuantity: qty - 1,
                                unitPrice: unitPrice,
                                productId: productId,
                              );
                            },
                          ),
                          Text('$qty', style: const TextStyle(color: Colors.white)),
                          IconButton(
                            icon: const Icon(Icons.add_circle_outline, color: Colors.white70),
                            onPressed: () {
                              controller.updateQuantity(
                                docId: item.id,
                                newQuantity: qty + 1,
                                unitPrice: unitPrice,
                                productId: productId,
                              );
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.redAccent),
                            onPressed: () {
                              Get.dialog(
                                AlertDialog(
                                  title: const Text('Confirm Delete'),
                                  content: const Text('Are you sure you want to remove this item?'),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Get.back(),
                                      child: const Text('Cancel'),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        controller.deleteItem(item.id);
                                        Get.back();
                                      },
                                      child: const Text('Delete', style: TextStyle(color: Colors.red)),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            Obx(
              () => Container(
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  color: Color(0xff39322d),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Total Price',
                          style: TextStyle(fontFamily: bold, fontSize: 18, color: Colors.white),
                        ),
                        Text(
                          '${controller.totalP.value} VND',
                          style: const TextStyle(
                            fontFamily: bold,
                            fontSize: 18,
                            color: golden,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Get.to(() => const ShippingDetails()); // Navigate to shipping screen
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: golden,
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        child: const Text(
                          'Proceed to Shipping',
                          style: TextStyle(
                            color: darkFontGrey,
                            fontFamily: semibold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      }),
    );
  }
}

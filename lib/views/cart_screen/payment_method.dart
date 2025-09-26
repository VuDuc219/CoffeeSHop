import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:myapp/consts/consts.dart';
import 'package:myapp/controllers/cart_controller.dart';
import 'package:myapp/views/home_screen/home.dart';

class PaymentMethods extends StatelessWidget {
  const PaymentMethods({super.key});

  @override
  Widget build(BuildContext context) {
    final CartController controller = Get.find<CartController>();
    final List<Map<String, dynamic>> paymentMethods = [
      {'name': 'Momo', 'icon': 'assets/icons/momo.png'},
      {'name': 'Cash on Delivery', 'icon': 'assets/icons/cod.png'},
    ];

    return Scaffold(
      backgroundColor: const Color(0xff27221f),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          "Choose Payment Method",
          style: TextStyle(fontFamily: semibold, color: Colors.white),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Obx(() {
          return Column(
            children: List.generate(paymentMethods.length, (index) {
              final item = paymentMethods[index];
              final bool isSelected = controller.paymentIndex.value == index;

              return GestureDetector(
                onTap: () {
                  controller.changePaymentIndex(index);
                },
                child: Container(
                  margin: const EdgeInsets.only(bottom: 12.0),
                  padding: const EdgeInsets.all(12.0),
                  decoration: BoxDecoration(
                    color: const Color(0xff39322d),
                    borderRadius: BorderRadius.circular(12),
                    border: isSelected
                        ? Border.all(color: golden, width: 2)
                        : null,
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: golden.withOpacity(0.5),
                              blurRadius: 8,
                              spreadRadius: 2,
                            ),
                          ]
                        : [],
                  ),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8.0),
                        child: Image.asset(
                          item['icon']!,
                          width: 50,
                          height: 50,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(
                                Icons.error,
                                color: Colors.white70,
                                size: 40,
                              ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          item['name']!,
                          style: const TextStyle(
                            color: Colors.white,
                            fontFamily: semibold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      if (isSelected)
                        const Icon(Icons.check_circle, color: golden),
                    ],
                  ),
                ),
              );
            }),
          );
        }),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(12.0),
        child: SizedBox(
          width: double.infinity,
          child: Obx(
            () => ElevatedButton(
              onPressed: controller.placingOrder.value
                  ? null
                  : () async {
                      bool success = await controller.placeMyOrder(
                        orderPaymentMethod:
                            paymentMethods[controller
                                .paymentIndex
                                .value]['name'],
                        totalAmount: controller.totalP.value,
                      );
                      if (success) {
                        await controller.clearCart();
                        Get.snackbar(
                          "Success",
                          "Your order has been placed successfully!",
                        );
                        Get.offAll(() => const Home());
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: golden,
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              child: controller.placingOrder.value
                  ? const CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation(Colors.white),
                    )
                  : const Text(
                      'Place my order',
                      style: TextStyle(
                        color: darkFontGrey,
                        fontFamily: semibold,
                        fontSize: 16,
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

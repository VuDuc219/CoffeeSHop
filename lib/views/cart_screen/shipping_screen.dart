import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:myapp/consts/consts.dart';
import 'package:myapp/controllers/cart_controller.dart';
import 'package:myapp/views/cart_screen/payment_method.dart';

class ShippingDetails extends StatelessWidget {
  const ShippingDetails({super.key});

  @override
  Widget build(BuildContext context) {
    final CartController controller = Get.find<CartController>();

    Widget addressTextField = TextFormField(
      controller: controller.addressController,
      style: const TextStyle(color: Colors.white),
      decoration: const InputDecoration(
        hintText: "Address",
        hintStyle: TextStyle(color: Colors.white38),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.white54),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: golden),
        ),
      ),
    );

    Widget phoneTextField = TextFormField(
      controller: controller.phoneController,
      style: const TextStyle(color: Colors.white),
      keyboardType: TextInputType.phone,
      decoration: const InputDecoration(
        hintText: "Phone",
        hintStyle: TextStyle(color: Colors.white38),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.white54),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: golden),
        ),
      ),
    );

    Widget continueButton = SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          if (controller.addressController.text.isEmpty) {
            Get.snackbar(
              "Error",
              "Please enter your address",
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: Colors.red,
              colorText: Colors.white,
            );
            return;
          }

          if (controller.phoneController.text.isEmpty) {
            Get.snackbar(
              "Error",
              "Please enter your phone number",
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: Colors.red,
              colorText: Colors.white,
            );
            return;
          }

          final phoneRegExp = RegExp(
            r'^(0|\+84|84)?(3[2-9]|5[25689]|7[06789]|8[1-689]|9[0-46-9])\d{7}$',
          );

          if (!phoneRegExp.hasMatch(controller.phoneController.text)) {
            Get.snackbar(
              "Error",
              "Invalid Vietnamese phone number format",
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: Colors.red,
              colorText: Colors.white,
            );
            return;
          }

          Get.to(() => const PaymentMethods());
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: golden,
          padding: const EdgeInsets.symmetric(vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
        child: const Text(
          'Continue',
          style: TextStyle(
            color: darkFontGrey,
            fontFamily: semibold,
            fontSize: 16,
          ),
        ),
      ),
    );

    return Scaffold(
      backgroundColor: const Color(0xff27221f),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          "Shipping Info",
          style: TextStyle(fontFamily: semibold, color: Colors.white),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Address",
              style: TextStyle(
                fontFamily: semibold,
                fontSize: 16,
                color: Colors.white70,
              ),
            ),
            const SizedBox(height: 8),
            addressTextField,
            const SizedBox(height: 20),
            const Text(
              "Phone",
              style: TextStyle(
                fontFamily: semibold,
                fontSize: 16,
                color: Colors.white70,
              ),
            ),
            const SizedBox(height: 8),
            phoneTextField,
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(12.0),
        child: continueButton,
      ),
    );
  }
}

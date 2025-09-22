import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:myapp/consts/firebase_consts.dart';
import 'package:velocity_x/velocity_x.dart';

class ProductController extends GetxController {
  var quantity = 1.obs; // Default quantity to 1
  var sizeIndex = 0.obs;
  var totalPrice = 0.obs;
  var priceList = <int>[].obs;
  var userRating = 0.0.obs;

  // Add to cart method
  addToCart({
    required String title,
    required String img,
    required String size,
    required int qty,
    required int tprice,
    required BuildContext context,
  }) async {
    try {
      await firestore.collection(cartCollection).doc().set({
        'title': title,
        'img': img,
        'size': size,
        'qty': qty,
        'tprice': tprice,
        'added_by': auth.currentUser!.uid,
      });
      VxToast.show(context, msg: "Added to cart");
    } catch (e) {
      VxToast.show(context, msg: e.toString());
    }
  }

  void initData(List<dynamic> prices) {
    quantity.value = 1;
    sizeIndex.value = 0;
    userRating.value = 0.0;
    priceList.value = prices
        .map((p) => int.tryParse(p.toString()) ?? 0)
        .toList();
    calculateTotalPrice();
  }

  void changeSizeIndex(int index) {
    sizeIndex.value = index;
    calculateTotalPrice();
  }

  void increaseQuantity(int availableStock) {
    if (quantity.value < availableStock) {
      quantity.value++;
      calculateTotalPrice();
    }
  }

  void decreaseQuantity() {
    if (quantity.value > 1) {
      quantity.value--;
      calculateTotalPrice();
    }
  }

  void calculateTotalPrice() {
    if (priceList.isNotEmpty && sizeIndex.value < priceList.length) {
      totalPrice.value = priceList[sizeIndex.value] * quantity.value;
    } else {
      totalPrice.value = 0;
    }
  }

  void updateUserRating(double rating) {
    userRating.value = rating;
  }
}

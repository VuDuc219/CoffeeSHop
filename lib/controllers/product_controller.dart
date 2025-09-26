import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:myapp/consts/firebase_consts.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProductController extends GetxController {
  var quantity = 1.obs;
  var sizeIndex = 0.obs;
  var totalPrice = 0.obs;
  var priceList = <int>[].obs;
  var userRating = 0.0.obs;
  var salePercentage = 0.obs; // To store sale percentage

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

  void initData(List<dynamic> prices, dynamic sale) {
    quantity.value = 1;
    sizeIndex.value = 0;
    userRating.value = 0.0;
    priceList.value = prices
        .map((p) => int.tryParse(p.toString()) ?? 0)
        .toList();
    salePercentage.value = int.tryParse(sale.toString()) ?? 0;
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
      int basePrice = priceList[sizeIndex.value];
      num finalPrice = basePrice;
      if (salePercentage.value > 0) {
        finalPrice = basePrice - (basePrice * salePercentage.value / 100);
      }
      totalPrice.value = (finalPrice * quantity.value).round();
    } else {
      totalPrice.value = 0;
    }
  }

  // Method to get the original price before discount
  int getOriginalPrice() {
    if (priceList.isNotEmpty && sizeIndex.value < priceList.length) {
      return priceList[sizeIndex.value] * quantity.value;
    }
    return 0;
  }

  void updateUserRating(double rating) {
    userRating.value = rating;
  }

  addToWishlist(docId, context) async {
    await firestore.collection(productsCollection).doc(docId).set({
      'p_wishlist': FieldValue.arrayUnion([auth.currentUser!.uid]),
    }, SetOptions(merge: true));
    VxToast.show(context, msg: "Added to wishlist");
  }

  removeFromWishlist(docId, context) async {
    await firestore.collection(productsCollection).doc(docId).set({
      'p_wishlist': FieldValue.arrayRemove([auth.currentUser!.uid]),
    }, SetOptions(merge: true));
    VxToast.show(context, msg: "Removed from wishlist");
  }
}

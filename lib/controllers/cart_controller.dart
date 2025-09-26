import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:myapp/consts/firebase_consts.dart';
import 'package:flutter/material.dart';
import 'package:myapp/controllers/home_controller.dart';

class CartController extends GetxController {
  final RxList<DocumentSnapshot> products = <DocumentSnapshot>[].obs;
  var totalP = 0.obs;
  var totalItems = 0.obs; // Add this line


  final addressController = TextEditingController();
  final phoneController = TextEditingController();

  var paymentIndex = 0.obs;
  late dynamic productSnapshot;
  var placingOrder = false.obs;

  @override
  void onInit() {
    super.onInit();
    listenToCartChanges();
  }

  void listenToCartChanges() {
    final user = auth.currentUser;
    if (user == null) return;

    firestore
        .collection(cartCollection)
        .where('added_by', isEqualTo: user.uid)
        .snapshots()
        .listen(
          (snapshot) {
            products.assignAll(snapshot.docs);
            calculateTotals(); // Change this line
            productSnapshot = snapshot.docs;
          },
          onError: (error) {
            Get.snackbar("Error", "Failed to listen to cart updates: $error");
          },
        );
  }

  void calculateTotals() {
    totalP.value = 0;
    totalItems.value = 0;
    for (var doc in products) {
      final data = doc.data() as Map<String, dynamic>?;
      if (data != null) {
        if (data.containsKey('tprice')) {
          totalP.value += (data['tprice'] as num).toInt();
        }
        // Use 'qty' to sum up total items
        if (data.containsKey('qty')) {
          totalItems.value += (data['qty'] as num).toInt();
        }
      }
    }
  }


  void changePaymentIndex(int index) {
    paymentIndex.value = index;
  }

  void updateQuantity({
    required String docId,
    required int newQuantity,
    required int unitPrice,
  }) {
    if (newQuantity > 0) {
      firestore.collection(cartCollection).doc(docId).update({
        'qty': newQuantity,
        'tprice': newQuantity * unitPrice,
      });
    } else {
      deleteItem(docId);
    }
  }

  void deleteItem(String docId) {
    firestore.collection(cartCollection).doc(docId).delete();
  }

  Future<bool> placeMyOrder({
    required String orderPaymentMethod,
    required int totalAmount,
  }) async {
    placingOrder(true);
    bool success = false;
    try {
      await firestore.collection(ordersCollection).doc().set({
        'order_code':
            "${DateTime.now().millisecondsSinceEpoch}${Random().nextInt(100)}",
        'order_date': FieldValue.serverTimestamp(),
        'order_by': auth.currentUser!.uid,
        'order_by_name':
            Get.find<HomeController>().username.value, // FIX: Added .value
        'order_by_email': auth.currentUser!.email,
        'order_by_address': addressController.text,
        'order_by_phone': phoneController.text,
        'shipping_method': "Home Delivery",
        'payment_method': orderPaymentMethod,
        'order_placed': true,
        'total_amount': totalAmount,
        'orders': FieldValue.arrayUnion(
          productSnapshot.map((e) {
            final data = e.data() as Map<String, dynamic>;
            return {
              'img': data['img'],
              'qty': data['qty'],
              'size': data['size'] ?? 'N/A',
              'title': data['title'],
            };
          }).toList(),
        ),
      });
      success = true;
    } catch (e) {
      Get.snackbar("Error", "Failed to place order: ${e.toString()}");
      success = false;
    }
    placingOrder(false);
    return success;
  }

  Future<void> clearCart() async {
    WriteBatch batch = firestore.batch();
    for (var doc in productSnapshot) {
      batch.delete(firestore.collection(cartCollection).doc(doc.id));
    }
    await batch.commit();
  }

  @override
  void onClose() {
    addressController.dispose();
    phoneController.dispose();
    super.onClose();
  }
}

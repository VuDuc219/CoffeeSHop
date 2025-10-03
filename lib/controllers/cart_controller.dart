import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:myapp/consts/firebase_consts.dart';
import 'package:flutter/material.dart';
import 'package:myapp/controllers/home_controller.dart';
import 'package:myapp/views/home_screen/home.dart';

class CartController extends GetxController {
  final RxList<DocumentSnapshot> products = <DocumentSnapshot>[].obs;
  var totalP = 0.obs;
  var totalItems = 0.obs;

  int get uniqueItemCount => products.length;

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
            calculateTotals();
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
    required String productId,
  }) async {
    if (newQuantity <= 0) {
      deleteItem(docId);
      return;
    }

    try {
      DocumentSnapshot productDoc = await firestore.collection(productsCollection).doc(productId).get();
      if (!productDoc.exists) {
        Get.snackbar("Error", "Product not found.");
        return;
      }

      final productData = productDoc.data() as Map<String, dynamic>;
      final availableStock = int.tryParse(productData['p_quantity'].toString()) ?? 0;

      if (newQuantity > availableStock) {
        Get.snackbar("Limit Reached", "Sorry, you can't add more than the available stock.",
            snackPosition: SnackPosition.TOP, margin: const EdgeInsets.all(10));
        return;
      }

      firestore.collection(cartCollection).doc(docId).update({
        'qty': newQuantity,
        'tprice': newQuantity * unitPrice,
      });
    } catch (e) {
      Get.snackbar("Error", "Failed to update quantity: $e");
    }
  }


  void deleteItem(String docId) {
    firestore.collection(cartCollection).doc(docId).delete();
  }

  Future<void> placeMyOrder({
    required String orderPaymentMethod,
    required int totalAmount,
  }) async {
    placingOrder(true);

    try {
      await firestore.runTransaction((transaction) async {
        final cartDocs = productSnapshot;
        if (cartDocs == null || cartDocs.isEmpty) {
          throw Exception("Your cart is empty.");
        }

        List<Future<DocumentSnapshot>> productDocFutures = [];
        for (var cartItem in cartDocs) {
          final cartData = cartItem.data() as Map<String, dynamic>;
          final productId = cartData['product_id'];
          DocumentReference productRef = firestore.collection(productsCollection).doc(productId);
          productDocFutures.add(transaction.get(productRef));
        }
        List<DocumentSnapshot> productDocs = await Future.wait(productDocFutures);

        List<Map<String, dynamic>> writeOperations = [];

        for (int i = 0; i < cartDocs.length; i++) {
          var cartItem = cartDocs[i];
          var productDoc = productDocs[i];

          final cartData = cartItem.data() as Map<String, dynamic>;
          final requestedQty = cartData['qty'] as int;
          
          if (!productDoc.exists) {
            throw Exception("Product ${cartData['title']} not found.");
          }

          final productData = productDoc.data() as Map<String, dynamic>;
          final currentStock = int.tryParse(productData['p_quantity'].toString()) ?? 0;

          if (currentStock < requestedQty) {
            throw Exception("Sorry, '${productData['p_name']}' is out of stock or not enough quantity.");
          }

          final newStock = currentStock - requestedQty;
          writeOperations.add({
            'ref': productDoc.reference,
            'data': {'p_quantity': newStock}
          });
        }

        for (var op in writeOperations) {
          transaction.update(op['ref'], op['data']);
        }

        DocumentReference orderDoc = firestore.collection(ordersCollection).doc();
        transaction.set(orderDoc, {
          'order_code': "${DateTime.now().millisecondsSinceEpoch}${Random().nextInt(100)}",
          'order_date': FieldValue.serverTimestamp(),
          'order_by': auth.currentUser!.uid,
          'order_by_name': Get.find<HomeController>().username.value,
          'order_by_email': auth.currentUser!.email,
          'order_by_address': addressController.text,
          'order_by_phone': phoneController.text,
          'shipping_method': "Home Delivery",
          'payment_method': orderPaymentMethod,
          'order_placed': true,
          'total_amount': totalAmount,
          'orders': FieldValue.arrayUnion(
            cartDocs.map((e) {
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
      });

      await clearCart();
      Get.snackbar("Success", "Your order has been placed successfully!");
      Get.offAll(() => const Home());

    } catch (e) {
      Get.snackbar("Order Failed", e.toString().replaceFirst("Exception: ", ""));
    } finally {
      placingOrder(false);
    }
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

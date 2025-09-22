import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:myapp/consts/firebase_consts.dart';

class CartController extends GetxController {
  final RxList<DocumentSnapshot> products = <DocumentSnapshot>[].obs;
  var totalP = 0.obs;

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
        .listen((snapshot) {
      products.assignAll(snapshot.docs);
      calculateTotalPrice();
    }, onError: (error) {
      Get.snackbar("Error", "Failed to listen to cart updates: $error");
    });
  }

  void calculateTotalPrice() {
    totalP.value = 0;
    for (var doc in products) {
      final data = doc.data() as Map<String, dynamic>?;
      if (data != null && data.containsKey('tprice')) {
        totalP.value += (data['tprice'] as num).toInt();
      }
    }
  }

  void updateQuantity({required String docId, required int newQuantity, required int unitPrice}) {
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
}

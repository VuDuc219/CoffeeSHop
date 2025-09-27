import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:myapp/consts/firebase_consts.dart';

class ItemDetailsController extends GetxController {
  final String productId;

  ItemDetailsController({required this.productId});

  var avgRating = 0.0.obs;
  var ratingCount = 0.obs;
  var yourRating = 0.0.obs;
  var hasPurchased = false.obs;
  var isSubmitting = false.obs;
  var isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    fetchRatingData();
  }

  double _dynamicToDouble(dynamic val) {
    if (val == null) return 0.0;
    if (val is num) return val.toDouble();
    if (val is String) return double.tryParse(val) ?? 0.0;
    return 0.0;
  }

  int _dynamicToInt(dynamic val) {
    if (val == null) return 0;
    if (val is num) return val.toInt();
    if (val is String) return int.tryParse(val) ?? 0;
    return 0;
  }

  Future<void> fetchRatingData() async {
    isLoading.value = true;
    try {
      final userId = auth.currentUser?.uid;

      final productDoc = await firestore.collection(productsCollection).doc(productId).get();
      final productData = productDoc.data();

      String productName = "";

      if (productDoc.exists && productData != null) {
        avgRating.value = _dynamicToDouble(productData['p_rating']);
        ratingCount.value = _dynamicToInt(productData['rating_count']);
        productName = productData['p_name'] ?? ""; // Get product name for matching
      }

      if (userId == null) {
        hasPurchased.value = false;
        yourRating.value = 0.0;
        isLoading.value = false;
        return;
      }

      final userRatingFuture = firestore.collection(productsCollection).doc(productId).collection('ratings').doc(userId).get();
      final userOrdersFuture = firestore.collection(ordersCollection).where('order_by', isEqualTo: userId).get();

      final results = await Future.wait([userRatingFuture, userOrdersFuture]);

      final userRatingDoc = results[0] as DocumentSnapshot;
      if (userRatingDoc.exists) {
        yourRating.value = _dynamicToDouble(userRatingDoc.get('rating'));
      }

      // *** FINAL FIX: Check purchase by NAME, not ID ***
      final ordersSnapshot = results[1] as QuerySnapshot;
      bool foundPurchase = false;
      if (ordersSnapshot.docs.isNotEmpty && productName.isNotEmpty) {
        for (final orderDoc in ordersSnapshot.docs) {
          final orderData = orderDoc.data() as Map<String, dynamic>? ?? {};
          if (orderData.containsKey('orders') && orderData['orders'] is List) {
            final List<dynamic> productsInOrder = orderData['orders'];
            // Match by 'title' field in order items against the product's actual name
            final bool productFound = productsInOrder.any((product) =>
                product is Map && product.containsKey('title') && product['title'] == productName);
            if (productFound) {
              foundPurchase = true;
              break;
            }
          }
        }
      }
      hasPurchased.value = foundPurchase;

    } catch (e) {
      Get.snackbar('Error', 'Failed to load rating data: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> submitRating(double rating) async {
    final userId = auth.currentUser?.uid;
    if (userId == null) {
      Get.snackbar('Error', 'You must be logged in to rate.');
      return;
    }
    if (!hasPurchased.value) {
      Get.snackbar('Notice', 'You can only rate products you have purchased.');
      return;
    }

    isSubmitting.value = true;
    try {
      await firestore
          .collection(productsCollection)
          .doc(productId)
          .collection('ratings')
          .doc(userId)
          .set({
        'rating': rating,
        'timestamp': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      yourRating.value = rating;
      Get.snackbar('Success', 'Thank you for your rating!');

      Future.delayed(const Duration(seconds: 3), () => fetchRatingData());

    } catch (e) {
      Get.snackbar('Error', 'Failed to submit rating: $e');
    } finally {
      isSubmitting.value = false;
    }
  }
}

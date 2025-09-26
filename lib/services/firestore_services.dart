import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:myapp/consts/firebase_consts.dart';

class FirestoreServices {
  static getUser(uid) {
    return firestore
        .collection(usersCollection)
        .where('id', isEqualTo: uid)
        .snapshots();
  }

  static getProductsByCategory(String category) {
    return firestore
        .collection(productsCollection)
        .where('p_category', isEqualTo: category)
        .snapshots();
  }

  static getCart(uid) {
    return firestore
        .collection(cartCollection)
        .where('added_by', isEqualTo: uid)
        .snapshots();
  }

  static deleteDocument(docId) {
    return firestore.collection(cartCollection).doc(docId).delete();
  }

  static Future<int> getWishlistCount(String uid) async {
    var snapshot = await firestore
        .collection(productsCollection)
        .where('p_wishlist', arrayContains: uid)
        .get();
    return snapshot.docs.length;
  }

  static Future<int> getOrderCount(String uid) async {
    var snapshot = await firestore
        .collection(ordersCollection)
        .where('order_by', isEqualTo: uid)
        .get();
    return snapshot.docs.length;
  }

  static getChatMessages(String docId) {
    return firestore
        .collection(chatsCollection)
        .doc(docId)
        .collection(messagesCollection)
        .orderBy('created_on', descending: false)
        .snapshots();
  }

  static getAllMessages() {
    return firestore
        .collection(chatsCollection)
        .where('users', arrayContains: auth.currentUser!.uid)
        .snapshots();
  }

  static getAllOrders() {
    return firestore
        .collection(ordersCollection)
        .where('order_by', isEqualTo: auth.currentUser!.uid)
        .snapshots();
  }

  static getWishlists() {
    return firestore
        .collection(productsCollection)
        .where('p_wishlist', arrayContains: auth.currentUser!.uid)
        .snapshots();
  }

  static getFeaturedProducts() {
    return firestore
        .collection(productsCollection)
        .where('is_featured', isEqualTo: true)
        .get();
  }

  static searchProducts() {
    return firestore.collection(productsCollection).get();
  }
  
  static getSaleProducts() {
    return firestore
        .collection(productsCollection)
        .where('p_sale', isNotEqualTo: '')
        .snapshots();
  }

  static Future<List<DocumentSnapshot>> getBestSellingProducts() async {
    final ordersSnapshot = await firestore.collection(ordersCollection).get();

    if (ordersSnapshot.docs.isEmpty) {
      return [];
    }

    final Map<String, int> productQuantities = {};

    for (var orderDoc in ordersSnapshot.docs) {
      final orderData = orderDoc.data();
      if (orderData.containsKey('orders')) {
        for (var item in orderData['orders']) {
          if (item['title'] != null && item['qty'] != null) {
            final String title = item['title'];
            final int quantity = item['qty'];
            productQuantities[title] =
                (productQuantities[title] ?? 0) + quantity;
          }
        }
      }
    }

    if (productQuantities.isEmpty) {
      return [];
    }

    final sortedProducts = productQuantities.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final topProductTitles = sortedProducts.take(6).map((e) => e.key).toList();

    if (topProductTitles.isEmpty) {
      return [];
    }

    final productsSnapshot = await firestore
        .collection(productsCollection)
        .where('p_name', whereIn: topProductTitles)
        .get();

    final sortedDocs = <DocumentSnapshot>[];
    for (var title in topProductTitles) {
      for (var doc in productsSnapshot.docs) {
        if (doc['p_name'] == title) {
          sortedDocs.add(doc);
          break;
        }
      }
    }

    return sortedDocs;
  }
}

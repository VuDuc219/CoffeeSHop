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

  // Methods to get all orders and wishlists for the current user
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
}

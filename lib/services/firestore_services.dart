import 'package:myapp/consts/firebase_consts.dart';

class FirestoreServices {
  //get users data
  static getUser(uid) {
    return firestore
        .collection(usersCollection)
        .where('id', isEqualTo: uid)
        .snapshots();
  }

  // get products by category
  static getProductsByCategory(String category) {
    return firestore
        .collection(productsCollection)
        .where('p_category', isEqualTo: category)
        .snapshots();
  }

  // get cart items
  static getCart(uid) {
    return firestore
        .collection(cartCollection)
        .where('added_by', isEqualTo: uid)
        .snapshots();
  }

  // delete item from cart
  static deleteDocument(docId) {
    return firestore.collection(cartCollection).doc(docId).delete();
  }

  static Future<int> getCartCount(String uid) async {
    var snapshot = await firestore
        .collection(cartCollection)
        .where('added_by', isEqualTo: uid)
        .get();
    return snapshot.docs.length;
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

  // Get all chat messages for a specific chat
  static getChatMessages(String docId) {
    return firestore
        .collection(chatsCollection)
        .doc(docId)
        .collection(messagesCollection)
        .orderBy('created_on', descending: false)
        .snapshots();
  }

  // Get all conversations for the current user
  static getAllMessages() {
    // Assuming 'users' field is an array of participant UIDs
    return firestore
        .collection(chatsCollection)
        .where('users', arrayContains: auth.currentUser!.uid) // CORRECTED
        .snapshots();
  }
}

import 'dart:async';
import 'dart:io';
import 'dart:developer' as developer;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:myapp/consts/firebase_consts.dart';
import 'package:myapp/services/firestore_services.dart';
import 'package:path/path.dart';

class ProfileController extends GetxController {
  var isLoading = false.obs;

  final RxInt unreadMessageCount = 0.obs;
  StreamSubscription<QuerySnapshot>? _unreadMessagesSubscription;

  final Rx<String> userName = ''.obs;
  final Rx<String> userEmail = ''.obs;
  final Rx<String> profileImageUrl = ''.obs;
  final Rx<int> wishlistCount = 0.obs;
  final Rx<int> orderCount = 0.obs;
  var pickedImagePath = ''.obs;

  @override
  void onInit() {
    super.onInit();
    if (auth.currentUser != null) {
      _initializeStreams(auth.currentUser!.uid);
      loadUserData();
    }
  }

  @override
  void onClose() {
    _unreadMessagesSubscription?.cancel();
    super.onClose();
  }

  void _initializeStreams(String userId) {
    _unreadMessagesSubscription?.cancel(); // Cancel any existing subscription
    final stream = firestore
        .collectionGroup(messagesCollection)
        .where('toId', isEqualTo: userId)
        .where('read', isEqualTo: '')
        .snapshots();

    // Listen to the stream and update the local count
    _unreadMessagesSubscription = stream.listen((snapshot) {
      unreadMessageCount.value = snapshot.docs.length;
    }, onError: (error) {
      developer.log("Error listening to unread messages", error: error);
      unreadMessageCount.value = 0;
    });
  }

  Future<void> loadUserData() async {
    isLoading.value = true;
    final user = auth.currentUser;
    if (user != null) {
      try {
        final doc = await firestore
            .collection(usersCollection)
            .doc(user.uid)
            .get();
        final data = doc.data();
        if (data != null) {
          userName.value = data['name'] ?? 'No Name';
          userEmail.value = data['email'] ?? 'No Email';
          profileImageUrl.value = data['imageUrl'] ?? '';
        }

        wishlistCount.value = await FirestoreServices.getWishlistCount(user.uid);
        orderCount.value = await FirestoreServices.getOrderCount(user.uid);
      } catch (e) {
        Get.snackbar("Error", "Failed to load user data: $e");
      } finally {
        isLoading.value = false;
      }
    } else {
      isLoading.value = false;
    }
  }

  Future<void> markMessagesAsRead() async {
    final user = auth.currentUser;
    if (user == null) return;

    try {
      final unreadMessages = await firestore
          .collectionGroup(messagesCollection)
          .where('toId', isEqualTo: user.uid)
          .where('read', isEqualTo: '')
          .get();

      final batch = firestore.batch();
      for (var doc in unreadMessages.docs) {
        batch.update(doc.reference, {'read': FieldValue.serverTimestamp()});
      }
      await batch.commit();
    } catch (e) {
      developer.log(
        "Error marking messages as read",
        name: "ProfileController",
        error: e,
      );
    }
  }

  // All other methods remain the same
  Future<void> pickImage() async {
    try {
      final pickedFile = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        imageQuality: 50,
      );
      if (pickedFile != null) {
        pickedImagePath.value = pickedFile.path;
        await uploadProfilePicture();
      }
    } catch (e) {
      Get.snackbar("Image Picking Error", e.toString());
    }
  }

  Future<void> uploadProfilePicture() async {
    if (pickedImagePath.value.isEmpty) return;

    isLoading.value = true;
    Get.snackbar("Uploading", "Attempting to upload picture...");

    final user = auth.currentUser;
    if (user == null) {
      isLoading.value = false;
      return;
    }

    try {
      final String uniqueFileName =
          '${user.uid}-${DateTime.now().millisecondsSinceEpoch}${extension(pickedImagePath.value)}';
      final ref = storage
          .ref()
          .child('images')
          .child(user.uid)
          .child(uniqueFileName);

      await ref.putFile(File(pickedImagePath.value));

      final newUrl = await ref.getDownloadURL();

      await firestore.collection(usersCollection).doc(user.uid).update({
        'imageUrl': newUrl,
      });

      profileImageUrl.value = newUrl;
      Get.snackbar("Success!", "Profile picture updated.");
    } catch (e, s) {
      developer.log(
        'CRITICAL UPLOAD FAILED',
        name: 'ProfileController',
        error: e,
        stackTrace: s,
      );
      Get.snackbar(
        "Upload Error",
        "Could not upload file: ${e.toString()}",
        duration: const Duration(seconds: 10), // Give time to read the error
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateProfile({required String newName}) async {
    final user = auth.currentUser;
    if (user == null) return;

    isLoading.value = true;
    try {
      await firestore.collection(usersCollection).doc(user.uid).update({
        'name': newName,
      });

      userName.value = newName;
      Get.snackbar("Success", "Profile name updated!");
    } catch (e) {
      Get.snackbar("Error", "Failed to update profile: $e");
    } finally {
      isLoading.value = false;
    }
  }
}

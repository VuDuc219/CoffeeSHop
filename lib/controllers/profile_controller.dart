import 'dart:io';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:myapp/consts/firebase_consts.dart';
import 'package:myapp/services/firestore_services.dart';
import 'package:path/path.dart';

class ProfileController extends GetxController {
  var isLoading = false.obs;

  final Rx<String> userName = ''.obs;
  final Rx<String> userEmail = ''.obs;
  final Rx<String> profileImageUrl = ''.obs;
  final Rx<int> wishlistCount = 0.obs;
  final Rx<int> orderCount = 0.obs;

  var pickedImagePath = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadUserData();
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
    Get.snackbar("Uploading", "Your new profile picture is being uploaded...");

    final user = auth.currentUser;
    if (user == null) return;

    final fileName = basename(pickedImagePath.value);
    final destination = 'images/${user.uid}/$fileName';

    try {
      final ref = storage.ref(destination);
      await ref.putFile(File(pickedImagePath.value));
      final url = await ref.getDownloadURL();

      await firestore.collection(usersCollection).doc(user.uid).update({
        'imageUrl': url,
      });

      profileImageUrl.value = url;
      Get.snackbar("Success", "Profile picture updated!");
    } catch (e) {
      Get.snackbar("Error", "Failed to upload image: $e");
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

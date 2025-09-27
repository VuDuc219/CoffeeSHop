import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:myapp/consts/firebase_consts.dart';

class AuthController extends GetxController {
  var isloading = false.obs;

  //text controllers
  var emailController = TextEditingController();
  var passwordController = TextEditingController();
  var nameController = TextEditingController();

  User? get currentUser => auth.currentUser;

  Future<UserCredential?> signupMethod({
    required String email,
    required String password,
    required BuildContext context,
  }) async {
    UserCredential? userCredential;
    isloading.value = true;
    try {
      userCredential = await auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      Get.snackbar("Error signing up", e.toString());
    } finally {
      isloading.value = false;
    }
    return userCredential;
  }

  Future<UserCredential?> loginMethod({
    required String email,
    required String password,
    required BuildContext context,
  }) async {
    UserCredential? userCredential;
    isloading.value = true;
    try {
      userCredential = await auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      Get.snackbar("Error logging in", e.toString());
    } finally {
      isloading.value = false;
    }
    return userCredential;
  }

  storeUserData({
    required String name,
    required String password,
    required String email,
  }) async {
    DocumentReference store = firestore
        .collection(usersCollection)
        .doc(auth.currentUser!.uid);
    await store.set({
      'id': auth.currentUser!.uid,
      'name': name,
      'password': password,
      'email': email,
      'imageUrl': '',
      'cart_count': '00',
      'order_count': '00',
      'whishlist_count': '00',
    });
  }

   Future<void> resetPassword(String email) async {
    isloading.value = true;
    try {
      await auth.sendPasswordResetEmail(email: email);
      Get.snackbar("Success", "Password reset email sent. Please check your inbox.");
    } on FirebaseAuthException catch (e) {
      Get.snackbar("Error sending email", e.toString());
    } finally {
      isloading.value = false;
    }
  }

    Future<void> changePassword(String oldPassword, String newPassword) async {
    isloading.value = true;
    try {
      // Re-authenticate user
      AuthCredential credential = EmailAuthProvider.credential(
        email: currentUser!.email!,
        password: oldPassword,
      );
      await currentUser!.reauthenticateWithCredential(credential);

      // Change password
      await currentUser!.updatePassword(newPassword);

      Get.snackbar("Success", "Your password has been changed successfully.");
    } on FirebaseAuthException catch (e) {
      Get.snackbar("Error changing password", e.toString());
    } finally {
      isloading.value = false;
    }
  }


  // FIXED: Removed unused context parameter
  Future<void> signOutMethod() async {
    try {
      await auth.signOut();
    } catch (e) {
      Get.snackbar("Error signing out", e.toString());
    }
  }
}

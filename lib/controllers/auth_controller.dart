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

  // FIXED: Removed unused context parameter
  Future<void> signOutMethod() async {
    try {
      await auth.signOut();
    } catch (e) {
      Get.snackbar("Error signing out", e.toString());
    }
  }
}

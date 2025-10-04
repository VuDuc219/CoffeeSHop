import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:myapp/consts/firebase_consts.dart';

class ChatController extends GetxController {
  var friendName = Get.arguments[0];
  var friendId = Get.arguments[1];

  late String senderName;
  var currentId = auth.currentUser!.uid;

  final messageController = TextEditingController();

  dynamic chatDocId;
  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    isLoading.value = true;
    getSenderName().then((_) {
      getChatId().then((_) {
        isLoading.value = false;
      });
    });
  }

  getSenderName() async {
    var userDoc = await firestore
        .collection(usersCollection)
        .doc(currentId)
        .get();
    if (userDoc.exists) {
      senderName = userDoc.data()?['name'] ?? 'Unknown User';
    } else {
      senderName = 'Unknown User';
    }
  }

  getChatId() async {
    List<String> sortedIds = [currentId, friendId];
    sortedIds.sort();
    chatDocId = sortedIds.join('_');

    var chatDocumentRef = firestore.collection(chatsCollection).doc(chatDocId);
    var docSnapshot = await chatDocumentRef.get();

    if (!docSnapshot.exists) {
      await chatDocumentRef.set({
        'created_on': FieldValue.serverTimestamp(),
        'last_msg': '',
        'last_msg_time': FieldValue.serverTimestamp(),
        'users': [currentId, friendId],
        'friend_name': friendName,
        'sender_name': senderName,
        'admin_unread_count': 0,
        'user_unread_count': 0,
      });
    }
  }

  sendMessage(String msg) async {
    if (msg.trim().isEmpty) return;

    var chatDocumentRef = firestore.collection(chatsCollection).doc(chatDocId);

    await chatDocumentRef.collection(messagesCollection).add({
      'created_on': FieldValue.serverTimestamp(),
      'msg': msg,
      'uid': currentId,
    });

    const adminId = 'QsoApR4yrPSCQzLOxcagt26k38n2';

    await chatDocumentRef.update({
      'last_msg': msg,
      'last_msg_time': FieldValue.serverTimestamp(),
      if (currentId != adminId) 'admin_unread_count': FieldValue.increment(1),
      if (currentId == adminId) 'user_unread_count': FieldValue.increment(1),
    });
  }
}

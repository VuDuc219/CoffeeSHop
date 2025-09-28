import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:myapp/consts/firebase_consts.dart';

class ChatController extends GetxController {
  late CollectionReference chats;

  var friendName = Get.arguments[0];
  var friendId = Get.arguments[1];

  var senderName = ''.obs;
  var currentId = ''.obs;

  final messageController = TextEditingController();

  dynamic chatDocId;

  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    chats = firestore.collection(chatsCollection);
    getChatId().then((value) {
      isLoading.value = false;
    });
  }

  getChatId() async {
    isLoading.value = true;
    await chats
        .where('users', isEqualTo: {friendId: null, currentId.value: null})
        .limit(1)
        .get()
        .then((QuerySnapshot snapshot) {
          if (snapshot.docs.isNotEmpty) {
            chatDocId = snapshot.docs.single.id;
          } else {
            chats
                .add({
                  'users': {friendId: null, currentId.value: null},
                  'friend_name': friendName,
                  'sender_name': senderName.value,
                  // Initialize fields for the new chat
                  'last_msg': '',
                  'last_msg_time': FieldValue.serverTimestamp(),
                  'admin_unread_count': 0,
                })
                .then((value) => {chatDocId = value});
          }
        });
  }

  sendMessage(String msg) async {
    if (msg.trim().isNotEmpty) {
      // 1. Add the new message
      chats.doc(chatDocId).collection(messagesCollection).add({
        'created_on': FieldValue.serverTimestamp(),
        'msg': msg,
        'uid': currentId.value,
      });

      // 2. Update the parent chat document
      chats.doc(chatDocId).update({
        'last_msg': msg,
        'last_msg_time': FieldValue.serverTimestamp(),
        'admin_unread_count': FieldValue.increment(1),
      });
    }
  }

  void markMessagesAsRead(String chatDocId) {
    var chatRef = chats.doc(chatDocId).collection(messagesCollection);
    chatRef.where('uid', isNotEqualTo: currentId.value).get().then((snapshot) {
      for (var doc in snapshot.docs) {
        doc.reference.update({'read': true});
      }
    });
  }
}

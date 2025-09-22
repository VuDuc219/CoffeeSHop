import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:myapp/consts/firebase_consts.dart';
import 'package:myapp/controllers/profile_controller.dart';

class ChatsController extends GetxController {
  final String friendName;
  final String friendId;
  late String senderName;

  late String currentId;
  var msgController = TextEditingController();
  dynamic chatDocId;
  var isLoading = false.obs;

  var chats = firestore.collection(chatsCollection);

  ChatsController({required this.friendName, required this.friendId});

  @override
  void onInit() {
    super.onInit();
    currentId = auth.currentUser!.uid;
    // FIXED: Used the correct property 'userName' instead of 'name'
    senderName = Get.find<ProfileController>().userName.value;
    createSecureChatRoom();
  }

  createSecureChatRoom() async {
    isLoading(true);

    if (currentId.hashCode <= friendId.hashCode) {
      chatDocId = '$currentId-$friendId';
    } else {
      chatDocId = '$friendId-$currentId';
    }

    var chatDocument = chats.doc(chatDocId);
    var docSnapshot = await chatDocument.get();

    if (!docSnapshot.exists) {
      await chatDocument.set({
        'created_on': FieldValue.serverTimestamp(),
        'last_msg': '',
        'last_msg_time': FieldValue.serverTimestamp(),
        'users': [currentId, friendId],
        'friend_name': friendName,
        'sender_name': senderName,
      });
    }

    isLoading(false);
  }

  sendMsg(String msg) async {
    if (msg.trim().isNotEmpty) {
      if (chatDocId != null) {
        var chatDocument = chats.doc(chatDocId);

        await chatDocument.collection(messagesCollection).doc().set({
          'created_on': FieldValue.serverTimestamp(),
          'msg': msg,
          'uid': currentId,
        });

        await chatDocument.update({
          'last_msg': msg,
          'last_msg_time': FieldValue.serverTimestamp(),
        });
      }
    }
  }
}

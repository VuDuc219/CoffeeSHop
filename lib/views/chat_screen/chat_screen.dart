import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:myapp/consts/consts.dart';
import 'package:myapp/controllers/chats_controller.dart';
import 'package:myapp/views/chat_screen/components/receiver_bubble.dart';
import 'package:myapp/views/chat_screen/components/sender_bubble.dart';

class ChatScreen extends StatefulWidget {
  final String friendName;
  final String friendId;
  const ChatScreen({
    super.key,
    required this.friendName,
    required this.friendId,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  late final ChatsController controller;

  @override
  void initState() {
    super.initState();
    // Pass the friend details to the controller upon initialization
    controller = Get.put(
      ChatsController(friendId: widget.friendId, friendName: widget.friendName),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        iconTheme: const IconThemeData(
          color: Colors.black, // Make back arrow black
        ),
        title: Text(
          widget.friendName, // Use the friend's name from the widget
          style: const TextStyle(fontFamily: semibold, color: Colors.black),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Obx(() {
              if (controller.isLoading.value) {
                return const Expanded(
                  child: Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation(redColor),
                    ),
                  ),
                );
              }

              return Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('chats')
                      .doc(controller.chatDocId)
                      .collection('messages')
                      .orderBy('created_on', descending: false)
                      .snapshots(),
                  builder:
                      (
                        BuildContext context,
                        AsyncSnapshot<QuerySnapshot> snapshot,
                      ) {
                        if (!snapshot.hasData) {
                          return const Center(
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation(redColor),
                            ),
                          );
                        }
                        if (snapshot.data!.docs.isEmpty) {
                          return const Center(child: Text("Send a message..."));
                        }

                        return ListView(
                          children: snapshot.data!.docs.map((
                            DocumentSnapshot document,
                          ) {
                            var data = document.data()! as Map<String, dynamic>;
                            var isSender = data['uid'] == controller.currentId;

                            var t = data['created_on'] == null
                                ? DateTime.now()
                                : (data['created_on'] as Timestamp).toDate();
                            var time = DateFormat("h:mm a").format(t);

                            return Align(
                              alignment: isSender
                                  ? Alignment.centerRight
                                  : Alignment.centerLeft,
                              child: isSender
                                  // FIXED: Passed the 'time' variable to the senderBubble.
                                  ? senderBubble(
                                      context,
                                      message: data['msg'] ?? '...',
                                      time: time,
                                    )
                                  : receiverBubble(
                                      context,
                                      message: data['msg'] ?? '...',
                                      time: time,
                                    ),
                            );
                          }).toList(),
                        );
                      },
                ),
              );
            }),
            const SizedBox(height: 10),
            // Text input field
            buildMessageInput(controller),
          ],
        ),
      ),
    );
  }

  Widget buildMessageInput(ChatsController controller) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: controller.msgController,
            maxLines: 1,
            decoration: InputDecoration(
              hintText: "Type a message...",
              isDense: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: fontGrey),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: redColor),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        IconButton(
          icon: const Icon(Icons.send, color: redColor),
          onPressed: () {
            if (controller.msgController.text.isNotEmpty) {
              controller.sendMsg(controller.msgController.text);
              controller.msgController.clear();
            }
          },
        ),
      ],
    );
  }
}

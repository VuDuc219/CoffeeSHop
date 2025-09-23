import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:myapp/consts/firebase_consts.dart';
import 'package:myapp/views/chat_screen/chat_screen.dart';

class AdminMessagesScreen extends StatelessWidget {
  AdminMessagesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final String currentAdminId = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "User Conversations",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.brown,
        iconTheme: const IconThemeData(
          color: Colors.white,
        ), // Make back button white
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: firestore
            .collection(chatsCollection)
            .where('users', arrayContains: currentAdminId)
            .snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text('Something went wrong: ${snapshot.error}'),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation(Colors.brown),
              ),
            );
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No conversations yet!"));
          }

          final conversations = snapshot.data!.docs;

          return ListView.separated(
            itemCount: conversations.length,
            separatorBuilder: (context, index) =>
                const Divider(height: 1, indent: 80, color: Colors.black12),
            itemBuilder: (context, index) {
              DocumentSnapshot doc = conversations[index];
              Map<String, dynamic> data = doc.data()! as Map<String, dynamic>;

              // --- Determine the other user's ID from the 'users' array ---
              List<dynamic> users = data['users'] ?? [];
              String friendId = users.firstWhere(
                (id) => id != currentAdminId,
                orElse: () => '',
              );

              if (friendId.isEmpty) {
                return const SizedBox.shrink();
              }

              String friendName = data['friend_name'] ?? 'Chat User';
              String lastMsg = data['last_msg'] ?? 'No messages yet';

              return FutureBuilder<DocumentSnapshot>(
                future: firestore
                    .collection(usersCollection)
                    .doc(friendId)
                    .get(),
                builder: (context, userSnapshot) {
                  Widget leadingWidget;
                  String finalFriendName = friendName;

                  if (userSnapshot.connectionState == ConnectionState.done &&
                      userSnapshot.hasData &&
                      userSnapshot.data!.exists) {
                    var userData =
                        userSnapshot.data!.data() as Map<String, dynamic>?;
                    finalFriendName = userData?['name'] ?? 'Unknown User';
                    String friendImageUrl = userData?['imageUrl'] ?? '';

                    leadingWidget = CircleAvatar(
                      radius: 28,
                      backgroundColor: Colors.brown.shade100,
                      backgroundImage: friendImageUrl.isNotEmpty
                          ? NetworkImage(friendImageUrl)
                          : null,
                      child: friendImageUrl.isEmpty
                          ? const Icon(
                              Icons.person,
                              color: Colors.brown,
                              size: 30,
                            )
                          : null,
                    );
                  } else {
                    leadingWidget = CircleAvatar(
                      radius: 28,
                      backgroundColor: Colors.grey[200],
                      child: const Icon(
                        Icons.person,
                        color: Colors.grey,
                        size: 30,
                      ),
                    );
                  }

                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    leading: leadingWidget,
                    title: Text(
                      finalFriendName,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      lastMsg,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    onTap: () {
                      Get.to(
                        () => ChatScreen(
                          friendName: finalFriendName,
                          friendId: friendId,
                        ),
                      );
                    },
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:myapp/consts/firebase_consts.dart';
import 'package:myapp/controllers/profile_controller.dart';
import 'package:myapp/views/chat_screen/chat_screen.dart';

class AdminMessagesScreen extends StatelessWidget {
  const AdminMessagesScreen({super.key});

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
        iconTheme: const IconThemeData(color: Colors.white),
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

              List<dynamic> users = data['users'] ?? [];
              String friendId = users.firstWhere(
                (id) => id != currentAdminId,
                orElse: () => '',
              );

              if (friendId.isEmpty) {
                // This case handles a chat document with invalid user data.
                return const ListTile(
                  leading: CircleAvatar(
                    radius: 28,
                    child: Icon(Icons.error_outline),
                  ),
                  title: Text("Invalid Conversation"),
                  subtitle: Text("Could not determine the other user."),
                );
              }

              String lastMsg = data['last_msg'] ?? 'No messages yet';

              return FutureBuilder<DocumentSnapshot>(
                future: firestore
                    .collection(usersCollection)
                    .doc(friendId)
                    .get(),
                builder: (context, userSnapshot) {
                  Widget leadingWidget;
                  String finalFriendName;

                  if (userSnapshot.hasError) {
                    leadingWidget = const CircleAvatar(
                      radius: 28,
                      backgroundColor: Colors.redAccent,
                      child: Icon(Icons.error, color: Colors.white),
                    );
                    finalFriendName = "Error Loading User";
                  } else if (userSnapshot.connectionState ==
                      ConnectionState.waiting) {
                    leadingWidget = CircleAvatar(
                      radius: 28,
                      backgroundColor: Colors.grey.shade200,
                      child: const CircularProgressIndicator(strokeWidth: 2),
                    );
                    finalFriendName = "Loading...";
                  } else if (userSnapshot.hasData &&
                      userSnapshot.data!.exists) {
                    var userData =
                        userSnapshot.data!.data() as Map<String, dynamic>?;
                    finalFriendName =
                        userData?['name'] ?? 'Name Not Available';
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
                    // Document does not exist
                    leadingWidget = CircleAvatar(
                      radius: 28,
                      backgroundColor: Colors.grey.shade300,
                      child: const Icon(
                        Icons.person_off_outlined,
                        color: Colors.black54,
                        size: 30,
                      ),
                    );
                    finalFriendName = "User Not Found";
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
                      userSnapshot.hasError
                          ? 'Failed to load details'
                          : lastMsg,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    onTap: () {
                      if (userSnapshot.hasData && userSnapshot.data!.exists) {
                        // Initialize ProfileController before navigating
                        Get.put(ProfileController());

                        Get.to(
                          () => ChatScreen(
                            friendName: finalFriendName,
                            friendId: friendId,
                          ),
                        );
                      }
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

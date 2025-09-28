
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:myapp/consts/firebase_consts.dart';
import 'package:myapp/controllers/profile_controller.dart';
import 'package:myapp/views/chat_screen/chat_screen.dart';
import 'package:badges/badges.dart' as badges;
import 'package:timeago/timeago.dart' as timeago;

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
        // 1. ORDER BY last_msg_time to show latest conversations first
        stream: firestore
            .collection(chatsCollection)
            .where('users', arrayContains: currentAdminId)
            .orderBy('last_msg_time', descending: true) 
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
                return const ListTile(
                  leading: CircleAvatar(radius: 28, child: Icon(Icons.error_outline)),
                  title: Text("Invalid Conversation"),
                  subtitle: Text("Could not determine the other user."),
                );
              }

              String lastMsg = data['last_msg'] ?? 'No messages yet';
              // 2. GET UNREAD COUNT and TIMESTAMP
              int unreadCount = data['admin_unread_count'] ?? 0;
              Timestamp? lastMsgTime = data['last_msg_time'];

              return FutureBuilder<DocumentSnapshot>(
                future: firestore.collection(usersCollection).doc(friendId).get(),
                builder: (context, userSnapshot) {
                  Widget leadingWidget;
                  String finalFriendName;

                  if (userSnapshot.connectionState == ConnectionState.waiting) {
                    leadingWidget = CircleAvatar(
                      radius: 28,
                      backgroundColor: Colors.grey.shade200,
                    );
                    finalFriendName = "Loading...";
                  } else if (userSnapshot.hasData && userSnapshot.data!.exists) {
                    var userData = userSnapshot.data!.data() as Map<String, dynamic>?;
                    finalFriendName = userData?['name'] ?? 'Name Not Available';
                    String friendImageUrl = userData?['imageUrl'] ?? '';
                    leadingWidget = CircleAvatar(
                      radius: 28,
                      backgroundColor: Colors.brown.shade100,
                      backgroundImage: friendImageUrl.isNotEmpty ? NetworkImage(friendImageUrl) : null,
                      child: friendImageUrl.isEmpty
                          ? const Icon(Icons.person, color: Colors.brown, size: 30)
                          : null,
                    );
                  } else {
                    leadingWidget = CircleAvatar(
                      radius: 28,
                      backgroundColor: Colors.grey.shade300,
                      child: const Icon(Icons.person_off_outlined, color: Colors.black54, size: 30),
                    );
                    finalFriendName = "User Not Found";
                  }

                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    leading: leadingWidget,
                    title: Text(
                      finalFriendName,
                      style: TextStyle(
                        fontWeight: unreadCount > 0 ? FontWeight.bold : FontWeight.normal,
                        color: unreadCount > 0 ? Colors.black : Colors.black87,
                      ),
                    ),
                    subtitle: Text(
                      lastMsg,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontWeight: unreadCount > 0 ? FontWeight.bold : FontWeight.normal,
                        color: unreadCount > 0 ? Colors.brown : Colors.grey[600],
                      ),
                    ),
                    // 3. ADD BADGE and TIMESTAMP
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        if (lastMsgTime != null)
                          Text(
                            timeago.format(lastMsgTime.toDate(), locale: 'en_short'),
                            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                          ),
                        const SizedBox(height: 4),
                        if (unreadCount > 0)
                          badges.Badge(
                            badgeContent: Text(
                              unreadCount.toString(),
                              style: const TextStyle(color: Colors.white, fontSize: 12),
                            ),
                            badgeStyle: const badges.BadgeStyle(
                              badgeColor: Colors.red,
                            ),
                          )
                        else
                          const SizedBox(height: 18), // Placeholder to keep alignment
                      ],
                    ),
                    onTap: () {
                      if (userSnapshot.hasData && userSnapshot.data!.exists) {
                        // 4. RESET UNREAD COUNT on tap
                        if (unreadCount > 0) {
                          firestore.collection(chatsCollection).doc(doc.id).update({
                            'admin_unread_count': 0,
                          });
                        }
                        
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

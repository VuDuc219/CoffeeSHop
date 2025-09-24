import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:myapp/consts/firebase_consts.dart';

class MessagesController extends GetxController {
  final RxInt unreadCount = 0.obs;
  final RxMap<String, int> _unreadCountsPerChat = <String, int>{}.obs;

  final Map<String, StreamSubscription> _messageSubscriptions = {};
  StreamSubscription? _chatRoomsSubscription;

  @override
  void onInit() {
    super.onInit();

    // Listen for future auth state changes.
    auth.authStateChanges().listen((user) {
      if (user != null) {
        _listenToChatRooms(user.uid);
      } else {
        _stopAllListeners();
      }
    });

    // Immediately check for a logged-in user in case the app starts already authenticated.
    final currentUser = auth.currentUser;
    if (currentUser != null) {
      _listenToChatRooms(currentUser.uid);
    }
  }

  void _listenToChatRooms(String userId) {
    _stopAllListeners(); // Stop any existing listeners to prevent duplicates

    final query = firestore.collection(chatsCollection).where('users', arrayContains: userId);

    _chatRoomsSubscription = query.snapshots().listen((chatRoomsSnapshot) {
      _updateMessageListeners(chatRoomsSnapshot.docs, userId);
    }, onError: (error) {
      print("Error listening to chat rooms: $error");
    });
  }

  void _updateMessageListeners(List<QueryDocumentSnapshot> rooms, String userId) {
    final currentRoomIds = rooms.map((r) => r.id).toSet();

    // Stop listening to rooms the user has left
    _messageSubscriptions.keys.where((roomId) => !currentRoomIds.contains(roomId)).toList().forEach((staleRoomId) {
      _messageSubscriptions[staleRoomId]?.cancel();
      _messageSubscriptions.remove(staleRoomId);
      _unreadCountsPerChat.remove(staleRoomId);
    });

    // Start listening to new rooms
    for (var room in rooms) {
      if (!_messageSubscriptions.containsKey(room.id)) {
        final unreadQuery = room.reference
            .collection(messagesCollection)
            .where('read', isEqualTo: false)
            .where('uid', isNotEqualTo: userId);

        _messageSubscriptions[room.id] = unreadQuery.snapshots().listen((messagesSnapshot) {
          _unreadCountsPerChat[room.id] = messagesSnapshot.docs.length;
          _recalculateTotalUnreadCount();
        });
      }
    }
    _recalculateTotalUnreadCount(); // Recalculate after any potential changes
  }

  void _recalculateTotalUnreadCount() {
    int total = 0;
    _unreadCountsPerChat.forEach((_, count) {
      total += count;
    });
    unreadCount.value = total;
  }

  Future<void> markMessagesAsRead(String chatDocId) async {
    final currentUser = auth.currentUser;
    if (currentUser == null) return;

    if ((_unreadCountsPerChat[chatDocId] ?? 0) > 0) {
      _unreadCountsPerChat[chatDocId] = 0;
      _recalculateTotalUnreadCount();
    }

    try {
      final messagesRef = firestore.collection(chatsCollection).doc(chatDocId).collection(messagesCollection);
      final unreadMessages = await messagesRef
          .where('read', isEqualTo: false)
          .where('uid', isNotEqualTo: currentUser.uid)
          .get();

      if (unreadMessages.docs.isNotEmpty) {
        WriteBatch batch = firestore.batch();
        for (var doc in unreadMessages.docs) {
          batch.update(doc.reference, {'read': true});
        }
        await batch.commit();
      }
    } catch (e) {
      print("Error marking messages as read: $e");
    }
  }

  void _stopAllListeners() {
    _chatRoomsSubscription?.cancel();
    _chatRoomsSubscription = null;
    _messageSubscriptions.forEach((_, sub) => sub.cancel());
    _messageSubscriptions.clear();
    _unreadCountsPerChat.clear();
    if (unreadCount.value != 0) {
      unreadCount.value = 0;
    }
  }

  @override
  void onClose() {
    _stopAllListeners();
    super.onClose();
  }
}

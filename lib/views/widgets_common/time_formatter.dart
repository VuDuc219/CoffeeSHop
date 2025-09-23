import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

String formatChatMessageTime(Timestamp timestamp) {
  final DateTime messageTime = timestamp.toDate();
  final DateTime now = DateTime.now();
  final Duration difference = now.difference(messageTime);

  if (difference.inDays == 0 && now.day == messageTime.day) {
    return DateFormat('HH:mm').format(messageTime);
  } else if (difference.inDays < 7) {
    return DateFormat('EEE HH:mm').format(messageTime);
  } else {
    return DateFormat('d MMM y, HH:mm').format(messageTime);
  }
}

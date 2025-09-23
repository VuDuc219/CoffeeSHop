import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

String formatChatMessageTime(Timestamp timestamp) {
  final DateTime localTime = timestamp.toDate();

  final DateTime utcTime = localTime.toUtc();

  final DateTime vietnamTime = utcTime.add(const Duration(hours: 7));

  final DateTime nowUtc = DateTime.now().toUtc();
  final DateTime nowVietnam = nowUtc.add(const Duration(hours: 7));

  final Duration difference = nowVietnam.difference(vietnamTime);

  if (difference.inDays == 0 && nowVietnam.day == vietnamTime.day) {
    return DateFormat('HH:mm').format(vietnamTime);
  } else if (difference.inDays < 7) {
    return DateFormat('EEE HH:mm').format(vietnamTime);
  } else {
    return DateFormat('d MMM y, HH:mm').format(vietnamTime);
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

String formatChatMessageTime(Timestamp timestamp) {
  // 1. Get the original DateTime object. toDate() converts it to the device's LOCAL time.
  final DateTime localTime = timestamp.toDate();

  // 2. Convert the local time to its UTC equivalent to have a standard baseline.
  final DateTime utcTime = localTime.toUtc();

  // 3. Manually add 7 hours to create a new DateTime object for the Vietnam timezone (UTC+7).
  final DateTime vietnamTime = utcTime.add(const Duration(hours: 7));

  // 4. Get the current time also in UTC+7 to make correct comparisons.
  final DateTime nowUtc = DateTime.now().toUtc();
  final DateTime nowVietnam = nowUtc.add(const Duration(hours: 7));

  final Duration difference = nowVietnam.difference(vietnamTime);

  // 5. Format the UTC+7 time for display.
  //    Now all devices will show the same time regardless of their local timezone.
  if (difference.inDays == 0 && nowVietnam.day == vietnamTime.day) {
    return DateFormat('HH:mm').format(vietnamTime);
  } else if (difference.inDays < 7) {
    return DateFormat('EEE HH:mm').format(vietnamTime);
  } else {
    return DateFormat('d MMM y, HH:mm').format(vietnamTime);
  }
}

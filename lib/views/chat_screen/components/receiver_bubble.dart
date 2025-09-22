import 'package:flutter/material.dart';

Widget receiverBubble(BuildContext context, {required String message, required String time}) {
  // REMOVED the unnecessary Directionality widget
  return Container(
    margin: const EdgeInsets.only(bottom: 8),
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: Colors.grey.shade300, // Grey color for receiver
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(20),
        topRight: Radius.circular(20),
        bottomRight: Radius.circular(20),
      ),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          message,
          style: const TextStyle(color: Colors.black, fontSize: 16),
        ),
        const SizedBox(height: 5),
        Text(
          time,
          style: const TextStyle(color: Colors.black54, fontSize: 12),
        ),
      ],
    ),
  );
}

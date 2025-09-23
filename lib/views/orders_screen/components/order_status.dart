import 'package:flutter/material.dart';
import 'package:myapp/consts/consts.dart';

Widget orderStatus({required IconData icon, required Color color, required String title, required bool showDone}) {
  return ListTile(
    leading: Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: color,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: Icon(icon, color: color),
      ),
    ),
    title: Text(
      title,
      style: const TextStyle(fontFamily: semibold, color: darkFontGrey),
    ),
    trailing: showDone
        ? const Icon(
            Icons.done,
            color: redColor,
          )
        : null,
  );
}

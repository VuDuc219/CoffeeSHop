import 'package:flutter/material.dart';
import 'package:myapp/consts/consts.dart';

Widget detailsCard({
  required String count,
  required String title,
  required double width,
}) {
  return SizedBox(
    width: width,
    height: 80,
    child: Card(
      elevation: 3,
      shadowColor: Colors.black.withOpacity(0.3),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              count,
              style: const TextStyle(
                fontFamily: bold,
                color: darkFontGrey,
                fontSize: 20,
              ),
            ),
            const SizedBox(height: 5),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                title,
                style: const TextStyle(
                  fontFamily: regular,
                  color: darkFontGrey,
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

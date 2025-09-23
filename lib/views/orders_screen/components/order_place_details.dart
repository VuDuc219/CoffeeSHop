import 'package:flutter/material.dart';
import 'package:myapp/consts/consts.dart';

Widget orderPlaceDetails({title1, title2, d1, d2}) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title1, style: const TextStyle(fontFamily: semibold)),
            Text(d1, style: const TextStyle(color: redColor, fontFamily: semibold)),
          ],
        ),
        SizedBox(
          width: 150, // Adjusted width for better spacing
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title2, style: const TextStyle(fontFamily: semibold)),
              Text(d2, style: const TextStyle()),
            ],
          ),
        )
      ],
    ),
  );
}

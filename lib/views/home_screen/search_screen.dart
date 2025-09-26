import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:myapp/consts/consts.dart';
import 'package:myapp/services/firestore_services.dart';
import 'package:myapp/views/category_screen/item_details.dart';
import 'package:myapp/views/widgets_common/loading_indicator.dart';

class SearchScreen extends StatelessWidget {
  final String title;
  const SearchScreen({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: whiteColor,
      appBar: AppBar(
        title: title.text.color(darkFontGrey).make(),
      ),
      body: FutureBuilder(
        future: FirestoreServices.searchProducts(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: loadingIndicator(),
            );
          } else {
            var data = snapshot.data!.docs;
            var filtered = data
                .where(
                  (element) => element['p_name']
                      .toString()
                      .toLowerCase()
                      .contains(title.toLowerCase()),
                )
                .toList();

            if (filtered.isEmpty) {
              return "No products found".text.makeCentered();
            }

            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: GridView(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                  mainAxisExtent: 300,
                ),
                children: filtered.map((item) {
                  var itemData = item.data() as Map<String, dynamic>;

                  // Find the minimum price
                  List<dynamic> prices = itemData['p_price'] ?? [];
                  String displayPrice = "N/A";
                  if (prices.isNotEmpty) {
                    List<double> numericPrices = prices
                        .map((p) => double.tryParse(p.toString()) ?? double.infinity)
                        .toList();
                    double minPrice = numericPrices.reduce(min);
                    if (minPrice != double.infinity) {
                      displayPrice = minPrice.toStringAsFixed(0);
                    }
                  }

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Image.network(
                        itemData['p_imgs'][0],
                        height: 200,
                        width: 200,
                        fit: BoxFit.cover,
                      ),
                      const Spacer(),
                      "${itemData['p_name']}"
                          .text
                          .fontFamily(semibold)
                          .color(darkFontGrey)
                          .make(),
                      10.heightBox,
                      displayPrice
                          .text
                          .color(redColor)
                          .fontFamily(bold)
                          .size(16)
                          .make(),
                    ],
                  )
                      .box
                      .white
                      .outerShadowMd
                      .margin(const EdgeInsets.symmetric(horizontal: 4))
                      .roundedSM
                      .padding(const EdgeInsets.all(12))
                      .make()
                      .onTap(() {
                    itemData['id'] = item.id;
                    Get.to(() => ItemDetails(
                          data: itemData,
                        ));
                  });
                }).toList(),
              ),
            );
          }
        },
      ),
    );
  }
}

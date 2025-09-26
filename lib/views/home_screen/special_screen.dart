import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:myapp/consts/consts.dart';
import 'package:myapp/services/firestore_services.dart';
import 'package:myapp/views/category_screen/item_details.dart';
import 'package:myapp/views/widgets_common/loading_indicator.dart';
import 'package:get/get.dart';

class SpecialScreen extends StatelessWidget {
  const SpecialScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Today's Special"),
      ),
      body: StreamBuilder(
        stream: FirestoreServices.getSaleProducts(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) {
            return Center(child: loadingIndicator());
          } else if (snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text("No products on sale"),
            );
          } else {
            var data = snapshot.data!.docs;
            return GridView.builder(
              physics: const BouncingScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
                mainAxisExtent: 250,
              ),
              itemCount: data.length,
              itemBuilder: (context, index) {
                var product = data[index];
                var productData = product.data() as Map<String, dynamic>;
                productData['id'] = product.id;

                num originalPrice =
                    num.tryParse(product['p_price'][0].toString()) ?? 0;
                num salePercentage =
                    num.tryParse(product['p_sale'].toString()) ?? 0;
                num salePrice = originalPrice;
                if (salePercentage > 0) {
                  salePrice = originalPrice * (1 - salePercentage / 100);
                }

                return GestureDetector(
                  onTap: () {
                    Get.to(() => ItemDetails(
                          data: productData,
                        ));
                  },
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Image.network(
                          product['p_imgs'][0],
                          height: 130,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          product['p_name'],
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            if (salePercentage > 0)
                              Text(
                                '${originalPrice.toStringAsFixed(0)}đ',
                                style: const TextStyle(
                                  color: Colors.grey,
                                  decoration: TextDecoration.lineThrough,
                                ),
                              ),
                            const SizedBox(width: 8),
                            Text(
                              '${salePrice.toStringAsFixed(0)}đ',
                              style: const TextStyle(
                                color: redColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:myapp/consts/consts.dart';
import 'package:myapp/services/firestore_services.dart';
import 'package:myapp/views/category_screen/item_details.dart';
import 'package:myapp/views/widgets_common/loading_indicator.dart';

class BestSellersScreen extends StatelessWidget {
  const BestSellersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: "Best Sellers".text.fontFamily(bold).white.make(),
        backgroundColor: const Color(0xFF6A4C3A),
      ),
      body: FutureBuilder<List<DocumentSnapshot>>(
        future: FirestoreServices.getBestSellingProducts(),
        builder:
            (
              BuildContext context,
              AsyncSnapshot<List<DocumentSnapshot>> snapshot,
            ) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: loadingIndicator());
              } else if (snapshot.hasError) {
                return "Something went wrong".text.makeCentered();
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return "No best selling products".text.makeCentered();
              } else {
                var bestSellingData = snapshot.data!;
                return GridView.builder(
                  padding: const EdgeInsets.all(12),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 0.8,
                  ),
                  itemCount: bestSellingData.length,
                  itemBuilder: (context, index) {
                    var doc = bestSellingData[index];
                    var product = doc.data() as Map<String, dynamic>;
                    product['id'] = doc.id;

                    // Price calculation logic
                    num originalPrice =
                        num.tryParse(product['p_price'][0].toString()) ?? 0;
                    num salePercentage =
                        num.tryParse(product['p_sale']?.toString() ?? '0') ?? 0;
                    num salePrice = originalPrice;
                    if (salePercentage > 0) {
                      salePrice = originalPrice * (1 - salePercentage / 100);
                    }

                    return Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.3),
                            spreadRadius: 2,
                            blurRadius: 5,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Product Image
                          Image.network(
                            product['p_imgs'][0],
                            width: double.infinity,
                            height: 150,
                            fit: BoxFit.cover,
                          ).box.rounded.clip(Clip.antiAlias).make(),
                          const Spacer(),
                          // Product Name
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8.0,
                            ),
                            child: Text(
                              product['p_name'],
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: darkFontGrey,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const Spacer(),
                          // Product Price
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8.0,
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                if (salePercentage > 0)
                                  Text(
                                    '${originalPrice.toStringAsFixed(0)}đ',
                                    style: const TextStyle(
                                      color: fontGrey,
                                      fontSize: 14,
                                      decoration: TextDecoration.lineThrough,
                                    ),
                                  ).marginOnly(right: 8),
                                Text(
                                  '${salePrice.toStringAsFixed(0)}đ',
                                  style: const TextStyle(
                                    fontSize:
                                        16, // Made sale price slightly bigger
                                    color: redColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),
                        ],
                      ),
                    ).onTap(() {
                      Get.to(() => ItemDetails(data: product));
                    });
                  },
                );
              }
            },
      ),
    );
  }
}

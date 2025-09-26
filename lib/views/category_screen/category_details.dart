import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:myapp/consts/consts.dart';
import 'package:myapp/services/firestore_services.dart';
import 'package:myapp/views/category_screen/item_details.dart';
import 'package:myapp/views/widgets_common/loading_indicator.dart';

class CategoryDetails extends StatelessWidget {
  final String title;
  const CategoryDetails({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          title,
          style: const TextStyle(fontFamily: bold, color: whiteColor),
        ),
      ),
      body: StreamBuilder(
        stream: FirestoreServices.getProductsByCategory(title),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) {
            return Center(child: loadingIndicator());
          } else if (snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                "No products found!",
                style: TextStyle(color: darkFontGrey),
              ),
            );
          } else {
            var data = snapshot.data!.docs;
            return GridView.builder(
              physics: const BouncingScrollPhysics(),
              shrinkWrap: true,
              itemCount: data.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisExtent: 250,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
              ),
              itemBuilder: (context, index) {
                var productData = data[index].data() as Map<String, dynamic>;
                productData['id'] = data[index].id;

                int originalPrice = int.tryParse(productData['p_price'][0].toString()) ?? 0;
                int salePercentage = int.tryParse(productData['p_sale'].toString()) ?? 0;
                bool onSale = salePercentage > 0;
                num finalPrice = originalPrice;
                if (onSale) {
                  finalPrice = originalPrice * (1 - salePercentage / 100);
                }

                return InkWell(
                  onTap: () {
                    Get.to(() => ItemDetails(data: productData));
                  },
                  child: Card(
                    clipBehavior: Clip.antiAlias,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Image.network(
                          productData['p_imgs'][0],
                          height: 150,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                        const Spacer(),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Text(
                            productData['p_name'],
                            style: const TextStyle(
                              fontFamily: semibold,
                              color: darkFontGrey,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: onSale
                              ? Row(
                                  children: [
                                    Text(
                                      NumberFormat.currency(
                                        locale: 'vi_VN',
                                        symbol: 'VND',
                                      ).format(originalPrice),
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey,
                                        decoration: TextDecoration.lineThrough,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      NumberFormat.currency(
                                        locale: 'vi_VN',
                                        symbol: 'VND',
                                      ).format(finalPrice.round()),
                                      style: const TextStyle(
                                        fontFamily: bold,
                                        color: redColor,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                )
                              : Text(
                                  NumberFormat.currency(
                                    locale: 'vi_VN',
                                    symbol: 'VND',
                                  ).format(originalPrice),
                                  style: const TextStyle(
                                    fontFamily: bold,
                                    color: redColor,
                                    fontSize: 16,
                                  ),
                                ),
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

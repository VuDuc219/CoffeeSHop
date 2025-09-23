import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:myapp/consts/consts.dart';
import 'package:myapp/consts/firebase_consts.dart';
import 'package:myapp/services/firestore_services.dart';
import 'package:myapp/views/category_screen/item_details.dart';
import 'package:myapp/views/widgets_common/loading_indicator.dart';
import 'package:velocity_x/velocity_x.dart';

class WishlistScreen extends StatelessWidget {
  const WishlistScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: whiteColor,
      appBar: AppBar(
        title: const Text(
          "My Wishlist",
          style: TextStyle(fontFamily: semibold, color: darkFontGrey),
        ),
      ),
      body: StreamBuilder(
        stream: FirestoreServices.getWishlists(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) {
            return Center(child: loadingIndicator());
          } else if (snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                "Your wishlist is empty!",
                style: TextStyle(color: darkFontGrey),
              ),
            );
          } else {
            var data = snapshot.data!.docs;
            return ListView.builder(
              itemCount: data.length,
              itemBuilder: (BuildContext context, int index) {
                // Handle price which might be a List, num, or String
                var priceData = data[index]['p_price'];
                String priceString;

                if (priceData is List && priceData.isNotEmpty) {
                  priceString = priceData[0].toString();
                } else if (priceData != null) {
                  priceString = priceData.toString();
                } else {
                  priceString = "0";
                }

                return ListTile(
                  onTap: () {
                    var itemData = data[index].data() as Map<String, dynamic>;
                    itemData['id'] = data[index].id;
                    Get.to(() => ItemDetails(
                          data: itemData,
                        ));
                  },
                  leading: Image.network(
                    data[index]['p_imgs'][0],
                    width: 80,
                    fit: BoxFit.cover,
                  ),
                  title: Text(
                    "${data[index]['p_name']}",
                    style: const TextStyle(fontFamily: semibold, fontSize: 16),
                  ),
                  subtitle: Text(
                    priceString.numCurrency,
                    style: const TextStyle(
                      color: redColor,
                      fontFamily: semibold,
                    ),
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.favorite, color: redColor),
                    onPressed: () async {
                      await firestore
                          .collection(productsCollection)
                          .doc(data[index].id)
                          .update({
                        'p_wishlist': FieldValue.arrayRemove([
                          auth.currentUser!.uid,
                        ]),
                      });
                    },
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

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:myapp/consts/consts.dart';
import 'package:myapp/services/firestore_services.dart';
import 'package:myapp/views/orders_screen/orders_details.dart';
import 'package:myapp/views/widgets_common/loading_indicator.dart';
import 'package:intl/intl.dart' as intl;

class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "My Orders",
          style: TextStyle(color: darkFontGrey, fontFamily: semibold),
        ),
      ),
      body: StreamBuilder(
        stream: FirestoreServices.getAllOrders(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: loadingIndicator());
          } else if (snapshot.data == null || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                "No orders yet!",
                style: TextStyle(color: darkFontGrey),
              ),
            );
          } else {
            var data = snapshot.data!.docs;
            return ListView.builder(
              itemCount: data.length,
              itemBuilder: (BuildContext context, int index) {
                // It's safer to cast to a Map
                var orderData = data[index].data() as Map<String, dynamic>;

                return ListTile(
                  leading: Text(
                    "#${index + 1}",
                    style: const TextStyle(
                      fontFamily: semibold,
                      color: darkFontGrey,
                      fontSize: 14,
                    ),
                  ),
                  title: Text(
                    orderData['order_code'].toString(),
                    style: const TextStyle(
                      color: redColor,
                      fontFamily: semibold,
                    ),
                  ),
                  subtitle: Text(
                    // Displaying the date in subtitle for better UX
                    intl.DateFormat().add_yMd().format(
                      (orderData['order_date'] as Timestamp).toDate(),
                    ),
                    style: const TextStyle(fontFamily: regular),
                  ),
                  trailing: Text(
                    // Using the reliable intl package for currency
                    intl.NumberFormat.currency(
                      symbol: "VND ",
                      decimalDigits: 0,
                    ).format(orderData['total_amount']),
                    style: const TextStyle(
                      fontFamily: bold,
                      color: darkFontGrey,
                    ),
                  ),
                  onTap: () {
                    // Pass the document data to the details screen
                    Get.to(() => OrdersDetails(data: data[index]));
                  },
                );
              },
            );
          }
        },
      ),
    );
  }
}

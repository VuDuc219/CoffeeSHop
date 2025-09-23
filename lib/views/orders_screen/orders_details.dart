import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;
import 'package:myapp/consts/consts.dart';
import 'package:myapp/views/orders_screen/components/order_place_details.dart';
import 'package:myapp/views/orders_screen/components/order_status.dart';

class OrdersDetails extends StatelessWidget {
  final dynamic data;
  const OrdersDetails({super.key, this.data});

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> orderData = data.data() as Map<String, dynamic>;

    return Scaffold(
        appBar: AppBar(
          title: const Text(
            "Order Details",
            style: TextStyle(fontFamily: semibold, color: darkFontGrey),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(children: [
              orderStatus(
                  color: redColor,
                  icon: Icons.done,
                  title: "Placed",
                  showDone: orderData['order_placed'] ?? false),
              orderStatus(
                  color: Colors.blue,
                  icon: Icons.thumb_up,
                  title: "Confirmed",
                  showDone: false),
              orderStatus(
                  color: Colors.orange,
                  icon: Icons.delivery_dining,
                  title: "On Delivery",
                  showDone: false),
              orderStatus(
                  color: Colors.purple,
                  icon: Icons.done_all_rounded,
                  title: "Delivered",
                  showDone: false),
              const Divider(),
              const SizedBox(height: 10),
              orderPlaceDetails(
                  d1: orderData['order_code'],
                  d2: orderData['shipping_method'],
                  title1: "Order Code",
                  title2: "Shipping Method"),
              orderPlaceDetails(
                  d1: intl.DateFormat()
                      .add_yMd()
                      .format((orderData['order_date'].toDate())),
                  d2: orderData['payment_method'],
                  title1: "Order Date",
                  title2: "Payment Method"),
              orderPlaceDetails(
                  d1: "Unpaid",
                  d2: "Order Placed",
                  title1: "Payment Status",
                  title2: "Delivery Status"),
              const Divider(),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Shipping Address", style: TextStyle(fontFamily: semibold)),
                          Text(orderData['order_by_name'].toString()),
                          Text(orderData['order_by_email'].toString()),
                          Text(orderData['order_by_address'].toString()),
                          Text(orderData['order_by_phone'].toString()),
                        ],
                      ),
                    ),
                    SizedBox(
                      width: 130,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Total Amount", style: TextStyle(fontFamily: semibold)),
                          Text(
                            intl.NumberFormat.currency(symbol: "VND ", decimalDigits: 0).format(orderData['total_amount']),
                            style: const TextStyle(color: redColor, fontFamily: bold),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
              const Divider(),
              const SizedBox(height: 10),
              const Text(
                "Ordered Product",
                style: TextStyle(fontSize: 16, color: darkFontGrey, fontFamily: semibold),
              ),
              const SizedBox(height: 10),
              ListView.builder(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: orderData['orders'].length,
                itemBuilder: (context, index) {
                  var item = orderData['orders'][index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item['title'].toString(),
                                style: const TextStyle(fontFamily: semibold, fontSize: 16),
                              ),
                              Text(
                                "${item['qty']}x",
                                style: const TextStyle(color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          width: 110,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              if(item['tprice'] != null)
                                Text(
                                  intl.NumberFormat.currency(symbol: "VND ", decimalDigits: 0).format(item['tprice']),
                                  style: const TextStyle(fontFamily: semibold),
                                ),
                              const Text(
                                "Refundable",
                                style: TextStyle(color: Colors.grey, fontSize: 12),
                              ),
                            ]
                          ),
                        )
                      ],
                    ),
                  );
                },
              ),
            ]),
          ),
        ));
  }
}

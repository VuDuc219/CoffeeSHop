import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:myapp/consts/firebase_consts.dart';

enum TimeRange { Day, Week, Month }

class AdminHomeController extends GetxController {
  // For Navigation
  var navIndex = 0.obs;

  // For Dashboard
  var timeRange = TimeRange.Week.obs;
  var orders = <DocumentSnapshot>[].obs;
  var totalRevenue = 0.0.obs;
  var chartData = <double>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchOrders();
  }

  void setTimeRange(TimeRange range) {
    timeRange.value = range;
    fetchOrders();
  }

  DateTime getStartDate() {
    DateTime now = DateTime.now();
    switch (timeRange.value) {
      case TimeRange.Day:
        return DateTime(now.year, now.month, now.day); // Start of today
      case TimeRange.Week:
        return now.subtract(const Duration(days: 7));
      case TimeRange.Month:
        return now.subtract(const Duration(days: 30));
    }
  }

  // Function to determine the interval for the chart's bottom axis
  double getChartInterval() {
    switch (timeRange.value) {
      case TimeRange.Day:
        return 4.0; // Show a label every 4 hours
      case TimeRange.Week:
        return 1.0; // Show a label every day
      case TimeRange.Month:
        return 5.0; // Show a label every 5 days
    }
  }

  void fetchOrders() async {
    try {
      DateTime startDate = getStartDate();
      var snapshot = await firestore
          .collection(ordersCollection)
          .where('order_date', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
          .get();

      orders.value = snapshot.docs;
      processOrders();
    } catch (e) {
      print("Error fetching orders: $e");
      totalRevenue.value = 0.0;
      chartData.value = List.filled(7, 0.0);
    }
  }

  void processOrders() {
    if (orders.isEmpty) {
      totalRevenue.value = 0.0;
      int points;
      switch (timeRange.value) {
        case TimeRange.Day:
          points = 24;
          break;
        case TimeRange.Week:
          points = 7;
          break;
        case TimeRange.Month:
          points = 30;
          break;
      }
      chartData.value = List.filled(points, 0.0);
      return;
    }

    double total = 0;
    Map<DateTime, int> dailyOrders = {};
    Map<int, int> hourlyOrders = {};

    for (var doc in orders) {
      var data = doc.data() as Map<String, dynamic>;
      total += (data['total_amount'] ?? 0).toDouble();

      if (data['order_date'] != null) {
        Timestamp orderTimestamp = data['order_date'];
        DateTime orderDate = orderTimestamp.toDate();

        if (timeRange.value == TimeRange.Day) {
          hourlyOrders.update(orderDate.hour, (value) => value + 1, ifAbsent: () => 1);
        } else {
          DateTime dayKey = DateTime(orderDate.year, orderDate.month, orderDate.day);
          dailyOrders.update(dayKey, (value) => value + 1, ifAbsent: () => 1);
        }
      }
    }

    totalRevenue.value = total;

    List<double> processedData = [];
    DateTime now = DateTime.now();

    switch (timeRange.value) {
      case TimeRange.Day:
        for (int i = 0; i < 24; i++) {
          processedData.add((hourlyOrders[i] ?? 0).toDouble());
        }
        break;
      case TimeRange.Week:
        for (int i = 6; i >= 0; i--) {
          DateTime date = now.subtract(Duration(days: i));
          DateTime dayKey = DateTime(date.year, date.month, date.day);
          processedData.add((dailyOrders[dayKey] ?? 0).toDouble());
        }
        break;
      case TimeRange.Month:
        for (int i = 29; i >= 0; i--) {
          DateTime date = now.subtract(Duration(days: i));
          DateTime dayKey = DateTime(date.year, date.month, date.day);
          processedData.add((dailyOrders[dayKey] ?? 0).toDouble());
        }
        break;
    }
    chartData.value = processedData;
  }
}

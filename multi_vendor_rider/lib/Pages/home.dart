import 'package:flutter/material.dart';
import 'package:rider/Widget/OrdersTab/all_orders.dart';
import 'package:rider/Widget/OrdersTab/completed_orders.dart';
import 'package:rider/Widget/OrdersTab/processing_orders.dart';
import 'package:rider/Widget/OrdersTab/accepted_orders.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return const TabBarView(
      children: [
        AllOrders(),
        AcceptedOrders(),
        ProcessingOrders(),
        CompletedOrders(),
        // CancelledOrders()
      ],
    );
  }
}

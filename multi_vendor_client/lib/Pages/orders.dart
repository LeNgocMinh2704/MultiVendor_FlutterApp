import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:vendor/Widget/OrdersTab/all_orders.dart';
import 'package:vendor/Widget/OrdersTab/cancelled_orders.dart';
import 'package:vendor/Widget/OrdersTab/completed_orders.dart';
import 'package:vendor/Widget/OrdersTab/processing_orders.dart';
import 'package:vendor/Widget/OrdersTab/received_orders.dart';

class OrdersPage extends StatefulWidget {
  const OrdersPage({Key? key}) : super(key: key);

  @override
  State<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 5,
      child: Scaffold(
        appBar: AppBar(
          iconTheme: Theme.of(context).iconTheme,
          backgroundColor: Theme.of(context).cardColor,
          title: Text('Orders',
                  style: TextStyle(color: Theme.of(context).iconTheme.color))
              .tr(),
          elevation: 0,
          bottom: TabBar(
            labelColor: Theme.of(context).iconTheme.color,
            tabs: [
              Tab(text: 'All'.tr()),
              Tab(text: 'Received'.tr()),
              Tab(text: 'Processing'.tr()),
              Tab(text: 'Completed'.tr()),
              Tab(text: 'Cancelled'.tr()),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            AllOrders(),
            ReceivedOrders(),
            ProcessingOrders(),
            CompletedOrders(),
            CancelledOrders()
          ],
        ),
      ),
    );
  }
}

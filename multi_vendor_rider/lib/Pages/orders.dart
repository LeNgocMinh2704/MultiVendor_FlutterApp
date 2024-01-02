import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:rider/Widget/OrdersTab/accepted_orders.dart';
import 'package:rider/Widget/OrdersTab/all_orders.dart';
import 'package:rider/Widget/OrdersTab/completed_orders.dart';
import 'package:rider/Widget/OrdersTab/processing_orders.dart';

class OrdersPage extends StatefulWidget {
  const OrdersPage({Key? key}) : super(key: key);

  @override
  State<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> {
  String all = tr('All');
  String accepted = tr('Accepted');
  String processing = tr('Proccessing');
  String completed = tr('Completed');

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Orders',
                  style: TextStyle(color: Theme.of(context).iconTheme.color))
              .tr(),
          elevation: 0,
          bottom: TabBar(
            labelColor: Theme.of(context).iconTheme.color,
            tabs: [
              Tab(text: all),
              Tab(text: accepted),
              Tab(text: processing),
              Tab(text: completed),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            AllOrders(),
            AcceptedOrders(),
            ProcessingOrders(),
            CompletedOrders(),
          ],
        ),
      ),
    );
  }
}

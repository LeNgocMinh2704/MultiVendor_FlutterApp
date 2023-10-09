import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:tab_indicator_styler/tab_indicator_styler.dart';
import '../Widgets/OrdersTab/all_orders.dart';
import '../Widgets/OrdersTab/cancelled_orders.dart';
import '../Widgets/OrdersTab/completed_orders.dart';
import '../Widgets/OrdersTab/processing_orders.dart';
import '../Widgets/OrdersTab/received_orders.dart';

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
          titleTextStyle: TextStyle(color: Theme.of(context).indicatorColor),
          backgroundColor: Theme.of(context).colorScheme.background,
          elevation: 0,
          centerTitle: true,
          title: const Text(
            'Orders',
          ).tr(),
          bottom: TabBar(
            isScrollable: true,
            tabs: [
              Tab(
                text: 'All'.tr(),
              ),
              Tab(text: 'Received'.tr()),
              Tab(text: 'Processing'.tr()),
              Tab(text: 'Completed'.tr()),
              Tab(text: 'Cancelled'.tr()),
            ],
            indicator: DotIndicator(
              distanceFromCenter: 16,
              radius: 3,
              paintingStyle: PaintingStyle.fill,
            ),
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

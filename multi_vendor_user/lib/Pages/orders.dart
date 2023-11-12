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
    getFavorite() {
    final FirebaseAuth auth = FirebaseAuth.instance;
    User? user = auth.currentUser;
    FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uid)
        .collection('Favorite')
        .where('marketID', isEqualTo: widget.productsModel.marketID)
        .where('vendorId', isEqualTo: widget.productsModel.vendorId)
        .where('name', isEqualTo: widget.productsModel.name)
        .snapshots()
        .listen((value) {
      setState(() {
        isFavorite = value.docs.isNotEmpty;
      });
    });
  }
  Widget build(BuildContext context) {
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

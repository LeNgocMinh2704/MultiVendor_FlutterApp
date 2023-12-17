import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:vendor/Model/order_model.dart';
import 'package:vendor/Pages/delivery_boys.dart';
import 'package:vendor/Pages/orders_previews.dart';
import 'package:easy_localization/easy_localization.dart';

import '../../Model/formatter.dart';

class ProcessingOrders extends StatefulWidget {
  const ProcessingOrders({Key? key}) : super(key: key);

  @override
  State<ProcessingOrders> createState() => _ProcessingOrdersState();
}

class _ProcessingOrdersState extends State<ProcessingOrders> {
  DocumentReference? userRef;

  @override
  initState() {
    super.initState();
    getCurrencyDetails();
    fetchOrders();
    _getUserModelDoc();
  }

  whenDeliveryboyIsEmpty() {
    userRef!.collection('Delivery Boys').get().then((value) {
      if (value.docs.isEmpty) {
        //print('Delivery is Empty');
        Fluttertoast.showToast(
            msg: "Please add your favorite drivers to continue",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.TOP,
            timeInSecForIosWeb: 1,
      
            fontSize: 14.0);
        Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const DeliveryBoys()));
      }
    });
  }

  String userID = '';
  List<OrderModel2> orders = [];
  Future<void> fetchOrders() async {
    final FirebaseAuth auth = FirebaseAuth.instance;
    final FirebaseFirestore firestore = FirebaseFirestore.instance;

    User? user = auth.currentUser;
    setState(() {
      userRef =
          firestore.collection('vendors').doc(user!.uid).get().then((value) {
        setState(() {
          userID = value['id'];
        });
      }).then((value) {
        return FirebaseFirestore.instance
            .collection('Orders')
            .where('vendorID', isEqualTo: userID)
            .where('status', isEqualTo: 'Processing')
            .snapshots()
            .listen((data) {
          orders.clear();
          for (var doc in data.docs) {
            if (mounted) {
              setState(() {
                orders.add(OrderModel2(
                  orders: [
                    ...(doc.data()['orders']).map((items) {
                      return OrdersList.fromMap(items);
                    })
                  ],
                  uid: doc.data()['uid'],
                  marketID: doc.data()['marketID'],
                  vendorID: doc.data()['vendorID'],
                  userID: doc.data()['userID'],
                  deliveryAddress: doc.data()['deliveryAddress'],
                  houseNumber: doc.data()['houseNumber'],
                  closesBusStop: doc.data()['closesBusStop'],
                  deliveryBoyID: doc.data()['deliveryBoyID'],
                  status: doc.data()['status'],
                  accept: doc.data()['accept'],
                  orderID: doc.data()['orderID'],
                  timeCreated: doc.data()['timeCreated'],
                  total: doc.data()['total'],
                  deliveryFee: doc.data()['deliveryFee'],
                  acceptDelivery: doc.data()['acceptDelivery'],
                  paymentType: doc.data()['paymentType'],
                ));
              });
            }
          }
        });
      }) as DocumentReference?;
    });
  }

  Future<void> _getUserModelDoc() async {
    final FirebaseAuth auth = FirebaseAuth.instance;
    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    User? user = auth.currentUser;
    setState(() {
      userRef = firestore.collection('vendors').doc(user!.uid);
    });
  }

  String currencyName = '';
  String currencyCode = '';
  String currencySymbol = '';
  String getcurrencyName = '';
  String getcurrencyCode = '';
  String getcurrencySymbol = '';

  getCurrencyDetails() {
    FirebaseFirestore.instance
        .collection('Currency Settings')
        .doc('Currency Settings')
        .get()
        .then((value) {
      setState(() {
        getcurrencyName = value['Currency name'];
        getcurrencyCode = value['Currency code'];
        getcurrencySymbol = value['Currency symbol'];
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const BouncingScrollPhysics(),
      shrinkWrap: true,
      scrollDirection: Axis.vertical,
      children: [
        const SizedBox(
          height: 20,
        ),
        orders.isEmpty
            ? Center(
                child: Image.asset(
                  'assets/image/empty.png',
                  height: MediaQuery.of(context).size.height / 2,
                ),
              )
            : ListView.builder(
                physics: const ScrollPhysics(),
                shrinkWrap: true,
                itemCount: orders.length,
                itemBuilder: (context, i) {
                  return _buildOrders(context, orders[i], i, getcurrencySymbol);
                }),
      ],
    );
  }
}

_buildOrders(
    BuildContext context, OrderModel2 orders, int i, String getcurrencySymbol) {
  return InkWell(
    onTap: () {
      Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => OrdersPreview(
                orderModel: orders,
                currencySymbol: getcurrencySymbol,
              )));
    },
    child: Padding(
      padding: const EdgeInsets.all(8.0),
      child: SizedBox(
      height: 114,
        child: Card(
            elevation: 0,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('#${orders.orderID}',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 18)),
                      Text(orders.timeCreated),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        children: [
                          const Text('Amount').tr(),
                          const SizedBox(height: 2),
                          Text('$getcurrencySymbol${Formatter().converter(orders.total.toDouble())}',
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 18)),
                        ],
                      ),
                      const SizedBox(
                          height: 40,
                          child: VerticalDivider(
                              thickness: 1, color: Colors.grey)),
                      orders.paymentType == 'Wallet'
                          ? Column(
                              children: [
                                const Text('Payment type').tr(),
                                const SizedBox(height: 2),
                                const Text('Wallet',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18)),
                              ],
                            )
                          : Column(
                              children: [
                                const Text('Payment type').tr(),
                                const SizedBox(height: 2),
                                const Text('Cash on delivery',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18))
                                    .tr(),
                              ],
                            ),
                    ],
                  ),
                ],
              ),
            )),
      ),
    ),
  );
}

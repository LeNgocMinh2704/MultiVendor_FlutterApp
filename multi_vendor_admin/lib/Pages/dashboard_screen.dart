import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:admin_web/Widget/orders_datatable.dart';
import 'package:pie_chart/pie_chart.dart';

import '../Models/formatter.dart';
import '../Models/order_model.dart';

class DashBoardScreen extends StatefulWidget {
  const DashBoardScreen({Key? key}) : super(key: key);

  @override
  State<DashBoardScreen> createState() => _DashBoardScreenState();
}

class _DashBoardScreenState extends State<DashBoardScreen> {
  responsiveness() {
    if (MediaQuery.of(context).size.width >= 1100) {
      return 4;
    } else if (MediaQuery.of(context).size.width < 1100 &&
        MediaQuery.of(context).size.width >= 850) {
      return 2;
    } else {
      return 1;
    }
  }

  @override
  void initState() {
    getNumberofMarkets();
    getNumberofCourier();
    getNumberofSubcategories();
    getNumberofCategories();
    getNumberofbrands();
    getNumberofOrders();
    fetchOrders();
    totalSales();
    fetchOrdersDelivered();
    fetchOrdersReceived();
    fetchOrdersPreparing();
    fetchOrdersReady();
    fetchOrdersOntheway();
    getCurrencyDetails();
    getNumberofUsers();
    getNumberofVendors();
    getNumberofDeliveryboys();
    adminCommissionDetails();
    super.initState();
  }

  num adminCommission = 0;

  adminCommissionDetails() {
    FirebaseFirestore.instance
        .collection('Admin')
        .doc('Admin')
        .get()
        .then((value) {
      setState(() {
        adminCommission = value['commission'];
      });
    });
  }

  DateFormat dateFormat = DateFormat('EEE, M-d-y');
  String vendorsID = '';
  DocumentReference? userRef;
  int totalQuantity = 0;
  num grossSales = 0;
  List<int> quantity = [];
  List<int> selectedPrice = [];
  List<OrderModel2> ordersReceived = [];
  List<OrderModel2> ordersPreparing = [];
  List<OrderModel2> ordersReady = [];
  List<OrderModel2> ordersOntheway = [];
  List<OrderModel2> ordersDelivered = [];

  List<OrderModel2> orders = [];
  Future fetchOrders() async {
    return FirebaseFirestore.instance
        .collection('Orders')
        .where('acceptDelivery', isEqualTo: true)
        .snapshots()
        .listen((data) {
      orders.clear();
      quantity.clear();
      selectedPrice.clear();
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
  }

  Future fetchOrdersReceived() async {
    return FirebaseFirestore.instance
        .collection('Orders')
        .where('status', isEqualTo: 'Recieved')
        .snapshots()
        .listen((data) {
      // ordersReceived.clear();

      for (var doc in data.docs) {
        if (mounted) {
          setState(() {
            ordersReceived.add(OrderModel2(
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
  }

  Future fetchOrdersPreparing() async {
    return FirebaseFirestore.instance
        .collection('Orders')
        .where('status', isEqualTo: 'Preparing')
        .snapshots()
        .listen((data) {
      // ordersPreparing.clear();

      for (var doc in data.docs) {
        if (mounted) {
          setState(() {
            ordersPreparing.add(OrderModel2(
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
  }

  Future fetchOrdersReady() async {
    return FirebaseFirestore.instance
        .collection('Orders')
        .where('status', isEqualTo: 'Ready')
        .snapshots()
        .listen((data) {
      // ordersReady.clear();

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
  }

  Future fetchOrdersOntheway() async {
    return FirebaseFirestore.instance
        .collection('Orders')
        .where('status', isEqualTo: 'On the way')
        .snapshots()
        .listen((data) {
      // ordersOntheway.clear();
      for (var doc in data.docs) {
        if (mounted) {
          setState(() {
            ordersOntheway.add(OrderModel2(
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
  }

  Future fetchOrdersDelivered() async {
    return FirebaseFirestore.instance
        .collection('Orders')
        .where('status', isEqualTo: 'Completed')
        .snapshots()
        .listen((data) {
      // ordersDelivered.clear();
      for (var doc in data.docs) {
        if (mounted) {
          setState(() {
            ordersDelivered.add(OrderModel2(
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
  }

  totalSales() {
    FirebaseFirestore.instance.collection('Orders').get().then((value) {
      num tempTotal =
          value.docs.fold(0, (tot, doc) => tot + doc.data()['total']);
      //print(tempTotal);
      setState(() {
        grossSales = tempTotal;
      });
    });
  }

  List<Color> colorList = [
    // Colors.red,
    Colors.green,
    Colors.blue,
    Colors.yellow,
    Colors.purple,
    Colors.deepOrange
  ];

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

  int userLength = 0;
  getNumberofUsers() {
    FirebaseFirestore.instance.collection('users').get().then((event) {
      //print('User length is ${event.docs.length}');
      setState(() {
        userLength = event.docs.length;
      });
    });
  }

  int vendorsLength = 0;
  getNumberofVendors() {
    FirebaseFirestore.instance
        .collection('vendors')
        .snapshots()
        .listen((event) {
      //print('Vendors length is ${event.docs.length}');
      setState(() {
        vendorsLength = event.docs.length;
      });
    });
  }

  int deliveryboysLength = 0;
  getNumberofDeliveryboys() {
    FirebaseFirestore.instance
        .collection('drivers')
        .snapshots()
        .listen((event) {
      //print('Delivery boys length is ${event.docs.length}');
      setState(() {
        deliveryboysLength = event.docs.length;
      });
    });
  }

  int ordersLength = 0;
  getNumberofOrders() {
    FirebaseFirestore.instance.collection('Orders').get().then((event) {
      //print('Order length is ${event.docs.length}');
      setState(() {
        ordersLength = event.docs.length;
      });
    });
  }

  int brandsLength = 0;
  getNumberofbrands() {
    FirebaseFirestore.instance.collection('Brands').get().then((event) {
      //print('Order length is ${event.docs.length}');
      setState(() {
        brandsLength = event.docs.length;
      });
    });
  }

  int categoriesLength = 0;
  getNumberofCategories() {
    FirebaseFirestore.instance
        .collection('Categories')
        .snapshots()
        .listen((event) {
      //print('Order length is ${event.docs.length}');
      setState(() {
        categoriesLength = event.docs.length;
      });
    });
  }

  int subCategoriesLength = 0;
  getNumberofSubcategories() {
    FirebaseFirestore.instance
        .collection('Sub Categories')
        .snapshots()
        .listen((event) {
      //print('Order length is ${event.docs.length}');
      setState(() {
        subCategoriesLength = event.docs.length;
      });
    });
  }

  int courierLength = 0;
  getNumberofCourier() {
    FirebaseFirestore.instance
        .collection('Courier')
        .snapshots()
        .listen((event) {
      //print('Courier length is ${event.docs.length}');
      setState(() {
        courierLength = event.docs.length;
      });
    });
  }

  int marketsLength = 0;
  getNumberofMarkets() {
    FirebaseFirestore.instance
        .collection('Markets')
        .snapshots()
        .listen((event) {
      //print('Order length is ${event.docs.length}');
      setState(() {
        marketsLength = event.docs.length;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        const SizedBox(
          height: 40,
        ),
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: const Text(
            'Dashboard',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
          ).tr(),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: GridView.count(
            physics: const BouncingScrollPhysics(),
            childAspectRatio: 3,
            shrinkWrap: true,
            crossAxisSpacing: 15,
            crossAxisCount: responsiveness(),
            mainAxisSpacing: 15,
            children: [
              Card(
                color: Colors.green,
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      const Icon(
                        Icons.monetization_on,
                        color: Colors.white,
                        size: 50,
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'Commissions After Sales',
                            style: TextStyle(color: Colors.white, fontSize: 18),
                          ).tr(),
                          Text(
                            '$getcurrencySymbol${Formatter().converter(adminCommission.toDouble())}',
                            style: const TextStyle(
                                color: Colors.white, fontSize: 15),
                          )
                        ],
                      )
                    ]),
              ),
              Card(
                color: Colors.greenAccent[700],
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      const Icon(
                        Icons.monetization_on,
                        color: Colors.white,
                        size: 50,
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'Gross Sales',
                            style: TextStyle(color: Colors.white, fontSize: 18),
                          ).tr(),
                          Text(
                            '$getcurrencySymbol${Formatter().converter(grossSales.toDouble())}',
                            style: const TextStyle(
                                color: Colors.white, fontSize: 15),
                          )
                        ],
                      )
                    ]),
              ),
              Card(
                color: Colors.green[700],
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      const Icon(
                        Icons.monetization_on,
                        color: Colors.white,
                        size: 50,
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'Average Monthly sales',
                            style: TextStyle(color: Colors.white, fontSize: 18),
                          ).tr(),
                          Text(
                            '$getcurrencySymbol${Formatter().converter((grossSales / 12).toDouble())}',
                            style: const TextStyle(
                                color: Colors.white, fontSize: 15),
                          )
                        ],
                      )
                    ]),
              ),
              Card(
                color: Colors.blue.shade800,
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      const Icon(
                        Icons.list_alt,
                        color: Colors.white,
                        size: 50,
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'Orders received',
                            style: TextStyle(color: Colors.white, fontSize: 18),
                          ).tr(),
                          Text(
                            '$ordersLength',
                            style: const TextStyle(
                                color: Colors.white, fontSize: 15),
                          )
                        ],
                      )
                    ]),
              ),
              Card(
                color: Colors.greenAccent,
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      const Icon(
                        Icons.person,
                        color: Colors.white,
                        size: 50,
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'Number of users',
                            style: TextStyle(color: Colors.white, fontSize: 18),
                          ).tr(),
                          Text(
                            '$userLength',
                            style: const TextStyle(
                                color: Colors.white, fontSize: 15),
                          )
                        ],
                      )
                    ]),
              ),
              Card(
                color: Colors.green,
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      const Icon(
                        Icons.person,
                        color: Colors.white,
                        size: 50,
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            "Vendors",
                            style: TextStyle(color: Colors.white, fontSize: 18),
                          ).tr(),
                          Text(
                            '$vendorsLength',
                            style: const TextStyle(
                                color: Colors.white, fontSize: 15),
                          )
                        ],
                      ),
                    ]),
              ),
              Card(
                color: Colors.deepOrange,
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      const Icon(
                        Icons.delivery_dining,
                        color: Colors.white,
                        size: 50,
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            "Delivery boys",
                            style: TextStyle(color: Colors.white, fontSize: 18),
                          ).tr(),
                          Text(
                            '$deliveryboysLength',
                            style: const TextStyle(
                                color: Colors.white, fontSize: 15),
                          )
                        ],
                      ),
                    ]),
              ),
              Card(
                color: Colors.cyan,
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      const Icon(
                        Icons.category,
                        color: Colors.white,
                        size: 50,
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            "Categories",
                            style: TextStyle(color: Colors.white, fontSize: 18),
                          ).tr(),
                          Text(
                            '$categoriesLength',
                            style: const TextStyle(
                                color: Colors.white, fontSize: 15),
                          )
                        ],
                      ),
                    ]),
              ),
              Card(
                color: Colors.purple,
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      const Icon(
                        Icons.category,
                        color: Colors.white,
                        size: 50,
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            "Sub categories",
                            style: TextStyle(color: Colors.white, fontSize: 18),
                          ).tr(),
                          Text(
                            '$subCategoriesLength',
                            style: const TextStyle(
                                color: Colors.white, fontSize: 15),
                          )
                        ],
                      ),
                    ]),
              ),
              // Card(
              //   color: Colors.pinkAccent,
              //   child: Row(
              //       mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              //       children: [
              //         const Icon(
              //           Icons.branding_watermark,
              //           color: Colors.white,
              //           size: 50,
              //         ),
              //         Column(
              //           mainAxisAlignment: MainAxisAlignment.center,
              //           children: [
              //             const Text(
              //               "Brands",
              //               style: TextStyle(
              //                   color: Colors.white, fontSize: 18),
              //             ).tr(),
              //             Text(
              //               '$brandsLength',
              //               style: const TextStyle(
              //                   color: Colors.white, fontSize: 15),
              //             )
              //           ],
              //         ),
              //       ]),
              // ),
              Card(
                color: Colors.greenAccent,
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      const Icon(
                        Icons.delivery_dining,
                        color: Colors.white,
                        size: 50,
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            "Couriers",
                            style: TextStyle(color: Colors.white, fontSize: 18),
                          ).tr(),
                          Text(
                            '$courierLength',
                            style: const TextStyle(
                                color: Colors.white, fontSize: 15),
                          )
                        ],
                      ),
                    ]),
              ),
              Card(
                color: Colors.pinkAccent,
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      const Icon(
                        Icons.local_mall,
                        color: Colors.white,
                        size: 50,
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            "Markets",
                            style: TextStyle(color: Colors.white, fontSize: 18),
                          ).tr(),
                          Text(
                            '$marketsLength',
                            style: const TextStyle(
                                color: Colors.white, fontSize: 15),
                          )
                        ],
                      ),
                    ]),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
// Start
        MediaQuery.of(context).size.width >= 1100
            ? Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Flexible(
                      flex: 3,
                      child: SizedBox(
                        height: MediaQuery.of(context).size.height / 2,
                        width: MediaQuery.of(context).size.width / 2.3,
                        child: Card(
                          color: Colors.white,
                          elevation: 10,
                          child: Column(
                            children: [
                              const SizedBox(height: 20),
                              const Text('Order summary').tr(),
                              const Divider(
                                color: Colors.grey,
                                thickness: 1,
                                endIndent: 10,
                                indent: 10,
                              ),
                              const SizedBox(height: 20),
                              PieChart(
                                dataMap: {
                                  'Received'.tr():
                                      ordersReceived.length.toDouble(),
                                  'Preparing'.tr():
                                      ordersPreparing.length.toDouble(),
                                  'Ready'.tr(): ordersReady.length.toDouble(),
                                  'On the way'.tr():
                                      ordersOntheway.length.toDouble(),
                                  'Delivered'.tr():
                                      ordersDelivered.length.toDouble()
                                },
                                animationDuration:
                                    const Duration(milliseconds: 800),
                                chartLegendSpacing: 32,
                                chartRadius:
                                    MediaQuery.of(context).size.width / 1.7,
                                colorList: colorList,
                                initialAngleInDegree: 0,
                                chartType: ChartType.disc,
                                ringStrokeWidth: 32,
                                centerText:
                                    ('Order Statistics'.tr()).toString(),
                                legendOptions: const LegendOptions(
                                  showLegendsInRow: false,
                                  legendPosition: LegendPosition.right,
                                  showLegends: true,
                                  legendShape: BoxShape.circle,
                                  legendTextStyle: TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                chartValuesOptions: const ChartValuesOptions(
                                  showChartValueBackground: true,
                                  showChartValues: true,
                                  showChartValuesInPercentage: false,
                                  showChartValuesOutside: false,
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                    Flexible(
                      flex: 7,
                      child: SizedBox(
                        height: MediaQuery.of(context).size.height / 1.5,
                        width: MediaQuery.of(context).size.width / 2,
                        child: Card(
                          color: Colors.white,
                          elevation: 10,
                          child: SingleChildScrollView(
                            child: Column(
                              children: [
                                const SizedBox(height: 20),
                                const Text('Newest Orders').tr(),
                                const Divider(
                                  color: Colors.grey,
                                  thickness: 1,
                                  endIndent: 10,
                                  indent: 10,
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    children: const [
                                      SizedBox(
                                          width: double.infinity,
                                          child: OrdersDatatable()),
                                    ],
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              )
            : Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    SizedBox(
                      height: MediaQuery.of(context).size.height / 2,
                      width: MediaQuery.of(context).size.width / 1.4,
                      child: Card(
                        color: Colors.white,
                        elevation: 10,
                        child: Column(
                          children: [
                            const SizedBox(height: 20),
                            const Text('Order summary').tr(),
                            const Divider(
                              color: Colors.grey,
                              thickness: 1,
                              endIndent: 10,
                              indent: 10,
                            ),
                            const SizedBox(height: 20),
                            SizedBox(
                              height: MediaQuery.of(context).size.height / 3,
                              width: MediaQuery.of(context).size.width / 1.4,
                              child: PieChart(
                                dataMap: {
                                  'Received'.tr():
                                      ordersReceived.length.toDouble(),
                                  'Preparing'.tr():
                                      ordersPreparing.length.toDouble(),
                                  'Ready'.tr(): ordersReady.length.toDouble(),
                                  'On the way'.tr():
                                      ordersOntheway.length.toDouble(),
                                  'Delivered'.tr():
                                      ordersDelivered.length.toDouble()
                                },
                                animationDuration:
                                    const Duration(milliseconds: 800),
                                chartLegendSpacing: 32,
                                chartRadius:
                                    MediaQuery.of(context).size.width / 1.7,
                                colorList: colorList,
                                initialAngleInDegree: 0,
                                chartType: ChartType.disc,
                                ringStrokeWidth: 32,
                                centerText:
                                    ('Order Statistics'.tr()).toString(),
                                legendOptions: const LegendOptions(
                                  showLegendsInRow: false,
                                  legendPosition: LegendPosition.right,
                                  showLegends: true,
                                  legendShape: BoxShape.circle,
                                  legendTextStyle: TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                chartValuesOptions: const ChartValuesOptions(
                                  showChartValueBackground: true,
                                  showChartValues: true,
                                  showChartValuesInPercentage: false,
                                  showChartValuesOutside: false,
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    SingleChildScrollView(
                      child: SizedBox(
                        height: MediaQuery.of(context).size.height / 1.5,
                        width: MediaQuery.of(context).size.width / 1.1,
                        child: Card(
                          color: Colors.white,
                          elevation: 10,
                          child: SingleChildScrollView(
                            child: Column(
                              children: [
                                const SizedBox(height: 20),
                                const Text('Newest Orders').tr(),
                                const Divider(
                                  color: Colors.grey,
                                  thickness: 1,
                                  endIndent: 10,
                                  indent: 10,
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    children: const [
                                      SizedBox(
                                          width: double.infinity,
                                          child: OrdersDatatable()),
                                    ],
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
// //  End

//           SizedBox(height: 20),
// // Start
//           MediaQuery.of(context).size.width >= 1100
//               ? Padding(
//                   padding: const EdgeInsets.all(8.0),
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Flexible(
//                         flex: 3,
//                         child: Container(
//                           height: MediaQuery.of(context).size.height / 2,
//                           width: MediaQuery.of(context).size.width / 2.3,
//                           child: Card(
//                             color: Colors.white,
//                             elevation: 10,
//                             child: Container(
//                               child: Column(
//                                 children: [
//                                   SizedBox(height: 20),
//                                   Text('Reviews').tr(),
//                                   Divider(
//                                     color: Colors.grey,
//                                     thickness: 1,
//                                     endIndent: 10,
//                                     indent: 10,
//                                   )
//                                 ],
//                               ),
//                             ),
//                           ),
//                         ),
//                       ),
//                       Flexible(
//                         flex: 7,
//                         child: Container(
//                           height: MediaQuery.of(context).size.height / 1.5,
//                           width: MediaQuery.of(context).size.width / 2,
//                           child: Card(
//                             color: Colors.white,
//                             elevation: 10,
//                             child: Container(
//                               child: Column(
//                                 children: [
//                                   SizedBox(height: 20),
//                                   Text('New notifications').tr(),
//                                   Divider(
//                                     color: Colors.grey,
//                                     thickness: 1,
//                                     endIndent: 10,
//                                     indent: 10,
//                                   )
//                                 ],
//                               ),
//                             ),
//                           ),
//                         ),
//                       )
//                     ],
//                   ),
//                 )
//               : Padding(
//                   padding: const EdgeInsets.all(8.0),
//                   child: Column(
//                     children: [
//                       Container(
//                         height: MediaQuery.of(context).size.height / 2,
//                         width: MediaQuery.of(context).size.width / 1.4,
//                         child: Card(
//                           color: Colors.white,
//                           elevation: 10,
//                           child: Container(
//                             child: Column(
//                               children: [
//                                 SizedBox(height: 20),
//                                 Text('Reviews').tr(),
//                                 Divider(
//                                   color: Colors.grey,
//                                   thickness: 1,
//                                   endIndent: 10,
//                                   indent: 10,
//                                 )
//                               ],
//                             ),
//                           ),
//                         ),
//                       ),
//                       Container(
//                         height: MediaQuery.of(context).size.height / 1.5,
//                         width: MediaQuery.of(context).size.width / 1.2,
//                         child: Card(
//                           color: Colors.white,
//                           elevation: 10,
//                           child: Container(
//                             child: Column(
//                               children: [
//                                 SizedBox(height: 20),
//                                 Text('New notifications').tr(),
//                                 Divider(
//                                   color: Colors.grey,
//                                   thickness: 1,
//                                   endIndent: 10,
//                                   indent: 10,
//                                 )
//                               ],
//                             ),
//                           ),
//                         ),
//                       )
//                     ],
//                   ),
//                 ),
// // End
//           SizedBox(height: 20),
// // Start
//           MediaQuery.of(context).size.width >= 1100
//               ? Padding(
//                   padding: const EdgeInsets.all(8.0),
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Flexible(
//                         child: Container(
//                           height: MediaQuery.of(context).size.height / 2,
//                           width: MediaQuery.of(context).size.width / 2.3,
//                           child: Card(
//                             color: Colors.white,
//                             elevation: 10,
//                             child: Container(
//                               child: Column(
//                                 children: [
//                                   SizedBox(height: 20),
//                                   Text('Categories').tr(),
//                                   Divider(
//                                     color: Colors.grey,
//                                     thickness: 1,
//                                     endIndent: 10,
//                                     indent: 10,
//                                   )
//                                 ],
//                               ),
//                             ),
//                           ),
//                         ),
//                       ),
//                       Flexible(
//                         child: Container(
//                           height: MediaQuery.of(context).size.height / 4,
//                           width: MediaQuery.of(context).size.width / 2.3,
//                           child: Card(
//                             color: Colors.white,
//                             elevation: 10,
//                             child: Container(
//                               child: Column(
//                                 children: [
//                                   SizedBox(height: 20),
//                                   Text('App Settings').tr(),
//                                   Divider(
//                                     color: Colors.grey,
//                                     thickness: 1,
//                                     endIndent: 10,
//                                     indent: 10,
//                                   )
//                                 ],
//                               ),
//                             ),
//                           ),
//                         ),
//                       )
//                     ],
//                   ),
//                 )
//               : Padding(
//                   padding: const EdgeInsets.all(8.0),
//                   child: Column(
//                     children: [
//                       Container(
//                         height: MediaQuery.of(context).size.height / 2,
//                         width: MediaQuery.of(context).size.width / 1.2,
//                         child: Card(
//                           color: Colors.white,
//                           elevation: 10,
//                           child: Container(
//                             child: Column(
//                               children: [
//                                 SizedBox(height: 20),
//                                 Text('My Categories').tr(),
//                                 Divider(
//                                   color: Colors.grey,
//                                   thickness: 1,
//                                   endIndent: 10,
//                                   indent: 10,
//                                 )
//                               ],
//                             ),
//                           ),
//                         ),
//                       ),
//                       Container(
//                         height: MediaQuery.of(context).size.height / 2,
//                         width: MediaQuery.of(context).size.width / 1.2,
//                         child: Card(
//                           color: Colors.white,
//                           elevation: 10,
//                           child: Container(
//                             child: Column(
//                               children: [
//                                 SizedBox(height: 20),
//                                 Text('App Settings').tr(),
//                                 Divider(
//                                   color: Colors.grey,
//                                   thickness: 1,
//                                   endIndent: 10,
//                                   indent: 10,
//                                 )
//                               ],
//                             ),
//                           ),
//                         ),
//                       )
//                     ],
//                   ),
//                 )
      ],
    );
  }
}

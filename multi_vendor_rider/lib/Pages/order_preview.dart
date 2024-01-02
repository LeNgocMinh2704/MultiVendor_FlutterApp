import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:rider/Model/history.dart';
import 'package:rider/Model/order_model.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:geocoder2/geocoder2.dart';

import '../Model/constant.dart';
import '../Model/formatter.dart';
import '../Widget/map.dart';

class OrdersPreview extends StatefulWidget {
  final OrderModel2 orderModel;
  final String currencySymbol;
  const OrdersPreview(
      {required this.orderModel, required this.currencySymbol, Key? key})
      : super(key: key);

  @override
  State<OrdersPreview> createState() => _OrdersPreviewState();
}

class _OrdersPreviewState extends State<OrdersPreview> {
  int _index = 0;
  String marketName = '';
  String marketAddress = '';
  String marketPhone = '';
  String riderName = '';
  String riderAddress = '';
  String riderPhone = '';
  num wallet = 0;
  DocumentReference? userDetails;
  String orderStatus = '';
  bool accepted = false;
  bool acceptDelivery = false;
  String deliveryAddress = '';
  String deliveryBoyID = '';
  String userName = '';
  String userAddress = '';
  String userPhone = '';
  String id = '';
  String getOnesignalKey = '';
  String playerId = '';
  Timer? oneSignalTimer;
  String vendorToken = '';

  getRiderUserDetails() {
    FirebaseFirestore.instance
        .collection('users')
        .doc(widget.orderModel.userID)
        .get()
        .then((val) {
      setState(() {
        userName = val['fullname'];
        userAddress = val['address'];
        userPhone = val['phone'];
      });
    });
  }

  Future<void> _callUser(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    await launchUrl(launchUri);
  }

  getOrderDetails() async {
    FirebaseFirestore.instance
        .collection('Orders')
        .doc(widget.orderModel.uid)
        .snapshots()
        .listen((value) {
      setState(() {
        orderStatus = value['status'];
        accepted = value['accept'];
        acceptDelivery = value['acceptDelivery'];
        deliveryAddress = value['deliveryAddress'];
        deliveryBoyID = value['deliveryBoyID'];
      });
    });
  }

  num marketLat = 0;
  num marketLong = 0;

  getMarketDetails() {
    FirebaseFirestore.instance
        .collection('Markets')
        .doc(widget.orderModel.marketID)
        .get()
        .then((val) {
      setState(() {
        marketName = val['Market Name'];
        marketAddress = val['Address'];
        marketPhone = val['Phonenumber'];
        marketLat = val['lat'];
        marketLong = val['long'];
      });
    });
  }

  Future<void> updateVendorNotification(HistoryModel historyModel) async {
    await FirebaseFirestore.instance
        .collection('vendors')
        .doc(widget.orderModel.vendorID)
        .collection('Notifications')
        .add(historyModel.toMap());
  }

  getVendortoken() {
    FirebaseFirestore.instance
        .collection('vendors')
        .doc(widget.orderModel.vendorID)
        .get()
        .then((val) {
      setState(() {
        vendorToken = val['tokenID'];
      });
    });
  }

  getRiderDetails() {
    if (deliveryBoyID == id) {
      FirebaseFirestore.instance
          .collection('drivers')
          .doc(widget.orderModel.deliveryBoyID)
          .snapshots()
          .listen((val) {
        setState(() {
          riderName = val['fullname'];
          riderAddress = val['address'];
          riderPhone = val['phone'];
        });
      });
    }
  }

  // Future<void> _getUserDetails() async {
  //   final FirebaseAuth
  //auth = FirebaseAuth.instance;
  //   final FirebaseFirestore
  //firestore = FirebaseFirestore.instance;
  //   User? user = _auth.currentUser;
  //   setState(() {
  //     userDetails =
  //         _firestore.collection('users').doc(user!.uid).get().then((value) {
  //       setState(() {
  //         wallet = value['wallet'];
  //       });
  //     }) as DocumentReference<Object?>?;
  //   });
  // }
  Future<void> _getUserDetails() async {
    final FirebaseAuth auth = FirebaseAuth.instance;
    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    User? user = auth.currentUser;
    setState(() {
      userDetails = firestore
          .collection('drivers')
          .doc(user!.uid)
          .snapshots()
          .listen((value) {
        setState(() {
          wallet = value['wallet'];
          id = value['id'];
        });
      }) as DocumentReference<Object?>?;
    });
  }

  updateWallet() {
    FirebaseFirestore.instance
        .collection('users')
        .doc(widget.orderModel.userID)
        .update({
      'wallet': wallet +
          widget.orderModel.total +
          (widget.orderModel.deliveryAddress == ''
              ? 0
              : widget.orderModel.deliveryFee)
    });
  }

  @override
  void initState() {
    getRiderDetails();
    _getUserDetails();
    getOrderDetails();
    getOneSignalDetails();
    oneSignalTimer = Timer.periodic(
        const Duration(milliseconds: 100), (Timer t) => initOneSignal());
    _handleGetDeviceState();
    getMarketDetails();
    getRiderUserDetails();
    getVendortoken();
    super.initState();
  }

  initOneSignal() {
    if (getOnesignalKey != '') {
      OneSignal.shared.setLogLevel(OSLogLevel.verbose, OSLogLevel.none);
      //print('One singal app id is jjjjjj');
      OneSignal.shared.setAppId(getOnesignalKey);
      //print('$getOnesignalKey is firebase oneSignal key');
      OneSignal.shared
          .promptUserForPushNotificationPermission()
          .then((accepted) {
        //print("Accepted permission: $accepted");
      });
      oneSignalTimer!.cancel();
    }
  }

  void _handleGetDeviceState() async {
    //print("Getting DeviceState");
    var deviceState = await OneSignal.shared.getDeviceState();
    setState(() {
      playerId = deviceState!.userId!;
    });

    //print('$playerId is your player ID');
  }

  getOneSignalDetails() {
    if (getOnesignalKey == '') {
      FirebaseFirestore.instance
          .collection('Push notification Settings')
          .doc('OneSignal')
          .snapshots()
          .listen((value) {
        setState(() {
          getOnesignalKey = value['OnesignalKey'];
        });
      });
    }
  }

  Future<void> _callMarket(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    await launchUrl(launchUri);
  }

  bool pleaseWait = false;
  acceptingFunc(bool acceptedVal, String status) async {
    setState(() {
      pleaseWait = false;
    });
    updateVendorNotification(HistoryModel(
        message:
            'Congratulations, Your rider is on the way. Order ID #${widget.orderModel.orderID}',
        timeCreated: DateFormat.yMMMMEEEEd().format(DateTime.now()).toString(),
        amount: '-${widget.currencySymbol}${widget.orderModel.deliveryFee}',
        paymentSystem: ''));
    _handleSendNotification(
        vendorToken,
        'Congratulations, Your rider is on the way. Order ID #${widget.orderModel.orderID}',
        'Order accepted');
    FirebaseFirestore.instance
        .collection('Orders')
        .doc(widget.orderModel.uid)
        .update({'acceptDelivery': acceptedVal, 'status': status}).then(
            (value) {
      setState(() {
        pleaseWait = false;
      });
    });
  }

  rejectFunc(String rejectOffer) async {
    setState(() {
      pleaseWait = true;
    });
    updateVendorNotification(HistoryModel(
        message:
            'Sorry, Rider rejected to deliver the order. Order ID #${widget.orderModel.orderID}',
        timeCreated: DateFormat.yMMMMEEEEd().format(DateTime.now()).toString(),
        amount: '-${widget.currencySymbol}${widget.orderModel.deliveryFee}',
        paymentSystem: ''));
    _handleSendNotification(
        vendorToken,
        'Sorry, Rider rejected to deliver the order. Order ID #${widget.orderModel.orderID}',
        'Order rejection');
    FirebaseFirestore.instance
        .collection('Orders')
        .doc(widget.orderModel.uid)
        .update({'deliveryBoyID': rejectOffer}).then((value) {
      setState(() {
        pleaseWait = false;
      });
    });
  }

  completedDeliveryFunc(String status) async {
    setState(() {
      pleaseWait = true;
    });

    FirebaseFirestore.instance
        .collection('Orders')
        .doc(widget.orderModel.uid)
        .update({'status': status}).then((value) {
      setState(() {
        pleaseWait = false;
      });
    });
  }

  void _handleSendNotification(
      String playerId, String content, String heading) async {
    // var imgUrlString =
    //     "http://cdn1-www.dogtime.com/assets/uploads/gallery/30-impossibly-cute-puppies/impossibly-cute-puppy-2.jpg";

    var notification = OSCreateNotification(
      playerIds: [playerId],
      content: content,
      heading: heading,
      // iosAttachments: {"id1": imgUrlString},
      // bigPicture: imgUrlString,
      // buttons: [
      //   OSActionButton(text: "test1", id: "id1"),
      //   OSActionButton(text: "test2", id: "id2")
      // ]
    );

    await OneSignal.shared.postNotification(notification).then((value) {
      Fluttertoast.showToast(
          msg: "$value",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          fontSize: 16.0);
    });
  }

  double deliveryAddressLat = 0;
  double deliveryAddressLong = 0;

  getDeliveryLocationLatAndLong() async {
    if (deliveryAddressLat == 0 && deliveryAddressLong == 0) {
      GeoData data = await Geocoder2.getDataFromAddress(
          address: widget.orderModel.deliveryAddress,
          googleMapApiKey: googleApiKey);
      if (mounted) {
        setState(() {
          deliveryAddressLat = data.latitude;
          deliveryAddressLong = data.longitude;
        });
        // print(deliveryAddressLat);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    getDeliveryLocationLatAndLong();
    return Scaffold(
        appBar: AppBar(
            centerTitle: true,
            title: const Text(
              'Order Preview',
            ),
            elevation: 0),
        body: SingleChildScrollView(
            child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 12, top: 12),
              child: Row(
                children: [
                  const Text('Order Tracking Update',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: Colors.grey))
                      .tr(),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Stack(
              children: [
                deliveryAddressLat != 0 && deliveryAddressLong != 0
                    ? SizedBox(
                        width: double.infinity,
                        height: MediaQuery.of(context).size.height / 1.9,
                        child: MapScreen(
                            zoom: 5,
                            userLat: deliveryAddressLat,
                            address: marketAddress,
                            userLong: deliveryAddressLong,
                            marketLong: marketLong,
                            marketLat: marketLat),
                      )
                    : SizedBox(
                        width: double.infinity,
                        height: MediaQuery.of(context).size.height / 2,
                      ),
                Stepper(
                  physics: const BouncingScrollPhysics(),
                  onStepTapped: (step) {
                    if (step > _index) {
                      setState(() {
                        _index = step;
                      });
                    }
                  },
                  type: StepperType.vertical,
                  controlsBuilder:
                      (BuildContext context, ControlsDetails controls) {
                    return const SizedBox();
                  },
                  currentStep: _index,
                  steps: <Step>[
                    Step(
                      isActive: orderStatus == 'Received'
                          ? true
                          : orderStatus == 'Cancelled'
                              ? false
                              : true,
                      title: orderStatus == 'Cancelled'
                          ? Container(
                              height: 30,
                              width: 100,
                              decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.3),
                                  shape: BoxShape.rectangle),
                              child: Center(
                                  child: const Text('Cancelled',
                                          style: TextStyle(color: Colors.white))
                                      .tr()))
                          : Container(
                              height: 30,
                              width: 100,
                              decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.3),
                                  shape: BoxShape.rectangle),
                              child: Center(
                                  child: const Text('Received',
                                          style: TextStyle(color: Colors.white))
                                      .tr())),
                      content: Container(),
                    ),
                    Step(
                      isActive: accepted == true ? true : false,
                      title: Container(
                          height: 30,
                          width: 100,
                          decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.3),
                              shape: BoxShape.rectangle),
                          child: Center(
                              child: const Text('Accepted',
                                      style: TextStyle(color: Colors.white))
                                  .tr())),
                      content: Container(),
                    ),
                    Step(
                      isActive: (acceptDelivery == true &&
                              (orderStatus == 'Processing' ||
                                  orderStatus == 'Completed'))
                          ? true
                          : false ||
                              (accepted == true &&
                                  deliveryAddress == '' &&
                                  (orderStatus == 'Processing' ||
                                      orderStatus == 'Completed')),
                      title: Container(
                          height: 30,
                          width: 100,
                          decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.3),
                              shape: BoxShape.rectangle),
                          child: Center(
                              child: const Text('Processing',
                                      style: TextStyle(color: Colors.white))
                                  .tr())),
                      content: Container(),
                    ),
                    deliveryAddress != ''
                        ? Step(
                            isActive: acceptDelivery == true &&
                                    (orderStatus == 'On the way' ||
                                        orderStatus == 'Completed')
                                ? true
                                : false,
                            content: Container(),
                            title: Container(
                                height: 30,
                                width: 100,
                                decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.3),
                                    shape: BoxShape.rectangle),
                                child: Center(
                                    child:
                                        const Text('On the way', style: TextStyle(color: Colors.white))
                                            .tr())))
                        : Step(
                            isActive: accepted == true &&
                                    deliveryAddress == '' &&
                                    orderStatus == 'Completed'
                                ? true
                                : false,
                            content: Container(),
                            title: Container(
                                height: 30,
                                width: 100,
                                decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.3),
                                    shape: BoxShape.rectangle),
                                child: Center(child: const Text('Pick up', style: TextStyle(color: Colors.white)).tr()))),
                    Step(
                      isActive: orderStatus == 'Completed'
                          ? true
                          : false ||
                              (accepted == true &&
                                  deliveryAddress == '' &&
                                  orderStatus == 'Completed'),
                      title: Container(
                          height: 30,
                          width: 100,
                          decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.3),
                              shape: BoxShape.rectangle),
                          child: Center(
                              child: const Text('Completed',
                                      style: TextStyle(color: Colors.white))
                                  .tr())),
                      content: Container(),
                    )
                  ],
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(left: 12, top: 12),
              child: Row(
                children: [
                  const Text('Market Detail',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: Colors.grey))
                      .tr(),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.only(left: 10, right: 10),
              child: Card(
                elevation: 0.1,
                child: ListTile(
                  title: Text(marketName),
                  subtitle: const Text('Market name').tr(),
                  leading: const Icon(Icons.info),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 10, right: 10),
              child: Card(
                elevation: 0.1,
                child: ListTile(
                  title: Text(marketAddress),
                  subtitle: const Text('Market address').tr(),
                  leading: const Icon(Icons.room),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 10, right: 10),
              child: Card(
                elevation: 0.1,
                child: ListTile(
                  title: Text(marketPhone),
                  subtitle: const Text('Market phone').tr(),
                  leading: const Icon(Icons.phone),
                  trailing: OutlinedButton(
                      onPressed: () {
                        _callMarket(marketPhone);
                      },
                      child: const Text('Call Market').tr()),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 12, top: 12),
              child: Row(
                children: [
                  const Text("Customer's Detail",
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: Colors.grey))
                      .tr(),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.only(left: 10, right: 10),
              child: Card(
                elevation: 0.1,
                child: ListTile(
                  title: Text(userName),
                  subtitle: const Text("Customer's name").tr(),
                  leading: const Icon(Icons.person),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 10, right: 10),
              child: Card(
                elevation: 0.1,
                child: ListTile(
                  title: Text(userAddress),
                  subtitle: const Text("Customer's address").tr(),
                  leading: const Icon(Icons.room),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 10, right: 10),
              child: Card(
                elevation: 0.1,
                child: ListTile(
                  title: Text(marketPhone),
                  subtitle: const Text("Customer's phone").tr(),
                  leading: const Icon(Icons.phone),
                  trailing: OutlinedButton(
                      onPressed: () {
                        _callUser(userPhone);
                      },
                      child: const Text('Call Customer').tr()),
                ),
              ),
            ),
            deliveryBoyID == ''
                ? Container()
                : Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 12, top: 12),
                        child: Row(
                          children: [
                            const Text("Rider's Detail",
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                        color: Colors.grey))
                                .tr(),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      Padding(
                        padding: const EdgeInsets.only(left: 10, right: 10),
                        child: Card(
                          elevation: 0.1,
                          child: ListTile(
                            title: Text(riderName),
                            subtitle: const Text("Rider's name").tr(),
                            leading: const Icon(Icons.person),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 10, right: 10),
                        child: Card(
                          elevation: 0.1,
                          child: ListTile(
                            title: Text(riderAddress),
                            subtitle: const Text("Rider's address").tr(),
                            leading: const Icon(Icons.room),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 10, right: 10),
                        child: Card(
                          elevation: 0.1,
                          child: ListTile(
                            title: Text(riderPhone),
                            subtitle: const Text("Rider's phone").tr(),
                            leading: const Icon(Icons.phone),
                            // trailing: OutlinedButton(
                            //     onPressed: () {
                            //       _callRider(riderPhone);
                            //     },
                            //     child: Text('Call Rider').tr()),
                          ),
                        ),
                      ),
                    ],
                  ),
            Padding(
              padding: const EdgeInsets.only(left: 12, top: 12),
              child: Row(
                children: [
                  const Text('Payment Detail',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: Colors.grey))
                      .tr(),
                ],
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 10, right: 10),
              child: Card(
                elevation: 0.1,
                child: ListTile(
                  title: widget.orderModel.paymentType == 'Wallet'
                      ? const Text('Wallet')
                      : const Text('Cash on delivery').tr(),
                  subtitle: const Text("Payment type").tr(),
                  leading: const Icon(Icons.payment),
                  trailing: Text(
                      '${widget.currencySymbol}${Formatter().converter(widget.orderModel.total.toDouble())}'),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 12, top: 12),
              child: Row(
                children: [
                  const Text('Delivery Detail',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: Colors.grey))
                      .tr(),
                ],
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            widget.orderModel.deliveryAddress != ''
                ? Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 10, right: 10),
                        child: Card(
                          elevation: 0.1,
                          child: ListTile(
                            title: Text(widget.orderModel.deliveryAddress),
                            subtitle: const Text("Delivery Address").tr(),
                            leading: const Icon(Icons.room),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 10, right: 10),
                        child: Card(
                          elevation: 0.1,
                          child: ListTile(
                            title: Text(widget.orderModel.houseNumber),
                            subtitle: const Text("House number").tr(),
                            leading: const Icon(Icons.home),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 10, right: 10),
                        child: Card(
                          elevation: 0.1,
                          child: ListTile(
                            title: Text(widget.orderModel.closesBusStop),
                            subtitle: const Text("Closest Bus stop").tr(),
                            leading: const Icon(Icons.bus_alert),
                          ),
                        ),
                      ),
                    ],
                  )
                : Padding(
                    padding: const EdgeInsets.only(left: 10, right: 10),
                    child: Card(
                      elevation: 0.1,
                      child: ListTile(
                        title: const Text('Pick Up'),
                        subtitle: const Text("Delivery Address").tr(),
                        leading: const Icon(Icons.room),
                      ),
                    ),
                  ),
            Padding(
              padding: const EdgeInsets.only(left: 12, top: 12),
              child: Row(
                children: [
                  const Text('Products',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: Colors.grey))
                      .tr(),
                ],
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Column(
                children: widget.orderModel.orders
                    .map((e) => Padding(
                          padding: const EdgeInsets.only(left: 10, right: 10),
                          child: Card(
                            elevation: 0.1,
                            child: ListTile(
                              subtitle: Text(e.selected),
                              leading: Text('QTY: ${e.quantity}'),
                              title: Text(e.productName),
                              trailing: Text(
                                  '${widget.currencySymbol}${Formatter().converter(e.selectedPrice.toDouble())}'),
                            ),
                          ),
                        ))
                    .toList()),
            const SizedBox(height: 20),
            deliveryBoyID == id && acceptDelivery == false
                ? Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                            onPressed: pleaseWait == true
                                ? null
                                : () async {
                                    acceptingFunc(true, 'Processing');
                                  },
                            child: pleaseWait == true
                                ? const Text('Please wait...').tr()
                                : const Text('Accept To Deliver Order').tr())),
                  )
                : Container(),
            deliveryBoyID == id && acceptDelivery == false
                ? Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                            onPressed: pleaseWait == true
                                ? null
                                : () async {
                                    rejectFunc('');
                                  },
                            child: pleaseWait == true
                                ? const Text('Please wait...').tr()
                                : const Text('Reject Delivery').tr())),
                  )
                : Container(),
            deliveryBoyID == id &&
                    acceptDelivery == true &&
                    orderStatus == 'On the way'
                ? Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                            onPressed: pleaseWait == true
                                ? null
                                : () async {
                                    completedDeliveryFunc('Completed');
                                  },
                            child: pleaseWait == true
                                ? const Text('Please wait...').tr()
                                : const Text('Completed delivery').tr())),
                  )
                : Container(),
            const SizedBox(height: 20),
          ],
        )));
  }
}

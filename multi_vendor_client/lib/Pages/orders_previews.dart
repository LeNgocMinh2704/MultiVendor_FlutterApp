import 'dart:async';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:vendor/Model/history.dart';
import 'package:vendor/Model/order_model.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../Model/constant.dart';
import '../Model/formatter.dart';
import '../Widget/map.dart';
import 'delivery_boys.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:geocoder2/geocoder2.dart';

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
  String riderName = 'fetching data...'.tr();
  String riderAddress = 'fetching data...'.tr();
  String riderPhone = 'fetching data...'.tr();
  String riderTokeID = '';
  num userWallet = 0;
  num vendorWallet = 0;
  DocumentReference? userDetails;
  String orderStatus = '';
  bool accepted = false;
  bool acceptDelivery = false;
  String deliveryAddress = '';
  String deliveryBoyID = '';
  Timer? timer;
  Timer? _timer;
  String getOnesignalKey = '';
  String playerId = '';
  Timer? oneSignalTimer;
  num marketCommission = 0;
  num adminCommission = 0;
  num adminBalance = 0;

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
    if (marketName == '') {
      FirebaseFirestore.instance
          .collection('Markets')
          .doc(widget.orderModel.marketID)
          .get()
          .then((val) {
        setState(() {
          marketName = val['Market Name'];
          marketAddress = val['Address'];
          marketPhone = val['Phonenumber'];
          marketCommission = val['commission'];
          marketLat = val['lat'];
          marketLong = val['long'];
        });
      });
    }
  }

  getMarketCommission() {
    setState(() {
      var total = widget.orderModel.total -
          (widget.orderModel.deliveryAddress == ''
              ? 0
              : widget.orderModel.deliveryFee);
      var adminReturns = total * marketCommission / 100;
      adminCommission = adminReturns;
    });
    //print('$adminCommission is your commission');
    //print(widget.orderModel.total);
  }

  getRiderDetails() {
    if (deliveryBoyID != '') {
      FirebaseFirestore.instance
          .collection('drivers')
          .doc(deliveryBoyID)
          .get()
          .then((val) {
        setState(() {
          riderName = val['fullname'];
          riderAddress = val['address'];
          riderPhone = val['phone'];
          riderTokeID = val['tokenID'];
        });
      });
    }
  }

  String userName = '';
  String userAddress = '';
  String userPhone = '';
  String userTokenID = '';

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
        userTokenID = val['tokenID'];
      });
    });
  }

  Future<void> _getUserDetails() async {
    setState(() {
      FirebaseFirestore.instance
          .collection('users')
          .doc(widget.orderModel.userID)
          .snapshots()
          .listen((value) {
        setState(() {
          userWallet = value['wallet'];
        });
      }) as DocumentReference<Object?>?;
    });
  }

  Future<void> _getvendorDetails() async {
    setState(() {
      FirebaseFirestore.instance
          .collection('vendors')
          .doc(widget.orderModel.vendorID)
          .snapshots()
          .listen((value) {
        setState(() {
          vendorWallet = value['wallet'];
        });
      }) as DocumentReference<Object?>?;
    });
  }

  Future<void> updateUserWallet(num wallet) async {
    FirebaseFirestore.instance
        .collection('users')
        .doc(widget.orderModel.userID)
        .update({'wallet': wallet});
  }

  Future<void> updateVendorWallet() async {
    FirebaseFirestore.instance
        .collection('vendors')
        .doc(widget.orderModel.vendorID)
        .update({
      'wallet': vendorWallet + (widget.orderModel.total - adminCommission)
    });
  }

  adminCommissionDetails() {
    if (accepted == true) {
      FirebaseFirestore.instance
          .collection('Admin')
          .doc('Admin')
          .snapshots()
          .listen((value) {
        setState(() {
          adminBalance = value['commission'];
        });
      });
    }
  }

  updateAdminCommission() {
    FirebaseFirestore.instance
        .collection('Admin')
        .doc('Admin')
        .update({'commission': adminBalance + adminCommission});
  }

  Future<void> updateVendorWalletWhenDeliveryIsTrue() async {
    FirebaseFirestore.instance
        .collection('vendors')
        .doc(widget.orderModel.vendorID)
        .update({
      'wallet': vendorWallet +
          (widget.orderModel.total - adminCommission) -
          (widget.orderModel.deliveryAddress == ''
              ? 0
              : widget.orderModel.deliveryFee)
    });
  }

  endLoader(Timer timer) {
    EasyLoading.addStatusCallback((status) {
      //print('EasyLoading Status $status');
      if (status == EasyLoadingStatus.dismiss) {
        timer.cancel();
      }
    });
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

  @override
  void initState() {
    _getvendorDetails();
    getMarketDetails();
    getOneSignalDetails();
    _getUserDetails();
    getOrderDetails();
    adminCommissionDetails();
    timer = Timer.periodic(
        const Duration(seconds: 10), (Timer t) => getRiderDetails());
    oneSignalTimer = Timer.periodic(
        const Duration(milliseconds: 100), (Timer t) => initOneSignal());
    _handleGetDeviceState();
    getRiderUserDetails();
    whenDeliveryboyIsEmpty();
    EasyLoading.addStatusCallback((status) {
      //print('EasyLoading Status $status');
      if (status == EasyLoadingStatus.dismiss) {
        _timer?.cancel();
      }
      endLoader(_timer!);
    });
    timer = Timer.periodic(
        const Duration(seconds: 5), (Timer t) => autoAssignRider(context));
    super.initState();
  }

  whenDeliveryboyIsEmpty() {
    FirebaseFirestore.instance
        .collection('vendors')
        .doc(widget.orderModel.vendorID)
        .collection('Delivery Boys')
        .get()
        .then((value) {
      if (value.docs.isEmpty) {
        //print('Delivery is Empty');
        Fluttertoast.showToast(
            msg: "Please add your favorite drivers to continue".tr(),
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.TOP,
            timeInSecForIosWeb: 1,
            fontSize: 14.0);
        Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const DeliveryBoys()));
      }
    });
  }

  Future<void> _callUser(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    await launchUrl(launchUri);
  }

  Future<void> _callRider(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    await launchUrl(launchUri);
  }

  Future<void> updateVendorHistory(HistoryModel historyModel) async {
    await FirebaseFirestore.instance
        .collection('vendors')
        .doc(widget.orderModel.vendorID)
        .collection('History')
        .add(historyModel.toMap());
  }

  Future<void> updateVendorNotification(HistoryModel historyModel) async {
    await FirebaseFirestore.instance
        .collection('vendors')
        .doc(widget.orderModel.vendorID)
        .collection('Notications')
        .add(historyModel.toMap());
  }

  Future<void> updateUserHistory(HistoryModel historyModel) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.orderModel.vendorID)
        .collection('History')
        .add(historyModel.toMap());
  }

  Future<void> updateUserNotification(HistoryModel historyModel) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.orderModel.userID)
        .collection('Notifications')
        .add(historyModel.toMap());
  }

  Future<void> updatedriverNotification(HistoryModel historyModel) async {
    await FirebaseFirestore.instance
        .collection('drivers')
        .doc(deliveryBoyID)
        .collection('Notifications')
        .add(historyModel.toMap());
  }

  bool pleaseWait = false;
  acceptingFunc(bool acceptedVal) async {
    setState(() {
      pleaseWait = true;
    });
    if (widget.orderModel.paymentType == 'Wallet') {
      updateVendorWalletWhenDeliveryIsTrue();
      updateAdminCommission();
      updateVendorHistory(HistoryModel(
          message: 'Fund received from an order placed',
          timeCreated:
              DateFormat.yMMMMEEEEd().format(DateTime.now()).toString(),
          amount:
              '-${widget.currencySymbol}${vendorWallet + (widget.orderModel.total - adminCommission) - (widget.orderModel.deliveryAddress == '' ? 0 : widget.orderModel.deliveryFee)}',
          paymentSystem: ''));
    }
    updateUserNotification(HistoryModel(
        message:
            'Congratulations, Your order has been accepted by $marketName.  Order ID #${widget.orderModel.orderID}',
        timeCreated: DateFormat.yMMMMEEEEd().format(DateTime.now()).toString(),
        amount:
            '-${widget.currencySymbol}${vendorWallet + widget.orderModel.total - (widget.orderModel.deliveryAddress == '' ? 0 : widget.orderModel.deliveryFee)}',
        paymentSystem: ''));
    _handleSendNotification(
        userTokenID,
        'Congratulations, Your order has been accepted by $marketName.  Order ID #${widget.orderModel.orderID}',
        'Order has been accepted');

    FirebaseFirestore.instance
        .collection('Orders')
        .doc(widget.orderModel.uid)
        .update({'accept': acceptedVal}).then((value) {
      setState(() {
        pleaseWait = false;
      });
    });
  }

  rejectFunc(String cancelled) async {
    setState(() {
      pleaseWait = true;
    });
    if (widget.orderModel.paymentType == 'Wallet') {
      updateUserWallet(userWallet + widget.orderModel.total);
      updateUserHistory(HistoryModel(
          message: 'Fund reversal because of order rejection',
          timeCreated:
              DateFormat.yMMMMEEEEd().format(DateTime.now()).toString(),
          amount:
              '-${widget.currencySymbol}${userWallet + widget.orderModel.total}',
          paymentSystem: ''));
    }
    updateUserNotification(HistoryModel(
        message:
            'Sorry, Your order was rejected by $marketName.  Order ID #${widget.orderModel.orderID}',
        timeCreated: DateFormat.yMMMMEEEEd().format(DateTime.now()).toString(),
        amount:
            '-${widget.currencySymbol}${vendorWallet + widget.orderModel.total}',
        paymentSystem: ''));
    _handleSendNotification(
        userTokenID,
        'Sorry, Your order was rejected by $marketName.  Order ID #${widget.orderModel.orderID}',
        'Order has been rejected');

    FirebaseFirestore.instance
        .collection('Orders')
        .doc(widget.orderModel.uid)
        .update({'status': cancelled}).then((value) {
      Navigator.of(context).pop();
      setState(() {
        pleaseWait = false;
      });
    });
  }

  processingPickupFunc(String processing) async {
    setState(() {
      pleaseWait = true;
    });
    updateUserNotification(HistoryModel(
        message:
            'Congratulations, Your order is being processed.  Order ID #${widget.orderModel.orderID}',
        timeCreated: DateFormat.yMMMMEEEEd().format(DateTime.now()).toString(),
        amount:
            '-${widget.currencySymbol}${vendorWallet + widget.orderModel.total}',
        paymentSystem: ''));
    _handleSendNotification(
        userTokenID,
        'Congratulations, Your order is being processed.  Order ID #${widget.orderModel.orderID}',
        'Order is processing');
    FirebaseFirestore.instance
        .collection('Orders')
        .doc(widget.orderModel.uid)
        .update({'status': processing}).then((value) {
      setState(() {
        pleaseWait = false;
      });
    });
  }

  completedPickupFunc(String completed) async {
    setState(() {
      pleaseWait = true;
    });

    if (widget.orderModel.paymentType == 'Wallet') {
      //  updateVendorWallet();
      updateAdminCommission();
      updateVendorHistory(HistoryModel(
          message: 'Completed Order',
          timeCreated:
              DateFormat.yMMMMEEEEd().format(DateTime.now()).toString(),
          amount:
              '+${widget.currencySymbol}${vendorWallet + (widget.orderModel.total - adminCommission)}',
          paymentSystem: ''));
    }
    updateUserNotification(HistoryModel(
        message:
            'Congratulations, Your order has been completed. Order ID #${widget.orderModel.orderID}',
        timeCreated: DateFormat.yMMMMEEEEd().format(DateTime.now()).toString(),
        amount:
            '-${widget.currencySymbol}${vendorWallet + widget.orderModel.total}',
        paymentSystem: ''));
    _handleSendNotification(
        userTokenID,
        'Congratulations, Your order has been completed. Order ID #${widget.orderModel.orderID}',
        'Order is completed');
    FirebaseFirestore.instance
        .collection('Orders')
        .doc(widget.orderModel.uid)
        .update({'status': completed}).then((value) {
      setState(() {
        pleaseWait = false;
      });
    });
  }

  onthewayFunc(String ontheWay) async {
    setState(() {
      pleaseWait = true;
    });
    updateUserNotification(HistoryModel(
        message:
            'Congratulations, Your order is on the way. Order ID #${widget.orderModel.orderID}',
        timeCreated: DateFormat.yMMMMEEEEd().format(DateTime.now()).toString(),
        amount:
            '-${widget.currencySymbol}${vendorWallet + widget.orderModel.total}',
        paymentSystem: ''));
    _handleSendNotification(
        userTokenID,
        'Congratulations, Your order is on the way. Order ID #${widget.orderModel.orderID}',
        'Order is on the way');
    FirebaseFirestore.instance
        .collection('Orders')
        .doc(widget.orderModel.uid)
        .update({'status': ontheWay}).then((value) {
      setState(() {
        pleaseWait = false;
      });
    });
  }

  int randomIndex = 0;
  List riders = [];
  autoAssignRider(context) async {
    if (accepted == true && deliveryAddress != '' && deliveryBoyID == '') {
      //print('Working');
      if (riders.isEmpty && deliveryBoyID == '') {
        Fluttertoast.showToast(
            msg: "Assigning a rider to this order please wait...".tr(),
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.CENTER,
            timeInSecForIosWeb: 1,
            fontSize: 16.0);
        // _timer?.cancel();
        // await EasyLoading.show(
        //   status: 'Assigning a rider please wait...',
        //   maskType: EasyLoadingMaskType.black,
        // );
      }
      // Fluttertoast.showToast(
      //     msg: "Assigning a rider to this order",
      //     toastLength: Toast.LENGTH_LONG,
      //     gravity: ToastGravity.CENTER,
      //     timeInSecForIosWeb: 1,
      //     backgroundColor: Theme.of(context).primaryColor,
      //     textColor: Colors.white,
      //     fontSize: 16.0);
      FirebaseFirestore.instance
          .collection('vendors')
          .doc(widget.orderModel.vendorID)
          .collection('Delivery Boys')
          .get()
          .then((value) {
        for (var element in value.docs) {
          if (riders.isEmpty) {
            riders.add(element['id']);
            setState(() {
              randomIndex = Random().nextInt(riders.length);
              deliveryBoyID = riders[randomIndex];
            });
            if (deliveryBoyID != '') {
              updatedriverNotification(HistoryModel(
                  message:
                      'Hello, You have a new delivery. Order ID #${widget.orderModel.orderID}',
                  timeCreated:
                      DateFormat.yMMMMEEEEd().format(DateTime.now()).toString(),
                  amount:
                      '${widget.currencySymbol}${widget.orderModel.deliveryFee}',
                  paymentSystem: ''));
              _handleSendNotification(
                  riderTokeID,
                  'Hello, You have a new delivery. Order ID #${widget.orderModel.orderID}',
                  'New Order');
              FirebaseFirestore.instance
                  .collection('Orders')
                  .doc(widget.orderModel.uid)
                  .update({'deliveryBoyID': deliveryBoyID});
              Fluttertoast.showToast(
                  msg: "A Rider has been assigned to the order".tr(),
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.TOP,
                  timeInSecForIosWeb: 1,
                  fontSize: 14.0);
              // EasyLoading.dismiss();
            }
          }
        }
      });
    }
  }

  assignRiderButton() {
    Fluttertoast.showToast(
        msg: "Assigning a rider to this order please wait...".tr(),
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 1,
        fontSize: 16.0);

    FirebaseFirestore.instance
        .collection('vendors')
        .doc(widget.orderModel.vendorID)
        .collection('Delivery Boys')
        .get()
        .then((value) {
      if (value.docs.isEmpty) {
        //print('Delivery is Empty');
        Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const DeliveryBoys()));
      } else {
        for (var element in value.docs) {
          riders.add(element['id']);
          setState(() {
            randomIndex = Random().nextInt(riders.length);
            deliveryBoyID = riders[randomIndex];
          });
          if (deliveryBoyID != '') {
            updatedriverNotification(HistoryModel(
                message:
                    'Hello, You have a new order. Order ID #${widget.orderModel.orderID}',
                timeCreated:
                    DateFormat.yMMMMEEEEd().format(DateTime.now()).toString(),
                amount:
                    '-${widget.currencySymbol}${widget.orderModel.deliveryFee}',
                paymentSystem: ''));
            _handleSendNotification(
                riderTokeID,
                'Hello, You have a new order. Order ID #${widget.orderModel.orderID}',
                'New Order');
            FirebaseFirestore.instance
                .collection('Orders')
                .doc(widget.orderModel.uid)
                .update({'deliveryBoyID': deliveryBoyID});
            Fluttertoast.showToast(
                msg: "A Rider has been assigned to the order".tr(),
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.TOP,
                timeInSecForIosWeb: 1,
                fontSize: 14.0);
          }
        }
      }
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
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
    getMarketCommission();
    getDeliveryLocationLatAndLong();
    // autoAssignRider(context);
    return Scaffold(
        appBar: AppBar(
            centerTitle: true,
            //    backgroundColor: Colors.blue,
            title: const Text(
              'Order Preview',
            ).tr(),
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
            // Padding(
            //   padding: const EdgeInsets.only(left: 10, right: 10),
            //   child: Card(
            //     elevation: 0.1,
            //     child: ListTile(
            //       title: Text(marketPhone),
            //       subtitle: Text('Market phone'),
            //       leading: Icon(Icons.phone),
            //       trailing: OutlinedButton(
            //           onPressed: () {
            //             _callMarket(marketPhone);
            //           },
            //           child: Text('Call Market')),
            //     ),
            //   ),
            // ),
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
                      child: const Text('Call Market').tr()),
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
                      // Padding(
                      //   padding: const EdgeInsets.only(left: 10, right: 10),
                      //   child: Card(
                      //     elevation: 0.1,
                      //     child: ListTile(
                      //       title: Text(riderAddress),
                      //       subtitle: Text("Rider's address"),
                      //       leading: Icon(Icons.room),
                      //     ),
                      //   ),
                      // ),
                      Padding(
                        padding: const EdgeInsets.only(left: 10, right: 10),
                        child: Card(
                          elevation: 0.1,
                          child: ListTile(
                            title: Text(riderPhone),
                            subtitle: const Text("Rider's phone").tr(),
                            leading: const Icon(Icons.phone),
                            trailing: OutlinedButton(
                                onPressed: () {
                                  _callRider(riderPhone);
                                },
                                child: const Text('Call Rider').tr()),
                          ),
                        ),
                      ),
                      acceptDelivery == true
                          ? Container()
                          : Padding(
                              padding:
                                  const EdgeInsets.only(left: 10, right: 10),
                              child: Card(
                                elevation: 0.1,
                                child: ListTile(
                                  title: acceptDelivery == false
                                      ? const Text('Not Yet').tr()
                                      : Container(),
                                  subtitle: const Text("Accept Delivery").tr(),
                                  trailing: acceptDelivery == false
                                      ? OutlinedButton(
                                          onPressed: () {
                                            assignRiderButton();
                                          },
                                          child: const Text(
                                                  'Auto Assign Another Rider')
                                              .tr())
                                      : Container(),
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
                      ? const Text('Wallet').tr()
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
                        title: const Text('Pick Up').tr(),
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
            accepted == false && orderStatus == 'Received'
                ? Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                            onPressed: pleaseWait == true
                                ? null
                                : () async {
                                    acceptingFunc(true);
                                  },
                            child: pleaseWait == true
                                ? const Text('Please wait...')
                                : const Text('Accept Order').tr())),
                  )
                : orderStatus == 'Cancelled'
                    ? const Text('Order is rejected by you').tr()
                    : Container(),
            accepted == false && orderStatus == 'Received'
                ? Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                            onPressed: pleaseWait == true
                                ? null
                                : () {
                                    showDialog(
                                        context: context,
                                        builder: (builder) {
                                          return AlertDialog(
                                              actions: [
                                                InkWell(
                                                    onTap: () async {
                                                      rejectFunc('Cancelled');
                                                    },
                                                    child:
                                                        const Text('Yes').tr()),
                                                const SizedBox(width: 10),
                                                InkWell(
                                                    onTap: () {
                                                      Navigator.of(context)
                                                          .pop();
                                                    },
                                                    child:
                                                        const Text('No').tr()),
                                              ],
                                              title: const Text(
                                                      'Order Rejection!!!',
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold))
                                                  .tr(),
                                              content: Container(
                                                child: const Text(
                                                        'Are you sure you want to reject this order?')
                                                    .tr(),
                                              ));
                                        });
                                  },
                            child: pleaseWait
                                ? const Text('Please wait...').tr()
                                : const Text('Reject Order').tr())),
                  )
                : Container(),
            accepted == true &&
                    deliveryAddress == '' &&
                    orderStatus == 'Received'
                ? Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                            onPressed: pleaseWait == true
                                ? null
                                : accepted == true &&
                                        deliveryAddress == '' &&
                                        orderStatus == 'Processing'
                                    ? null
                                    : () async {
                                        processingPickupFunc('Processing');
                                      },
                            child: pleaseWait == true
                                ? const Text('Please wait...').tr()
                                : const Text('Update To Processing').tr())))
                : Container(),
            accepted == true &&
                    deliveryAddress == '' &&
                    orderStatus == 'Processing'
                ? Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                            onPressed: pleaseWait == true
                                ? null
                                : accepted == true &&
                                        deliveryAddress == '' &&
                                        orderStatus == 'Completed'
                                    ? null
                                    : () async {
                                        completedPickupFunc('Completed');
                                      },
                            child: pleaseWait == true
                                ? const Text('Please wait...').tr()
                                : const Text('Update To Completed').tr())))
                : Container(),
            accepted == true &&
                    deliveryAddress != '' &&
                    orderStatus == 'Processing' &&
                    acceptDelivery == true
                ? Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                            onPressed: pleaseWait == true
                                ? null
                                : () {
                                    onthewayFunc('On the way');
                                  },
                            child: pleaseWait == true
                                ? const Text('Please wait...').tr()
                                : const Text('Update to on the way').tr())))
                : Container(),
            const SizedBox(height: 20),
          ],
        )));
  }
}

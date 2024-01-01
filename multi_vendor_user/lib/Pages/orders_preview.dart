import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geocoder2/geocoder2.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:url_launcher/url_launcher.dart';
import '../Model/constant.dart';
import '../Model/formatter.dart';
import '../Model/history.dart';
import '../Model/order_model.dart';
import '../Widgets/map.dart';

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
  num riderWallet = 0;
  bool confirmationStatus = false;
  String getOnesignalKey = '';
  String playerId = '';
  Timer? oneSignalTimer;
  num totalNumberOfUserRatingRider = 0;
  num totalNumberOfUserRatingMarket = 0;
  num totalRatingRider = 0;
  num totalRatingMarket = 0;
  String reviewMarket = '';
  num ratingValMarket = 0;
  String reviewRider = '';
  num ratingValRider = 0;
  String reviewProduct = '';
  num ratingValProduct = 0;
  String userFullname = '';
  String userProfilePic = '';
  num? tip;
  String? userId;

  ratingAndReviewProduct(String productID, num totalRatingProduct,
      num totalNumberOfUserRatingProduct) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Review Product').tr(),
            content: SizedBox(
              height: MediaQuery.of(context).size.height / 3,
              width: double.infinity,
              child: Column(children: [
                RatingBar.builder(
                  initialRating: 1,
                  minRating: 1,
                  direction: Axis.horizontal,
                  allowHalfRating: true,
                  itemCount: 5,
                  itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
                  itemBuilder: (context, _) => const Icon(
                    Icons.star,
                    color: Colors.amber,
                  ),
                  onRatingUpdate: (rating) {
                    setState(() {
                      ratingValProduct = rating;
                    });
                  },
                ),
                const SizedBox(height: 10),
                TextField(
                  decoration: InputDecoration(hintText: 'Review Product'.tr()),
                  onChanged: (val) {
                    setState(() {
                      reviewProduct = val;
                    });
                  },
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                    onPressed: () {
                      FirebaseFirestore.instance
                          .collection('Products')
                          .doc(productID)
                          .update({
                        'totalRating': totalRatingProduct + ratingValProduct,
                        'totalNumberOfUserRating':
                            totalNumberOfUserRatingProduct + 1
                      });
                      FirebaseFirestore.instance
                          .collection('Products')
                          .doc(productID)
                          .collection('Ratings')
                          .doc(userId) // Document ID là userID
                          .set({
                        'productId': productID,
                        'userId': userId,
                        'rating': ratingValProduct,
                        'review': reviewProduct,
                        'fullname': userFullname,
                        'profilePicture': userProfilePic,
                        'timeCreated': DateFormat.yMMMMEEEEd()
                            .format(DateTime.now())
                            .toString()
                      }).then((value) => Navigator.of(context).pop());
                    },
                    child: const Text('Submit').tr())
              ]),
            ),
          );
        });
  }

  ratingAndReviewRider() {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Rate And Review Rider').tr(),
            content: SizedBox(
              height: MediaQuery.of(context).size.height / 3,
              width: double.infinity,
              child: Column(children: [
                RatingBar.builder(
                  initialRating: 1,
                  minRating: 1,
                  direction: Axis.horizontal,
                  allowHalfRating: true,
                  itemCount: 5,
                  itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
                  itemBuilder: (context, _) => const Icon(
                    Icons.star,
                    color: Colors.amber,
                  ),
                  onRatingUpdate: (rating) {
                    setState(() {
                      ratingValRider = rating;
                    });
                  },
                ),
                const SizedBox(height: 10),
                TextField(
                  decoration: InputDecoration(hintText: 'Review Rider'.tr()),
                  onChanged: (val) {
                    setState(() {
                      reviewRider = val;
                    });
                  },
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                    onPressed: () {
                      FirebaseFirestore.instance
                          .collection('drivers')
                          .doc(deliveryBoyID)
                          .update({
                        'totalRating': totalRatingRider + ratingValRider,
                        'totalNumberOfUserRating':
                            totalNumberOfUserRatingRider + 1
                      });
                      FirebaseFirestore.instance
                          .collection('drivers')
                          .doc(deliveryBoyID)
                          .collection('Ratings')
                          .add({
                        'rating': ratingValRider,
                        'review': reviewRider,
                        'fullname': userFullname,
                        'profilePicture': userProfilePic,
                        'timeCreated': DateFormat.yMMMMEEEEd()
                            .format(DateTime.now())
                            .toString()
                      }).then((value) => Navigator.of(context).pop());
                    },
                    child: const Text('Submit').tr())
              ]),
            ),
          );
        });
  }

  ratingAndReviewMarket() {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Rate And Review Market').tr(),
            content: SizedBox(
              height: MediaQuery.of(context).size.height / 3,
              width: double.infinity,
              child: Column(children: [
                RatingBar.builder(
                  initialRating: 1,
                  minRating: 1,
                  direction: Axis.horizontal,
                  allowHalfRating: true,
                  itemCount: 5,
                  itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
                  itemBuilder: (context, _) => const Icon(
                    Icons.star,
                    color: Colors.amber,
                  ),
                  onRatingUpdate: (rating) {
                    setState(() {
                      ratingValMarket = rating;
                    });
                  },
                ),
                const SizedBox(height: 10),
                TextField(
                  decoration: InputDecoration(hintText: 'Review Market'.tr()),
                  onChanged: (val) {
                    setState(() {
                      reviewMarket = val;
                    });
                  },
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                    onPressed: () {
                      FirebaseFirestore.instance
                          .collection('Markets')
                          .doc(widget.orderModel.marketID)
                          .update({
                        'totalRating': totalRatingMarket + ratingValMarket,
                        'totalNumberOfUserRating':
                            totalNumberOfUserRatingMarket + 1
                      });
                      FirebaseFirestore.instance
                          .collection('Markets')
                          .doc(widget.orderModel.marketID)
                          .collection('Ratings')
                          .add({
                        'rating': ratingValMarket,
                        'review': reviewMarket,
                        'fullname': userFullname,
                        'profilePicture': userProfilePic,
                        'timeCreated': DateFormat.yMMMMEEEEd()
                            .format(DateTime.now())
                            .toString()
                      }).then((value) => Navigator.of(context).pop());
                    },
                    child: const Text('Submit'))
              ]),
            ),
          );
        });
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
        confirmationStatus = value['confirmationStatus'];
      });
      getRiderDetails(value['deliveryBoyID']);
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
        totalRatingMarket = val['totalRating'];
        totalNumberOfUserRatingMarket = val['totalNumberOfUserRating'];
        marketLat = val['lat'];
        marketLong = val['long'];
      });
    });
  }

  getRiderDetails(String deliveryBoyID) {
    if (deliveryBoyID != '') {
      FirebaseFirestore.instance
          .collection('drivers')
          .doc(widget.orderModel.deliveryBoyID)
          .snapshots()
          .listen((val) {
        setState(() {
          riderName = val['fullname'];
          riderAddress = val['address'];
          riderPhone = val['phone'];
          riderWallet = val['wallet'];
          totalRatingRider = val['totalRating'];
          totalNumberOfUserRatingRider = val['totalNumberOfUserRating'];
        });
      });
    }
  }

  Future<void> _getUserDetails() async {
    final FirebaseAuth auth = FirebaseAuth.instance;
    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    User? user = auth.currentUser;
    setState(() {
      userDetails =
          firestore.collection('users').doc(user!.uid).get().then((value) {
        setState(() {
          userId = value['id'];
          wallet = value['wallet'];
          userFullname = value['fullname'];
          userProfilePic = value['photoUrl'];
        });
      }) as DocumentReference<Object?>?;
    });
  }

  updateWallet() {
    FirebaseFirestore.instance
        .collection('users')
        .doc(widget.orderModel.userID)
        .update({'wallet': wallet + widget.orderModel.total});
  }

  initOneSignal() {
    if (getOnesignalKey != '') {
      OneSignal.shared.setLogLevel(OSLogLevel.verbose, OSLogLevel.none);
      debugPrint('One singal app id is jjjjjj');
      OneSignal.shared.setAppId(getOnesignalKey);
      debugPrint('$getOnesignalKey is firebase oneSignal key');
      OneSignal.shared
          .promptUserForPushNotificationPermission()
          .then((accepted) {
        debugPrint("Accepted permission: $accepted");
      });
      oneSignalTimer!.cancel();
    }
  }

  void _handleGetDeviceState() async {
    debugPrint("Getting DeviceState");
    var deviceState = await OneSignal.shared.getDeviceState();
    setState(() {
      playerId = deviceState!.userId!;
    });

    debugPrint('$playerId is your player ID');
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

  updateHistory(HistoryModel historyModel, String collection, String id) {
    FirebaseFirestore.instance
        .collection(collection)
        .doc(id)
        .collection('History')
        .add(historyModel.toMap());
  }

  @override
  void initState() {
    getOneSignalDetails();
    getOrderDetails();
    oneSignalTimer = Timer.periodic(
        const Duration(milliseconds: 100), (Timer t) => initOneSignal());
    _handleGetDeviceState();

    getMarketDetails();
    _getUserDetails();
    super.initState();
  }

  Future<void> updatedriverNotification(HistoryModel historyModel) async {
    await FirebaseFirestore.instance
        .collection('drivers')
        .doc(deliveryBoyID)
        .collection('Notifications')
        .add(historyModel.toMap());
  }

  Future<void> _callMarket(String phoneNumber) async {
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

  bool pleaseWait = false;
  confirmFunc(bool status) async {
    setState(() {
      pleaseWait = true;
    });
    updateDriverWallet(riderWallet + widget.orderModel.deliveryFee);
    updatedriverNotification(HistoryModel(
        message:
            'Congratulations, Your delivery has been confirmed. Order ID #${widget.orderModel.orderID}',
        timeCreated: DateFormat.yMMMMEEEEd().format(DateTime.now()).toString(),
        amount: '-${widget.currencySymbol}${widget.orderModel.deliveryFee}',
        paymentSystem: ''));
    FirebaseFirestore.instance
        .collection('Orders')
        .doc(widget.orderModel.uid)
        .update({'confirmationStatus': status}).then((value) {
      Navigator.of(context).pop();
      setState(() {
        pleaseWait = false;
      });
    });
  }

  updateDriverWallet(num wallet) {
    FirebaseFirestore.instance
        .collection('drivers')
        .doc(widget.orderModel.deliveryBoyID)
        .update({'wallet': wallet});
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

  String currentAddress = '';
  double addressLat = 0;
  double addressLong = 0;

  getCurrentLocationLatAndLong() async {
    if (widget.orderModel.deliveryAddress == '' && currentAddress != '') {
      List<Location> locations = await locationFromAddress(currentAddress);

      setState(() {
        for (var element in locations) {
          deliveryAddressLong = element.longitude;
          deliveryAddressLat = element.latitude;
        }
      });
    }
  }

  getLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }
    if (currentAddress == '') {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.best);
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      for (var element in placemarks) {
        setState(() {
          currentAddress = element.name!;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    getCurrentLocationLatAndLong();
    getDeliveryLocationLatAndLong();
    getLocation();
    return Scaffold(
        appBar: AppBar(
            iconTheme: Theme.of(context).iconTheme,
            titleTextStyle: TextStyle(color: Theme.of(context).indicatorColor),
            backgroundColor: Theme.of(context).colorScheme.background,
            centerTitle: true,
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
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 12))
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
                                        const Text('On the way', style: TextStyle(color: Colors.white, fontSize: 12))
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
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 12))
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
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Market Detail',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: Colors.grey))
                      .tr(),
                  orderStatus == 'Completed'
                      ? Padding(
                          padding: const EdgeInsets.only(right: 10),
                          child: InkWell(
                            onTap: () {
                              ratingAndReviewMarket();
                            },
                            child: const Text("Rate Market",
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                        color: Colors.grey))
                                .tr(),
                          ),
                        )
                      : Container(),
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
            deliveryBoyID == ''
                ? Container()
                : Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 12, top: 12),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text("Rider's Detail",
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                        color: Colors.grey))
                                .tr(),
                            orderStatus == 'Completed' && deliveryBoyID != ''
                                ? InkWell(
                                    onTap: () {
                                      ratingAndReviewRider();
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.only(right: 10),
                                      child: const Text("Rate Rider",
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 18,
                                                  color: Colors.grey))
                                          .tr(),
                                    ),
                                  )
                                : Container(),
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
                            trailing: OutlinedButton(
                                onPressed: () {
                                  _callRider(riderPhone);
                                },
                                child: const Text('Call Rider').tr()),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      OutlinedButton(
                          onPressed: () {
                            showDialog(
                                context: context,
                                builder: (context) {
                                  return AlertDialog(
                                    title: const Text('Tip Rider'),
                                    content: SizedBox(
                                      height: 200,
                                      width: 300,
                                      child: Column(children: [
                                        SizedBox(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width /
                                              1.5,
                                          child: TextField(
                                            onChanged: (v) {
                                              setState(() {
                                                tip = int.parse(v);
                                              });
                                            },
                                            keyboardType: TextInputType.number,
                                            decoration: const InputDecoration(
                                                helperText: 'Tip'),
                                          ),
                                        ),
                                        const SizedBox(
                                          height: 20,
                                        ),
                                        OutlinedButton(
                                            onPressed: () {
                                              if (tip == null || tip!.isNaN) {
                                                Fluttertoast.showToast(
                                                    msg: "Required field".tr(),
                                                    toastLength:
                                                        Toast.LENGTH_SHORT,
                                                    gravity: ToastGravity.TOP,
                                                    timeInSecForIosWeb: 1,
                                                    fontSize: 14.0);
                                              } else {
                                                FirebaseFirestore.instance
                                                    .collection('drivers')
                                                    .doc(deliveryBoyID)
                                                    .update({
                                                  'wallet': riderWallet + tip!
                                                }).then((value) {
                                                  FirebaseFirestore.instance
                                                      .collection('users')
                                                      .doc(widget
                                                          .orderModel.userID)
                                                      .update({
                                                    'wallet': wallet - tip!
                                                  });
                                                  updateHistory(
                                                      HistoryModel(
                                                          message:
                                                              'tipped rider $riderName',
                                                          amount:
                                                              tip.toString(),
                                                          paymentSystem: '',
                                                          timeCreated: DateFormat
                                                                  .yMMMMEEEEd()
                                                              .format(DateTime
                                                                  .now())),
                                                      'users',
                                                      widget.orderModel.userID);
                                                  updateHistory(
                                                      HistoryModel(
                                                          message:
                                                              'tip from $userFullname',
                                                          amount:
                                                              tip.toString(),
                                                          paymentSystem: '',
                                                          timeCreated: DateFormat
                                                                  .yMMMMEEEEd()
                                                              .format(DateTime
                                                                  .now())),
                                                      'drivers',
                                                      deliveryBoyID);
                                                });
                                                Fluttertoast.showToast(
                                                        msg:
                                                            "Rider has been tipped"
                                                                .tr(),
                                                        toastLength:
                                                            Toast.LENGTH_SHORT,
                                                        gravity:
                                                            ToastGravity.TOP,
                                                        timeInSecForIosWeb: 1,
                                                        fontSize: 14.0)
                                                    .then((value) {
                                                  Navigator.of(context).pop();
                                                });
                                              }
                                            },
                                            child: const Text('Tip Rider'))
                                      ]),
                                    ),
                                  );
                                });
                          },
                          child: const Text('Tip Rider'))
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
                            child: Column(
                              children: [
                                ListTile(
                                  subtitle: Text(e.selected),
                                  leading: Text('QTY: ${e.quantity}'),
                                  title: Text(e.productName),
                                  trailing: Text(
                                      '${widget.currencySymbol}${Formatter().converter(e.selectedPrice.toDouble())}'),
                                ),
                                orderStatus == 'Completed'
                                    ? OutlinedButton(
                                        onPressed: () {
                                          ratingAndReviewProduct(
                                              e.productID,
                                              e.totalRating,
                                              e.totalNumberOfUserRating);
                                        },
                                        child: const Text('Rate Product').tr())
                                    : Container()
                              ],
                            ),
                          ),
                        ))
                    .toList()),
            const SizedBox(height: 20),
            accepted == false
                ? Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                            onPressed: () {
                              if (widget.orderModel.paymentType == 'Wallet') {
                                updateWallet();
                              }
                              FirebaseFirestore.instance
                                  .collection('Orders')
                                  .doc(widget.orderModel.uid)
                                  .delete()
                                  .then((value) {
                                Navigator.of(context).pop();
                              });
                            },
                            child: const Text('Delete Order').tr())),
                  )
                : Container(),
            acceptDelivery == true &&
                    accepted == true &&
                    deliveryAddress != '' &&
                    orderStatus == 'Completed' &&
                    confirmationStatus == false
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
                                                      confirmFunc(true);
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
                                                      'Order Confirmation!!!',
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold))
                                                  .tr(),
                                              content: Container(
                                                child: const Text(
                                                        'Are you sure you received all your order?')
                                                    .tr(),
                                              ));
                                        });
                                  },
                            child: pleaseWait == true
                                ? const Text('Please wait...').tr()
                                : const Text('Confirm order has arrived')
                                    .tr())),
                  )
                : Container(),
            const SizedBox(height: 20),
          ],
        )));
  }
}

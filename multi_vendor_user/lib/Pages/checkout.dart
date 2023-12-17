import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:shimmer/shimmer.dart';
import 'package:animated_check/animated_check.dart';
import '../Model/address.dart';
import 'package:geocoding/geocoding.dart';
import '../Model/formatter.dart';
import '../Model/history.dart';
import '../Model/order_model.dart';
import '../Model/products.dart';
import '../Widgets/map_snapshot.dart';
import 'delivery_addresses.dart';
import 'wallet_page.dart';

class CheckoutPage extends StatefulWidget {
  const CheckoutPage({Key? key}) : super(key: key);

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage>
    with SingleTickerProviderStateMixin {
  int _index = 0;
  DocumentReference? userDetails;
  String id = '';
  String addressID = '';
  DocumentReference? userRef;
  String currencySymbol = '';
  num subTotal = 0;
  bool selectedStepper1 = true;
  bool selectedStepper2 = false;
  num deliveryFee = 0;
  bool deliveryBool = true;
  bool pickupBool = false;
  bool isAddressEmpty = false;
  num wallet = 0;
  bool walletBool = false;
  bool cashOnDeliveryBool = false;
  bool selectedStepper3 = false;
  bool cashDatabase = false;
  String currentMarketID = '';
  String deliveryAddress = '';
  String houseNumber = '';
  String closestBustStop = '';
  String vendorID = '';
  int orderID = 0;
  List<Map<String, dynamic>> orders = [];
  AnimationController? _animationController;
  Animation<double>? _animation;
  String uid = DateTime.now().toString();
  String getOnesignalKey = '';
  String playerId = '';
  Timer? oneSignalTimer;
  String vendorToken = '';
  num couponReward = 0;

  initOneSignal() {
    if (getOnesignalKey != '') {
      OneSignal.shared.setLogLevel(OSLogLevel.verbose, OSLogLevel.none);
      OneSignal.shared.setAppId(getOnesignalKey);
      OneSignal.shared
          .promptUserForPushNotificationPermission()
          .then((accepted) {});
      oneSignalTimer!.cancel();
    }
  }

  void _handleGetDeviceState() async {
    var deviceState = await OneSignal.shared.getDeviceState();
    setState(() {
      playerId = deviceState!.userId!;
    });
  }

  getOneSignalDetails() {
    FirebaseFirestore.instance
        .collection('Push notification Settings')
        .doc('OneSignal')
        .get()
        .then((value) {
      setState(() {
        getOnesignalKey = value['OnesignalKey'];
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

  Future<List<ProductsModel>> getMyCart() {
    return userRef!.collection('Cart').get().then((snapshot) {
      return snapshot.docs
          .map((doc) => ProductsModel.fromMap(doc.data(), doc.id))
          .toList();
    });
  }

  Future<List<ProductsModel>> getMyCartToOrders() {
    return userRef!.collection('Cart').get().then((snapshot) {
      for (var element in snapshot.docs) {
        orders.add(element.data());
      }
      return snapshot.docs
          .map((doc) => ProductsModel.fromMap(doc.data(), doc.id))
          .toList();
    });
  }

  getDeliveryFee() {
    if (userRef != null) {
      userRef!.snapshots().listen((val) {
        setState(() {
          deliveryFee = val['deliveryFee'];
          couponReward = val['Coupon Reward'];
          debugPrint('delivery fee is $deliveryFee');
        });
      });
    }
  }

  Future<void> _getUserDoc() async {
    final FirebaseAuth auth = FirebaseAuth.instance;
    final FirebaseFirestore firestore = FirebaseFirestore.instance;

    User? user = auth.currentUser;
    setState(() {
      userRef = firestore.collection('users').doc(user!.uid);
    });
  }

  Future<List<AddressModel>> getDeliveryAddresses() {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(id)
        .collection('DeliveryAddress')
        .get()
        .then((event) {
      if (event.docs.isEmpty) {
        setState(() {
          isAddressEmpty = true;
        });
      } else {
        setState(() {
          isAddressEmpty = false;
        });
      }
      return event.docs
          .map((e) => AddressModel.fromMap(e.data(), e.id))
          .toList();
    });
  }

  getSubTotal() {
    userRef!.collection('Cart').get().then((val) {
      num tempTotal = val.docs.fold(0, (tot, doc) => tot + doc.data()['price']);
      setState(() {
        subTotal = tempTotal -
            (couponStatus == true && couponReward != 0
                ? (couponReward * tempTotal / 100)
                : 0);
      });
    });
  }

  bool couponStatus = false;
  getCouponStatus() {
    FirebaseFirestore.instance
        .collection('Coupon System')
        .doc('Coupon System')
        .get()
        .then((value) {
      setState(() {
        couponStatus = value['Status'];
      });
      getSubTotal();
    });
  }

  Future<void> _getUserDetails() async {
    final FirebaseAuth auth = FirebaseAuth.instance;
    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    User? user = auth.currentUser;
    setState(() {
      userDetails = firestore
          .collection('users')
          .doc(user!.uid)
          .snapshots()
          .listen((value) {
        setState(() {
          id = value['id'];
          addressID = value['DeliveryAddressID'];
          wallet = value['wallet'];
          currentMarketID = value['CurrentMarketID'];
          deliveryAddress = value['DeliveryAddress'];
          houseNumber = value['HouseNumber'];
          closestBustStop = value['ClosestBustStop'];
          if (currentMarketID != '') {
            getVendorID();
          }
        });
      }) as DocumentReference?;
    });
  }

  getVendorID() {
    FirebaseFirestore.instance
        .collection('Markets')
        .doc(currentMarketID)
        .snapshots()
        .listen((val) {
      setState(() {
        vendorID = val['Vendor ID'];
        if (vendorID != '') {
          getVendorOrderID();
        }
      });
    });
  }

  getVendorOrderID() {
    FirebaseFirestore.instance
        .collection('vendors')
        .doc(vendorID)
        .snapshots()
        .listen((value) {
      setState(() {
        orderID = value['orderID'];
        vendorToken = value['tokenID'];
        debugPrint('Vendor Token is $orderID');
      });
    });
  }

  updateVendorOrderID() {
    FirebaseFirestore.instance
        .collection('vendors')
        .doc(vendorID)
        .update({'orderID': orderID + 1});
  }

  updateWallet() {
    userRef!.update({
      'wallet': wallet - (subTotal + (deliveryBool == false ? 0 : deliveryFee))
    });
  }

  @override
  void initState() {
    getCurrencySymbol();
    _getUserDoc();
    _getUserDetails();
    getDeliveryFee();
    getCashOnDeliveryStatus();
    getCouponStatus();
    super.initState();
    _animationController =
        AnimationController(vsync: this, duration: const Duration(seconds: 1));

    _animation = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(
        parent: _animationController!, curve: Curves.easeInOutCirc));

    oneSignalTimer = Timer.periodic(
        const Duration(milliseconds: 100), (Timer t) => initOneSignal());
    _handleGetDeviceState();
    getOneSignalDetails();
    super.initState();
  }

  getCurrencySymbol() {
    FirebaseFirestore.instance
        .collection('Currency Settings')
        .doc('Currency Settings')
        .get()
        .then((value) {
      setState(() {
        currencySymbol = value['Currency symbol'];
      });
    });
  }

  getCashOnDeliveryStatus() {
    return FirebaseFirestore.instance
        .collection('Payment System')
        .doc('Cash on delivery')
        .get()
        .then((val) {
      setState(() {
        cashDatabase = val['Cash on delivery'];
      });
    });
  }

  addToOrder(OrderModel orderModel, String uid) {
    FirebaseFirestore.instance
        .collection('Orders')
        .doc(uid)
        .set(orderModel.toMap())
        .then((value) {
      Fluttertoast.showToast(
          msg: "Your new order has been placed",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.TOP,
          timeInSecForIosWeb: 1,
          fontSize: 14.0);
    });
  }

  Future deleteCartCollection() async {
    userRef!.collection('Cart').get().then((snapshot) {
      for (DocumentSnapshot ds in snapshot.docs) {
        ds.reference.delete();
      }
    });
  }

  deleteVendorsID() {
    userRef!
        .update({'CurrentMarketID': '', 'deliveryFee': 0, 'Coupon Reward': 0});
  }

  updateHistory(HistoryModel historyModel) {
    userRef!.collection('History').add(historyModel.toMap());
  }

  updateHistoryVendor(HistoryModel historyModel) {
    FirebaseFirestore.instance
        .collection('vendors')
        .doc(vendorID)
        .collection('Notifications')
        .add(historyModel.toMap());
  }

  double deliveryAddressLat = 0;
  double deliveryAddressLong = 0;
  bool? stopFetchingData;

  getDeliveryLocationLatAndLong() async {
    if (deliveryAddressLat == 0 && deliveryAddressLong == 0) {
      List<Location> locations = await locationFromAddress(deliveryAddress);
      if (mounted) {
        setState(() {
          for (var element in locations) {
            deliveryAddressLong = element.longitude;
            deliveryAddressLat = element.latitude;
          }
        });
        debugPrint(deliveryAddressLat.toString());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    getDeliveryLocationLatAndLong();
    return Scaffold(
      appBar: AppBar(
          iconTheme: Theme.of(context).iconTheme,
          titleTextStyle: TextStyle(color: Theme.of(context).indicatorColor),
          backgroundColor: Theme.of(context).colorScheme.background,
          centerTitle: true,
          elevation: 0,
          title: const Text(
            'Checkout',
          ).tr()),
      body: Stack(
        children: [
          Stepper(
            elevation: 0,
            onStepTapped: (step) {
              if (_index == 1) {
                setState(() {
                  _index = step;
                });
              } else if (step > _index) {
                setState(() {
                  _index = step;
                });
                Fluttertoast.showToast(
                    msg: "Order has been submitted".tr(),
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.TOP,
                    timeInSecForIosWeb: 1,
                    fontSize: 14.0);
              }
            },
            type: StepperType.horizontal,
            controlsBuilder: (BuildContext context, ControlsDetails controls) {
              return const SizedBox();
            },
            currentStep: _index,
            steps: <Step>[
              Step(
                  isActive: selectedStepper1,
                  title: const Text('Delivery').tr(),
                  content: SingleChildScrollView(
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text("Delivery Address",
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15))
                                .tr(),
                            InkWell(
                                onTap: () {
                                  Navigator.of(context)
                                      .pushNamed('/delivery-address');
                                  setState(() {
                                    deliveryAddressLat = 0;
                                    deliveryAddressLong = 0;
                                  });
                                },
                                child: Container(
                                    decoration: const BoxDecoration(
                                      color: Colors.orange,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.chevron_right_rounded,
                                      color: Colors.white,
                                    )))
                          ],
                        ),
                        CheckboxListTile(
                            value: deliveryBool,
                            title: const Text('Delivery').tr(),
                            onChanged: (value) {
                              if (isAddressEmpty == true) {
                                Navigator.of(context).push(MaterialPageRoute(
                                    builder: (context) =>
                                        const DeliveryAddressesPage()));
                              } else {
                                setState(() {
                                  deliveryBool = true;
                                  pickupBool = false;
                                });
                              }
                            }),
                        deliveryBool == false
                            ? Container()
                            : Column(
                                children: [
                                  deliveryAddressLat != 0 &&
                                          deliveryAddressLong != 0
                                      ? SnapshotBody(
                                          lat: deliveryAddressLat,
                                          long: deliveryAddressLong,
                                        )
                                      : const SizedBox(),
                                  Text(deliveryAddress)
                                ],
                              ),
                        const SizedBox(
                          height: 10,
                        ),
                        CheckboxListTile(
                            value: pickupBool,
                            title: const Text('Pick Up').tr(),
                            onChanged: (value) {
                              setState(() {
                                deliveryBool = false;
                                pickupBool = true;
                              });
                            }),
                        const SizedBox(
                          width: double.infinity,
                          child: Divider(
                            color: Colors.grey,
                          ),
                        ),
                        Row(
                          children: const [
                            Text("Order Summary",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 15)),
                          ],
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        FutureBuilder<List<ProductsModel>>(
                            future: getMyCart(),
                            builder: (context, snapshot) {
                              if (snapshot.hasData) {
                                return ListView.builder(
                                  physics: const BouncingScrollPhysics(),
                                  shrinkWrap: true,
                                  itemCount: snapshot.data?.length,
                                  itemBuilder: (context, index) {
                                    ProductsModel productsModel =
                                        snapshot.data![index];
                                    return Card(
                                      elevation: 0,
                                      child: ListTile(
                                        subtitle: Text(productsModel.selected!),
                                        leading: Text(
                                            'QTY: ${productsModel.quantity}'),
                                        title: Text(productsModel.name),
                                        trailing: Text(
                                            '$currencySymbol${Formatter().converter(productsModel.price!.toDouble())}'),
                                      ),
                                    );
                                  },
                                );
                              } else {
                                return Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16.0, vertical: 16.0),
                                  child: Shimmer.fromColors(
                                    baseColor: Colors.grey[300]!,
                                    highlightColor: Colors.grey[100]!,
                                    enabled: true,
                                    child: ListView.builder(
                                      shrinkWrap: true,
                                      itemBuilder: (_, __) => SizedBox(
                                          height: 100,
                                          width: 300,
                                          child: Card(
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(20.0),
                                            ),
                                          )),
                                      itemCount: 10,
                                    ),
                                  ),
                                );
                              }
                            }),
                        Container(height: 120)
                      ],
                    ),
                  )),
              Step(
                isActive: selectedStepper2,
                title: const Text('Payment').tr(),
                content: SingleChildScrollView(
                  child: Column(
                    children: [
                      Row(children: [
                        const Text("Payment Method",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 18))
                            .tr(),
                      ]),
                      const SizedBox(height: 20),
                      Card(
                        elevation: 0,
                        child: CheckboxListTile(
                            title: const Text('Wallet').tr(),
                            subtitle: Text(
                                '$currencySymbol${Formatter().converter(wallet.toDouble())}'),
                            value: walletBool,
                            onChanged: (val) {
                              if (wallet <
                                  subTotal +
                                      (deliveryBool == false
                                          ? 0
                                          : deliveryFee)) {
                                Navigator.of(context)
                                    .push(MaterialPageRoute(
                                        builder: (context) =>
                                            const WalletPage()))
                                    .then((value) {
                                  Fluttertoast.showToast(
                                      msg:
                                          "Please upload more money to continue"
                                              .tr(),
                                      toastLength: Toast.LENGTH_SHORT,
                                      gravity: ToastGravity.TOP,
                                      timeInSecForIosWeb: 1,
                                      fontSize: 14.0);
                                });
                              } else {
                                if (orders.isEmpty) {
                                  getMyCartToOrders();
                                }

                                setState(() {
                                  walletBool = true;
                                  cashOnDeliveryBool = false;
                                });
                              }
                            }),
                      ),
                      cashDatabase == false
                          ? Container()
                          : Card(
                              elevation: 0,
                              child: CheckboxListTile(
                                  title: const Text('Cash on delivery').tr(),
                                  subtitle: const Text(
                                          'Cash payment after product is delivered')
                                      .tr(),
                                  value: cashOnDeliveryBool,
                                  onChanged: (val) {
                                    if (orders.isEmpty) {
                                      getMyCartToOrders();
                                    }
                                    setState(() {
                                      walletBool = false;
                                      cashOnDeliveryBool = true;
                                    });
                                  }),
                            )
                    ],
                  ),
                ),
              ),
              Step(
                isActive: selectedStepper3,
                title: const Text('Completed').tr(),
                content: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      AnimatedCheck(
                        progress: _animation!,
                        size: 200,
                      ),
                      ElevatedButton(
                          onPressed: () {
                            Navigator.pushNamed(context, '/orders');
                          },
                          child: const Text('View in orders page').tr()),
                      ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange),
                          onPressed: () {
                            Navigator.pushNamed(context, '/home');
                          },
                          child: const Text('Go back home').tr())
                    ],
                  ),
                ),
              )
            ],
          ),
          _index == 2
              ? Container()
              : Align(
                  alignment: Alignment.bottomCenter,
                  child: Card(
                    elevation: 0,
                    child: SizedBox(
                        height: 70,
                        width: double.infinity,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.info),
                                  const SizedBox(width: 5),
                                  const Text(
                                    'Total',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18),
                                  ).tr(),
                                ],
                              ),
                              Text(
                                  '$currencySymbol${Formatter().converter((subTotal + (deliveryBool == false ? 0 : deliveryFee)).toDouble())}',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18)),
                              _index == 1
                                  ? ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.orange),
                                      onPressed: () {
                                        if (isAddressEmpty == true &&
                                            pickupBool == false) {
                                          setState(() {
                                            _index = 0;
                                          });
                                          Fluttertoast.showToast(
                                              msg:
                                                  "Please select or add an address"
                                                      .tr(),
                                              toastLength: Toast.LENGTH_SHORT,
                                              gravity: ToastGravity.TOP,
                                              timeInSecForIosWeb: 1,
                                              fontSize: 14.0);
                                        } else {
                                          if (walletBool == false &&
                                              cashOnDeliveryBool == false) {
                                            Fluttertoast.showToast(
                                                msg:
                                                    "Please select a payment method"
                                                        .tr(),
                                                toastLength: Toast.LENGTH_SHORT,
                                                gravity: ToastGravity.TOP,
                                                timeInSecForIosWeb: 1,
                                                fontSize: 14.0);
                                          } else {
                                            deleteCartCollection();
                                            deleteVendorsID();
                                            updateVendorOrderID();

                                            if (walletBool == true) {
                                              updateWallet();
                                              updateHistory(HistoryModel(
                                                  timeCreated:
                                                      DateFormat.yMMMMEEEEd()
                                                          .format(
                                                              DateTime.now())
                                                          .toString(),
                                                  message:
                                                      'Placed an order'.tr(),
                                                  amount:
                                                      '-$currencySymbol${subTotal + (deliveryBool == false ? 0 : deliveryFee)}',
                                                  paymentSystem: ''));
                                            }

                                            addToOrder(
                                                OrderModel(
                                                    confirmationStatus: false,
                                                    uid: uid,
                                                    marketID: currentMarketID,
                                                    orderID: orderID + 1,
                                                    orders: orders,
                                                    acceptDelivery: false,
                                                    deliveryFee: pickupBool ==
                                                            false
                                                        ? deliveryFee
                                                        : 0,
                                                    total:
                                                        subTotal +
                                                            (deliveryBool ==
                                                                    false
                                                                ? 0
                                                                : deliveryFee),
                                                    vendorID: vendorID,
                                                    paymentType:
                                                        cashOnDeliveryBool ==
                                                                true
                                                            ? 'Cash on delivery'
                                                            : 'Wallet',
                                                    userID: id,
                                                    timeCreated:
                                                        DateFormat.yMMMMEEEEd()
                                                            .format(
                                                                DateTime.now())
                                                            .toString(),
                                                    deliveryAddress:
                                                        pickupBool == true
                                                            ? ''
                                                            : deliveryAddress,
                                                    houseNumber:
                                                        pickupBool == true
                                                            ? ''
                                                            : houseNumber,
                                                    closesBusStop:
                                                        pickupBool == true
                                                            ? ''
                                                            : closestBustStop,
                                                    deliveryBoyID: '',
                                                    status: 'Received',
                                                    accept: false),
                                                uid);
                                            updateHistoryVendor(HistoryModel(
                                                message:
                                                    'New order alert Order ID #${orderID + 1}',
                                                amount:
                                                    '$currencySymbol ${subTotal + (deliveryBool == false ? 0 : deliveryFee)}',
                                                paymentSystem: '',
                                                timeCreated:
                                                    DateFormat.yMMMMEEEEd()
                                                        .format(DateTime.now())
                                                        .toString()));
                                            _handleSendNotification(
                                                vendorToken,
                                                'New order alert Order ID #${orderID + 1}',
                                                'New order alert');
                                            setState(() {
                                              _index = 2;
                                              selectedStepper3 = true;
                                              selectedStepper1 = false;
                                              selectedStepper2 = false;
                                            });
                                            _animationController!.forward();
                                          }
                                        }
                                      },
                                      child: Row(
                                        children: [
                                          const Text('PROCEED',
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 18))
                                              .tr(),
                                          const SizedBox(width: 5),
                                          const Icon(Icons.arrow_forward)
                                        ],
                                      ))
                                  : ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.orange),
                                      onPressed: () {
                                        if (isAddressEmpty == true &&
                                            pickupBool == false) {
                                          Fluttertoast.showToast(
                                              msg:
                                                  "Please select or add an address"
                                                      .tr(),
                                              toastLength: Toast.LENGTH_SHORT,
                                              gravity: ToastGravity.TOP,
                                              timeInSecForIosWeb: 1,
                                              fontSize: 14.0);
                                        } else {
                                          setState(() {
                                            _index = 1;
                                            selectedStepper2 = true;
                                          });
                                        }
                                      },
                                      child: Row(
                                        children: [
                                          const Text('CONFIRM',
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 18))
                                              .tr(),
                                          const SizedBox(width: 5),
                                          const Icon(Icons.done)
                                        ],
                                      ))
                            ],
                          ),
                        )),
                  ))
        ],
      ),
    );
  }
}

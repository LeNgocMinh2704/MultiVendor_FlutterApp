import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geocoder2/geocoder2.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../Model/courier.dart';
import '../Model/history.dart';
import 'autocomplete.dart';

class AddCourier extends StatefulWidget {
  const AddCourier({Key? key}) : super(key: key);

  @override
  State<AddCourier> createState() => _AddCourierState();
}

class _AddCourierState extends State<AddCourier> {
  String userAddress = '';
  String recipientAddress = '';
  num perKm = 0;
  num perKg = 0;
  String deliveryBoyID = '';

  _navigateAndDisplaySelection(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => CustomSearchScaffold()),
    );
    setState(() {
      userAddress = result ?? '';
    });
  }

  _navigateAndDisplaySelection2(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => CustomSearchScaffold()),
    );
    setState(() {
      recipientAddress = result ?? '';
      // debugPrint(recipientAddress);
    });
  }

  bool kgStatus = false;
  getKgStatus() {
    FirebaseFirestore.instance
        .collection('Courier System')
        .doc('Kg Courier')
        .get()
        .then((value) {
      setState(() {
        kgStatus = value['Kg Courier'];
      });
    });
  }

  num deliveryCommissionKg = 0;
  num deliveryCommissionKm = 0;
  num kg = 0;
  num km = 0;
  getCourierDetails() {
    FirebaseFirestore.instance
        .collection('Courier System')
        .doc('Courier Details')
        .get()
        .then((value) {
      setState(() {
        kg = value['kg'];
        km = value['km'];
        deliveryCommissionKg = value['deliveryCommissionKg'];
        deliveryCommissionKm = value['deliveryCommissionKm'];
      });
    });
  }

  getParcelID() {
    FirebaseFirestore.instance
        .collection('Admin')
        .doc('Admin')
        .get()
        .then((value) {
      setState(() {
        parcelID = value['ParcelID'];
      });
    });
  }

  updateParcelID() {
    FirebaseFirestore.instance
        .collection('Admin')
        .doc('Admin')
        .update({'ParcelID': parcelID + 1});
  }

  @override
  initState() {
    super.initState();
    getuserID();
    getKgStatus();
    getCourierDetails();
    getCurrencyDetails();
    assignRider();
    oneSignalTimer = Timer.periodic(
        const Duration(milliseconds: 100), (Timer t) => initOneSignal());
    _handleGetDeviceState();
    getOneSignalDetails();
    getParcelID();
  }

  String getOnesignalKey = '';
  String playerId = '';
  Timer? oneSignalTimer;
  String vendorToken = '';

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

  num distance = 0;
  num priceKg = 0;
  num priceKm = 0;
  num weight = 0;
  String getcurrencyName = '';
  String getcurrencyCode = '';
  final picker = ImagePicker();
  String getcurrencySymbol = '';
  String parcelName = '';
  String sendersName = '';
  String sendersPhone = '';
  String sendersAddress = '';
  String recipientName = '';
  String deliveryDate = '';
  String deliveryBoysName = '';
  String deliveryBoysPhone = '';
  String deliveryBoysAddress = '';
  String recipientPhone = '';
  num price = 0;
  num parcelID = 0;
  String parcelDescription = '';
  String parcelImage = '';
  String userName = '';
  String userPhone = '';
  String tokenID = '';

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

  convertToCoordinate() async {
    if (userAddress != '' && recipientAddress != '') {
      GeoData data = await Geocoder2.getDataFromAddress(
          address: userAddress,
          googleMapApiKey: "AIzaSyAcqpzOvxzn1GHebVAuxZC-25EmCr3n1bs");
      GeoData data2 = await Geocoder2.getDataFromAddress(
          address: recipientAddress,
          googleMapApiKey: "AIzaSyAcqpzOvxzn1GHebVAuxZC-25EmCr3n1bs");

      double distanceInMeters = Geolocator.distanceBetween(
          data.latitude, data.longitude, data2.latitude, data2.longitude);

      setState(() {
        distance = distanceInMeters;
      });
    }
  }

  XFile? imageFile;
  bool? loading;
  Future<void> getImage(context) async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    setState(() {
      imageFile = image;
      loading = true;
    });
    if (imageFile != null) {
      var snapshot = await FirebaseStorage.instance
          .ref()
          .child(imageFile!.path)
          .putFile(File(imageFile!.path));
      String downloadUrl =
          await snapshot.ref.getDownloadURL().whenComplete(() => setState(() {
                loading = false;
              }));

      setState(() {
        parcelImage = downloadUrl;
      });
    }
  }

  final formKey = GlobalKey<FormState>();

  addCourier(CourierModel courierModel) {
    FirebaseFirestore.instance
        .collection('Courier')
        .add(courierModel.toMap())
        .then((value) => updateParcelID());
    _handleSendNotification(
        tokenID,
        'Hello, You have a logistics order please preview.',
        'New Logistics Order');
    updateHistoryDriver(HistoryModel(
        amount: '',
        paymentSystem: '',
        message: 'Hello, You have a logistics order please preview.',
        timeCreated:
            DateFormat.yMMMMEEEEd().format(DateTime.now()).toString()));
  }

  updateHistoryDriver(HistoryModel historyModel) {
    FirebaseFirestore.instance
        .collection('drivers')
        .doc(deliveryBoyID)
        .collection('Notifications')
        .add(historyModel.toMap());
  }

  DocumentReference? userRef;
  String userID = '';

  getuserID() async {
    final FirebaseAuth auth = FirebaseAuth.instance;
    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    User? user = auth.currentUser;
    firestore
        .collection('users')
        .doc(user!.uid)
        .snapshots()
        .listen((value) async {
      setState(() {
        userID = value['id'];
        userName = value['fullname'];
        userPhone = value['phonenumber'];
      });
    });
  }

  updateComission() {
    if (kgStatus == true) {
      return deliveryCommissionKg;
    } else {
      return deliveryCommissionKm;
    }
  }

  List<String> riders = [];
  int randomIndex = 0;

  assignRider() {
    return FirebaseFirestore.instance.collection('drivers').get().then((value) {
      for (var element in value.docs) {
        riders.add(element['id']);
        debugPrint('Delivery boys are $riders');
        if (riders.isEmpty) {
          Fluttertoast.showToast(
              msg: "Assigning a rider please wait...".tr(),
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.TOP,
              timeInSecForIosWeb: 1,
              backgroundColor: Theme.of(context).primaryColor,
              textColor: Colors.white,
              fontSize: 14.0);
        } else if (riders.isNotEmpty) {
          debugPrint(riders[randomIndex]);
          FirebaseFirestore.instance
              .collection('drivers')
              .doc(riders[randomIndex])
              .get()
              .then((value) {
            setState(() {
              deliveryBoysName = value['fullname'];
              deliveryBoyID = value['id'];
              deliveryBoysPhone = value['phone'];
              tokenID = value['tokenID'];
            });
          });

          Fluttertoast.showToast(
              msg: "Rider has been selected".tr(),
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.TOP,
              timeInSecForIosWeb: 1,
              backgroundColor: Theme.of(context).primaryColor,
              textColor: Colors.white,
              fontSize: 14.0);
        }

        setState(() {
          randomIndex = Random().nextInt(riders.length);
        });
      }
    });
  }

  Future<void> _callRider(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    await launchUrl(launchUri);
  }

  @override
  Widget build(BuildContext context) {
    convertToCoordinate();
    return Scaffold(
        appBar: AppBar(
            elevation: 0,
            centerTitle: true,
            title: const Text(
              'Add New Courier',
            ).tr()),
        body: SingleChildScrollView(
            child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Form(
            key: formKey,
            child: Column(children: [
              const SizedBox(height: 20),
              Row(
                children: [
                  const Text(
                    'From:',
                    style: TextStyle(fontSize: 15),
                  ).tr(),
                ],
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 50,
                width: double.infinity,
                child: OutlinedButton(
                    child: Text(userAddress),
                    onPressed: () {
                      _navigateAndDisplaySelection(context);
                    }),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  const Text(
                    'Recipient Address:',
                    style: TextStyle(fontSize: 15),
                  ).tr(),
                ],
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 50,
                width: double.infinity,
                child: OutlinedButton(
                    child: Text(recipientAddress),
                    onPressed: () {
                      _navigateAndDisplaySelection2(context);
                    }),
              ),
              const SizedBox(height: 20),
              TextFormField(
                onChanged: (value) {
                  setState(() {
                    recipientName = value;
                  });
                },
                validator: (String? val) {
                  if (val == '') {
                    return 'Required field'.tr();
                  } else {
                    return null;
                  }
                },
                decoration: InputDecoration(
                  focusedBorder: const OutlineInputBorder(
                    borderSide:
                        BorderSide(color: Colors.greenAccent, width: 1.0),
                  ),
                  enabledBorder: const OutlineInputBorder(),
                  hintText: 'Recipient Name'.tr(),
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                keyboardType: TextInputType.phone,
                onChanged: (value) {
                  setState(() {
                    recipientPhone = value;
                  });
                },
                validator: (String? val) {
                  if (val == '') {
                    return 'Required field'.tr();
                  } else {
                    return null;
                  }
                },
                decoration: InputDecoration(
                  focusedBorder: const OutlineInputBorder(
                    borderSide:
                        BorderSide(color: Colors.greenAccent, width: 1.0),
                  ),
                  enabledBorder: const OutlineInputBorder(),
                  hintText: 'Recipient Phone'.tr(),
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                onChanged: (value) {
                  setState(() {
                    parcelName = value;
                  });
                },
                validator: (String? val) {
                  if (val == '') {
                    return 'Required field'.tr();
                  } else {
                    return null;
                  }
                },
                decoration: InputDecoration(
                  focusedBorder: const OutlineInputBorder(
                    borderSide:
                        BorderSide(color: Colors.greenAccent, width: 1.0),
                  ),
                  enabledBorder: const OutlineInputBorder(),
                  hintText: 'Parcel Name'.tr(),
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  setState(() {
                    weight = int.parse(value);
                  });
                },
                validator: (String? val) {
                  if (val == '') {
                    return 'Required field'.tr();
                  } else {
                    return null;
                  }
                },
                decoration: InputDecoration(
                  focusedBorder: const OutlineInputBorder(
                    borderSide:
                        BorderSide(color: Colors.greenAccent, width: 1.0),
                  ),
                  enabledBorder: const OutlineInputBorder(),
                  hintText: 'Parcel Weight In Kg'.tr(),
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                onChanged: (value) {
                  setState(() {
                    parcelDescription = value;
                  });
                },
                validator: (String? val) {
                  if (val == '') {
                    return 'Required field'.tr();
                  } else {
                    return null;
                  }
                },
                maxLines: 5,
                decoration: InputDecoration(
                  focusedBorder: const OutlineInputBorder(
                    borderSide:
                        BorderSide(color: Colors.greenAccent, width: 1.0),
                  ),
                  enabledBorder: const OutlineInputBorder(),
                  hintText: 'Parcel Description'.tr(),
                ),
              ),
              const SizedBox(height: 20),
              Row(children: [const Text('Parcel Image').tr()]),
              const SizedBox(height: 20),
              parcelImage == ''
                  ? const Icon(Icons.image, size: 120, color: Colors.grey)
                  : Image.file(
                      File(imageFile!.path),
                      fit: BoxFit.cover,
                      height: 120,
                      width: 120,
                    ),
              const SizedBox(height: 20),
              InkWell(
                  onTap: () {
                    getImage(context);
                  },
                  child: Icon(Icons.photo_camera,
                      size: 40, color: Colors.blue.shade800)),
              const SizedBox(height: 20),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Admin selected calculation format:',
                          style: TextStyle(fontWeight: FontWeight.bold))
                      .tr(),
                  kgStatus == true ? Text('Per Kg $kg') : Text('Per Km $km')
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Text('Distance:  ${distance.round() / 1000}Km',
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  const Text('Price:',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(width: 10),
                  kgStatus == false
                      ? Text(
                          '$getcurrencySymbol ${distance.round() / 1000 * km}',
                          style: const TextStyle(fontWeight: FontWeight.bold))
                      : Text('$getcurrencySymbol ${weight * kg}',
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),

              Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 12, top: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Assigned Rider's Detail",
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
                        title: Text(deliveryBoysName),
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
                        title: Text(deliveryBoysPhone),
                        subtitle: const Text("Rider's phone").tr(),
                        leading: const Icon(Icons.phone),
                        trailing: OutlinedButton(
                            onPressed: () {
                              _callRider(deliveryBoysPhone);
                            },
                            child: const Text('Call Rider').tr()),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              // Container(
              //   width: double.infinity,
              //   child: ElevatedButton(
              //       style: ButtonStyle(
              //         elevation: MaterialStateProperty.all(10),
              //         backgroundColor: MaterialStateProperty.all<Color>(
              //           Colors.blue.shade800,
              //         ),
              //       ),
              //       onPressed: () async {
              //         selectRider(context);
              //       },
              //       child: Text('Assign a rider',
              //           style: TextStyle(color: Colors.white))),
              // ),
              SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange),
                      onPressed: () {
                        if (formKey.currentState!.validate() &&
                            recipientAddress != '' &&
                            deliveryBoyID != '' &&
                            userAddress != '' &&
                            parcelImage != '') {
                          addCourier(CourierModel(
                            status: false,
                            parcelName: parcelName,
                            sendersName: userName,
                            sendersPhone: userPhone,
                            sendersAddress: userAddress,
                            recipientName: recipientName,
                            recipientAddress: recipientAddress,
                            recipientPhone: recipientPhone,
                            deliveryDate: DateTime.now().toString(),
                            deliveryBoysName: '',
                            deliveryBoyID: deliveryBoyID,
                            deliveryBoysPhone: '',
                            deliveryBoysAddress: '',
                            weight: weight,
                            comission: (price * updateComission()) / 100,
                            price: kgStatus == false
                                ? distance.round() / 1000 * km
                                : weight * kg,
                            km: km,
                            parcelDescription: parcelDescription,
                            parcelID: parcelID + 1,
                            parcelImage: parcelImage,
                            userUID: userID,
                          ));
                          Navigator.of(context).pop();
                        } else {
                          Fluttertoast.showToast(
                              msg: "Some fields are empty".tr(),
                              toastLength: Toast.LENGTH_SHORT,
                              gravity: ToastGravity.TOP,
                              timeInSecForIosWeb: 1,
                              backgroundColor: Theme.of(context).primaryColor,
                              textColor: Colors.white,
                              fontSize: 14.0);
                        }
                      },
                      child: const Text('Submit',
                              style: TextStyle(color: Colors.white))
                          .tr()))
            ]),
          ),
        )));
  }
}

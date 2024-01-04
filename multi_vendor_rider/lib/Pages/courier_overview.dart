import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:rider/Pages/my_dashboard.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../Model/courier.dart';
import 'package:easy_localization/easy_localization.dart';
import '../Widget/tracking.dart';

class CourierOverview extends StatefulWidget {
  final CourierModel courierModel;
  const CourierOverview({Key? key, required this.courierModel})
      : super(key: key);

  @override
  State<CourierOverview> createState() => _CourierOverviewState();
}

class _CourierOverviewState extends State<CourierOverview> {
  String getcurrencyName = '';
  String getcurrencyCode = '';
  String getcurrencySymbol = '';
  DocumentReference? userRef;
  String vendorsPhone = '';
  String vendorsName = '';
  num wallet = 0;
  String deliveryBoysName = '';
  bool status = false;

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

  Future<void> _getUserDoc() async {
    final FirebaseAuth auth = FirebaseAuth.instance;
    final FirebaseFirestore firestore = FirebaseFirestore.instance;

    User user = auth.currentUser!;
    setState(() {
      userRef = firestore.collection('drivers').doc(user.uid);
    });
  }

  getDriversDetail() {
    final FirebaseAuth auth = FirebaseAuth.instance;
    final FirebaseFirestore firestore = FirebaseFirestore.instance;

    User user = auth.currentUser!;
    firestore.collection('drivers').doc(user.uid).snapshots().listen((value) {
      setState(() {
        vendorsPhone = value['phone'];
        vendorsName = value['fullname'];
        wallet = value['wallet'];
      });
    });
  }

  @override
  void initState() {
    getDriversDetail();
    getCurrencyDetails();
    _getUserDoc();
    getKgStatus();
    getCourier();
    getCourierDetails();
    super.initState();
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

  getCourier() {
    FirebaseFirestore.instance
        .collection('Courier')
        .doc(widget.courierModel.uid)
        .snapshots()
        .listen((event) {
      setState(() {
        deliveryBoysName = event['deliveryBoysName'];
        status = event['status'];
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          elevation: 0,
          title: const Text(
            'Courier details',
          ).tr(),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                deliveryBoysName != ''
                    ? status == false
                        ? ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                textStyle: const TextStyle(color: Colors.white),
                                backgroundColor: Colors.blue.shade800),
                            onPressed: () {
                              FirebaseFirestore.instance
                                  .collection('Courier')
                                  .doc(widget.courierModel.uid)
                                  .update({
                                'status': true,
                              }).then((value) {
                                Navigator.of(context).pop();
                                userRef!.update({
                                  'wallet': wallet -
                                      (widget.courierModel.price -
                                          widget.courierModel.comission)
                                });
                              });
                            },
                            child: const Text(
                              'Press after delivery is completed',
                              style: TextStyle(color: Colors.white),
                            ).tr())
                        : Container()
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                            ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                    textStyle:
                                        const TextStyle(color: Colors.white),
                                    backgroundColor: Colors.blue.shade800),
                                onPressed: () {
                                  if (vendorsPhone == '') {
                                    Navigator.of(context)
                                        .pushNamed('/profile')
                                        .then((value) {
                                      Fluttertoast.showToast(
                                          msg:
                                              'Please complete your profile to continue'
                                                  .tr(),
                                          backgroundColor: Colors.black,
                                          textColor: Colors.white);
                                    });
                                  } else {
                                    if (wallet <= widget.courierModel.price) {
                                      Fluttertoast.showToast(
                                          msg:
                                              "You don't have enough money in your wallet. Please upload money to your wallet"
                                                  .tr(),
                                          backgroundColor: Colors.black,
                                          textColor: Colors.white);
                                      Navigator.of(context).push(
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  const WalletPage()));
                                    } else {
                                      FirebaseFirestore.instance
                                          .collection('Courier')
                                          .doc(widget.courierModel.uid)
                                          .update({
                                        'deliveryBoysName': vendorsName,
                                        'deliveryBoysPhone': vendorsPhone
                                      }).then((value) {
                                        Navigator.pop(context);
                                        Fluttertoast.showToast(
                                            msg:
                                                'Congratulations on accepting to make the order'
                                                    .tr(),
                                            backgroundColor: Colors.black,
                                            textColor: Colors.white);
                                      });
                                    }
                                  }
                                },
                                child: const Text(
                                  'Accept Delivery',
                                  style: TextStyle(color: Colors.white),
                                ).tr()),
                            const SizedBox(width: 10),
                            ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                    textStyle:
                                        const TextStyle(color: Colors.white),
                                    backgroundColor: Colors.blue.shade800),
                                onPressed: () {
                                  FirebaseFirestore.instance
                                      .collection('Courier')
                                      .doc(widget.courierModel.uid)
                                      .update({'deliveryBoyID': ''}).then(
                                          (value) {
                                    Navigator.of(context).pop();
                                  });
                                },
                                child: const Text(
                                  'Reject Delivery',
                                  style: TextStyle(color: Colors.white),
                                ).tr()),
                          ]),
                const SizedBox(
                  height: 20,
                ),
                const SizedBox(height: 20),
                Tracking(courierModel: widget.courierModel),
                const SizedBox(
                  height: 20,
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: const Text(
                    'Parcel Details',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ).tr(),
                ),
                Row(
                  children: [
                    const Text('Parcel Image',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 12))
                        .tr(),
                  ],
                ),
                const SizedBox(
                  height: 20,
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height / 3,
                  width: double.infinity,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Image.network(
                      widget.courierModel.parcelImage,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                SizedBox(
                  height: 75,
                  width: double.infinity,
                  child: Card(
                    elevation: 0,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 5),
                        Padding(
                          padding: const EdgeInsets.only(left: 10.0),
                          child: Text(
                            'Parcel ID: #${widget.courierModel.parcelID}',
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 12),
                          ),
                        ),
                        const SizedBox(height: 5),
                        Padding(
                          padding: const EdgeInsets.only(left: 10.0),
                          child: Text(
                            'Date: ${widget.courierModel.deliveryDate}',
                          ),
                        ),
                        const SizedBox(height: 5),
                        Padding(
                          padding: const EdgeInsets.only(left: 10.0),
                          child: Row(
                            children: [
                              const Text('Parcel Name:',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12))
                                  .tr(),
                              const SizedBox(width: 10),
                              Text(
                                widget.courierModel.parcelName,
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                Card(
                  elevation: 0,
                  child: Column(
                    children: [
                      const SizedBox(height: 5),
                      Row(
                        children: [
                          const Text("Sender's Name:",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12))
                              .tr(),
                          const SizedBox(width: 10),
                          Text(
                            widget.courierModel.sendersName,
                          )
                        ],
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      Row(
                        children: [
                          const Text("Sender's Address:",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12))
                              .tr(),
                          const SizedBox(width: 10),
                          Text(widget.courierModel.sendersAddress,
                              style: const TextStyle(fontSize: 12))
                        ],
                      ),
                      const SizedBox(height: 5),
                      Row(
                        children: [
                          const Text('Pick Up Address:',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12))
                              .tr(),
                          const SizedBox(width: 10),
                          Text(widget.courierModel.sendersAddress,
                              style: const TextStyle(fontSize: 12))
                        ],
                      ),
                      const SizedBox(height: 5),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                Card(
                  elevation: 0,
                  child: Column(
                    children: [
                      Row(
                        children: [
                          const Text('Recipient Name:',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12))
                              .tr(),
                          const SizedBox(width: 10),
                          Text(
                            widget.courierModel.recipientName,
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      Row(
                        children: [
                          const Text('Recipient Address:',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12))
                              .tr(),
                          const SizedBox(width: 10),
                          Text(widget.courierModel.recipientAddress,
                              style: const TextStyle(fontSize: 12)),
                        ],
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      Row(
                        children: [
                          const Text('Pick Up Address:',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12))
                              .tr(),
                          const SizedBox(width: 10),
                          Text(widget.courierModel.recipientAddress,
                              style: const TextStyle(fontSize: 12)),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25.0),
                        side: const BorderSide(color: Colors.orange)),
                    backgroundColor: Colors.orange,
                  ),
                  onPressed: () async {
                    final Uri launchUri = Uri(
                        scheme: 'tel', path: widget.courierModel.sendersPhone);
                    await launchUrl(launchUri);
                  },
                  child: const Text('Call Sender',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      )).tr(),
                ),
                const SizedBox(
                  height: 20,
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25.0),
                        side: const BorderSide(color: Colors.orange)),
                    backgroundColor: Colors.orange,
                  ),
                  onPressed: () async {
                    final Uri launchUri = Uri(
                      scheme: 'tel',
                      path: widget.courierModel.recipientPhone,
                    );
                    await launchUrl(launchUri);
                  },
                  child: const Text('Call Recipient',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      )).tr(),
                ),
                const SizedBox(
                  height: 20,
                ),
                Card(
                  elevation: 0,
                  child: Column(
                    children: [
                      Row(
                        children: [
                          const Text('Price:',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12))
                              .tr(),
                          const SizedBox(
                            width: 10,
                          ),
                          Text(
                            '$getcurrencySymbol${widget.courierModel.price}',
                          )
                        ],
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      Row(
                        children: [
                          const Text('Distance:',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12))
                              .tr(),
                          const SizedBox(
                            width: 10,
                          ),
                          Text('${widget.courierModel.km.toString()}Km')
                        ],
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      Row(
                        children: [
                          const Text('Weight:',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12))
                              .tr(),
                          const SizedBox(
                            width: 10,
                          ),
                          Text(
                            '${widget.courierModel.weight.toString()}Kg',
                          )
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                SizedBox(
                  height: 40,
                  width: double.infinity,
                  child: Card(
                    elevation: 0,
                    child: Row(
                      children: [
                        const Text('Parcel Description',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 12))
                            .tr(),
                        const SizedBox(
                          width: 10,
                        ),
                        Text(widget.courierModel.parcelDescription,
                            style: const TextStyle(fontSize: 12))
                      ],
                    ),
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
              ],
            ),
          ),
        ));
  }
}

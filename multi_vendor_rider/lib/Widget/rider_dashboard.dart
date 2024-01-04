import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:rider/Pages/cashout.dart';
import 'package:rider/Widget/paystack.dart';
import 'package:rider/Widget/stripe.dart';
import 'package:easy_localization/easy_localization.dart';
import 'flutterwave.dart';

class RiderDashboard extends StatefulWidget {
  final String id;
  const RiderDashboard({Key? key, required this.id}) : super(key: key);

  @override
  State<RiderDashboard> createState() => _RiderDashboardState();
}

class _RiderDashboardState extends State<RiderDashboard> {
  int orderLength = 0;
  DocumentReference? userDetails;
  String id = '';

  Future<void> getUserDetails() async {
    final FirebaseAuth auth = FirebaseAuth.instance;
    final FirebaseFirestore firestore = FirebaseFirestore.instance;

    User? user = auth.currentUser;

    userDetails = firestore
        .collection('drivers')
        .doc(user!.uid)
        .snapshots()
        .listen((value) {
      setState(() {
        id = value['id'];
        FirebaseFirestore.instance
            .collection('Orders')
            .where('deliveryBoyID', isEqualTo: value['id'])
            .get()
            .then((value) {
          setState(() {
            orderLength = value.docs.length;
          });
        });
      });
    }) as DocumentReference<Object?>?;
  }

  bool stripe = false;
  bool flutterwave = false;
  bool paystack = false;

  getFlutterwaveStatus() {
    return FirebaseFirestore.instance
        .collection('Payment System')
        .doc('Flutterwave')
        .get()
        .then((val) {
      setState(() {
        flutterwave = val['Flutterwave'];
      });
    });
  }

  getPaystackStatus() {
    return FirebaseFirestore.instance
        .collection('Payment System')
        .doc('Paystack')
        .get()
        .then((val) {
      setState(() {
        paystack = val['Paystack'];
      });
    });
  }

  getStripeStatus() {
    return FirebaseFirestore.instance
        .collection('Payment System')
        .doc('Stripe')
        .get()
        .then((val) {
      setState(() {
        stripe = val['Stripe'];
      });
    });
  }

  @override
  void initState() {
    getStripeStatus();
    getPaystackStatus();
    getUserDetails();
    getPaystackDetails();
    getStripeDetails();
    getFlutterwaveStatus();
    super.initState();
  }

  String backendUrl = '';
  String paystackPublicKey = '';
  String pKey = '';
  String sKey = '';

  getStripeDetails() {
    FirebaseFirestore.instance
        .collection('Payment System Details')
        .doc('Stripe')
        .get()
        .then((value) {
      setState(() {
        pKey = value['Publishable key'];
        sKey = value['Secret Key'];
      });
    });
  }

  getPaystackDetails() {
    return FirebaseFirestore.instance
        .collection('Payment System Details')
        .doc('Paystack')
        .get()
        .then((value) {
      setState(() {
        backendUrl = value['banckendUrl'];
        paystackPublicKey = value['Public key'];
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      scrollDirection: Axis.horizontal,
      shrinkWrap: true,
      children: [
        InkWell(
          onTap: () {},
          child: SizedBox(
            height: 250,
            width: 180,
            child: Card(
              elevation: 10,
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 8, right: 8, top: 3),
                      child: const Text('Number of completed orders',
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 12))
                          .tr(),
                    ),
                    Text(
                      '$orderLength',
                      style: const TextStyle(
                          fontSize: 40, fontWeight: FontWeight.bold),
                    )
                  ]),
            ),
          ),
        ),
        stripe == false
            ? Container()
            : InkWell(
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => StripePage(
                            id: widget.id,
                            pkey: pKey,
                            sKey: sKey,
                          )));
                },
                child: SizedBox(
                  height: 250,
                  width: 180,
                  child: Card(
                    elevation: 10,
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(
                                left: 8, right: 8, top: 3),
                            child: const Text('Tap To Upload Wallet With',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(fontSize: 12))
                                .tr(),
                          ),
                          Image.asset(
                            'assets/image/stripe.png',
                            height: 50,
                            scale: 4,
                          ),
                          // const Text('Stripe'),
                        ]),
                  ),
                ),
              ),
        flutterwave == false
            ? Container()
            : InkWell(
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => FlutterwavePage(id: widget.id)));
                },
                child: SizedBox(
                  height: 250,
                  width: 180,
                  child: Card(
                    elevation: 10,
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(
                                left: 8, right: 8, top: 3),
                            child: const Text('Tap To Upload Wallet With',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(fontSize: 12))
                                .tr(),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 8, right: 8),
                            child: Image.asset(
                              'assets/image/flutterwave.png',
                              height: 70,
                              scale: 4,
                            ),
                          ),
                          // const Text('Flutter Wave'),
                        ]),
                  ),
                ),
              ),
        paystack == false
            ? Container()
            : InkWell(
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => PaystackPage(
                            id: widget.id,
                            backendUrl: backendUrl,
                            paystackPublicKey: paystackPublicKey,
                          )));
                },
                child: SizedBox(
                  height: 250,
                  width: 180,
                  child: Card(
                    elevation: 10,
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(
                                left: 8, right: 8, top: 3),
                            child: const Text('Tap To Upload Wallet With',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(fontSize: 12))
                                .tr(),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 8, right: 8),
                            child: Image.asset('assets/image/paystack.png',
                                scale: 1, height: 70),
                          ),
                          // const Text('Paystack'),
                        ]),
                  ),
                ),
              ),
        InkWell(
          onTap: () {
            Navigator.of(context)
                .push(MaterialPageRoute(builder: (context) => const Cashout()));
          },
          child: SizedBox(
            height: 250,
            width: 180,
            child: Card(
              elevation: 10,
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Tap To Cash Out').tr(),
                    Image.network(
                        'https://play-lh.googleusercontent.com/NncHrhT1YP_h5_w3IvAR4MeJJTQocjtAvGCvEfdwU2oko7JF2NigxP81RtZPA_nMA0M',
                        width: 70,
                        height: 70),
                    const Text('Cash out').tr(),
                  ]),
            ),
          ),
        )
      ],
    );
  }
}

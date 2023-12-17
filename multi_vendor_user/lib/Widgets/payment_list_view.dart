import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'flutterwave.dart';
import 'stripe.dart';
import 'paystack.dart';
import 'package:easy_localization/easy_localization.dart';

class PaymentListView extends StatefulWidget {
  final String id;
  const PaymentListView({Key? key, required this.id}) : super(key: key);

  @override
  State<PaymentListView> createState() => _PaymentListViewState();
}

class _PaymentListViewState extends State<PaymentListView> {
  bool stripe = false;
  bool flutterwave = false;
  bool paystack = false;
  num wallet = 0;

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
    getPaystackDetails();
    getFlutterwaveStatus();
    getStripeDetails();
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
                  height: 120,
                  width: 160,
                  child: Card(
                    elevation: 10,
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: const Text(
                                    'Tap To Upload Money In Wallet With',
                                    textAlign: TextAlign.center)
                                .tr(),
                          ),
                          Image.asset(
                            'assets/image/stripe.png',
                            height: 50,
                            scale: 4,
                          ),
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
                  height: 120,
                  width: 160,
                  child: Card(
                    elevation: 10,
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: const Text(
                                    'Tap To Upload Money In Wallet With',
                                    textAlign: TextAlign.center)
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
                  height: 120,
                  width: 160,
                  child: Card(
                    elevation: 10,
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: const Text(
                                    'Tap To Upload Money In Wallet With',
                                    textAlign: TextAlign.center)
                                .tr(),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 8, right: 8),
                            child: Image.asset('assets/image/paystack.png',
                                scale: 1, height: 70),
                          ),
                        ]),
                  ),
                ),
              ),
        // paystack == false
        //     ? Container()
        //     : InkWell(
        //         onTap: () {
        //           Navigator.of(context).push(
        //               MaterialPageRoute(builder: (context) => BrainTreePage()));
        //         },
        //         child: Container(
        //           height: 120,
        //           width: 160,
        //           child: Card(
        //             elevation: 10,
        //             child: Column(children: [
        //               Padding(
        //                 padding: const EdgeInsets.all(8.0),
        //                 child: Text('Tap To Upload Money In Wallet With',
        //                         textAlign: TextAlign.center)
        //                     .tr(),
        //               ),
        //               Image.asset('assets/image/Braintree_Payments_Logo.png',
        //                   width: 70, height: 70),
        //             ]),
        //           ),
        //         ),
        //       )
      ],
    );
  }
}

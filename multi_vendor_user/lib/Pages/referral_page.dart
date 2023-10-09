import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:clipboard/clipboard.dart';

class ReferralPage extends StatefulWidget {
  const ReferralPage({Key? key}) : super(key: key);

  @override
  State<ReferralPage> createState() => _ReferralPageState();
}

class _ReferralPageState extends State<ReferralPage> {
  DocumentReference? userRef;
  DocumentReference? userDetails;
  String referralCode = '';
  bool referralStatus = false;
  num? reward;

  Future<void> _getUserDoc() async {
    final FirebaseAuth auth = FirebaseAuth.instance;
    final FirebaseFirestore firestore = FirebaseFirestore.instance;

    User? user = auth.currentUser;
    setState(() {
      userRef = firestore.collection('users').doc(user!.uid);
    });
  }

  Future<void> _getUserDetails() async {
    final FirebaseAuth auth = FirebaseAuth.instance;
    final FirebaseFirestore firestore = FirebaseFirestore.instance;

    User? user = auth.currentUser;
    setState(() {
      userDetails =
          firestore.collection('users').doc(user!.uid).get().then((value) {
        setState(() {
          referralCode = value['personalReferralCode'];
        });
      }) as DocumentReference<Object?>?;
    });
  }

  @override
  void initState() {
    super.initState();
    _getUserDetails();
    getReferralStatus();
    getCurrencySymbol();
    _getUserDoc();
  }

  getReferralStatus() {
    FirebaseFirestore.instance
        .collection('Referral System')
        .doc('Referral System')
        .snapshots()
        .listen((value) {
      setState(() {
        referralStatus = value['Status'];
        reward = value['Referral Amount'];
      });
    });
  }

  String currencySymbol = '';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: Theme.of(context).iconTheme,
        titleTextStyle: TextStyle(color: Theme.of(context).indicatorColor),
        backgroundColor: Theme.of(context).colorScheme.background,
        centerTitle: true,
        elevation: 0,
        title: const Text(
          'Referral',
        ).tr(),
      ),
      body: Padding(
        padding: const EdgeInsets.only(bottom: 200),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
                height: 120,
                width: 120,
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.orange.withOpacity(0.2)),
                child: Image.asset('assets/image/gift.png',
                    height: 200, width: 200)),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Get $currencySymbol$reward for each friend you refer',
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            const Text(
              'Share your referral code',
              style: TextStyle(
                fontSize: 12,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 20.0, right: 20),
              child: TextFormField(
                readOnly: true,
                decoration: InputDecoration(
                    suffixIcon: InkWell(
                        onTap: () {
                          FlutterClipboard.copy(referralCode).then((value) {
                            Fluttertoast.showToast(
                                msg: "Referral Code Copied".tr(),
                                toastLength: Toast.LENGTH_SHORT,
                                gravity: ToastGravity.TOP,
                                timeInSecForIosWeb: 1,
                              
                                fontSize: 14.0);
                          });
                        },
                        child: const Icon(Icons.copy, color: Colors.black)),
                    hintText: referralCode,
                    hintStyle: const TextStyle(color: Colors.black),
                    filled: true,
                    fillColor: Colors.white,
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.white),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: const BorderSide(color: Colors.white),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    focusColor: Colors.orange),
              ),
            ),
            //  Text(
            //   'Get $currencySymbol$reward for each friend you refer',
            //   style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            // ),
          ],
        ),
      ),
    );
  }
}

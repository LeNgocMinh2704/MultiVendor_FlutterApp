import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:rider/Model/history.dart';
import 'package:rider/Pages/wallet_history.dart';
import 'package:rider/Widget/rider_dashboard.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
import 'package:easy_localization/easy_localization.dart';

import '../Model/formatter.dart';
import '../Widget/drawer_clippath.dart';

class WalletPage extends StatefulWidget {
  const WalletPage({Key? key}) : super(key: key);

  @override
  State<WalletPage> createState() => _WalletPageState();
}

class _WalletPageState extends State<WalletPage> {
  DocumentReference? userDetails;
  String id = '';
  String addressID = '';
  DocumentReference? userRef;
  String currencySymbol = '';
  num wallet = 0;

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

  Future<void> _getUserDoc() async {
    final FirebaseAuth auth = FirebaseAuth.instance;
    final FirebaseFirestore firestore = FirebaseFirestore.instance;

    User? user = auth.currentUser;
    setState(() {
      userRef = firestore.collection('drivers').doc(user!.uid);
    });
  }

  Future<List<HistoryModel>> getHistory() {
    return userRef!
        .collection('History')
        .orderBy('timeCreated', descending: true)
        .limit(10)
        .get()
        .then((snapshot) {
      return snapshot.docs
          .map((doc) => HistoryModel.fromMap(doc.data(), doc.id))
          .toList();
    });
  }

  @override
  void initState() {
    getCurrencySymbol();
    _getUserDoc();
    _getUserDetails();
    super.initState();
  }

  dynamic themeMode;
  getThemeDetail() async {
    SharedPreferences.getInstance().then((prefs) {
      var lightModeOn = prefs.getBool('lightMode');
      setState(() {
        themeMode = lightModeOn!;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    getThemeDetail();
    return Scaffold(
      appBar: AppBar(
          centerTitle: true,
          title: const Text(
            'Wallet',
          ).tr(),
          elevation: 0),
      body: SingleChildScrollView(
        child: Column(children: [
          ClipPath(
            clipper: CustomClipPath(),
            child: Container(
              height: 170,
              color: themeMode == true || themeMode == null
                  ? Colors.blue
                  : const Color(0xFF362F2F),
              child: Column(
                children: [
                  const SizedBox(height: 40),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Total Balance',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold),
                      ).tr(),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '$currencySymbol${Formatter().converter(wallet.toDouble())}',
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 30,
                            fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const Text(
                  'Market Overview',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey),
                ).tr(),
              ],
            ),
          ),
          SizedBox(
            height: 130,
            width: double.infinity,
            child: RiderDashboard(
              id: id,
            ),
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Transaction History',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey),
                ).tr(),
                InkWell(
                    onTap: () {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => const WalletHistory()));
                    },
                    child: const Icon(Icons.chevron_right, color: Colors.grey))
              ],
            ),
          ),
          FutureBuilder<List<HistoryModel>>(
              future: getHistory(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: snapshot.data?.length,
                    itemBuilder: (context, index) {
                      HistoryModel historyModel = snapshot.data![index];
                      return Card(
                        child: ListTile(
                          title: Text(historyModel.message,
                              style: const TextStyle(fontSize: 12)),
                          trailing: Text(
                              historyModel.amount.split('.')[0].trim(),
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text(historyModel.timeCreated,
                              style: const TextStyle(fontSize: 10)),
                          leading: Text(
                              historyModel.paymentSystem == 'Paid'
                                  ? 'Paid'.tr()
                                  : "Payment is processing".tr(),
                              style: const TextStyle(fontSize: 12)),
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
                                borderRadius: BorderRadius.circular(20.0),
                              ),
                            )),
                        itemCount: 10,
                      ),
                    ),
                  );
                }
              }),
        ]),
      ),
    );
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:rider/Model/history.dart';
import 'package:shimmer/shimmer.dart';
import 'package:easy_localization/easy_localization.dart';

class WalletHistory extends StatefulWidget {
  const WalletHistory({Key? key}) : super(key: key);

  @override
  State<WalletHistory> createState() => _WalletHistoryState();
}

class _WalletHistoryState extends State<WalletHistory> {
  DocumentReference? userDetails;
  String id = '';
  String addressID = '';
  DocumentReference? userRef;
  String currencySymbol = '';
  num wallet = 0;

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
        .get()
        .then((snapshot) {
      return snapshot.docs
          .map((doc) => HistoryModel.fromMap(doc.data(), doc.id))
          .toList();
    });
  }

  @override
  void initState() {
    _getUserDoc();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          centerTitle: true,
          title: const Text(
            'Wallet History',
          ).tr(),
          elevation: 0),
      body: FutureBuilder<List<HistoryModel>>(
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
                      trailing: Text(historyModel.amount.split('.')[0].trim(),
                          style: const TextStyle(fontWeight: FontWeight.bold)),
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
    );
  }
}

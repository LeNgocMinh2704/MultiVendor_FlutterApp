import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:rider/Model/history.dart';
import 'package:shimmer/shimmer.dart';

class InboxPage extends StatefulWidget {
  const InboxPage({Key? key}) : super(key: key);

  @override
  State<InboxPage> createState() => _InboxPageState();
}

class _InboxPageState extends State<InboxPage> {
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
        .collection('Notifications')
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
          elevation: 0,
          title: const Text(
            'Inbox',
          ).tr()),
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
                  return Dismissible(
                    key: ValueKey<int>(snapshot.data!.length),
                    onDismissed: (DismissDirection direction) {
                      userRef!
                          .collection('Notifications')
                          .doc(historyModel.uid)
                          .delete()
                          .then((value) {
                        Fluttertoast.showToast(
                            msg: "Notification has been deleted.".tr(),
                            toastLength: Toast.LENGTH_LONG,
                            gravity: ToastGravity.CENTER,
                            timeInSecForIosWeb: 1,
                        
                            fontSize: 16.0);
                      });
                    },
                    child: Card(
                      child: ListTile(
                        title: Text(historyModel.message),
                        trailing: Text(historyModel.amount,
                            style:
                                const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(historyModel.timeCreated),
                        leading: Text(historyModel.paymentSystem),
                      ),
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

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shimmer/shimmer.dart';

import '../Model/history.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({Key? key}) : super(key: key);

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  String currencySymbol = '';
  num wallet = 0;
  DocumentReference? userDetails;
  String addressID = '';
  String id = '';

  DocumentReference? userRef;

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

  Future<void> _getUserDoc() async {
    final FirebaseAuth auth = FirebaseAuth.instance;
    final FirebaseFirestore firestore = FirebaseFirestore.instance;

    User? user = auth.currentUser;
    setState(() {
      userRef = firestore.collection('users').doc(user!.uid);
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
      iconTheme: Theme.of(context).iconTheme,
        titleTextStyle: TextStyle(color: Theme.of(context).indicatorColor),
        backgroundColor: Theme.of(context).colorScheme.background,
          elevation: 0,
          centerTitle: true,
          title: const Text(
            'Inbox',
          ).tr()),
      body: FutureBuilder<List<HistoryModel>>(
          future: getHistory(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return snapshot.data?.isEmpty ?? true
                  ? Center(child: Image.asset('assets/image/notifications.jpg'))
                  : ListView.builder(
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
                                  msg: "Notification has been deleted.",
                                  toastLength: Toast.LENGTH_LONG,
                                  gravity: ToastGravity.CENTER,
                                  timeInSecForIosWeb: 1,
                                  backgroundColor:
                                      Theme.of(context).primaryColor,
                                  textColor: Colors.white,
                                  fontSize: 16.0);
                            });
                          },
                          child: Card(
                            child: ListTile(
                              title: Text(historyModel.message),
                              trailing: Text(historyModel.amount,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold)),
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

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:easy_localization/easy_localization.dart';

import '../Model/courier.dart';
import '../Widgets/add_courier.dart';
import 'courier_overview.dart';

class CourierPage extends StatefulWidget {
  const CourierPage({Key? key}) : super(key: key);

  @override
  State<CourierPage> createState() => _CourierPageState();
}

class _CourierPageState extends State<CourierPage> {
  DocumentReference? userRef;

  String userID = '';
  Future<void> _getUserModelDoc() async {
    final FirebaseAuth auth = FirebaseAuth.instance;
    final FirebaseFirestore firestore = FirebaseFirestore.instance;

    User? user = auth.currentUser;
    setState(() {
      userRef = firestore.collection('users').doc(user!.uid);
    });
  }

  getuserID() async {
    if (userRef == null) {
      return null;
    } else {
      userRef!.get().then((value) async {
        setState(() {
          userID = value['id'];
        });
      }).then((value) async {
        // debugPrint(userID);
      });
    }
  }

  @override
  void initState() {
    _getUserModelDoc();
    getuserID();
    super.initState();
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
            'Courier System',
          ).tr(),
        ),
        floatingActionButton: FloatingActionButton(
            backgroundColor: Colors.orange,
            onPressed: () {
              Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const AddCourier()));
            },
            child: const Icon(Icons.add)),
        body: StreamBuilder<List<CourierModel>>(
            stream: FirebaseFirestore.instance
                .collection('Courier')
                .where('userUID', isEqualTo: userID)
                .snapshots()
                .map((event) => event.docs
                    .map((e) => CourierModel.fromMap(e.data(), e.id))
                    .toList()),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return snapshot.data!.isEmpty
                    ? Center(
                        child: Image.asset(
                          'assets/image/rider update.png',
                          height: MediaQuery.of(context).size.height / 2,
                        ),
                      )
                    : ListView.builder(
                        shrinkWrap: true,
                        itemCount: snapshot.data!.length,
                        itemBuilder: (context, int index) {
                          CourierModel courierModel = snapshot.data![index];
                          return Card(
                            elevation: 0,
                            child: ListTile(
                                onTap: () {
                                  Navigator.of(context).push(MaterialPageRoute(
                                      builder: (context) => CourierOverview(
                                            courierModel: courierModel,
                                          )));
                                },
                                trailing: const Icon(Icons.chevron_right),
                                subtitle: courierModel.status == true
                                    ? const Text('Completed').tr()
                                    : const SizedBox(),
                                title: Text(
                                    'Parcel ID: #${courierModel.parcelID}')),
                          );
                        });
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
                          width: double.infinity,
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
            }));
  }
}

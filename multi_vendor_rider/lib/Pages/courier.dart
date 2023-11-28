import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../Model/courier.dart';
import 'courier_overview.dart';
import 'package:easy_localization/easy_localization.dart';

class CourierSystem extends StatefulWidget {
  final String userID;
  const CourierSystem({
    Key? key,
    required this.userID,
  }) : super(key: key);

  @override
  State<CourierSystem> createState() => _CourierSystemState();
}

class _CourierSystemState extends State<CourierSystem> {
  DocumentReference? userRef;
  String userID = '';

  getuserID() async {
    final FirebaseAuth auth = FirebaseAuth.instance;
    final FirebaseFirestore firestore = FirebaseFirestore.instance;

    User user = auth.currentUser!;
    firestore
        .collection('drivers')
        .doc(user.uid)
        .snapshots()
        .listen((value) async {
      setState(() {
        userID = value['id'];
      });
    });
  }

  @override
  void initState() {
    super.initState();
    getuserID();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          elevation: 0,
          title: const Text(
            'Courier System',
          ).tr(),
        ),
        body: FutureBuilder<List<CourierModel>>(
            future: FirebaseFirestore.instance
                .collection('Courier')
                .where('deliveryBoyID', isEqualTo: userID)
                .get()
                .then((event) => event.docs
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

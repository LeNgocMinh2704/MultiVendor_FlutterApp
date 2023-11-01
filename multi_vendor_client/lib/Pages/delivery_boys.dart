import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:vendor/Model/other_users.dart';
import 'package:vendor/Widget/add_delivery_boy.dart';
import 'package:vendor/Widget/delivery_boy_detail.dart';
import 'package:shimmer/shimmer.dart';
import 'package:easy_localization/easy_localization.dart';

class DeliveryBoys extends StatefulWidget {
  const DeliveryBoys({Key? key}) : super(key: key);

  @override
  State<DeliveryBoys> createState() => _DeliveryBoysState();
}

class _DeliveryBoysState extends State<DeliveryBoys> {
  Stream<List<OtherUserModel>> getDeliveryBoys() {
    return FirebaseFirestore.instance
        .collection('vendors')
        .doc(userID)
        .collection('Delivery Boys')
        .snapshots()
        .map((snapshot) {
      //print('Users ${snapshot.docs.length}');
      return snapshot.docs
          .map((doc) => OtherUserModel.fromMap(doc.data(), doc.id))
          .toList();
    });
  }

  bool confirmFav = false;
  DocumentReference? userRef;
  String userID = '';

  Future<void> _getUserDetails() async {
    final FirebaseAuth auth = FirebaseAuth.instance;
    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    User? user = auth.currentUser;
    setState(() {
      userRef =
          firestore.collection('vendors').doc(user!.uid).get().then((value) {
        setState(() {
          userID = value['id'];
        });
      }) as DocumentReference<Object?>?;
    });
  }

  @override
  void initState() {
    _getUserDetails();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            elevation: 0,
            //   backgroundColor: Colors.blue,
            centerTitle: true,
            title: const Text(
              'Favorite Delivery boys',
            ).tr()),
        floatingActionButton: FloatingActionButton(
            backgroundColor: Colors.orange,
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => const AddDeliveryBoys()));
            },
            child: const Icon(Icons.add)),
        body: StreamBuilder<List<OtherUserModel>>(
            stream: getDeliveryBoys(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return const Text('Something went wrong');
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 16.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    children: <Widget>[
                      Expanded(
                        child: Shimmer.fromColors(
                          baseColor: Colors.grey[300]!,
                          highlightColor: Colors.grey[100]!,
                          enabled: true,
                          child: ListView.builder(
                            itemBuilder: (_, __) => Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: SizedBox(
                                  height: 80,
                                  width: double.infinity,
                                  child: Card(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15.0),
                                    ),
                                  )),
                            ),
                            itemCount: 10,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }
              return ListView.builder(
                itemCount: snapshot.data!.length,
                physics: const BouncingScrollPhysics(),
                shrinkWrap: true,
                itemBuilder: (BuildContext buildContext, int index) {
                  OtherUserModel userModel = snapshot.data![index];
                  //print(snapshot.data!.length);
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: InkWell(
                      onTap: () {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => DeliveryBoyDetail(
                                  otherUserModel: userModel,
                                )));
                      },
                      child: SizedBox(
                          height: 80,
                          width: double.infinity,
                          child: Card(
                            child: ListTile(
                                leading: ClipOval(
                                  child: CachedNetworkImage(
                                    height: 50,
                                    fit: BoxFit.cover,
                                    width: 50,
                                    imageUrl: userModel.photoUrl == ''
                                        ? "https://eitrawmaterials.eu/wp-content/uploads/2016/09/person-icon.png"
                                        : userModel.photoUrl,
                                    placeholder: (context, url) =>
                                        const SpinKitRing(
                                      color: Colors.orange,
                                      size: 30,
                                      lineWidth: 3,
                                    ),
                                    errorWidget: (context, url, error) =>
                                        const Icon(Icons.error),
                                  ),
                                ),
                                trailing: const Icon(Icons.chevron_right),
                                title: Text(userModel.displayName),
                                subtitle: Text(userModel.address)),
                          )),
                    ),
                  );
                },
              );
            }));
  }
}

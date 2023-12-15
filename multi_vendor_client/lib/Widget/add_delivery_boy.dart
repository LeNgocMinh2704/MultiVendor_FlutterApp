import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:vendor/Model/other_users.dart';
import 'package:shimmer/shimmer.dart';
import 'package:easy_localization/easy_localization.dart';

import 'delivery_boy_detail.dart';

class AddDeliveryBoys extends StatefulWidget {
  const AddDeliveryBoys({
    Key? key,
  }) : super(key: key);

  @override
  State<AddDeliveryBoys> createState() => _AddDeliveryBoysState();
}

class _AddDeliveryBoysState extends State<AddDeliveryBoys> {
  Future<List<OtherUserModel>> getDeliveryBoys() {
    return FirebaseFirestore.instance
        .collection('drivers')
        .get()
        .then((snapshot) {
      //print('Users ${snapshot.docs.length}');
      return snapshot.docs
          .map((doc) => OtherUserModel.fromMap(doc.data(), doc.id))
          .toList();
    });
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          elevation: 0,
          title: const Text('Select Your Personal Delivery Boys').tr(),
        ),
        body: FutureBuilder<List<OtherUserModel>>(
            future: getDeliveryBoys(),
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

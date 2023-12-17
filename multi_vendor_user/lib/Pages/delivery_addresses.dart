import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shimmer/shimmer.dart';

import '../Model/address.dart';
import '../Widgets/add_delivery_address.dart';

class DeliveryAddressesPage extends StatefulWidget {
  const DeliveryAddressesPage({Key? key}) : super(key: key);

  @override
  State<DeliveryAddressesPage> createState() => _DeliveryAddressesPageState();
}

class _DeliveryAddressesPageState extends State<DeliveryAddressesPage> {
  DocumentReference? userDetails;
  String id = '';
  String addressID = '';

  Future<List<AddressModel>> getDeliveryAddresses() {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(id)
        .collection('DeliveryAddress')
        .get()
        .then((event) => event.docs
            .map((e) => AddressModel.fromMap(e.data(), e.id))
            .toList());
  }

  Future<void> _getUserDetails() async {
    final FirebaseAuth auth = FirebaseAuth.instance;
    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    User? user = auth.currentUser;
    setState(() {
      userDetails = firestore
          .collection('users')
          .doc(user!.uid)
          .snapshots()
          .listen((value) {
        setState(() {
          id = value['id'];
          addressID = value['DeliveryAddressID'];
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
      floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.orange,
          onPressed: () {
            Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => const AddDeliveryAddress()));
          },
          child: const Icon(Icons.add)),
      appBar: AppBar(
          centerTitle: true,
          iconTheme: Theme.of(context).iconTheme,
          titleTextStyle: TextStyle(color: Theme.of(context).indicatorColor),
          backgroundColor: Theme.of(context).colorScheme.background,
          elevation: 0,
          title: const Text(
            'Delivery Addresses',
          ).tr()),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  const Text(
                    'Swipe Left Or Right To Delete',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Colors.grey),
                  ).tr(),
                ],
              ),
            ),
            FutureBuilder<List<AddressModel>>(
                future: getDeliveryAddresses(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return snapshot.data?.isEmpty ?? true
                        ? Center(
                            child: Image.asset(
                              'assets/image/rider update.png',
                              height: MediaQuery.of(context).size.height / 2,
                            ),
                          )
                        : ListView.builder(
                            shrinkWrap: true,
                            itemCount: snapshot.data?.length,
                            itemBuilder: (context, index) {
                              AddressModel addressModel = snapshot.data![index];
                              return Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Dismissible(
                                  key: ValueKey<int>(snapshot.data!.length),
                                  onDismissed: (DismissDirection direction) {
                                    FirebaseFirestore.instance
                                        .collection('users')
                                        .doc(id)
                                        .collection('DeliveryAddress')
                                        .doc(addressModel.uid)
                                        .delete()
                                        .then((value) {
                                      Fluttertoast.showToast(
                                          msg: "Address has been deleted",
                                          toastLength: Toast.LENGTH_SHORT,
                                          gravity: ToastGravity.TOP,
                                          timeInSecForIosWeb: 1,
                                          fontSize: 14.0);
                                    });
                                  },
                                  child: SizedBox(
                                      height: 75,
                                      width: double.infinity,
                                      child: Card(
                                        elevation: 0,
                                        child: ListTile(
                                            leading:
                                                addressID == addressModel.id
                                                    ? const Icon(Icons.done)
                                                    : null,
                                            onTap: () {
                                              FirebaseFirestore.instance
                                                  .collection('users')
                                                  .doc(id)
                                                  .update({
                                                'DeliveryAddress':
                                                    addressModel.address,
                                                'HouseNumber':
                                                    addressModel.houseNumber,
                                                'ClosestBustStop':
                                                    addressModel.closestbusStop,
                                                'DeliveryAddressID':
                                                    addressModel.id
                                              }).then((value) {
                                                Navigator.of(context).pop();
                                                Fluttertoast.showToast(
                                                    msg:
                                                        "Default Address Selected"
                                                            .tr(),
                                                    toastLength:
                                                        Toast.LENGTH_SHORT,
                                                    gravity: ToastGravity.TOP,
                                                    timeInSecForIosWeb: 1,
                                                    
                                                    fontSize: 14.0);
                                              });
                                            },
                                            title: Text(addressModel.address),
                                            subtitle: Row(
                                              children: [
                                                const Text('House Number:')
                                                    .tr(),
                                                const SizedBox(width: 10),
                                                Text(addressModel.houseNumber),
                                              ],
                                            )),
                                      )),
                                ),
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
                }),
          ],
        ),
      ),
    );
  }
}

import 'dart:async';
import 'package:easy_localization/easy_localization.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:rider/Providers/auth.dart';

import 'courier.dart';

class AccountPage extends StatefulWidget {
  final Function navToCategory;

  const AccountPage({Key? key, required this.navToCategory}) : super(key: key);

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  DocumentReference? userRef;
  DocumentReference? userDetails;
  String fullname = 'Fetching data...'.tr();
  String email = 'Fetching data...'.tr();
  Timer? _timer;
  String userPic = '';
  num wallet = 0;
  String currencySymbol = '';
  String id = '';
  bool courier = false;

  Future<void> _getUserDoc() async {
    final FirebaseAuth auth = FirebaseAuth.instance;
    final FirebaseFirestore firestore = FirebaseFirestore.instance;

    User? user = auth.currentUser;
    setState(() {
      userRef = firestore.collection('drivers').doc(user!.uid);
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
          fullname = value['fullname'].split(' ')[0].trim();
          email = value['email'];
          userPic = value['photoUrl'];
          wallet = value['wallet'];
        });
      }) as DocumentReference<Object?>?;
    });
  }

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

  getCourierStatus() {
    FirebaseFirestore.instance
        .collection('Courier System')
        .doc('Courier System')
        .get()
        .then((v) {
      setState(() {
        courier = v['Enable Courier'];
      });
    });
  }

  @override
  void initState() {
    super.initState();
    getCurrencySymbol();
    _getUserDetails();
    getCourierStatus();
    _getUserDoc();
    EasyLoading.addStatusCallback((status) {
      //print('EasyLoading Status $status');
      if (status == EasyLoadingStatus.dismiss) {
        _timer?.cancel();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        Container(
          color: Theme.of(context).cardColor,
          height: MediaQuery.of(context).size.height / 9,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                userRef == null
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Text(
                                'Welcome Guess',
                                style: TextStyle(
                                    color: Colors.orange, fontSize: 18),
                              ).tr(),
                              const Text(
                                '!',
                                style: TextStyle(
                                    color: Colors.orange, fontSize: 18),
                              )
                            ],
                          ),
                          const Text(
                            'Please login or sign up to shop!',
                            style: TextStyle(color: Colors.white),
                          ).tr()
                        ],
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Text(
                                'Welcome',
                                style: TextStyle(
                                    color: Colors.orange, fontSize: 18),
                              ).tr(),
                              const SizedBox(width: 5),
                              Text(
                                '$fullname!',
                                style: const TextStyle(
                                    color: Colors.orange, fontSize: 18),
                              ),
                            ],
                          ),
                          Text(
                            email,
                            style: const TextStyle(color: Colors.white),
                          )
                        ],
                      ),
                userRef == null
                    ? Padding(
                        padding: const EdgeInsets.only(bottom: 30, right: 20),
                        child: ElevatedButton(
                          style:
                              ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                          child: const Text('Login',
                                  style: TextStyle(color: Colors.white))
                              .tr(),
                          onPressed: () {
                            Navigator.of(context).pushNamed('/login');
                          },
                        ),
                      )
                    : Padding(
                        padding: const EdgeInsets.only(bottom: 20, right: 10),
                        child: CircleAvatar(
                          radius: 40.0,
                          backgroundImage: NetworkImage(
                            userPic == ''
                                ? "https://eitrawmaterials.eu/wp-content/uploads/2016/09/person-icon.png"
                                : userPic,
                          ),
                          backgroundColor: Colors.transparent,
                        ),
                      ),
              ],
            ),
          ),
        ),
        Container(
          height: 55,
          color: Theme.of(context).cardColor,
          child: ListTile(
            onTap: () {
              if (userRef == null) {
                Navigator.of(context).pushNamed('/login');
              } else {
                widget.navToCategory();
              }
            },
            leading: Icon(
              Icons.account_balance_wallet,
              color: Colors.blue.shade800,
            ),
            trailing: const Icon(Icons.chevron_right),
            title: userRef == null
                ? Text('Login to see your balance',
                    style: TextStyle(
                      color: Colors.blue.shade800,
                    )).tr()
                : Row(
                    children: [
                      Text('Your dashboard',
                          style: TextStyle(
                            color: Colors.blue.shade800,
                          )).tr(),
                      const SizedBox(width: 10),
                      Text('$currencySymbol$wallet',
                          style: TextStyle(
                            color: Colors.blue.shade800,
                          )),
                    ],
                  ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: const Text('My Account', style: TextStyle(color: Colors.grey))
              .tr(),
        ),
        Card(
            elevation: 0,
            child: Column(
              children: [
                ListTile(
                    onTap: () {
                      if (userRef == null) {
                        Navigator.of(context).pushNamed('/login');
                      } else {
                        Navigator.of(context).pushNamed('/orders');
                      }
                    },
                    leading: const Icon(Icons.shopping_bag_outlined),
                    title: Text(
                      'Orders',
                      style: TextStyle(
                          fontSize:
                              Theme.of(context).textTheme.titleLarge!.fontSize),
                    ).tr(),
                    trailing: const Icon(Icons.chevron_right)),
                courier == false
                    ? Container()
                    : ListTile(
                        onTap: () {
                          if (userRef == null) {
                            Navigator.of(context).pushNamed('/login');
                          } else {
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) => CourierSystem(
                                      userID: id,
                                    )));
                          }
                        },
                        leading: const Icon(Icons.delivery_dining),
                        title: Text(
                          'Courier/Logistics',
                          style: TextStyle(
                              fontSize: Theme.of(context)
                                  .textTheme
                                  .titleLarge!
                                  .fontSize),
                        ).tr(),
                        trailing: const Icon(Icons.chevron_right)),
                ListTile(
                    onTap: () {
                      if (userRef == null) {
                        Navigator.of(context).pushNamed('/login');
                      } else {
                        Navigator.of(context).pushNamed('/inbox');
                      }
                    },
                    leading: const Icon(Icons.sms_outlined),
                    title: Text(
                      'Inbox',
                      style: TextStyle(
                          fontSize:
                              Theme.of(context).textTheme.titleLarge!.fontSize),
                    ).tr(),
                    trailing: const Icon(Icons.chevron_right)),
                ListTile(
                    onTap: () {
                      if (userRef == null) {
                        Navigator.of(context).pushNamed('/login');
                      } else {
                        Navigator.of(context).pushNamed('/reviews');
                      }
                    },
                    leading: const Icon(Icons.reviews_outlined),
                    title: Text(
                      'Reviews',
                      style: TextStyle(
                          fontSize:
                              Theme.of(context).textTheme.titleLarge!.fontSize),
                    ).tr(),
                    trailing: const Icon(Icons.chevron_right)),
                // ListTile(
                //     onTap: () {
                //       if (userRef == null) {
                //         Navigator.of(context).pushNamed('/login');
                //       } else {
                //         Navigator.of(context).pushNamed('/my-markets');
                //       }
                //     },
                //     leading: Icon(Icons.local_mall),
                //     title: Text(
                //       'My markets',
                //       style: TextStyle(
                //           fontSize:
                //               Theme.of(context).textTheme.headline6!.fontSize),
                //     ).tr(),
                //     trailing: Icon(Icons.chevron_right)),
              ],
            )),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: const Text('MY SETTINGS', style: TextStyle(color: Colors.grey))
              .tr(),
        ),
        Card(
            elevation: 0,
            child: Column(
              children: [
                ListTile(
                    onTap: () {
                      if (userRef == null) {
                        Navigator.of(context).pushNamed('/login');
                      } else {
                        Navigator.of(context).pushNamed('/profile');
                      }
                    },
                    leading: const Icon(Icons.person),
                    title: Text(
                      'Profile',
                      style: TextStyle(
                          fontSize:
                              Theme.of(context).textTheme.titleLarge!.fontSize),
                    ).tr(),
                    trailing: const Icon(Icons.chevron_right)),
              ],
            )),
        const SizedBox(height: 20),
        userRef == null
            ? Container()
            : Column(
                children: [
                  InkWell(
                    onTap: () async {
                      _timer?.cancel();
                      AuthService()
                          .signOut(context)
                          .then((value) => EasyLoading.dismiss());
                      Fluttertoast.showToast(
                          msg: "You have successfully logged out".tr(),
                          toastLength: Toast.LENGTH_SHORT,
                          gravity: ToastGravity.TOP,
                          timeInSecForIosWeb: 1,
                        
                          fontSize: 14.0);
                      await EasyLoading.show(
                        status: 'loading...'.tr(),
                        maskType: EasyLoadingMaskType.black,
                      );
                    },
                    child: const Text('LOGOUT',
                            style:
                                TextStyle(color: Colors.orange, fontSize: 17))
                        .tr(),
                  ),
                ],
              ),
        const SizedBox(height: 20),
      ],
    );
  }
}

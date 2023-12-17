import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:vendor/Model/cashout.dart';
import 'package:vendor/Model/history.dart';

class Cashout extends StatefulWidget {
  const Cashout({Key? key}) : super(key: key);

  @override
  State<Cashout> createState() => _CashoutState();
}

class _CashoutState extends State<Cashout> {
  DocumentReference? userDetails;
  String id = '';
  String addressID = '';
  DocumentReference? userRef;
  String currencySymbol = '';
  num wallet = 0;
  final _formKey = GlobalKey<FormState>();
  num accountNumber = 0;
  num amount = 0;
  String accountName = '';
  String bankName = '';
  String vendorsName = '';

  Future<void> _getUserDetails() async {
    final FirebaseAuth auth = FirebaseAuth.instance;
    final FirebaseFirestore firestore = FirebaseFirestore.instance;

    User? user = auth.currentUser;
    setState(() {
      userDetails = firestore
          .collection('vendors')
          .doc(user!.uid)
          .snapshots()
          .listen((value) {
        setState(() {
          wallet = value['wallet'];
          id = value['id'];
          vendorsName = value['fullname'];
        });
      }) as DocumentReference<Object?>?;
    });
    //print(wallet);
  }

  Future<void> _getUser() async {
    final FirebaseAuth auth = FirebaseAuth.instance;
    final FirebaseFirestore firestore = FirebaseFirestore.instance;

    User? user = auth.currentUser;
    setState(() {
      userRef = firestore.collection('vendors').doc(user!.uid);
    });
    //print(wallet);
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

  @override
  void initState() {
    getCurrencySymbol();
    _getUser();
    _getUserDetails();
    super.initState();
  }

  updateHistory(HistoryModel historyModel) {
    userRef!.collection('History').add(historyModel.toMap());
  }

  withDraw(CashOutModel cashOutModel) {
    FirebaseFirestore.instance
        .collection('Cash out')
        .add(cashOutModel.toMap())
        .then((v) {
      userRef!.update({'wallet': wallet - amount});
      updateHistory(HistoryModel(
        message: 'Cash out request',
        amount: '$currencySymbol$amount',
        paymentSystem: 'Payment is processing',
        timeCreated: DateFormat.yMMMMEEEEd().format(DateTime.now()).toString(),
      ));
      Fluttertoast.showToast(
          msg: "Cashout request has been sent successfully.".tr(),
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.TOP,
          timeInSecForIosWeb: 1,
          fontSize: 14.0);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
       //   backgroundColor: Colors.blue,
          title: const Text(
            'Cash out',
          ).tr(),
          elevation: 0,
          // actions: [
          //   Center(
          //       child: Padding(
          //     padding: const EdgeInsets.only(right: 10),
          //     child: InkWell(
          //         onTap: () {
          //           Navigator.of(context).push(MaterialPageRoute(
          //               builder: (context) => CashoutHistory()));
          //         },
          //         child: Text('Cashout History')),
          //   ))
          // ],
        ),
        body: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const SizedBox(height: 40),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Total Balance',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ).tr(),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '$currencySymbol$wallet',
                      style: const TextStyle(
                          fontSize: 30, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextFormField(
                    keyboardType: TextInputType.number,
                    onChanged: (v) {
                      setState(() {
                        amount = int.parse(v);
                      });
                    },
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Required field'.tr();
                      } else {
                        return null;
                      }
                    },
                    decoration: InputDecoration(hintText: 'Amount'.tr()),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextFormField(
                    onChanged: (v) {
                      accountName = v;
                    },
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Required field'.tr();
                      } else {
                        return null;
                      }
                    },
                    decoration: InputDecoration(hintText: 'Account Name'.tr()),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextFormField(
                    onChanged: (v) {
                      accountNumber = int.parse(v);
                    },
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Required field'.tr();
                      } else {
                        return null;
                      }
                    },
                    decoration:
                        InputDecoration(hintText: 'Account Number'.tr()),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextFormField(
                    onChanged: (v) {
                      bankName = v;
                    },
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Required field'.tr();
                      } else {
                        return null;
                      }
                    },
                    decoration: InputDecoration(hintText: 'Bank Name'.tr()),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                    width: double.infinity,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ElevatedButton(
                          onPressed: () {
                            if (amount > wallet || wallet == 0) {
                              Fluttertoast.showToast(
                                  msg:
                                      "You don't have such available amount in your wallet."
                                          .tr(),
                                  toastLength: Toast.LENGTH_SHORT,
                                  gravity: ToastGravity.TOP,
                                  timeInSecForIosWeb: 1,
                               
                                  fontSize: 14.0);
                            } else {
                              if (_formKey.currentState!.validate()) {
                                withDraw(CashOutModel(
                                    paid: false,
                                    status: 'Vendor',
                                    accountName: accountName,
                                    vendorID: id,
                                    vendorsName: vendorsName,
                                    amount: amount,
                                    bankName: bankName,
                                    timeCreated: DateFormat.yMMMMEEEEd()
                                        .format(DateTime.now())
                                        .toString(),
                                    accountNumber: accountNumber));
                                _formKey.currentState!.reset();
                              }
                            }
                          },
                          child: const Text('Cash out').tr()),
                    ))
              ],
            ),
          ),
        ));
  }
}

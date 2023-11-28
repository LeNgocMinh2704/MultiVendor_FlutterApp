import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutterwave_standard/flutterwave.dart';
import 'package:flutterwave_standard/models/subaccount.dart';
import 'package:uuid/uuid.dart';

import '../Model/history.dart';

class FlutterwavePage extends StatefulWidget {
  final String id;
  const FlutterwavePage({Key? key, required this.id}) : super(key: key);

  @override
  State<FlutterwavePage> createState() => _FlutterwavePageState();
}

class _FlutterwavePageState extends State<FlutterwavePage> {
  final formKey = GlobalKey<FormState>();
  final amountController = TextEditingController();
  final currencyController = TextEditingController();
  final narrationController = TextEditingController();
  final publicKeyController = TextEditingController();
  final encryptionKeyController = TextEditingController();
  final emailController = TextEditingController();
  final phoneNumberController = TextEditingController();
  String selectedCurrency = "";
  bool isDebug = true;
  String encryptedKey = '';
  String publicKey = '';
  bool isTestMode = true;
  final pbk = "FLWPUBK_TEST";
  num wallet = 0;
  String currencySymbol = '';
  num amount = 0;

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

  getFlutterwaveDetails() {
    return FirebaseFirestore.instance
        .collection('Payment System Details')
        .doc('Flutterwave')
        .get()
        .then((value) {
      setState(() {
        encryptedKey = value['Encryption Key'];
        publicKey = value['Public key'];
      });
    });
  }

  @override
  void initState() {
    getWallet();
    getFlutterwaveDetails();
    getCurrencySymbol();
    super.initState();
  }

  getWallet() {
    FirebaseFirestore.instance
        .collection('users')
        .doc(widget.id)
        .snapshots()
        .listen((value) {
      setState(() {
        wallet = value['wallet'];
      });
    });
  }

  updateHistory(HistoryModel historyModel) {
    FirebaseFirestore.instance
        .collection('users')
        .doc(widget.id)
        .collection('History')
        .add(historyModel.toMap());
  }

  updateWallet(num amount) {
    FirebaseFirestore.instance
        .collection('users')
        .doc(widget.id)
        .update({'wallet': wallet + amount}).then((value) {
      updateHistory(HistoryModel(
          timeCreated:
              DateFormat.yMMMMEEEEd().format(DateTime.now()).toString(),
          message: 'Wallet Upload.',
          amount: '+$currencySymbol$amount',
          paymentSystem: 'Flutterwave'));
      formKey.currentState!.reset();
      Fluttertoast.showToast(
          msg: "Wallet has been uploaded with $amount.",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          fontSize: 16.0);
    });
  }

  @override
  Widget build(BuildContext context) {
    currencyController.text = selectedCurrency;

    return Scaffold(
      appBar: AppBar(
        iconTheme: Theme.of(context).iconTheme,
        backgroundColor: Theme.of(context).cardColor,
        elevation: 0,
        title: Text(
          'Flutterwave Payment',
          style: TextStyle(color: Theme.of(context).iconTheme.color),
        ),
      ),
      body: Container(
        width: double.infinity,
        margin: const EdgeInsets.fromLTRB(20, 10, 20, 10),
        child: Form(
          key: formKey,
          child: ListView(
            children: <Widget>[
              Container(
                margin: const EdgeInsets.fromLTRB(0, 20, 0, 10),
                child: TextFormField(
                  onChanged: (value) {
                    setState(() {
                      amount = int.parse(value);
                    });
                  },
                  controller: amountController,
                  textInputAction: TextInputAction.next,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(color: Colors.black),
                  decoration: const InputDecoration(hintText: "Amount"),
                  validator: (value) =>
                      value!.isNotEmpty ? null : "Amount is required",
                ),
              ),
              Container(
                margin: const EdgeInsets.fromLTRB(0, 20, 0, 10),
                child: TextFormField(
                  controller: currencyController,
                  textInputAction: TextInputAction.next,
                  style: const TextStyle(color: Colors.black),
                  readOnly: true,
                  onTap: _openBottomSheet,
                  decoration: const InputDecoration(
                    hintText: "Currency",
                  ),
                  validator: (value) =>
                      value!.isNotEmpty ? null : "Currency is required",
                ),
              ),
              // Container(
              //   margin: EdgeInsets.fromLTRB(0, 20, 0, 10),
              //   child: TextFormField(
              //     controller: this.publicKeyController,
              //     textInputAction: TextInputAction.next,
              //     style: TextStyle(color: Colors.black),
              //     obscureText: true,
              //     decoration: InputDecoration(
              //       hintText: "Public Key",
              //     ),
              //   ),
              // ),
              // Container(
              //   margin: EdgeInsets.fromLTRB(0, 20, 0, 10),
              //   child: TextFormField(
              //     controller: this.encryptionKeyController,
              //     textInputAction: TextInputAction.next,
              //     style: TextStyle(color: Colors.black),
              //     obscureText: true,
              //     decoration: InputDecoration(
              //       hintText: "Encryption Key",
              //     ),
              //   ),
              // ),
              Container(
                margin: const EdgeInsets.fromLTRB(0, 20, 0, 10),
                child: TextFormField(
                  controller: emailController,
                  textInputAction: TextInputAction.next,
                  style: const TextStyle(color: Colors.black),
                  decoration: const InputDecoration(
                    hintText: "Email",
                  ),
                ),
              ),
              Container(
                margin: const EdgeInsets.fromLTRB(0, 20, 0, 10),
                child: TextFormField(
                  controller: phoneNumberController,
                  textInputAction: TextInputAction.next,
                  style: const TextStyle(color: Colors.black),
                  decoration: const InputDecoration(
                    hintText: "Phone Number",
                  ),
                ),
              ),
              // Container(
              //   width: double.infinity,
              //   margin: EdgeInsets.fromLTRB(0, 20, 0, 10),
              //   child: Row(
              //     // mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //     children: [
              //       Text("Use Debug"),
              //       Switch(
              //         onChanged: (value) => {
              //           setState(() {
              //             isTestMode = value;
              //           })
              //         },
              //         value: this.isTestMode,
              //       ),
              //     ],
              //   ),
              // ),
              Container(
                width: double.infinity,
                height: 50,
                margin: const EdgeInsets.fromLTRB(0, 20, 0, 10),
                child: ElevatedButton(
                  onPressed: _onPressed,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                  ),
                  child: const Text(
                    "Make Payment",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              )
            ],
          ),
        ),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  _onPressed() {
    if (formKey.currentState!.validate()) {
      _handlePaymentInitialization();
    }
  }

  _handlePaymentInitialization() async {
    // ignore: deprecated_member_use
    final style = FlutterwaveStyle(
      appBarText: "Press to make payment",
      buttonColor: const Color(0xffd0ebff),
      buttonTextStyle: const TextStyle(
        color: Colors.deepOrangeAccent,
        fontSize: 16,
      ),
      appBarColor: const Color(0xff8fa33b),
      dialogCancelTextStyle: const TextStyle(
        color: Colors.brown,
        fontSize: 18,
      ),
      dialogContinueTextStyle: const TextStyle(
        color: Colors.purpleAccent,
        fontSize: 18,
      ),
      mainBackgroundColor: Colors.indigo,
      mainTextStyle:
          const TextStyle(color: Colors.indigo, fontSize: 19, letterSpacing: 2),
      dialogBackgroundColor: Colors.greenAccent,
      appBarIcon: const Icon(Icons.message, color: Colors.purple),
      buttonText: "Pay $selectedCurrency${amountController.text}",
      appBarTitleTextStyle: const TextStyle(
        color: Colors.purpleAccent,
        fontSize: 18,
      ),
    );

    final Customer customer = Customer(
        name: "FLW Developer",
        phoneNumber: phoneNumberController.text,
        email: emailController.text);

    final subAccounts = [
      SubAccount(
          id: "RS_1A3278129B808CB588B53A14608169AD",
          transactionChargeType: "flat",
          transactionPercentage: 25),
      SubAccount(
          id: "RS_C7C265B8E4B16C2D472475D7F9F4426A",
          transactionChargeType: "flat",
          transactionPercentage: 50)
    ];

    final Flutterwave flutterwave = Flutterwave(
        context: context,
        style: style,
        publicKey: publicKey,
        currency: selectedCurrency,
        txRef: const Uuid().v1(),
        amount: amountController.text.toString().trim(),
        customer: customer,
        subAccounts: subAccounts,
        paymentOptions: "card, payattitude",
        customization: Customization(title: "Test Payment"),
        redirectUrl: "https://www.google.com",
        isTestMode: isTestMode);
    final ChargeResponse response = await flutterwave.charge();
    // ignore: unnecessary_null_comparison
    if (response != null) {
      showLoading(response.status!);
      if (response.success == true) {
        updateWallet(amount);
      }
      debugPrint("${response.toJson()}");
    } else {
      showLoading("No Response!");
    }
  }

  String getPublicKey() {
    if (isTestMode) return "FLWPUBK_TEST--X";
    return "FLWPUBK-X";
  }

  void _openBottomSheet() {
    showModalBottomSheet(
        context: context,
        builder: (context) {
          return _getCurrency();
        });
  }

  Widget _getCurrency() {
    final currencies = ["NGN", "RWF", "UGX", "ZAR", "USD", "GHS"];
    return Container(
      height: 250,
      margin: const EdgeInsets.fromLTRB(0, 10, 0, 0),
      color: Colors.white,
      child: ListView(
        children: currencies
            .map((currency) => ListTile(
                  onTap: () => {_handleCurrencyTap(currency)},
                  title: Column(
                    children: [
                      Text(
                        currency,
                        textAlign: TextAlign.start,
                        style: const TextStyle(color: Colors.black),
                      ),
                      const SizedBox(height: 4),
                      const Divider(height: 1)
                    ],
                  ),
                ))
            .toList(),
      ),
    );
  }

  _handleCurrencyTap(String currency) {
    setState(() {
      selectedCurrency = currency;
      currencyController.text = currency;
    });
    Navigator.pop(context);
  }

  Future<void> showLoading(String message) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Container(
            margin: const EdgeInsets.fromLTRB(30, 20, 30, 20),
            width: double.infinity,
            height: 50,
            child: Text(message),
          ),
        );
      },
    );
  }
}

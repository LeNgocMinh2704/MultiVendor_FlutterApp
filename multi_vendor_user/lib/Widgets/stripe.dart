// ignore_for_file: deprecated_member_use

import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_stripe/flutter_stripe.dart';
import '../Model/history.dart';

// ignore: prefer_function_declarations_over_variables
final ControlsWidgetBuilder emptyControlBuilder = (_, __) => Container();

class StripePage extends StatefulWidget {
  final String pkey;
  final String id;
  final String sKey;
  const StripePage(
      {Key? key, required this.pkey, required this.sKey, required this.id})
      : super(key: key);

  @override
  State<StripePage> createState() => _StripePageState();
}

class _StripePageState extends State<StripePage> {
  Map<String, dynamic>? paymentIntentData;
  String currencyCode = '';
  String currencySymbol = '';
  String name = '';
  num wallet = 0;

  getUserName() {
    FirebaseFirestore.instance
        .collection('users')
        .doc(widget.id)
        .get()
        .then((value) {
      name = value['fullname'];
    });
  }

  getCurrencySymbol() {
    FirebaseFirestore.instance
        .collection('Currency Settings')
        .doc('Currency Settings')
        .get()
        .then((value) {
      setState(() {
        currencyCode = value['Currency code'];
        currencySymbol = value['Currency symbol'];
      });
    });
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
    debugPrint('$wallet is your balance');
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
          paymentSystem: 'Stripe'));

      Fluttertoast.showToast(
          msg: "Wallet has been uploaded with $amount.",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          fontSize: 16.0);
    });
  }

  @override
  void initState() {
    getWallet();
    getCurrencySymbol();
    getUserName();
    super.initState();
  }

  stripeDetail() async {
    Stripe.publishableKey = widget.pkey;
    Stripe.merchantIdentifier = 'merchant.flutter.stripe.test';
    Stripe.urlScheme = 'flutterstripe';
    await Stripe.instance.applySettings();
  }

  int step = 0;
  String amount = '';
  @override
  Widget build(BuildContext context) {
    stripeDetail();
    return Scaffold(
      appBar: AppBar(
        iconTheme: Theme.of(context).iconTheme,
        backgroundColor: Theme.of(context).cardColor,
        title: Text(
          'Stripe Payment',
          style: TextStyle(color: Theme.of(context).iconTheme.color),
        ),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextFormField(
                validator: (v) {
                  if (v == '') {
                    return 'Enter Amount';
                  } else {
                    return null;
                  }
                },
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  border: UnderlineInputBorder(),
                  labelText: 'Amount',
                ),
                onSaved: (String? value) => amount = value!,
                onChanged: (String? value) => amount = value!,
              ),
            ),
            const SizedBox(height: 50),
            Center(
              child: InkWell(
                onTap: () async {
                  await makePayment();
                },
                child: Container(
                  height: 50,
                  color: Colors.orange,
                  child: const Center(
                    child: Text(
                      'Pay',
                      style: TextStyle(color: Colors.white, fontSize: 20),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> makePayment() async {
    try {
      paymentIntentData = await createPaymentIntent('${amount}00',
          currencyCode.toUpperCase()); //json.decode(response.body);
      // debugPrint('Response body==>${response.body.toString()}');
      await Stripe.instance
          .initPaymentSheet(
              paymentSheetParameters: SetupPaymentSheetParameters(
                  paymentIntentClientSecret:
                      paymentIntentData!['client_secret'],
                  applePay: true,
                  googlePay: true,
                  testEnv: true,
                  style: ThemeMode.dark,
                  merchantCountryCode: 'US',
                  merchantDisplayName: name))
          .then((value) {});

      ///now finally display payment sheeet
      displayPaymentSheet();
    } catch (e, s) {
      debugPrint('exception:$e$s');
    }
  }

  displayPaymentSheet() async {
    try {
      await Stripe.instance
          .presentPaymentSheet(
              parameters: PresentPaymentSheetParameters(
        clientSecret: paymentIntentData!['client_secret'],
        confirmPayment: true,
      ))
          .then((newValue) {
        debugPrint('payment intent${paymentIntentData!['id']}');
        debugPrint('payment intent${paymentIntentData!['client_secret']}');
        debugPrint('payment intent${paymentIntentData!['amount']}');
        debugPrint('payment intent$paymentIntentData');
        //orderPlaceApi(paymentIntentData!['id'].toString());
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text("paid successfully")));
        updateWallet(int.parse(amount));
        paymentIntentData = null;
      }).onError((error, stackTrace) {
        debugPrint('Exception/DISPLAYPAYMENTSHEET==> $error $stackTrace');
      });
    } on StripeException catch (e) {
      debugPrint('Exception/DISPLAYPAYMENTSHEET==> $e');
      showDialog(
          context: context,
          builder: (_) => const AlertDialog(
                content: Text("Cancelled "),
              ));
    } catch (e) {
      debugPrint('$e');
    }
  }

  //  Future<Map<String, dynamic>>
  createPaymentIntent(String amount, String currency) async {
    try {
      Map<String, dynamic> body = {
        'amount': amount,
        'currency': currency,
        'payment_method_types[]': 'card'
      };
      var response = await http.post(
          Uri.parse('https://api.stripe.com/v1/payment_intents'),
          body: body,
          headers: {
            'Authorization': 'Bearer ${widget.sKey}',
            'Content-Type': 'application/x-www-form-urlencoded'
          });
      debugPrint('Create Intent reponse ===> ${response.body.toString()}');
      debugPrint('Status Code ${response.statusCode}');

      return jsonDecode(response.body);
    } catch (err) {
      debugPrint('err charging user: ${err.toString()}');
    }
  }
}

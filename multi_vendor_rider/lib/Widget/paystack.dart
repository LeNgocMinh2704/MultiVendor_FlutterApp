// ignore_for_file: use_build_context_synchronously

import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_paystack/flutter_paystack.dart';

import '../Model/history.dart';

class PaystackPage extends StatefulWidget {
  final String id;
  final String paystackPublicKey;
  final String backendUrl;
  const PaystackPage(
      {Key? key,
      required this.paystackPublicKey,
      required this.backendUrl,
      required this.id})
      : super(key: key);

  @override
  State<PaystackPage> createState() => _PaystackPageState();
}

class _PaystackPageState extends State<PaystackPage> {
  final _formKey = GlobalKey<FormState>();
  final _verticalSizeBox = const SizedBox(height: 20.0);
  final _horizontalSizeBox = const SizedBox(width: 10.0);
  final plugin = PaystackPlugin();

  final int _radioValue = 0;
  final CheckoutMethod _method = CheckoutMethod.card;
  bool _inProgress = false;

  String? _cardNumber;
  String? _cvv;
  int? _expiryMonth;
  int? _expiryYear;
  num wallet = 0;
  String currencySymbol = '';
  int? amount = 0;
  String email = '';

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
          paymentSystem: 'Paystack'));

      Fluttertoast.showToast(
          msg: "Wallet has been uploaded with $amount.",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          fontSize: 16.0);
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

  getUserEmail() {
    FirebaseFirestore.instance
        .collection('users')
        .doc(widget.id)
        .get()
        .then((value) {
      email = value['email'];
    });
  }

  @override
  void initState() {
    getWallet();
    getUserEmail();
    getCurrencySymbol();
    plugin.initialize(publicKey: widget.paystackPublicKey);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          iconTheme: Theme.of(context).iconTheme,
          backgroundColor: Theme.of(context).cardColor,
          elevation: 0,
          title: Text(
            'Paystack Payment',
            style: TextStyle(color: Theme.of(context).iconTheme.color),
          )),
      body: Container(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                _verticalSizeBox,
                TextFormField(
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
                  onSaved: (String? value) => amount = int.parse(value!),
                ),
                _verticalSizeBox,
                Theme(
                  data: Theme.of(context).copyWith(
                    primaryColorLight: Colors.white,
                    primaryColorDark: navyBlue,
                    textTheme: Theme.of(context).textTheme.copyWith(
                          bodyMedium: const TextStyle(
                            color: lightBlue,
                          ),
                        ),
                  ),
                  child: Builder(
                    builder: (context) {
                      return _inProgress
                          ? Container(
                              alignment: Alignment.center,
                              height: 50.0,
                              child: Platform.isIOS
                                  ? const CupertinoActivityIndicator()
                                  : const CircularProgressIndicator(),
                            )
                          : Column(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                _verticalSizeBox,
                                const SizedBox(
                                  height: 40.0,
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: <Widget>[
                                    _horizontalSizeBox,
                                    Flexible(
                                      flex: 2,
                                      child: SizedBox(
                                        width: double.infinity,
                                        child: _getPlatformButton(
                                          'Checkout',
                                          () => _handleCheckout(context),
                                        ),
                                      ),
                                    ),
                                  ],
                                )
                              ],
                            );
                    },
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  _handleCheckout(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      if (_method != CheckoutMethod.card && _isLocal) {
        _showMessage('Select server initialization method at the top');
        return;
      }
      setState(() => _inProgress = true);
      _formKey.currentState?.save();
      Charge charge = Charge()
        ..amount = amount! * 100 // In base currency
        ..email = email
        ..card = _getCardFromUI();

      if (!_isLocal) {
        var accessCode = await _fetchAccessCodeFrmServer(_getReference());
        charge.accessCode = accessCode;
      } else {
        charge.reference = _getReference();
      }

      try {
        CheckoutResponse response = await plugin.checkout(
          context,
          method: _method,
          charge: charge,
          fullscreen: false,
          logo: const MyLogo(),
        );

        if (response.status == true) {
          updateWallet(amount!);
        }
        setState(() => _inProgress = false);
        // _updateStatus(response.reference, '$response');
      } catch (e) {
        setState(() => _inProgress = false);
        _showMessage("Check console for error");
        rethrow;
      }
    }
  }

  String _getReference() {
    String platform;
    if (Platform.isIOS) {
      platform = 'iOS';
    } else {
      platform = 'Android';
    }

    return 'ChargedFrom${platform}_${DateTime.now().millisecondsSinceEpoch}';
  }

  PaymentCard _getCardFromUI() {
    // Using just the must-required parameters.
    return PaymentCard(
      number: _cardNumber,
      cvc: _cvv,
      expiryMonth: _expiryMonth,
      expiryYear: _expiryYear,
    );

    // Using Cascade notation (similar to Java's builder pattern)
//    return PaymentCard(
//        number: cardNumber,
//        cvc: cvv,
//        expiryMonth: expiryMonth,
//        expiryYear: expiryYear)
//      ..name = 'Segun Chukwuma Adamu'
//      ..country = 'Nigeria'
//      ..addressLine1 = 'Ikeja, Lagos'
//      ..addressPostalCode = '100001';

    // Using optional parameters
//    return PaymentCard(
//        number: cardNumber,
//        cvc: cvv,
//        expiryMonth: expiryMonth,
//        expiryYear: expiryYear,
//        name: 'Ismail Adebola Emeka',
//        addressCountry: 'Nigeria',
//        addressLine1: '90, Nnebisi Road, Asaba, Deleta State');
  }

  Widget _getPlatformButton(String string, Function() function) {
    // is still in progress
    Widget widget;
    if (Platform.isIOS) {
      widget = CupertinoButton(
        onPressed: function,
        color: Colors.orange,
        child: Text(
          string,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      );
    } else {
      widget = ElevatedButton(
        onPressed: function,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.orange,
        ),
        child: Text(
          string.toUpperCase(),
          style: const TextStyle(fontSize: 17.0),
        ),
      );
    }
    return widget;
  }

  Future<String?> _fetchAccessCodeFrmServer(String reference) async {
    String url = '${widget.backendUrl}/new-access-code';
    String? accessCode;
    try {
      http.Response response = await http.get(Uri.parse(url));
      accessCode = response.body;
    } catch (e) {
      setState(() => _inProgress = false);
      _updateStatus(
          reference,
          'There was a problem getting a new access code form'
          ' the backend: $e');
    }

    return accessCode;
  }

  _updateStatus(String? reference, String message) {
    _showMessage('Reference: $reference \n Response: $message',
        const Duration(seconds: 7));
  }

  _showMessage(String message,
      [Duration duration = const Duration(seconds: 4)]) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      duration: duration,
      action: SnackBarAction(
          label: 'CLOSE',
          onPressed: () =>
              ScaffoldMessenger.of(context).removeCurrentSnackBar()),
    ));
  }

  bool get _isLocal => _radioValue == 0;
}

class MyLogo extends StatelessWidget {
  const MyLogo({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.black,
      ),
      alignment: Alignment.center,
      padding: const EdgeInsets.all(10),
      child: const Text(
        "CO",
        style: TextStyle(
          color: Colors.white,
          fontSize: 13,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

const Color green = Color(0xFF3db76d);
const Color lightBlue = Color(0xFF34a5db);
const Color navyBlue = Color(0xFF031b33);

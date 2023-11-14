import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:admin_web/Utils/Database/database.dart';

class PaymentSettings extends StatefulWidget {
  const PaymentSettings({Key? key}) : super(key: key);

  @override
  State<PaymentSettings> createState() => _PaymentSettingsState();
}

class _PaymentSettingsState extends State<PaymentSettings> {
  @override
  void initState() {
    getStripeStatus();
    getPaystackDetails();
    getPaystackStatus();
    getFlutterwaveStatus();
    getCashondeliveryStatus();
    getStripeDetails();
    getFlutterwaveDetails();
    super.initState();
  }

  getStripeStatus() {
    FirebaseFirestore.instance
        .collection('Payment System')
        .doc('Stripe')
        .get()
        .then((value) {
      setState(() {
        enableStripe = value['Stripe'];
      });
    });
  }

  getPaystackStatus() {
    FirebaseFirestore.instance
        .collection('Payment System')
        .doc('Paystack')
        .get()
        .then((value) {
      setState(() {
        enablePaystack = value['Paystack'];
      });
    });
  }

  getFlutterwaveStatus() {
    FirebaseFirestore.instance
        .collection('Payment System')
        .doc('Flutterwave')
        .get()
        .then((value) {
      setState(() {
        enableFlutterwave = value['Flutterwave'];
      });
    });
  }

  getCashondeliveryStatus() {
    FirebaseFirestore.instance
        .collection('Payment System')
        .doc('Cash on delivery')
        .get()
        .then((value) {
      setState(() {
        enableCashondelivery = value['Cash on delivery'];
      });
    });
  }

  bool enableStripe = false;
  bool enablePaystack = false;
  bool enableFlutterwave = false;
  bool enableCashondelivery = false;
  String publishableKey = '';
  String secretKey = '';
  String flutterwavePublicKey = '';
  String paystackPublicKey = '';
  String backendUrl = '';
  String encryptionKey = '';
  final _formKey = GlobalKey<FormState>();
  final _formKey2 = GlobalKey<FormState>();
  final _formKey3 = GlobalKey<FormState>();
  String getPublishableKey = '';
  String getSecretKey = '';
  String getFlutterwavePublicKey = '';
  String getPaystackPublicKey = '';
  String getBackendUrl = '';
  String getEncryptionKey = '';

  getStripeDetails() {
    FirebaseFirestore.instance
        .collection('Payment System Details')
        .doc('Stripe')
        .get()
        .then((value) {
      if (mounted) {
        setState(() {
          getPublishableKey = value['Publishable key'];
          getSecretKey = value['Secret Key'];
        });
      }
    });
  }

  whenPublishabelKeyisNull() {
    if (publishableKey == '') {
      return getPublishableKey;
    } else {
      return publishableKey;
    }
  }

  whensecretKeyisNull() {
    if (secretKey == '') {
      return getSecretKey;
    } else {
      return secretKey;
    }
  }

  getPaystackDetails() {
    FirebaseFirestore.instance
        .collection('Payment System Details')
        .doc('Paystack')
        .get()
        .then((value) {
      if (mounted) {
        setState(() {
          getPaystackPublicKey = value['Public key'];
          getBackendUrl = value['banckendUrl'];
        });
      }
    });
  }

  whenPaystackPublicKeyisNull() {
    if (paystackPublicKey == '') {
      return getPaystackPublicKey;
    } else {
      return paystackPublicKey;
    }
  }

  whenBackendUrlisNull() {
    if (backendUrl == '') {
      return getBackendUrl;
    } else {
      return backendUrl;
    }
  }

  getFlutterwaveDetails() {
    FirebaseFirestore.instance
        .collection('Payment System Details')
        .doc('Flutterwave')
        .get()
        .then((value) {
      if (mounted) {
        setState(() {
          getFlutterwavePublicKey = value['Public key'];
          getEncryptionKey = value['Encryption Key'];
        });
      }
    });
  }

  whenFlutterwavePublicKeyisNull() {
    if (flutterwavePublicKey == '') {
      return getFlutterwavePublicKey;
    } else {
      return flutterwavePublicKey;
    }
  }

  whenEncryptionisNull() {
    if (encryptionKey == '') {
      return getEncryptionKey;
    } else {
      return encryptionKey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: const [
            Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                'Stripe Payment (Visa and MasterCards card)',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
          ],
        ),
        CheckboxListTile(
          title: const Text('Enable Stripe payment'),
          value: enableStripe,
          onChanged: (bool? value) {
            setState(() {
              enableStripe = !enableStripe;
              PaymentClass().enableStripe(enableStripe);
            });
          },
        ),
        Form(
          key: _formKey,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Flexible(
                        flex: 1,
                        child: Text('Publishable Key:',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ))),
                    Flexible(
                        flex: 4,
                        child: TextFormField(
                            readOnly: true,
                            onTap: () {
                              Fluttertoast.showToast(
                                  msg:
                                      "This is a test version you can't change the key",
                                  backgroundColor: Colors.blue.shade800,
                                  textColor: Colors.white);
                            },
                            onChanged: (value) {
                              setState(() {
                                publishableKey = value;
                              });
                            },
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(
                                    color: Colors.grey, width: 1.0),
                              ),
                              hintText: whenPublishabelKeyisNull(),
                              focusColor: Colors.grey,
                              filled: true,
                              fillColor: Colors.white10,
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: const BorderSide(
                                    color: Colors.grey, width: 1.0),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(
                                    color: Colors.grey, width: 1.0),
                              ),
                            )))
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Flexible(
                        flex: 1,
                        child: Text('Secret Key:',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ))),
                    Flexible(
                        flex: 4,
                        child: TextFormField(
                            readOnly: true,
                            onTap: () {
                              Fluttertoast.showToast(
                                  msg:
                                      "This is a test version you can't change the key",
                                  backgroundColor: Colors.blue.shade800,
                                  textColor: Colors.white);
                            },
                            onChanged: (value) {
                              setState(() {
                                secretKey = value;
                              });
                            },
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(
                                    color: Colors.grey, width: 1.0),
                              ),
                              hintText: whensecretKeyisNull(),
                              focusColor: Colors.grey,
                              filled: true,
                              fillColor: Colors.white10,
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: const BorderSide(
                                    color: Colors.grey, width: 1.0),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(
                                    color: Colors.grey, width: 1.0),
                              ),
                            )))
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ElevatedButton(
                  style: ButtonStyle(
                    elevation: MaterialStateProperty.all(10),
                    backgroundColor: MaterialStateProperty.all<Color>(
                      Colors.blue.shade800,
                    ),
                  ),
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      PaymentClass().updateStripe(
                          whenPublishabelKeyisNull(), whensecretKeyisNull());
                      _formKey.currentState!.reset();
                      Fluttertoast.showToast(
                          msg: "Update completed",
                          backgroundColor: Colors.blue.shade800,
                          textColor: Colors.white);
                    }
                  },
                  child: const Text('Update',
                      style: TextStyle(color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
        const Divider(
          color: Colors.grey,
          thickness: 2,
        ),
        Row(
          children: const [
            Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                'Paystack Payment (Visa and MasterCards card)',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
          ],
        ),
        CheckboxListTile(
          title: const Text('Enable Paystack payment'),
          value: enablePaystack,
          onChanged: (bool? value) {
            setState(() {
              enablePaystack = !enablePaystack;
              PaymentClass().enablePaystack(enablePaystack);
            });
          },
        ),
        Form(
          key: _formKey2,
          child: Column(children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Flexible(
                      flex: 1,
                      child: Text('Public Key:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ))),
                  Flexible(
                      flex: 4,
                      child: TextFormField(
                          readOnly: true,
                          onTap: () {
                            Fluttertoast.showToast(
                                msg:
                                    "This is a test version you can't change the key",
                                backgroundColor: Colors.blue.shade800,
                                textColor: Colors.white);
                          },
                          onChanged: (value) {
                            setState(() {
                              paystackPublicKey = value;
                            });
                          },
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(
                                  color: Colors.grey, width: 1.0),
                            ),
                            hintText: whenPaystackPublicKeyisNull(),
                            focusColor: Colors.grey,
                            filled: true,
                            fillColor: Colors.white10,
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(
                                  color: Colors.grey, width: 1.0),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(
                                  color: Colors.grey, width: 1.0),
                            ),
                          )))
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Flexible(
                      flex: 1,
                      child: Text('Backend Url:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ))),
                  Flexible(
                      flex: 4,
                      child: TextFormField(
                          readOnly: true,
                          onTap: () {
                            Fluttertoast.showToast(
                                msg:
                                    "This is a test version you can't change the key",
                                backgroundColor: Colors.blue.shade800,
                                textColor: Colors.white);
                          },
                          onChanged: (value) {
                            setState(() {
                              backendUrl = value;
                            });
                          },
                          decoration: InputDecoration(
                            hintText: whenBackendUrlisNull(),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(
                                  color: Colors.grey, width: 1.0),
                            ),
                            focusColor: Colors.grey,
                            filled: true,
                            fillColor: Colors.white10,
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(
                                  color: Colors.grey, width: 1.0),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(
                                  color: Colors.grey, width: 1.0),
                            ),
                          )))
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(
                style: ButtonStyle(
                  elevation: MaterialStateProperty.all(10),
                  backgroundColor: MaterialStateProperty.all<Color>(
                    Colors.blue.shade800,
                  ),
                ),
                onPressed: () {
                  if (_formKey2.currentState!.validate()) {
                    PaymentClass().updatePaystack(
                        whenPaystackPublicKeyisNull(), whenBackendUrlisNull());
                    _formKey2.currentState!.reset();
                    Fluttertoast.showToast(
                        msg: "Update completed",
                        backgroundColor: Colors.blue.shade800,
                        textColor: Colors.white);
                  }
                },
                child: const Text(
                  'Update',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ]),
        ),
        const Divider(
          color: Colors.grey,
          thickness: 2,
        ),
        Row(
          children: const [
            Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                'Flutterwave Payment (Visa and MasterCards card)',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
          ],
        ),
        CheckboxListTile(
          title: const Text('Enable Flutterwave payment'),
          value: enableFlutterwave,
          onChanged: (bool? value) {
            setState(() {
              enableFlutterwave = !enableFlutterwave;
              PaymentClass().enableFlutterwave(enableFlutterwave);
            });
          },
        ),
        Form(
          key: _formKey3,
          child: Column(children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Flexible(
                      flex: 1,
                      child: Text('Public Key:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ))),
                  Flexible(
                      flex: 4,
                      child: TextFormField(
                          readOnly: true,
                          onTap: () {
                            Fluttertoast.showToast(
                                msg:
                                    "This is a test version you can't change the key",
                                backgroundColor: Colors.blue.shade800,
                                textColor: Colors.white);
                          },
                          onChanged: (value) {
                            setState(() {
                              flutterwavePublicKey = value;
                            });
                          },
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(
                                  color: Colors.grey, width: 1.0),
                            ),
                            hintText: whenFlutterwavePublicKeyisNull(),
                            focusColor: Colors.grey,
                            filled: true,
                            fillColor: Colors.white10,
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(
                                  color: Colors.grey, width: 1.0),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(
                                  color: Colors.grey, width: 1.0),
                            ),
                          )))
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Flexible(
                      flex: 1,
                      child: Text('Encryption Key:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ))),
                  Flexible(
                      flex: 4,
                      child: TextFormField(
                          readOnly: true,
                          onTap: () {
                            Fluttertoast.showToast(
                                msg:
                                    "This is a test version you can't change the key",
                                backgroundColor: Colors.blue.shade800,
                                textColor: Colors.white);
                          },
                          onChanged: (value) {
                            setState(() {
                              encryptionKey = value;
                            });
                          },
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(
                                  color: Colors.grey, width: 1.0),
                            ),
                            focusColor: Colors.grey,
                            hintText: whenEncryptionisNull(),
                            filled: true,
                            fillColor: Colors.white10,
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(
                                  color: Colors.grey, width: 1.0),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(
                                  color: Colors.grey, width: 1.0),
                            ),
                          )))
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(
                style: ButtonStyle(
                  elevation: MaterialStateProperty.all(10),
                  backgroundColor: MaterialStateProperty.all<Color>(
                    Colors.blue.shade800,
                  ),
                ),
                onPressed: () {
                  if (_formKey3.currentState!.validate()) {
                    PaymentClass().updateFlutterwave(
                        whenFlutterwavePublicKeyisNull(),
                        whenEncryptionisNull());
                    _formKey3.currentState!.reset();
                    Fluttertoast.showToast(
                        msg: "Update completed",
                        backgroundColor: Colors.blue.shade800,
                        textColor: Colors.white);
                  }
                },
                child: const Text(
                  'Update',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ]),
        ),
        const Divider(
          color: Colors.grey,
          thickness: 2,
        ),
        Row(
          children: const [
            Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                'Cash on delivery Payment',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
          ],
        ),
        CheckboxListTile(
          title: const Text('Enable Cash on delivery payment'),
          value: enableCashondelivery,
          onChanged: (bool? value) {
            setState(() {
              enableCashondelivery = !enableCashondelivery;
              PaymentClass().enableCashondelivery(enableCashondelivery);
            });
          },
        ),
        const SizedBox(height: 100)
      ],
    );
  }
}

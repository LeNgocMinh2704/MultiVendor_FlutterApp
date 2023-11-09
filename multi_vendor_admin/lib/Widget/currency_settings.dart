import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CurrencySettings extends StatefulWidget {
  const CurrencySettings({Key? key}) : super(key: key);

  @override
  State<CurrencySettings> createState() => _CurrencySettingsState();
}

class _CurrencySettingsState extends State<CurrencySettings> {
  @override
  void initState() {
    getCurrencyDetails();
    super.initState();
  }

  String currencyName = '';
  String currencyCode = '';
  String currencySymbol = '';
  final _formKey = GlobalKey<FormState>();
  String getcurrencyName = '';
  String getcurrencyCode = '';
  String getcurrencySymbol = '';

  getCurrencyDetails() {
    FirebaseFirestore.instance
        .collection('Currency Settings')
        .doc('Currency Settings')
        .get()
        .then((value) {
      if (mounted) {
        setState(() {
          getcurrencyName = value['Currency name'];
          getcurrencyCode = value['Currency code'];
          getcurrencySymbol = value['Currency symbol'];
        });
      }
    });
  }

  updateCurrencyDetails() {
    FirebaseFirestore.instance
        .collection('Currency Settings')
        .doc('Currency Settings')
        .set({
      'Currency name': whencurrencyNameisNull(),
      'Currency code': whencurrencyCodeisNull(),
      'Currency symbol': whencurrencySymbolisNull()
    });
  }

  whencurrencyNameisNull() {
    if (currencyName == '') {
      return getcurrencyName;
    } else {
      return currencyName;
    }
  }

  whencurrencyCodeisNull() {
    if (currencyCode == '') {
      return getcurrencyCode;
    } else {
      return currencyCode;
    }
  }

  whencurrencySymbolisNull() {
    if (currencySymbol == '') {
      return getcurrencySymbol;
    } else {
      return currencySymbol;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: const [
            Padding(
              padding: EdgeInsets.all(12.0),
              child: Text(
                'Set app default currency e.g ( Dollar,USD,\$)',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
          ],
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
                        child: Text('Currency name:',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ))),
                    Flexible(
                        flex: 4,
                        child: TextFormField(
                            validator: (value) {
                              if (value!.isEmpty) {
                                return 'Currency name is required';
                              } else {
                                return null;
                              }
                            },
                            onChanged: (value) {
                              setState(() {
                                currencyName = value;
                              });
                            },
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(
                                    color: Colors.grey, width: 1.0),
                              ),
                              hintText: whencurrencyNameisNull(),
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
                        child: Text('Currency code:',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ))),
                    Flexible(
                        flex: 4,
                        child: TextFormField(
                            validator: (value) {
                              if (value!.isEmpty) {
                                return 'Currency code is required';
                              } else {
                                return null;
                              }
                            },
                            onChanged: (value) {
                              setState(() {
                                currencyCode = value;
                              });
                            },
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(
                                    color: Colors.grey, width: 1.0),
                              ),
                              hintText: whencurrencyCodeisNull(),
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
                        child: Text('Currency Symbol:',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ))),
                    Flexible(
                        flex: 4,
                        child: TextFormField(
                            validator: (value) {
                              if (value!.isEmpty) {
                                return 'Currency symbol is required';
                              } else {
                                return null;
                              }
                            },
                            onChanged: (value) {
                              setState(() {
                                currencySymbol = value;
                              });
                            },
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(
                                    color: Colors.grey, width: 1.0),
                              ),
                              hintText: whencurrencySymbolisNull(),
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
                      updateCurrencyDetails();
                      _formKey.currentState!.reset();
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
            ],
          ),
        ),
      ],
    );
  }
}

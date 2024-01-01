import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';

class CourierSetingsWidget extends StatefulWidget {
  const CourierSetingsWidget({Key? key}) : super(key: key);

  @override
  State<CourierSetingsWidget> createState() => _CourierSetingsWidgetState();
}

class _CourierSetingsWidgetState extends State<CourierSetingsWidget> {
  @override
  void initState() {
    super.initState();
  }

  bool enableCourier = false;
  bool enableCourierFirestore = false;
  bool enableKg = true;
  bool enableKm = false;
  bool enableKgFireStore = false;
  bool enableKmFireStore = false;
  final _formKey = GlobalKey<FormState>();
  final _formKey2 = GlobalKey<FormState>();
  num perKgPrice = 0;
  num deliveryBoyCommissionKg = 0;
  num perKmPrice = 0;
  num deliveryBoyCommissionKm = 0;
  num perKgPriceFireStore = 0;
  num deliveryBoyCommissionKgFireStore = 0;
  num perKmPriceFireStore = 0;
  num deliveryBoyCommissionKmFireStore = 0;

  setCourierServiceStatus() {
    FirebaseFirestore.instance
        .collection('Courier System')
        .doc('Courier System')
        .set({'Enable Courier': enableCourier});
  }

  setKmStatus() {
    FirebaseFirestore.instance
        .collection('Courier System')
        .doc('Km Courier')
        .set({'Km Courier': enableKm});
  }

  setKgStatus() {
    FirebaseFirestore.instance
        .collection('Courier System')
        .doc('Kg Courier')
        .set({'Kg Courier': enableKg});
  }

  getKgStatus() {
    FirebaseFirestore.instance
        .collection('Courier System')
        .doc('Kg Courier')
        .get()
        .then((value) => {
              setState(() {
                enableKgFireStore = value['Kg Courier'];
              })
            });
  }

  getKmStatus() {
    FirebaseFirestore.instance
        .collection('Courier System')
        .doc('Km Courier')
        .get()
        .then((value) => {
              setState(() {
                enableKmFireStore = value['Km Courier'];
              })
            });
  }

  getCourierServiceStatus() {
    FirebaseFirestore.instance
        .collection('Courier System')
        .doc('Courier System')
        .get()
        .then((value) => {
              setState(() {
                enableCourierFirestore = value['Enable Courier'];
              })
            });
  }

  setDetails(
      {required num perKmPrice,
      required num perKgPrice,
      required num deliveryBoyCommissionKg,
      required num deliveryBoyCommissionKm}) {
    FirebaseFirestore.instance
        .collection('Courier System')
        .doc('Courier Details')
        .set({
      'km': perKmPrice,
      'kg': perKgPrice,
      'deliveryCommissionKg': deliveryBoyCommissionKg,
      'deliveryCommissionKm': deliveryBoyCommissionKm
    }).then((value) {
      Fluttertoast.showToast(
          toastLength: Toast.LENGTH_LONG,
          msg: "Update completed",
          backgroundColor: Colors.blue.shade800,
          textColor: Colors.white);
    });
  }

  getDetails() {
    FirebaseFirestore.instance
        .collection('Courier System')
        .doc('Courier Details')
        .get()
        .then((value) => {
              setState(() {
                perKgPriceFireStore = value['kg'];
                perKmPriceFireStore = value['km'];
                deliveryBoyCommissionKgFireStore =
                    value['deliveryCommissionKg'];
                deliveryBoyCommissionKmFireStore =
                    value['deliveryCommissionKm'];
              })
            });
  }

  whenCourierIsNull() {
    // ignore: unnecessary_null_comparison
    if (enableCourierFirestore == null) {
      return false;
    } else {
      return enableCourierFirestore;
    }
  }

  whenKmIsNull() {
    // ignore: unnecessary_null_comparison
    if (enableKmFireStore == null) {
      return false;
    } else {
      return enableKmFireStore;
    }
  }

  whenKgIsNull() {
    // ignore: unnecessary_null_comparison
    if (enableKgFireStore == null) {
      return false;
    } else {
      return enableKgFireStore;
    }
  }

  whenperKgPriceisNull() {
    if (perKgPriceFireStore == 0) {
      return perKgPrice.toString();
    } else {
      return perKgPriceFireStore.toString();
    }
  }

  whenperKmPriceisNull() {
    if (perKmPriceFireStore == 0) {
      return perKmPrice.toString();
    } else {
      return perKmPriceFireStore.toString();
    }
  }

  whendeliveryBoyCommissionKgisNull() {
    if (deliveryBoyCommissionKgFireStore == 0) {
      return deliveryBoyCommissionKgFireStore.toString();
    } else {
      return deliveryBoyCommissionKgFireStore.toString();
    }
  }

  whendeliveryBoyCommissionKmisNull() {
    if (deliveryBoyCommissionKmFireStore == 0) {
      return deliveryBoyCommissionKm.toString();
    } else {
      return deliveryBoyCommissionKmFireStore.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    getCourierServiceStatus();
    getKmStatus();
    getDetails();
    getKgStatus();

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ListView(
        physics: const BouncingScrollPhysics(),
        children: [
          const SizedBox(height: 20),
          CheckboxListTile(
            title: const Text('Enable Courier System'),
            value: whenCourierIsNull(),
            onChanged: (bool? value) {
              setState(() {
                enableCourier = !enableCourier;
                setCourierServiceStatus();
              });
            },
          ),
          const Divider(
            color: Colors.black,
            thickness: 2,
          ),
          const SizedBox(
            height: 20,
          ),
          CheckboxListTile(
            title: const Text('Enable this concept'),
            value: whenKgIsNull(),
            onChanged: (bool? value) {
              setState(() {
                enableKg = !enableKg;
                setKgStatus();
                if (enableKg == true) {
                  enableKm = false;
                  setKmStatus();
                }
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
                          child: Text('Price Per Kg:',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ))),
                      Flexible(
                          flex: 4,
                          child: TextFormField(
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                              onChanged: (value) {
                                setState(() {
                                  perKgPrice = int.parse(value);
                                });
                              },
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: const BorderSide(
                                      color: Colors.grey, width: 1.0),
                                ),
                                hintText: whenperKgPriceisNull(),
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
                          child: Text('Delivery boy commission:',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ))),
                      Flexible(
                          flex: 4,
                          child: TextFormField(
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                              onChanged: (value) {
                                setState(() {
                                  deliveryBoyCommissionKg = int.parse(value);
                                });
                              },
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: const BorderSide(
                                      color: Colors.grey, width: 1.0),
                                ),
                                hintText: whendeliveryBoyCommissionKgisNull(),
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
              ],
            ),
          ),
          const Divider(
            color: Colors.black,
            thickness: 2,
          ),
          const SizedBox(
            height: 20,
          ),
          CheckboxListTile(
            title: const Text('Enable this concept'),
            value: whenKmIsNull(),
            onChanged: (bool? value) {
              setState(() {
                enableKm = !enableKm;
                setKmStatus();
                if (enableKm == true) {
                  enableKg = false;
                  setKgStatus();
                }
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
                        child: Text('Price Per Km:',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ))),
                    Flexible(
                        flex: 4,
                        child: TextFormField(
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            onChanged: (value) {
                              setState(() {
                                perKmPrice = int.parse(value);
                              });
                            },
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide:
                                    const BorderSide(color: Colors.grey, width: 1.0),
                              ),
                              hintText: whenperKmPriceisNull(),
                              focusColor: Colors.grey,
                              filled: true,
                              fillColor: Colors.white10,
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide:
                                    const BorderSide(color: Colors.grey, width: 1.0),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide:
                                    const BorderSide(color: Colors.grey, width: 1.0),
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
                        child: Text('Delivery boy commission:',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ))),
                    Flexible(
                        flex: 4,
                        child: TextFormField(
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            onChanged: (value) {
                              setState(() {
                                deliveryBoyCommissionKm = int.parse(value);
                              });
                            },
                            decoration: InputDecoration(
                              hintText: whendeliveryBoyCommissionKmisNull(),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide:
                                    const BorderSide(color: Colors.grey, width: 1.0),
                              ),
                              focusColor: Colors.grey,
                              filled: true,
                              fillColor: Colors.white10,
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide:
                                    const BorderSide(color: Colors.grey, width: 1.0),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide:
                                    const BorderSide(color: Colors.grey, width: 1.0),
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
                    setDetails(
                        perKgPrice: perKgPrice,
                        perKmPrice: perKmPrice,
                        deliveryBoyCommissionKg: deliveryBoyCommissionKg,
                        deliveryBoyCommissionKm: deliveryBoyCommissionKm);
                  },
                  child: const Text(
                    'Update',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ]),
          ),
        ],
      ),
    );
  }
}

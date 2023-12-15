import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../Models/order_model.dart';

class OrderDetail extends StatefulWidget {
  final OrderModel2 orderModel;
  const OrderDetail({
    Key? key,
    required this.orderModel,
  }) : super(key: key);
  @override
  State<OrderDetail> createState() => _OrderDetailState();
}

class _OrderDetailState extends State<OrderDetail> {
  String userEmail = '';
  String userphone = '';
  String vendorsEmail = '';
  String vendorsphone = '';
  String vendorsName = '';

  getUserDetails() {
    FirebaseFirestore.instance
        .collection('users')
        .doc(widget.orderModel.userID)
        .get()
        .then((value) {
      setState(() {
        userEmail = value['email'];
        userphone = value['phonenumber'];
      });
    });
  }

  getVendorDetails() {
    FirebaseFirestore.instance
        .collection('vendors')
        .doc(widget.orderModel.vendorID)
        .get()
        .then((value) {
      setState(() {
        vendorsName = value['fullname'];
        vendorsEmail = value['email'];
        vendorsphone = value['phone'];
      });
    });
  }

  Widget fetchPaymenttype() {
    if (widget.orderModel.paymentType == 'cash on delivery') {
      return const Text('Cash on Delivery');
    } else if (widget.orderModel.paymentType == 'stripe') {
      return Image.asset(
        "assets/image/stripe.png",
        height: 40,
      );
    } else if (widget.orderModel.paymentType == 'flutterwave') {
      return Image.asset(
        "assets/image/flutterwave.png",
        height: 40,
      );
    } else if (widget.orderModel.paymentType == 'paystack') {
      return Image.asset("assets/image/paystack.png", height: 40, width: 70);
    } else {
      return Image.asset(
        "assets/image/razorpay.png",
        height: 40,
      );
    }
  }

  String currencyName = '';
  String currencyCode = '';
  String currencySymbol = '';
  String getcurrencyName = '';
  String getcurrencyCode = '';
  String getcurrencySymbol = '';

  getCurrencyDetails() {
    FirebaseFirestore.instance
        .collection('Currency Settings')
        .doc('Currency Settings')
        .get()
        .then((value) {
      getcurrencyName = value['Currency name'];
      getcurrencyCode = value['Currency code'];
      currencySymbol = value['Currency symbol'];
    });
  }

  int _index = 0;
  String marketName = '';
  String marketAddress = '';
  String marketPhone = '';
  String riderName = '';
  String riderAddress = '';
  String riderPhone = '';
  num wallet = 0;
  DocumentReference? userDetails;

  getMarketDetails() {
    FirebaseFirestore.instance
        .collection('Markets')
        .doc(widget.orderModel.marketID)
        .get()
        .then((val) {
      setState(() {
        marketName = val['Market Name'];
        marketAddress = val['Address'];
        marketPhone = val['Phonenumber'];
      });
    });
  }

  getRiderDetails() {
    if (widget.orderModel.deliveryBoyID != '') {
      FirebaseFirestore.instance
          .collection('drivers')
          .doc(widget.orderModel.deliveryBoyID)
          .get()
          .then((val) {
        setState(() {
          riderName = val['fullname'];
          riderAddress = val['address'];
          riderPhone = val['phone'];
        });
      });
    }
  }

  updateWallet() {
    FirebaseFirestore.instance
        .collection('users')
        .doc(widget.orderModel.userID)
        .update({
      'wallet': wallet +
          widget.orderModel.total +
          (widget.orderModel.deliveryAddress == ''
              ? 0
              : widget.orderModel.deliveryFee)
    });
  }

  @override
  void initState() {
    getMarketDetails();
    getUserDetails();
    getVendorDetails();
    getCurrencyDetails();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: SizedBox(
        width: MediaQuery.of(context).size.width / 1.5,
        child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: SingleChildScrollView(
                child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 12, top: 12),
                  child: Row(
                    children: const [
                      Text('Order Tracking Update',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: Colors.grey)),
                    ],
                  ),
                ),
                Stepper(
                  physics: const BouncingScrollPhysics(),
                  onStepTapped: (step) {
                    if (step > _index) {
                      setState(() {
                        _index = step;
                      });
                    }
                  },
                  type: StepperType.vertical,
                  controlsBuilder:
                      (BuildContext context, ControlsDetails controls) {
                    return const SizedBox();
                  },
                  currentStep: _index,
                  steps: <Step>[
                    Step(
                      isActive: widget.orderModel.status == 'Received'
                          ? true
                          : widget.orderModel.status == 'Cancelled'
                              ? false
                              : true,
                      title: widget.orderModel.status == 'Cancelled'
                          ? const Text('Cancelled')
                          : const Text('Received'),
                      content: Container(),
                    ),
                    Step(
                      isActive: widget.orderModel.accept == true ? true : false,
                      title: const Text('Accepted'),
                      content: Container(),
                    ),
                    Step(
                      isActive: widget.orderModel.acceptDelivery == true
                          ? true
                          : false,
                      title: const Text('Processing'),
                      content: Container(),
                    ),
                    Step(
                      isActive: widget.orderModel.status == 'Completed'
                          ? true
                          : false,
                      title: const Text('Completed'),
                      content: Container(),
                    )
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 12, top: 12),
                  child: Row(
                    children: const [
                      Text('Vendor Detail ',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: Colors.grey)),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.only(left: 10, right: 10),
                  child: Card(
                    elevation: 0.1,
                    child: ListTile(
                      title: Text(vendorsName),
                      subtitle: const Text('Vendor name'),
                      leading: const Icon(Icons.info),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 10, right: 10),
                  child: Card(
                    elevation: 0.1,
                    child: ListTile(
                      title: Text(vendorsphone),
                      subtitle: const Text('Vendor Phone'),
                      leading: const Icon(Icons.phone),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 12, top: 12),
                  child: Row(
                    children: const [
                      Text('Market Detail',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: Colors.grey)),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.only(left: 10, right: 10),
                  child: Card(
                    elevation: 0.1,
                    child: ListTile(
                      title: Text(marketName),
                      subtitle: const Text('Market name'),
                      leading: const Icon(Icons.info),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 10, right: 10),
                  child: Card(
                    elevation: 0.1,
                    child: ListTile(
                      title: Text(marketAddress),
                      subtitle: const Text('Market address'),
                      leading: const Icon(Icons.room),
                    ),
                  ),
                ),
                // Padding(
                //   padding: const EdgeInsets.only(left: 10, right: 10),
                //   child: Card(
                //     elevation: 0.1,
                //     child: ListTile(
                //       title: Text(marketPhone),
                //       subtitle: Text('Market phone'),
                //       leading: Icon(Icons.phone),
                //       trailing: OutlinedButton(
                //           onPressed: () {
                //             _callMarket(marketPhone);
                //           },
                //           child: Text('Call Market')),
                //     ),
                //   ),
                // ),
                widget.orderModel.deliveryBoyID == ''
                    ? Container()
                    : Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 12, top: 12),
                            child: Row(
                              children: const [
                                Text("Rider's Detail",
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                        color: Colors.grey)),
                              ],
                            ),
                          ),
                          const SizedBox(height: 10),
                          Padding(
                            padding: const EdgeInsets.only(left: 10, right: 10),
                            child: Card(
                              elevation: 0.1,
                              child: ListTile(
                                title: Text(riderName),
                                subtitle: const Text("Riders name"),
                                leading: const Icon(Icons.person),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 10, right: 10),
                            child: Card(
                              elevation: 0.1,
                              child: ListTile(
                                title: Text(riderAddress),
                                subtitle: const Text("Rider's address"),
                                leading: const Icon(Icons.room),
                              ),
                            ),
                          ),
                          // Padding(
                          //   padding: const EdgeInsets.only(left: 10, right: 10),
                          //   child: Card(
                          //     elevation: 0.1,
                          //     child: ListTile(
                          //       title: Text(riderPhone),
                          //       subtitle: Text("Rider's phone"),
                          //       leading: Icon(Icons.phone),
                          //       trailing: OutlinedButton(
                          //           onPressed: () {
                          //             _callRider(riderPhone);
                          //           },
                          //           child: Text('Call Rider')),
                          //     ),
                          //   ),
                          // ),
                        ],
                      ),
                Padding(
                  padding: const EdgeInsets.only(left: 12, top: 12),
                  child: Row(
                    children: const [
                      Text('Payment Detail',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: Colors.grey)),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 10, right: 10),
                  child: Card(
                    elevation: 0.1,
                    child: ListTile(
                      title: widget.orderModel.paymentType == 'Wallet'
                          ? const Text('Wallet')
                          : const Text('Cash on delivery'),
                      subtitle: const Text("Payment type"),
                      leading: const Icon(Icons.payment),
                      trailing:
                          Text('$currencySymbol${widget.orderModel.total}'),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 12, top: 12),
                  child: Row(
                    children: const [
                      Text('Delivery Detail',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: Colors.grey)),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                widget.orderModel.deliveryAddress != ''
                    ? Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 10, right: 10),
                            child: Card(
                              elevation: 0.1,
                              child: ListTile(
                                title: Text(widget.orderModel.deliveryAddress),
                                subtitle: const Text("Delivery Address"),
                                leading: const Icon(Icons.room),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 10, right: 10),
                            child: Card(
                              elevation: 0.1,
                              child: ListTile(
                                title: Text(widget.orderModel.houseNumber),
                                subtitle: const Text("House number"),
                                leading: const Icon(Icons.home),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 10, right: 10),
                            child: Card(
                              elevation: 0.1,
                              child: ListTile(
                                title: Text(widget.orderModel.closesBusStop),
                                subtitle: const Text("Closest Bus stop"),
                                leading: const Icon(Icons.bus_alert),
                              ),
                            ),
                          ),
                        ],
                      )
                    : const Padding(
                        padding: EdgeInsets.only(left: 10, right: 10),
                        child: Card(
                          elevation: 0.1,
                          child: ListTile(
                            title: Text('Pick Up'),
                            subtitle: Text("Delivery Address"),
                            leading: Icon(Icons.room),
                          ),
                        ),
                      ),
                Padding(
                  padding: const EdgeInsets.only(left: 12, top: 12),
                  child: Row(
                    children: const [
                      Text('Products',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: Colors.grey)),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                Column(
                    children: widget.orderModel.orders
                        .map((e) => Padding(
                              padding:
                                  const EdgeInsets.only(left: 10, right: 10),
                              child: Card(
                                elevation: 0.1,
                                child: ListTile(
                                  subtitle: Text(e.selected),
                                  leading: Text('QTY: ${e.quantity}'),
                                  title: Text(e.productName),
                                  trailing:
                                      Text('$currencySymbol${e.selectedPrice}'),
                                ),
                              ),
                            ))
                        .toList()),
                const SizedBox(height: 20),
                widget.orderModel.accept == false
                    ? Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: const Text('Back'))),
                      )
                    : Container(),
                const SizedBox(height: 20),
              ],
            ))),
      ),
    );
  }
}

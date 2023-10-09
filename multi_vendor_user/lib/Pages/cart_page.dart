import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shimmer/shimmer.dart';

import '../Model/formatter.dart';
import '../Model/products.dart';
import 'product_detail.dart';

class CartPage extends StatefulWidget {
  const CartPage({Key? key}) : super(key: key);

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  DocumentReference? userRef;
  bool showBottomSheet = true;
  bool showBottomSheetOnLoading = false;
  String currencySymbol = '';
  num subTotal = 0;
  num deliveryFee = 0;
  num couponReward = 0;
  bool couponStatus = false;
  bool pleaseWait = false;

  Future<void> _getUserDoc() async {
    final FirebaseAuth auth = FirebaseAuth.instance;
    final FirebaseFirestore firestore = FirebaseFirestore.instance;

    User? user = auth.currentUser;
    setState(() {
      userRef = firestore.collection('users').doc(user!.uid);
    });
  }

  Future<List<ProductsModel>> getMyCart() {
    return userRef!.collection('Cart').get().then((snapshot) {
      if (snapshot.docs.isEmpty) {
        userRef!
            .update({'CurrentMarketID': '', 'deliveryFee': 0}).then((value) {
          setState(() {
            showBottomSheet = false;
          });
        });
      }

      return snapshot.docs
          .map((doc) => ProductsModel.fromMap(doc.data(), doc.id))
          .toList();
    });
  }

  getSubTotal() {
    userRef!.collection('Cart').snapshots().listen((val) {
      num tempTotal = val.docs.fold(0, (tot, doc) => tot + doc.data()['price']);

      setState(() {
        subTotal = tempTotal -
            (couponStatus == true && couponReward != 0
                ? (couponReward * tempTotal / 100)
                : 0);
      });
    });
  }

  String coupon = '';
  getCouponStatus() {
    FirebaseFirestore.instance
        .collection('Coupon System')
        .doc('Coupon System')
        .snapshots()
        .listen((value) {
      setState(() {
        couponStatus = value['Status'];
      });
      getSubTotal();
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

  getDeliveryFee() {
    userRef!.snapshots().listen((val) {
      setState(() {
        deliveryFee = val['deliveryFee'];
        couponReward = val["Coupon Reward"];
      });
    });
  }

  @override
  void initState() {
    getCurrencySymbol();
    _getUserDoc();
    getCouponStatus();
    getDeliveryFee();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            iconTheme: Theme.of(context).iconTheme,
            titleTextStyle: TextStyle(color: Theme.of(context).indicatorColor),
            backgroundColor: Theme.of(context).colorScheme.background,
            centerTitle: true,
            elevation: 0,
            title: const Text(
              'My Cart',
            ).tr()),
        body: SingleChildScrollView(
          child: Column(
            children: [
              FutureBuilder<List<ProductsModel>>(
                future: getMyCart(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Column(
                      children: const [
                        SizedBox(height: 10),
                        Text('Something went wrong'),
                      ],
                    );
                  }

                  if (!snapshot.hasData) {
                    return Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16.0, vertical: 16.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        children: <Widget>[
                          Shimmer.fromColors(
                            baseColor: Colors.grey[300]!,
                            highlightColor: Colors.grey[100]!,
                            enabled: true,
                            child: ListView.builder(
                              shrinkWrap: true,
                              itemBuilder: (_, __) => const Padding(
                                padding: EdgeInsets.all(8.0),
                                child: SizedBox(
                                    height: 140,
                                    width: double.infinity,
                                    child: Card(
                                      elevation: 0,
                                    )),
                              ),
                              itemCount: 10,
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                  return snapshot.data?.isEmpty ?? true
                      ? Column(
                          children: [
                            Image.asset(
                              'assets/image/empty.png',
                              height: MediaQuery.of(context).size.height / 2,
                            ),
                            ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.orange),
                                onPressed: () {
                                  Navigator.of(context).pushNamed('/home');
                                },
                                child: const Text('Continue Shopping').tr())
                          ],
                        )
                      : ListView.builder(
                          itemCount: snapshot.data!.length,
                          physics: const BouncingScrollPhysics(),
                          shrinkWrap: true,
                          itemBuilder: (BuildContext buildContext, int index) {
                            ProductsModel productModel = snapshot.data![index];

                            return Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: InkWell(
                                onTap: () {
                                  Navigator.of(context).push(MaterialPageRoute(
                                      builder: (context) => ProductDetailsPage(
                                            currency: currencySymbol,
                                            marketID: productModel.marketID,
                                            productsModel: productModel,
                                          )));
                                },
                                child: SizedBox(
                                    height: 140,
                                    width: double.infinity,
                                    child: Card(
                                        elevation: 0,
                                        child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Image.network(
                                                      productModel.image1,
                                                      height: 60,
                                                      width: 60,
                                                    ),
                                                    Column(
                                                      children: [
                                                        SizedBox(
                                                          width: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .width /
                                                              3,
                                                          child: Text(
                                                            productModel.name,
                                                            maxLines: 1,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                            style: const TextStyle(
                                                                fontSize: 12,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold),
                                                            textAlign: TextAlign
                                                                .center,
                                                          ),
                                                        ),
                                                        Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceBetween,
                                                          children: [
                                                            const Text("Price:",
                                                                    style: TextStyle(
                                                                        fontSize:
                                                                            12,
                                                                        fontWeight:
                                                                            FontWeight.bold))
                                                                .tr(),
                                                            const SizedBox(
                                                                width: 10),
                                                            Text(
                                                                '$currencySymbol${Formatter().converter(productModel.price!.toDouble())}',
                                                                style:
                                                                    const TextStyle(
                                                                  fontSize: 14,
                                                                )),
                                                          ],
                                                        ),
                                                        Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceBetween,
                                                          children: [
                                                            const Text(
                                                                    "Selected Item:",
                                                                    style: TextStyle(
                                                                        fontSize:
                                                                            12,
                                                                        fontWeight:
                                                                            FontWeight.bold))
                                                                .tr(),
                                                            const SizedBox(
                                                                width: 10),
                                                            Text(
                                                                productModel
                                                                    .selected
                                                                    .toString(),
                                                                style:
                                                                    const TextStyle(
                                                                  fontSize: 14,
                                                                )),
                                                          ],
                                                        ),
                                                        Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .spaceBetween,
                                                            children: [
                                                              Text(
                                                                  '$currencySymbol${Formatter().converter(productModel.unitPrice1.toDouble())}',
                                                                  style: const TextStyle(
                                                                      fontSize:
                                                                          14,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold)),
                                                              const SizedBox(
                                                                  width: 20),
                                                              Text(
                                                                  '$currencySymbol${Formatter().converter(productModel.unitOldPrice1.toDouble())}',
                                                                  style: const TextStyle(
                                                                      color: Colors
                                                                          .grey,
                                                                      fontSize:
                                                                          14,
                                                                      decoration:
                                                                          TextDecoration
                                                                              .lineThrough,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold)),
                                                            ])
                                                      ],
                                                    ),
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              right: 10),
                                                      child: Column(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        children: [
                                                          IconButton(
                                                              iconSize: 20,
                                                              onPressed: () {
                                                                userRef!
                                                                    .collection(
                                                                        'Cart')
                                                                    .doc(productModel
                                                                        .uid)
                                                                    .update({
                                                                  'quantity':
                                                                      productModel
                                                                              .quantity! +
                                                                          1,
                                                                  'price': (productModel
                                                                              .quantity! +
                                                                          1) *
                                                                      productModel
                                                                          .selectedPrice!,
                                                                });
                                                              },
                                                              icon: const Icon(
                                                                  Icons.add)),
                                                          Text(productModel
                                                              .quantity
                                                              .toString()),
                                                          IconButton(
                                                              iconSize: 20,
                                                              onPressed: () {
                                                                if (productModel
                                                                        .quantity! <=
                                                                    1) {
                                                                  userRef!
                                                                      .collection(
                                                                          'Cart')
                                                                      .doc(productModel
                                                                          .uid)
                                                                      .delete()
                                                                      .then(
                                                                          (value) {
                                                                    Fluttertoast.showToast(
                                                                        msg: "Product has been deleted"
                                                                            .tr(),
                                                                        toastLength:
                                                                            Toast
                                                                                .LENGTH_SHORT,
                                                                        gravity:
                                                                            ToastGravity
                                                                                .TOP,
                                                                        timeInSecForIosWeb:
                                                                            1,
                                                                        fontSize:
                                                                            14.0);
                                                                  });
                                                                } else {
                                                                  userRef!
                                                                      .collection(
                                                                          'Cart')
                                                                      .doc(productModel
                                                                          .uid)
                                                                      .update({
                                                                    'quantity':
                                                                        productModel.quantity! -
                                                                            1,
                                                                    'price': (productModel.quantity! -
                                                                            1) *
                                                                        productModel
                                                                            .selectedPrice!
                                                                  });
                                                                }
                                                              },
                                                              icon: const Icon(
                                                                  Icons
                                                                      .remove)),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ]))),
                              ),
                            );
                          },
                        );
                },
              ),
              const SizedBox(
                height: 260,
              )
            ],
          ),
        ),
        bottomSheet: showBottomSheet == false
            ? null
            : SizedBox(
                height: couponStatus == true ? 230 : 190,
                width: double.infinity,
                child: Card(
                    elevation: 0,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(3.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text("SubTotal:",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14))
                                  .tr(),
                              Text(
                                  '$currencySymbol${Formatter().converter(subTotal.toDouble())}',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14))
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(3.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text("Delivery Fee:",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14))
                                  .tr(),
                              Text(
                                  '$currencySymbol${Formatter().converter(deliveryFee.toDouble())}',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14))
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(3.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text("Total:",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14))
                                  .tr(),
                              Text(
                                  '$currencySymbol${Formatter().converter((deliveryFee + subTotal).toDouble())}',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14))
                            ],
                          ),
                        ),
                        couponStatus == true
                            ? Padding(
                                padding: const EdgeInsets.all(3.0),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text("Coupon:",
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 14))
                                        .tr(),
                                    SizedBox(
                                      height: 50,
                                      width: 150,
                                      child: TextField(
                                          maxLength: 10,
                                          onChanged: (val) {
                                            setState(() {
                                              coupon = val;
                                            });
                                          },
                                          decoration: const InputDecoration(
                                              border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.all(
                                                          Radius.circular(
                                                              10))))),
                                    ),
                                  ],
                                ),
                              )
                            : const SizedBox(),
                        Padding(
                          padding: const EdgeInsets.only(right: 8, left: 8),
                          child: SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.orange),
                                onPressed: pleaseWait == true
                                    ? null
                                    : () {
                                        if (subTotal == 0) {
                                          Navigator.of(context)
                                              .pushNamed('/bottomNav');
                                        } else {
                                          if (coupon == '') {
                                            Navigator.of(context)
                                                .pushNamed('/checkout');
                                          } else {
                                            if (coupon != '') {
                                              FirebaseFirestore.instance
                                                  .collection('Coupons')
                                                  .where('coupon',
                                                      isEqualTo: coupon)
                                                  .get()
                                                  .then((value) {
                                                if (value.docs.isNotEmpty) {
                                                  for (var item in value.docs) {
                                                    setState(() {
                                                      pleaseWait = true;
                                                    });
                                                    Fluttertoast.showToast(
                                                        msg:
                                                            "Coupon reward added to your cart."
                                                                .tr(),
                                                        toastLength:
                                                            Toast.LENGTH_SHORT,
                                                        gravity:
                                                            ToastGravity.TOP,
                                                        timeInSecForIosWeb: 1,
                                                        fontSize: 14.0);
                                                    userRef!.update({
                                                      'Coupon Reward':
                                                          item['percentage']
                                                    }).then((value) {
                                                      setState(() {
                                                        pleaseWait = false;
                                                      });
                                                      Navigator.of(context)
                                                          .pushNamed(
                                                              '/checkout');
                                                    });
                                                  }
                                                } else {
                                                  Fluttertoast.showToast(
                                                      msg:
                                                          "Wrong coupon number."
                                                              .tr(),
                                                      toastLength:
                                                          Toast.LENGTH_SHORT,
                                                      gravity: ToastGravity.TOP,
                                                      timeInSecForIosWeb: 1,
                                                      fontSize: 14.0);
                                                }
                                              });
                                            }
                                          }
                                        }
                                      },
                                child: const Text('Check Out').tr()),
                          ),
                        )
                      ],
                    )),
              ));
  }
}

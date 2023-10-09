import 'package:animations/animations.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_countdown_timer/flutter_countdown_timer.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

import '../Model/formatter.dart';
import '../Model/products.dart';
import '../Pages/product_detail.dart';

class FlashSales extends StatefulWidget {
  final String marketID;

  const FlashSales({
    Key? key,
    required this.marketID,
  }) : super(key: key);

  @override
  State<FlashSales> createState() => _FlashSalesState();
}

class _FlashSalesState extends State<FlashSales> {
  Future<List<ProductsModel>> getMyProducts() {
    return FirebaseFirestore.instance
        .collection('Flash Sales Products')
        .where('marketID', isEqualTo: widget.marketID)
        .get()
        .then((snapshot) {
      return snapshot.docs
          .map((doc) => ProductsModel.fromMap(doc.data(), doc.id))
          .toList();
    });
  }

  String currencySymbol = '';
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
    _getUserDoc();
    getselectedMarket();
    getMarketDetails();
    super.initState();
  }

  DocumentReference? userRef;
  num deliveryFee = 0;
  Future<void> _getUserDoc() async {
    final FirebaseAuth auth = FirebaseAuth.instance;
    final FirebaseFirestore firestore = FirebaseFirestore.instance;

    User? user = auth.currentUser;
    setState(() {
      userRef = firestore.collection('users').doc(user!.uid);
    });
  }

  getMarketDetails() {
    FirebaseFirestore.instance
        .collection('Markets')
        .doc(widget.marketID)
        .get()
        .then((val) {
      setState(() {
        deliveryFee = val['Delivery Fee'];
      });
    });
  }

  num quantity = 1;
  String selectedProduct = '';
  updateQuantity(String product) {
    if (selectedProduct == '') {
      setState(() {
        selectedProduct = product;
      });
    }
    if (selectedProduct != '') {
      if (selectedProduct == product) {
        setState(() {
          quantity++;
        });
      } else {
        setState(() {
          selectedProduct = product;
          quantity = 1;
        });
      }
    }
  }

  String? currentMarketID;

  getselectedMarket() {
    if (userRef != null) {
      userRef!.snapshots().listen((value) {
        setState(() {
          currentMarketID = value['CurrentMarketID'];
        });
      });
    }
  }

  Future deleteCartCollection() async {
    userRef!.collection('Cart').get().then((snapshot) {
      for (DocumentSnapshot ds in snapshot.docs) {
        ds.reference.delete();
      }
    });
  }

  deleteVendorsID() {
    userRef!.update({'CurrentMarketID': '', 'deliveryFee': 0});
  }

  addToCart(
    ProductsModel productsModel,
  ) {
    if (currentMarketID == widget.marketID || currentMarketID == '') {
      userRef!
          .collection('Cart')
          .doc(
              '${widget.marketID}${productsModel.vendorId}${productsModel.name}unit1')
          .set(productsModel.toMap())
          .then((val) {
        Fluttertoast.showToast(
            msg: "Product has been added to your cart".tr(),
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.TOP,
            timeInSecForIosWeb: 1,
            
            fontSize: 14.0);
      });
      userRef!.update(
          {'CurrentMarketID': widget.marketID, 'deliveryFee': deliveryFee});
      updateQuantity(productsModel.name);
    } else {
      showModal(
          configuration: const FadeScaleTransitionConfiguration(
              transitionDuration: Duration(seconds: 1)),
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Image.asset(
                "assets/image/new cart.gif",
                height: 200,
              ),
              content: SingleChildScrollView(
                child: ListBody(
                  children: <Widget>[
                    const Text("Your Cart is not Empty").tr(),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton.icon(
                    onPressed: () {
                      Navigator.of(context).pop();
                      deleteVendorsID();
                      deleteCartCollection().then((_) {
                        Fluttertoast.showToast(
                            msg: "Your cart is empty".tr(),
                            toastLength: Toast.LENGTH_SHORT,
                            gravity: ToastGravity.TOP,
                            timeInSecForIosWeb: 1,
                            backgroundColor: Theme.of(context).primaryColor,
                            textColor: Colors.white,
                            fontSize: 14.0);
                      });
                    },
                    icon: const Icon(Icons.delete),
                    label: const Text("Empty").tr()),
                TextButton.icon(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    icon: const Icon(Icons.cancel),
                    label: const Text('No').tr()),
              ],
            );
          });
    }
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('Market UID is ${widget.marketID}');
    return FutureBuilder<List<ProductsModel>>(
        future: getMyProducts(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: SpinKitCircle(color: Colors.orange),
            );
          } else {
            return snapshot.data?.isEmpty ?? true
                ? Center(child: Image.asset('assets/image/empty.png'))
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
                            showMaterialModalBottomSheet(
                              bounce: true,
                              expand: true,
                              context: context,
                              backgroundColor: Colors.transparent,
                              builder: (context) => ProductDetailsPage(
                                currency: currencySymbol,
                                marketID: widget.marketID,
                                productsModel: productModel,
                              ),
                            );
                          },
                          child: SizedBox(
                              height: 110,
                              width: double.infinity,
                              child: Card(
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(5.0),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Flexible(
                                          flex: 6,
                                          child: Image.network(
                                            productModel.image1,
                                            height: 70,
                                            width: 70,
                                          ),
                                        ),
                                        Flexible(
                                          flex: 6,
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: [
                                              SizedBox(
                                                child: Center(
                                                  child: Text(productModel.name,
                                                      maxLines: 2,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      style: const TextStyle(
                                                          fontSize: 15,
                                                          fontWeight:
                                                              FontWeight.bold)),
                                                ),
                                              ),
                                              SizedBox(
                                                  child: Center(
                                                child: Text(
                                                  productModel.description,
                                                  maxLines: 2,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              )),
                                            ],
                                          ),
                                        ),
                                        Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Text(
                                                      '$currencySymbol${Formatter().converter(productModel.unitPrice1.toDouble())}',
                                                      style: const TextStyle(
                                                          fontSize: 15,
                                                          fontWeight:
                                                              FontWeight.bold)),
                                                  const SizedBox(width: 20),
                                                  Text(
                                                      '$currencySymbol${Formatter().converter(productModel.unitOldPrice1.toDouble())}',
                                                      style: const TextStyle(
                                                          color: Colors.grey,
                                                          fontSize: 15,
                                                          decoration:
                                                              TextDecoration
                                                                  .lineThrough,
                                                          fontWeight:
                                                              FontWeight.bold)),
                                                ]),
                                            CountdownTimer(
                                              textStyle:
                                                  const TextStyle(fontSize: 12),
                                              endTime: DateTime.parse(
                                                      productModel.endFlash!)
                                                  .millisecondsSinceEpoch,
                                              onEnd: () {
                                                FirebaseFirestore.instance
                                                    .collection(
                                                        'Flash Sales Products')
                                                    .doc(productModel.uid)
                                                    .delete();
                                              },
                                            ),
                                            IconButton(
                                                onPressed: () {
                                                  if (userRef == null) {
                                                    Navigator.of(context)
                                                        .pushNamed('/login');
                                                  } else {
                                                    addToCart(ProductsModel(
                                                        totalNumberOfUserRating:
                                                            productModel
                                                                .totalNumberOfUserRating,
                                                        totalRating: productModel
                                                            .totalRating,
                                                        productID: productModel
                                                            .productID,
                                                        price:quantity * productModel
                                                            .unitPrice1,
                                                        selectedPrice: productModel
                                                            .unitPrice1,
                                                        quantity: quantity,
                                                        selected: productModel
                                                            .unitname1,
                                                        description: productModel
                                                            .description,
                                                        marketID:
                                                            widget.marketID,
                                                        marketName: productModel
                                                            .marketName,
                                                        uid: productModel.uid,
                                                        name: productModel.name,
                                                        category: productModel
                                                            .category,
                                                        subCategory: productModel
                                                            .subCategory,
                                                        subSubCategory: productModel
                                                            .subSubCategory,
                                                        image1:
                                                            productModel.image1,
                                                        image2:
                                                            productModel.image2,
                                                        image3:
                                                            productModel.image3,
                                                        unitname1: productModel
                                                            .unitname1,
                                                        unitname2: productModel
                                                            .unitname2,
                                                        unitname3: productModel
                                                            .unitname3,
                                                        unitname4: productModel
                                                            .unitname4,
                                                        unitname5: productModel
                                                            .unitname5,
                                                        unitname6: productModel
                                                            .unitname6,
                                                        unitname7: productModel
                                                            .unitname7,
                                                        unitPrice1: productModel
                                                            .unitPrice1,
                                                        unitPrice2:
                                                            productModel.unitPrice2,
                                                        unitPrice3: productModel.unitPrice3,
                                                        unitPrice4: productModel.unitPrice4,
                                                        unitPrice5: productModel.unitPrice5,
                                                        unitPrice6: productModel.unitPrice6,
                                                        unitPrice7: productModel.unitPrice7,
                                                        unitOldPrice1: productModel.unitOldPrice1,
                                                        unitOldPrice2: productModel.unitOldPrice2,
                                                        unitOldPrice3: productModel.unitOldPrice3,
                                                        unitOldPrice4: productModel.unitOldPrice4,
                                                        unitOldPrice5: productModel.unitOldPrice5,
                                                        unitOldPrice6: productModel.unitOldPrice6,
                                                        unitOldPrice7: productModel.unitOldPrice7,
                                                        percantageDiscount: productModel.percantageDiscount,
                                                        vendorId: productModel.vendorId,
                                                        brandName: productModel.brandName));
                                                  }
                                                },
                                                icon: const Icon(
                                                  Icons.add,
                                                  color: Colors.grey,
                                                ))
                                          ],
                                        )
                                      ],
                                    ),
                                  ))),
                        ),
                      );
                    },
                  );
          }
        });
  }
}

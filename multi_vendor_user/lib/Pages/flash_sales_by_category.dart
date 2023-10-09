import 'package:badges/badges.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart' hide Badge;
import 'package:flutter_countdown_timer/flutter_countdown_timer.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

import '../Model/formatter.dart';
import '../Model/products.dart';
import '../Pages/product_detail.dart';
import '../Widgets/search.dart';

class FlashSalesByCategories extends StatefulWidget {
  final String category;

  const FlashSalesByCategories({
    Key? key,
    required this.category,
  }) : super(key: key);

  @override
  State<FlashSalesByCategories> createState() => _FlashSalesByCategoriesState();
}

class _FlashSalesByCategoriesState extends State<FlashSalesByCategories> {
  Future<List<ProductsModel>> getMyProducts() {
    return FirebaseFirestore.instance
        .collection('Flash Sales Products')
        .where('category', isEqualTo: widget.category)
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
    getCart();
    _getUserDoc();
    getselectedMarket();
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

  num cartQuantity = 0;

  getCart() {
    if (userRef != null) {
      userRef!.collection('Cart').snapshots().listen((val) {
        num tempTotal =
            val.docs.fold(0, (tot, doc) => tot + doc.data()['quantity']);
        setState(() {
          cartQuantity = tempTotal;
        });
      });
    }
  }

  String search ="Search For Markets on".tr();


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: Theme.of(context).iconTheme,
        titleTextStyle: TextStyle(color: Theme.of(context).indicatorColor),
        backgroundColor: Theme.of(context).colorScheme.background,
        elevation: 0,
        centerTitle: true,
        title: SizedBox(
            width: MediaQuery.of(context).size.width / 1.2,
            height: 40,
            child: TextField(
              readOnly: true,
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) =>
                        const SearchPage(category: "Markets")));
              },
              decoration: InputDecoration(
                filled: true,
                fillColor: const Color.fromARGB(255, 236, 230, 230),
                hintStyle:const TextStyle(color:Colors.black),
                hintText: '$search Olivette',
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.white),
                  borderRadius: BorderRadius.circular(15),
                ),
                enabledBorder: UnderlineInputBorder(
                  borderSide: const BorderSide(color: Colors.white),
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
            )),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: InkWell(
              onTap: () {
                if (userRef == null) {
                  Navigator.of(context).pushNamed('/login');
                } else {
                  Navigator.of(context).pushNamed('/cart');
                }
              },
              child: Container(
                height: 40,
                width: 40,
                decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color.fromARGB(255, 236, 230, 230)),
                child: Badge(
                 badgeStyle: const BadgeStyle( badgeColor: Colors.orange,),
                  badgeContent: Text(cartQuantity.toString(),
                      style: const TextStyle(color: Colors.white)),
                  child: const Icon(
                    Icons.shopping_cart,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
          )
        ],
      ),
      body: FutureBuilder<List<ProductsModel>>(
          future: getMyProducts(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(
                child: SpinKitCircle(color: Colors.orange),
              );
            } else {
              return snapshot.data?.isEmpty ?? true
                  ? Center(child: Image.asset('assets/image/empty.png'))
                  : GridView.builder(
                      //controller: _scrollController,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          mainAxisSpacing: MediaQuery.of(context).size.width >=
                                  1100
                              ? 10
                              : MediaQuery.of(context).size.width > 600 &&
                                      MediaQuery.of(context).size.width < 1200
                                  ? 5
                                  : 0,
                          crossAxisSpacing: MediaQuery.of(context).size.width >=
                                  1100
                              ? 10
                              : MediaQuery.of(context).size.width > 600 &&
                                      MediaQuery.of(context).size.width < 1200
                                  ? 5
                                  : 0,
                          crossAxisCount: MediaQuery.of(context).size.width >=
                                  1100
                              ? 4
                              : MediaQuery.of(context).size.width > 600 &&
                                      MediaQuery.of(context).size.width < 1200
                                  ? 3
                                  : 2,
                          childAspectRatio: MediaQuery.of(context).size.width >=
                                  1100
                              ? 1
                              : MediaQuery.of(context).size.width > 600 &&
                                      MediaQuery.of(context).size.width < 1200
                                  ? 0.9
                                  : 0.8),
                      itemCount: snapshot.data!.length,
                      physics: const BouncingScrollPhysics(),
                      shrinkWrap: true,
                      itemBuilder: (BuildContext buildContext, int index) {
                        ProductsModel productModel = snapshot.data![index];
                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: InkWell(
                            onTap: () {
                              if (MediaQuery.of(context).size.width >= 1100) {
                                showDialog(
                                    context: context,
                                    builder: (context) {
                                      return AlertDialog(
                                          content: SizedBox(
                                        width:
                                            MediaQuery.of(context).size.width /
                                                1.5,
                                        child: ProductDetailsPage(
                                          currency: currencySymbol,
                                          marketID: productModel.marketID,
                                          productsModel: productModel,
                                        ),
                                      ));
                                    });
                              } else {
                                showMaterialModalBottomSheet(
                                  bounce: true,
                                  expand: true,
                                  context: context,
                                  backgroundColor: Colors.transparent,
                                  builder: (context) => Padding(
                                    padding:
                                        MediaQuery.of(context).size.width >=
                                                1100
                                            ? const EdgeInsets.only(
                                                left: 200, right: 200)
                                            : const EdgeInsets.only(
                                                left: 0, right: 0),
                                    child: ProductDetailsPage(
                                      currency: currencySymbol,
                                      marketID: productModel.marketID,
                                      productsModel: productModel,
                                    ),
                                  ),
                                );
                              }
                            },
                            child: Card(
                                elevation: 0,
                                child: Stack(
                                  children: [
                                    Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceAround,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.stretch,
                                        children: [
                                          Image.network(
                                            productModel.image1,
                                            height: MediaQuery.of(context)
                                                        .size
                                                        .width >=
                                                    1100
                                                ? 120
                                                : MediaQuery.of(context)
                                                                .size
                                                                .width >
                                                            600 &&
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width <
                                                            1200
                                                    ? 120
                                                    : 120,
                                            width: double.infinity,
                                            fit: BoxFit.cover,
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Column(
                                              children: [
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Flexible(
                                                      flex: 5,
                                                      child: Text(
                                                          productModel.name,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          style: TextStyle(
                                                              fontSize: MediaQuery.of(
                                                                              context)
                                                                          .size
                                                                          .width >=
                                                                      1100
                                                                  ? 13
                                                                  : 10,
                                                          
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold)),
                                                    ),
                                                    productModel.totalNumberOfUserRating ==
                                                                0 &&
                                                            productModel
                                                                    .totalRating ==
                                                                0
                                                        ? const SizedBox()
                                                        : Flexible(
                                                            flex: MediaQuery.of(
                                                                            context)
                                                                        .size
                                                                        .width >=
                                                                    1100
                                                                ? 3
                                                                : MediaQuery.of(context).size.width >
                                                                            600 &&
                                                                        MediaQuery.of(context).size.width <
                                                                            1200
                                                                    ? 3
                                                                    : 4,
                                                            child: Row(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .end,
                                                                children: [
                                                                  RatingBarIndicator(
                                                                    rating: (productModel.totalRating /
                                                                            productModel.totalNumberOfUserRating)
                                                                        .roundToDouble(),
                                                                    itemBuilder:
                                                                        (context,
                                                                                index) =>
                                                                            const Icon(
                                                                      Icons
                                                                          .star,
                                                                      color: Colors
                                                                          .orange,
                                                                    ),
                                                                    itemCount:
                                                                        5,
                                                                    itemSize: 6,
                                                                    direction: Axis
                                                                        .horizontal,
                                                                  ),
                                                                  Text(
                                                                      ' ${(productModel.totalRating / productModel.totalNumberOfUserRating).roundToDouble()}',
                                                                      style: TextStyle(
                                                                          fontSize: MediaQuery.of(context).size.width >= 1100
                                                                              ? 10
                                                                              : MediaQuery.of(context).size.width > 600 && MediaQuery.of(context).size.width < 1200
                                                                                  ? 10
                                                                                  : 8,
                                                                       
                                                                          fontWeight: FontWeight.bold))
                                                                ]))
                                                  ],
                                                ),
                                                Row(
                                                  children: [
                                                    Flexible(
                                                      flex: 5,
                                                      child: Text(
                                                        productModel
                                                            .description,
                                                        maxLines: 1,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        style: TextStyle(
                                                          
                                                            fontSize: MediaQuery.of(
                                                                            context)
                                                                        .size
                                                                        .width >=
                                                                    1100
                                                                ? 10
                                                                : 8),
                                                      ),
                                                    ),
                                                    const Flexible(
                                                        flex: 1,
                                                        child: Text(''))
                                                  ],
                                                ),
                                                Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      Text(
                                                          '$currencySymbol${Formatter().converter(productModel.unitPrice1.toDouble())}',
                                                          style: TextStyle(
                                                           
                                                              fontSize: MediaQuery.of(
                                                                              context)
                                                                          .size
                                                                          .width >=
                                                                      1100
                                                                  ? 13
                                                                  : 12,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold)),
                                                      const SizedBox(width: 20),
                                                      CountdownTimer(
                                                        textStyle:
                                                            const TextStyle(
                                                                fontSize: 12),
                                                        endTime: DateTime.parse(
                                                                productModel
                                                                    .endFlash!)
                                                            .millisecondsSinceEpoch,
                                                        onEnd: () {
                                                          FirebaseFirestore
                                                              .instance
                                                              .collection(
                                                                  'Flash Sales Products')
                                                              .doc(productModel
                                                                  .uid)
                                                              .delete();
                                                        },
                                                      ),
                                                    ])
                                              ],
                                            ),
                                          ),
                                        ]),
                                    Align(
                                        alignment: Alignment.topRight,
                                        child: Padding(
                                          padding: const EdgeInsets.only(
                                              top: 10, right: 10),
                                          child: Container(
                                            color: Colors.orange,
                                            width: 50,
                                            height: 20,
                                            child: Center(
                                              child: Text(
                                                '-${productModel.percantageDiscount}%',
                                                style: const TextStyle(
                                                  fontSize: 13,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ))
                                  ],
                                )),
                          ),
                        );
                      },
                    );
            }
          }),
    );
  }
}

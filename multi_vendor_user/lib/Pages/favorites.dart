import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import '../Model/formatter.dart';
import '../Model/products.dart';
import '../Pages/product_detail.dart';

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({
    Key? key,
  }) : super(key: key);

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  DocumentReference? userRef;
  num deliveryFee = 0;

  Stream<List<ProductsModel>> getMyFavorite() {
    return userRef!.collection('Favorite').snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => ProductsModel.fromMap(doc.data(), doc.id))
          .toList();
    });
  }
  Stream<List<ProductsModel>> GetFav() {
    return userRef!.collection('Favorite').snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => ProductsModel.fromMap(doc.data(), doc.id))
          .toList();
    });
  }

  Future<void> _getUserDoc() async {
    final FirebaseAuth auth = FirebaseAuth.instance;
    final FirebaseFirestore firestore = FirebaseFirestore.instance;

    User? user = auth.currentUser;
    setState(() {
      userRef = firestore.collection('users').doc(user!.uid);
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
    super.initState();
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
          'Favorites',
        ).tr(),
      ),
      body: StreamBuilder<List<ProductsModel>>(
          stream: getMyFavorite(),
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
                                  marketID: productModel.marketID,
                                  productsModel: productModel,
                                ),
                              );
                            },
                            child: SizedBox(
                                height: 100,
                                width: double.infinity,
                                child: Card(
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15.0),
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
                                                  MainAxisAlignment.spaceAround,
                                              children: [
                                                SizedBox(
                                                  child: Center(
                                                    child: Text(
                                                        productModel.name,
                                                        maxLines: 2,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        style: const TextStyle(
                                                            fontSize: 15,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold)),
                                                  ),
                                                ),
                                                SizedBox(
                                                    child: Center(
                                                  child: Text(
                                                    productModel.description,
                                                    style: const TextStyle(
                                                      fontSize: 12,
                                                    ),
                                                    maxLines: 2,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                )),
                                                Center(
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      RatingBarIndicator(
                                                        rating: productModel
                                                                    .totalRating ==
                                                                0
                                                            ? 0
                                                            : productModel
                                                                    .totalRating /
                                                                productModel
                                                                    .totalNumberOfUserRating,
                                                        itemBuilder:
                                                            (context, index) =>
                                                                const Icon(
                                                          Icons.star,
                                                          color: Colors.orange,
                                                        ),
                                                        itemCount: 5,
                                                        itemSize: 12,
                                                        direction:
                                                            Axis.horizontal,
                                                      ),
                                                      const SizedBox(width: 5),
                                                      Text(
                                                          '(${productModel.totalNumberOfUserRating.toString()})',
                                                          style:
                                                              const TextStyle(
                                                                  fontSize: 12,
                                                                  color: Colors
                                                                      .grey)),
                                                    ],
                                                  ),
                                                ),
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
                                                                FontWeight
                                                                    .bold)),
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
                                                                FontWeight
                                                                    .bold)),
                                                  ]),
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
          }),
    );
  }
}

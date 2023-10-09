import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:easy_localization/easy_localization.dart';
import '../Model/formatter.dart';
import '../Model/products.dart';
import '../Pages/product_detail.dart';

class SearchProductPage extends StatefulWidget {
  final String? marketID;
  final String? category;
  const SearchProductPage(
      {Key? key, required this.marketID, required this.category})
      : super(key: key);

  @override
  State<SearchProductPage> createState() => _SearchProductPageState();
}

class _SearchProductPageState extends State<SearchProductPage> {
  final _searchController = TextEditingController();
  String currencySymbol = '';
  Future<List<ProductsModel>> getMyProducts() {
    return FirebaseFirestore.instance
        .collection('Products')
        .where('marketID', isEqualTo: widget.marketID)
        .where('category', isEqualTo: widget.category)
        .get()
        .then((snapshot) {
      return snapshot.docs
          .map((doc) => ProductsModel.fromMap(doc.data(), doc.id))
          .toList();
    });
  }

  Future<List<ProductsModel>> getAllProducts() {
    return FirebaseFirestore.instance
        .collection('Products')
        .get()
        .then((snapshot) {
      return snapshot.docs
          .map((doc) => ProductsModel.fromMap(doc.data(), doc.id))
          .toList();
    });
  }

  Future<List<ProductsModel>> getByCategoryProducts() {
    return FirebaseFirestore.instance
        .collection('Products')
        .where('category', isEqualTo: widget.category)
        .get()
        .then((snapshot) {
      return snapshot.docs
          .map((doc) => ProductsModel.fromMap(doc.data(), doc.id))
          .toList();
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

  @override
  void initState() {
    super.initState();
    getCurrencySymbol();
  }

  String displayName = '';
  getList(int itemList) {
    if (displayName == '') {
      return 0;
    } else {
      return itemList;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            actions: const [],
            automaticallyImplyLeading: false,
            backgroundColor: Colors.white12,
            expandedHeight: 200,
            flexibleSpace: FlexibleSpaceBar(
              collapseMode: CollapseMode.pin,
              centerTitle: true,
              background: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(
                      height: 50,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.fromLTRB(5, 0, 97, 0),
                              child: const Text(
                                'search',
                                style: TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.bold),
                                textAlign: TextAlign.start,
                              ).tr(),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child:
                                  const Text('ordered by market Products').tr(),
                            ),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.only(right: 30),
                          child: InkWell(
                            onTap: () {
                              Navigator.of(context).pop();
                            },
                            child: const Icon(
                              Icons.close,
                              size: 30,
                            ),
                          ),
                        )
                      ],
                    ),
                    const SizedBox(height: 30),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
                      child: SizedBox(
                        height: 50,
                        width: MediaQuery.of(context).size.width / 1,
                        child: TextField(
                            onChanged: (value) {
                              setState(() {
                                displayName = value.toLowerCase();
                              });
                            },
                            controller: _searchController,
                            autofocus: true,
                            style: const TextStyle(color: Colors.grey),
                            decoration: InputDecoration(
                              focusColor: Colors.grey,
                              hintText: 'search for market products'.tr(),
                              hintStyle: const TextStyle(color: Colors.grey),
                              prefixIcon: Icon(
                                Icons.search,
                                size: 30,
                                color: Colors.blue.shade800,
                              ),
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
                            )),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SliverFillRemaining(
              child: ListView(
            shrinkWrap: true,
            scrollDirection: Axis.vertical,
            physics: const BouncingScrollPhysics(),
            children: [
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: const Text(
                  'Search Results',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.start,
                ).tr(),
              ),
              displayName == ''
                  ? Container()
                  : FutureBuilder<List<ProductsModel>>(
                      future: widget.marketID == '' && widget.category == ''
                          ? getAllProducts()
                          : widget.category != '' && widget.marketID == ''
                              ? getByCategoryProducts()
                              : widget.category != '' && widget.marketID != ''
                                  ? getMyProducts()
                                  : getAllProducts(),
                      builder: (context, snapshot) {
                        if (snapshot.hasError) {
                          return Column(
                            children: const [
                              SizedBox(height: 10),
                              Text('Something went wrong'),
                            ],
                          );
                        } else if (snapshot.hasData) {
                          return ListView.builder(
                              itemCount: snapshot.data!.length,
                              physics: const BouncingScrollPhysics(),
                              shrinkWrap: true,
                              itemBuilder:
                                  (BuildContext buildContext, int index) {
                                ProductsModel productModel =
                                    snapshot.data![index];
                                return productModel.name
                                        .toLowerCase()
                                        .contains(displayName)
                                    ? Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: InkWell(
                                          onTap: () {
                                            Navigator.of(context).push(
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        ProductDetailsPage(
                                                          currency:
                                                              currencySymbol,
                                                          marketID: productModel
                                                              .marketID,
                                                          productsModel:
                                                              productModel,
                                                        )));
                                          },
                                          child: SizedBox(
                                              height: 140,
                                              width: double.infinity,
                                              child: Card(
                                                  elevation: 0,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            15.0),
                                                  ),
                                                  child: Column(children: [
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              8.0),
                                                      child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        children: [
                                                          Image.network(
                                                            productModel.image1,
                                                            height: 100,
                                                            width: 100,
                                                            fit: BoxFit.cover,
                                                          ),
                                                          Column(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .spaceBetween,
                                                            children: [
                                                              SizedBox(
                                                                width: MediaQuery.of(
                                                                            context)
                                                                        .size
                                                                        .width /
                                                                    2,
                                                                child: Text(
                                                                    productModel
                                                                        .name,
                                                                    maxLines: 2,
                                                                    textAlign:
                                                                        TextAlign
                                                                            .center,
                                                                    overflow:
                                                                        TextOverflow
                                                                            .ellipsis,
                                                                    style: const TextStyle(
                                                                        fontSize:
                                                                            15,
                                                                        fontWeight:
                                                                            FontWeight.bold)),
                                                              ),
                                                              SizedBox(
                                                                  width: MediaQuery.of(
                                                                              context)
                                                                          .size
                                                                          .width /
                                                                      2,
                                                                  child: Text(
                                                                    productModel
                                                                        .description,
                                                                    maxLines: 2,
                                                                    overflow:
                                                                        TextOverflow
                                                                            .ellipsis,
                                                                    textAlign:
                                                                        TextAlign
                                                                            .center,
                                                                  )),
                                                              Row(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .spaceBetween,
                                                                  children: [
                                                                    Text(
                                                                        '$currencySymbol${Formatter().converter(productModel.unitPrice1.toDouble())}',
                                                                        style: const TextStyle(
                                                                            fontSize:
                                                                                18,
                                                                            fontWeight:
                                                                                FontWeight.bold)),
                                                                    const SizedBox(
                                                                        width:
                                                                            20),
                                                                    Text(
                                                                        '$currencySymbol${Formatter().converter(productModel.unitOldPrice1.toDouble())}',
                                                                        style: const TextStyle(
                                                                            color: Colors
                                                                                .grey,
                                                                            fontSize:
                                                                                18,
                                                                            decoration:
                                                                                TextDecoration.lineThrough,
                                                                            fontWeight: FontWeight.bold)),
                                                                  ]),
                                                              Center(
                                                                child: Row(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .center,
                                                                  children: [
                                                                    RatingBarIndicator(
                                                                      rating: productModel.totalRating ==
                                                                              0
                                                                          ? 0
                                                                          : productModel.totalRating /
                                                                              productModel.totalNumberOfUserRating,
                                                                      itemBuilder:
                                                                          (context, index) =>
                                                                              const Icon(
                                                                        Icons
                                                                            .star,
                                                                        color: Colors
                                                                            .orange,
                                                                      ),
                                                                      itemCount:
                                                                          5,
                                                                      itemSize:
                                                                          12,
                                                                      direction:
                                                                          Axis.horizontal,
                                                                    ),
                                                                    const SizedBox(
                                                                        width:
                                                                            5),
                                                                    Text(
                                                                        '(${productModel.totalNumberOfUserRating.toString()})',
                                                                        style: const TextStyle(
                                                                            fontSize:
                                                                                12,
                                                                            color:
                                                                                Colors.grey)),
                                                                  ],
                                                                ),
                                                              ),
                                                            ],
                                                          )
                                                        ],
                                                      ),
                                                    ),
                                                  ]))),
                                        ),
                                      )
                                    : Container();
                              });
                        } else {
                          return const Center(
                              child: SpinKitCircle(color: Colors.orange));
                        }
                      })
            ],
          ))
        ],
      ),
    );
  }
}

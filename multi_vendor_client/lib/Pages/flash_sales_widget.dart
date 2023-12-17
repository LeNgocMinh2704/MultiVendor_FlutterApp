import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_countdown_timer/flutter_countdown_timer.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:vendor/Pages/product_detail.dart';
import '../Model/formatter.dart';
import '../Model/products.dart';
import '../Widget/add_flash_sales_from_page.dart';

class FlashSalePage extends StatefulWidget {
  final String vendorID;
  const FlashSalePage({Key? key, required this.vendorID}) : super(key: key);

  @override
  State<FlashSalePage> createState() => _FlashSalesListState();
}

class _FlashSalesListState extends State<FlashSalePage> {
  String? market;
  List<String> markets = ['All'];
  Stream<List<ProductsModel>> getMyProducts() {
    return FirebaseFirestore.instance
        .collection('Flash Sales Products')
        .where('vendorId', isEqualTo: widget.vendorID)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => ProductsModel.fromMap(doc.data(), doc.id))
          .toList();
    });
  }

  Stream<List<ProductsModel>> getMyProductsByMarketName(String market) {
    return FirebaseFirestore.instance
        .collection('Flash Sales Products')
        .where('vendorId', isEqualTo: widget.vendorID)
        .where('marketName', isEqualTo: market)
        .snapshots()
        .map((snapshot) {
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
    getMarkets();
    super.initState();
  }

  getMarkets() {
    final FirebaseAuth auth = FirebaseAuth.instance;

    User? user = auth.currentUser;
    List<String> allMarkets = ['All'];
    FirebaseFirestore.instance
        .collection('Markets')
        .where('Vendor ID', isEqualTo: user!.uid)
        .snapshots()
        .listen((event) {
      for (var item in event.docs) {
        allMarkets.add(item['Market Name']);
        setState(() {
          markets = allMarkets;
        });
      }
    });
  }

  dynamic themeMode;
  getThemeDetail() async {
    SharedPreferences.getInstance().then((prefs) {
      var lightModeOn = prefs.getBool('lightMode');
      setState(() {
        themeMode = lightModeOn!;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    getThemeDetail();
    return Scaffold(
      floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.orange,
          onPressed: () {
            Navigator.of(context).push(MaterialPageRoute(
                builder: (context) =>
                    AddFlashSalesFromPage(vendorID: widget.vendorID)));
          },
          child: const Icon(Icons.add)),
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Flash Sales').tr(),
        elevation: 0,
        //  backgroundColor: Colors.blue,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: DropdownButtonHideUnderline(
              child: DropdownButton2(
                style: const TextStyle(color: Colors.white),
                customButton: const Icon(
                  Icons.filter_list,
                  size: 35,
                  color: Colors.white,
                ),
                // customItemsIndexes: const [3],
                // customItemsHeight: 50,
                items: markets
                    .map((item) => DropdownMenuItem<String>(
                          value: item,
                          child: Text(
                            item,
                            style: TextStyle(
                                fontSize: 12,
                                color: themeMode == false
                                    ? Colors.white
                                    : const Color.fromARGB(255, 0, 0, 0)),
                          ),
                        ))
                    .toList(),
                value: market,
                onChanged: (value) {
                  setState(() {
                    market = value;
                  });
                },
                itemPadding: const EdgeInsets.only(left: 16, right: 16),
                dropdownWidth: 160,
                dropdownPadding: const EdgeInsets.symmetric(vertical: 6),
                dropdownDecoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                ),
                dropdownElevation: 8,
                offset: const Offset(0, 8),
              ),
            ),
          ),
        ],
      ),
      body: StreamBuilder<List<ProductsModel>>(
          stream: market == null || market == 'All'
              ? getMyProducts()
              : getMyProductsByMarketName(market!),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return GridView.builder(
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
                          height: 210,
                          child: Column(children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Image.network(
                                    productModel.image1 == ''
                                        ? 'https://pixsector.com/cache/517d8be6/av5c8336583e291842624.png'
                                        : productModel.image1,
                                    height: 110,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  Row(
                                    children: [
                                      Flexible(
                                        flex: 5,
                                        child: Text(productModel.name,
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                                fontSize: 13,
                                                fontWeight: FontWeight.bold)),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Flexible(
                                          flex: 5,
                                          child: Text(
                                            productModel.description,
                                            style: const TextStyle(
                                              fontSize: 10,
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          )),
                                    ],
                                  ),
                                  Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                            '$currencySymbol${Formatter().converter(productModel.unitPrice1.toDouble())}',
                                            style: const TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold)),
                                        const SizedBox(width: 20),
                                        Text(
                                            '$currencySymbol${Formatter().converter(productModel.unitOldPrice1.toDouble())}',
                                            style: const TextStyle(
                                                color: Colors.grey,
                                                fontSize: 12,
                                                decoration:
                                                    TextDecoration.lineThrough,
                                                fontWeight: FontWeight.bold)),
                                      ])
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 8, right: 8),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  InkWell(
                                      onTap: () {
                                        showDialog(
                                            context: context,
                                            builder: (builder) {
                                              return AlertDialog(
                                                title: Text(productModel.name),
                                                content: const Text(
                                                        'Are you sure you want to delete this product?')
                                                    .tr(),
                                                actions: [
                                                  InkWell(
                                                      onTap: () {
                                                        FirebaseFirestore
                                                            .instance
                                                            .collection(
                                                                'Flash Sales Products')
                                                            .doc(productModel
                                                                .uid)
                                                            .delete()
                                                            .then((value) {
                                                          Navigator.pop(
                                                              context);
                                                          Fluttertoast.showToast(
                                                              msg:
                                                                  "Product has been deleted Successfully"
                                                                      .tr(),
                                                              toastLength: Toast
                                                                  .LENGTH_SHORT,
                                                              gravity:
                                                                  ToastGravity
                                                                      .TOP,
                                                              timeInSecForIosWeb:
                                                                  1,
                                                              fontSize: 14.0);
                                                        });
                                                      },
                                                      child: const Text('Yes')
                                                          .tr()),
                                                  const SizedBox(width: 50),
                                                  InkWell(
                                                      onTap: () {
                                                        Navigator.of(context)
                                                            .pop();
                                                      },
                                                      child:
                                                          const Text('No').tr())
                                                ],
                                              );
                                            });
                                      },
                                      child: const Icon(Icons.delete)),
                                  CountdownTimer(
                                    endTime:
                                        DateTime.parse(productModel.endFlash!)
                                            .millisecondsSinceEpoch,
                                    // onEnd: onEnd,
                                  ),
                                ],
                              ),
                            )
                          ])),
                    ),
                  );
                },
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                  crossAxisCount: MediaQuery.of(context).size.width >= 1100
                      ? 4
                      : MediaQuery.of(context).size.width > 600 &&
                              MediaQuery.of(context).size.width < 1200
                          ? 3
                          : 2,
                  childAspectRatio: MediaQuery.of(context).size.width >= 1100
                      ? (1 / 0.97)
                      : (0.8),
                ),
              );
            } else {
              return Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                    horizontal: 16.0, vertical: 16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  children: <Widget>[
                    Expanded(
                      child: Shimmer.fromColors(
                        baseColor: Colors.grey[300]!,
                        highlightColor: Colors.grey[100]!,
                        enabled: true,
                        child: GridView.builder(
                          itemBuilder: (_, __) => Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: SizedBox(
                                height: 190,
                                width: double.infinity,
                                child: Card(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15.0),
                                  ),
                                )),
                          ),
                          itemCount: 24,
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            mainAxisSpacing: 10,
                            crossAxisSpacing: 10,
                            crossAxisCount: MediaQuery.of(context).size.width >=
                                    1100
                                ? 4
                                : MediaQuery.of(context).size.width > 600 &&
                                        MediaQuery.of(context).size.width < 1200
                                    ? 3
                                    : 2,
                            childAspectRatio:
                                MediaQuery.of(context).size.width >= 1100
                                    ? (1 / 0.97)
                                    : (0.8),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }
          }),
    );
  }
}

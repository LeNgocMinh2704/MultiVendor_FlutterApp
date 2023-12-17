import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_countdown_timer/flutter_countdown_timer.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:easy_localization/easy_localization.dart';
import '../Model/formatter.dart';
import '../Model/products.dart';
import '../Pages/product_detail.dart';

class FlashSalesList extends StatefulWidget {
  final String marketID;
  const FlashSalesList({Key? key, required this.marketID}) : super(key: key);

  @override
  State<FlashSalesList> createState() => _FlashSalesListState();
}

class _FlashSalesListState extends State<FlashSalesList> {
  Stream<List<ProductsModel>> getMyProducts() {
    return FirebaseFirestore.instance
        .collection('Flash Sales Products')
        .where('marketID', isEqualTo: widget.marketID)
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
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<ProductsModel>>(
        stream: getMyProducts(),
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
            return const Center(
              child: SpinKitCircle(color: Colors.orange),
            );
          } else {
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
                        height: 190,
                        child: Card(
                            elevation: 1,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15.0),
                            ),
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
                                                  decoration: TextDecoration
                                                      .lineThrough,
                                                  fontWeight: FontWeight.bold)),
                                        ])
                                  ],
                                ),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.only(left: 8, right: 8),
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
                                                  title:
                                                      Text(productModel.name),
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
                                                        child: const Text('No')
                                                            .tr())
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
                            ]))),
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
          }
        });
  }
}

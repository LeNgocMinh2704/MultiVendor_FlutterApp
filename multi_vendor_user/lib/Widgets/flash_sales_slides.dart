import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_countdown_timer/flutter_countdown_timer.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:gap/gap.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:shimmer/shimmer.dart';
import '../../Model/products.dart';
import '../Model/formatter.dart';
import '../Pages/product_detail.dart';

class FlashSalesSlides extends StatefulWidget {
  final String category;
  const FlashSalesSlides({
    Key? key,
    required this.category,
  }) : super(key: key);

  @override
  State<FlashSalesSlides> createState() => _FlashSalesSlidesState();
}

class _FlashSalesSlidesState extends State<FlashSalesSlides> {
  Future<List<ProductsModel>> getMyProducts() {
    return FirebaseFirestore.instance
        .collection('Flash Sales Products')
        .where('category', isEqualTo: widget.category)
        .limit(6)
        .get()
        .then((snapshot) {
      return snapshot.docs
          .map((doc) => ProductsModel.fromMap(doc.data(), doc.id))
          .toList();
    });
  }

  String currencySymbol = '';
  bool listview = true;
  bool gridview = false;

  getCurrencySymbol() {
    FirebaseFirestore.instance
        .collection('Currency Settings')
        .doc('Currency Settings')
        .get()
        .then((value) {
      if (mounted) {
        setState(() {
          currencySymbol = value['Currency symbol'];
        });
      }
    });
  }

  @override
  void initState() {
    getCurrencySymbol();
    super.initState();
  }

  final CarouselController controller = CarouselController();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<ProductsModel>>(
        future: getMyProducts(),
        builder: (context, snapshot) {
          if (snapshot.data?.isEmpty ?? true) {
            return SizedBox(
              width: double.infinity,
              child: Column(
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  const Gap(15),
                  Expanded(
                    child: Shimmer.fromColors(
                      baseColor: Colors.grey[300]!,
                      highlightColor: Colors.grey[100]!,
                      enabled: true,
                      child: ListView.builder(
                        shrinkWrap: true,
                        scrollDirection: Axis.horizontal,
                        itemBuilder: (_, __) => SizedBox(
                            height: 270,
                            width: 180,
                            child: Padding(
                              padding:
                                  const EdgeInsets.only(left: 10, right: 10),
                              child: Column(
                                children: [
                                  Container(
                                    height: MediaQuery.of(context).size.width >=
                                            1100
                                        ? 120
                                        : MediaQuery.of(context).size.width >
                                                    600 &&
                                                MediaQuery.of(context)
                                                        .size
                                                        .width <
                                                    1200
                                            ? 150
                                            : 150,
                                    decoration: const BoxDecoration(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(20)),
                                        color: Colors.white),
                                  ),
                                  const SizedBox(height: 10),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 10),
                                    child: Container(
                                        height: 10,
                                        width: 100,
                                        color: Colors.white),
                                  ),
                                  const SizedBox(height: 10),
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        left: 10, right: 10),
                                    child: Row(
                                      children: [
                                        Flexible(
                                          flex: 3,
                                          child: Container(
                                              height: 10,
                                              width: 200,
                                              color: Colors.white),
                                        ),
                                        const SizedBox(width: 10),
                                        Flexible(
                                          flex: 5,
                                          child: Container(
                                              height: 10,
                                              width: 200,
                                              color: Colors.white),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            )),
                        itemCount: 8,
                      ),
                    ),
                  ),
                ],
              ),
            );
          } else if (snapshot.hasData) {
            return Stack(
              children: [
                SizedBox(
                  height: 270,
                  width: double.infinity,
                  child: CarouselSlider.builder(
                    carouselController: controller,
                    itemCount: snapshot.data!.length,
                    itemBuilder: (BuildContext buildContext, int index,
                        int pageViewIndex) {
                      ProductsModel productModel = snapshot.data![index];
                      return Column(
                        children: [
                          Card(
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15.0),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: InkWell(
                                  onTap: () {
                                    if (MediaQuery.of(context).size.width >=
                                        1100) {
                                      showDialog(
                                          context: context,
                                          builder: (context) {
                                            return AlertDialog(
                                                content: SizedBox(
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width /
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
                                          padding: MediaQuery.of(context)
                                                      .size
                                                      .width >=
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
                                  child: SizedBox(
                                      child: Card(
                                          elevation: 0,
                                          child: Stack(
                                            children: [
                                              Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceAround,
                                                  children: [
                                                    Image.network(
                                                      productModel.image1,
                                                      height: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .width >=
                                                              1100
                                                          ? 90
                                                          : MediaQuery.of(context)
                                                                          .size
                                                                          .width >
                                                                      600 &&
                                                                  MediaQuery.of(
                                                                              context)
                                                                          .size
                                                                          .width <
                                                                      1200
                                                              ? 120
                                                              : 120,
                                                      width: double.infinity,
                                                      fit: BoxFit.cover,
                                                    ),
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              8.0),
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
                                                                    productModel
                                                                        .name,
                                                                    overflow:
                                                                        TextOverflow
                                                                            .ellipsis,
                                                                    style: TextStyle(
                                                                        fontSize: MediaQuery.of(context).size.width >=
                                                                                1100
                                                                            ? 13
                                                                            : 12,
                                                                        fontWeight:
                                                                            FontWeight.bold)),
                                                              ),
                                                              productModel.totalNumberOfUserRating ==
                                                                          0 &&
                                                                      productModel
                                                                              .totalRating ==
                                                                          0
                                                                  ? const SizedBox()
                                                                  : Flexible(
                                                                      flex: 3,
                                                                      child: Row(
                                                                          mainAxisAlignment:
                                                                              MainAxisAlignment.end,
                                                                          children: [
                                                                            RatingBarIndicator(
                                                                              rating: (productModel.totalRating / productModel.totalNumberOfUserRating).roundToDouble(),
                                                                              itemBuilder: (context, index) => const Icon(
                                                                                Icons.star,
                                                                                color: Colors.orange,
                                                                              ),
                                                                              itemCount: 5,
                                                                              itemSize: 10,
                                                                              direction: Axis.horizontal,
                                                                            ),
                                                                            Text(' ${(productModel.totalRating / productModel.totalNumberOfUserRating).roundToDouble()}',
                                                                                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold))
                                                                          ]))
                                                            ],
                                                          ),
                                                          const Gap(5),
                                                          Row(
                                                            children: [
                                                              Flexible(
                                                                flex: 5,
                                                                child: Text(
                                                                  productModel
                                                                      .description,
                                                                  maxLines: 1,
                                                                  overflow:
                                                                      TextOverflow
                                                                          .ellipsis,
                                                                  style: TextStyle(
                                                                      color: Colors
                                                                          .grey,
                                                                      fontSize: MediaQuery.of(context).size.width >=
                                                                              1100
                                                                          ? 10
                                                                          : 10),
                                                                ),
                                                              ),
                                                              const Flexible(
                                                                  flex: 1,
                                                                  child:
                                                                      Text(''))
                                                            ],
                                                          ),
                                                          const Gap(2),
                                                          Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .spaceBetween,
                                                              children: [
                                                                Text(
                                                                    '$currencySymbol${Formatter().converter(productModel.unitPrice1.toDouble())}',
                                                                    style: TextStyle(
                                                                        fontSize: MediaQuery.of(context).size.width >=
                                                                                1100
                                                                            ? 13
                                                                            : 12,
                                                                        fontWeight:
                                                                            FontWeight.bold)),
                                                                const SizedBox(
                                                                    width: 20),
                                                                CountdownTimer(
                                                                  textStyle:
                                                                      const TextStyle(
                                                                          fontSize:
                                                                              12),
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
                                                    padding:
                                                        const EdgeInsets.only(
                                                            top: 10, right: 10),
                                                    child: Container(
                                                      color: Colors.orange,
                                                      width: 50,
                                                      height: 20,
                                                      child: Center(
                                                        child: Text(
                                                          '-${productModel.percantageDiscount}%',
                                                          style:
                                                              const TextStyle(
                                                            fontSize: 13,
                                                            color: Colors.white,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ))
                                            ],
                                          ))),
                                ),
                              )),
                        ],
                      );
                    },
                    options: CarouselOptions(
                      enlargeStrategy: CenterPageEnlargeStrategy.height,
                      initialPage: MediaQuery.of(context).size.width >= 1100
                          ? 2
                          : MediaQuery.of(context).size.width > 600 &&
                                  MediaQuery.of(context).size.width < 1200
                              ? 2
                              : 1,
                      disableCenter: true,
                      enableInfiniteScroll: false,
                      viewportFraction:
                          MediaQuery.of(context).size.width >= 1100
                              ? 0.23
                              : MediaQuery.of(context).size.width > 600 &&
                                      MediaQuery.of(context).size.width < 1200
                                  ? 0.3
                                  : 0.52,
                    ),
                  ),
                ),
                Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      iconSize: 30,
                      onPressed: () {
                        controller.previousPage();
                      },
                      icon: Container(
                          height: 50,
                          width: 50,
                          decoration: const BoxDecoration(
                            color: Colors.orange,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.chevron_left)),
                      color: Colors.white,
                    )),
                Align(
                    alignment: Alignment.centerRight,
                    child: IconButton(
                      iconSize: 30,
                      onPressed: () {
                        controller.nextPage();
                      },
                      icon: Container(
                          height: 50,
                          width: 50,
                          decoration: const BoxDecoration(
                            color: Colors.orange,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.chevron_right)),
                      color: Colors.white,
                    )),
              ],
            );
          } else {
            return SizedBox(
              width: double.infinity,
              child: Column(
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  const Gap(15),
                  Expanded(
                    child: Shimmer.fromColors(
                      baseColor: Colors.grey[300]!,
                      highlightColor: Colors.grey[100]!,
                      enabled: true,
                      child: ListView.builder(
                        shrinkWrap: true,
                        scrollDirection: Axis.horizontal,
                        itemBuilder: (_, __) => SizedBox(
                            height: 270,
                            width: 180,
                            child: Padding(
                              padding:
                                  const EdgeInsets.only(left: 10, right: 10),
                              child: Column(
                                children: [
                                  Container(
                                    height: MediaQuery.of(context).size.width >=
                                            1100
                                        ? 120
                                        : MediaQuery.of(context).size.width >
                                                    600 &&
                                                MediaQuery.of(context)
                                                        .size
                                                        .width <
                                                    1200
                                            ? 150
                                            : 150,
                                    decoration: const BoxDecoration(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(20)),
                                        color: Colors.white),
                                  ),
                                  const SizedBox(height: 10),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 10),
                                    child: Container(
                                        height: 10,
                                        width: 100,
                                        color: Colors.white),
                                  ),
                                  const SizedBox(height: 10),
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        left: 10, right: 10),
                                    child: Row(
                                      children: [
                                        Flexible(
                                          flex: 3,
                                          child: Container(
                                              height: 10,
                                              width: 200,
                                              color: Colors.white),
                                        ),
                                        const SizedBox(width: 10),
                                        Flexible(
                                          flex: 5,
                                          child: Container(
                                              height: 10,
                                              width: 200,
                                              color: Colors.white),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            )),
                        itemCount: 8,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }
        });
  }
}

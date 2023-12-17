// ignore_for_file: avoid_print

import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shimmer/shimmer.dart';
import 'package:easy_localization/easy_localization.dart';
import '../Model/market.dart';
import '../Pages/market_detail.dart';

class MarketWidgetSlider extends StatefulWidget {
  final String category;
  const MarketWidgetSlider({
    Key? key,
    required this.category,
  }) : super(key: key);

  @override
  State<MarketWidgetSlider> createState() => _MarketWidgetSliderState();
}

class _MarketWidgetSliderState extends State<MarketWidgetSlider> {
  Future<List<MarketModel>> getMarkets() {
    return FirebaseFirestore.instance
        .collection('Markets')
        .where('Approval', isEqualTo: true)
        .where('Category', isEqualTo: widget.category)
        .limit(5)
        .get()
        .then((event) => event.docs
            .map((e) => MarketModel.fromMap(e.data(), e.id))
            .toList());
  }

  num distance = 0;

  final CarouselController controller = CarouselController();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<MarketModel>>(
        future: getMarkets(),
        builder: (context, snapshot) {
          if (snapshot.data?.isEmpty ?? true) {
            return SizedBox(
              width: double.infinity,
              child: Column(
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  Expanded(
                    child: Shimmer.fromColors(
                      baseColor: Colors.grey[300]!,
                      highlightColor: Colors.grey[100]!,
                      enabled: true,
                      child: ListView.builder(
                        shrinkWrap: true,
                        scrollDirection: Axis.horizontal,
                        itemBuilder: (_, __) => SizedBox(
                            height: 120,
                            width: 250,
                            child: Padding(
                              padding:
                                  const EdgeInsets.only(left: 10, right: 10),
                              child: Column(
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    height: 80,
                                  ),
                                  const SizedBox(height: 10),
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        left: 10, right: 10),
                                    child: Row(
                                      children: [
                                        Flexible(
                                          flex: 5,
                                          child: Container(
                                              height: 10,
                                              width: 200,
                                              color: Colors.white),
                                        ),
                                        const SizedBox(width: 10),
                                        Flexible(
                                          flex: 3,
                                          child: Container(
                                              height: 10,
                                              width: 200,
                                              color: Colors.white),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 10),
                                    child: Row(
                                      children: [
                                        Container(
                                            height: 10,
                                            width: 100,
                                            color: Colors.white),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            )),
                        itemCount: 5,
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
                  width: double.infinity,
                  child: CarouselSlider.builder(
                    carouselController: controller,
                    itemCount: snapshot.data!.length,
                    itemBuilder: (BuildContext buildContext, int index,
                        int pageViewIndex) {
                      MarketModel marketModel = snapshot.data![index];
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: SizedBox(
                            height: 120,
                            width: 250,
                            child: Card(
                              elevation: 0,
                              color: const Color.fromARGB(134, 243, 234, 234),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15.0),
                              ),
                              child: marketModel.openStatus == true
                                  ? InkWell(
                                      onTap: () async {
                                        Navigator.of(context).push(
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    MarketDetail(
                                                        marketModel:
                                                            marketModel)));
                                      },
                                      child: Column(
                                        children: [
                                          Stack(
                                            children: [
                                              ClipRRect(
                                                borderRadius:
                                                    const BorderRadius.only(
                                                        topLeft:
                                                            Radius.circular(15),
                                                        topRight:
                                                            Radius.circular(
                                                                15)),
                                                child: Image.network(
                                                  marketModel.image1,
                                                  height: 80,
                                                  fit: BoxFit.cover,
                                                  width: double.infinity,
                                                ),
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    top: 8, right: 8),
                                                child: Align(
                                                  alignment: Alignment.topRight,
                                                  child: Container(
                                                      height: 30,
                                                      width: 70,
                                                      decoration: const BoxDecoration(
                                                          color: Colors.orange,
                                                          shape: BoxShape
                                                              .rectangle),
                                                      child: marketModel
                                                                  .openStatus ==
                                                              true
                                                          ? Center(
                                                              child:
                                                                  const Text('Open', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))
                                                                      .tr())
                                                          : Center(
                                                              child: const Text(
                                                                      'Closed',
                                                                      style: TextStyle(
                                                                          color: Colors.white,
                                                                          fontWeight: FontWeight.bold))
                                                                  .tr())),
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 10),
                                          Padding(
                                            padding:
                                                const EdgeInsets.only(left: 10),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Flexible(
                                                  flex: 4,
                                                  child: Text(
                                                      marketModel.marketName,
                                                      style: TextStyle(
                                                          fontSize: MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .width >=
                                                                  1100
                                                              ? 15
                                                              : MediaQuery.of(context)
                                                                              .size
                                                                              .width >
                                                                          600 &&
                                                                      MediaQuery.of(context)
                                                                              .size
                                                                              .width <
                                                                          1200
                                                                  ? 15
                                                                  : 12,
                                                          fontWeight:
                                                              FontWeight.bold),
                                                      overflow: TextOverflow
                                                          .ellipsis),
                                                ),
                                                marketModel.totalNumberOfUserRating ==
                                                        0
                                                    ? Container()
                                                    : Flexible(
                                                        flex: 2,
                                                        child: Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .end,
                                                            children: [
                                                              RatingBarIndicator(
                                                                rating: (marketModel
                                                                            .totalRating! /
                                                                        marketModel
                                                                            .totalNumberOfUserRating!)
                                                                    .roundToDouble(),
                                                                itemBuilder: (context,
                                                                        index) =>
                                                                    const Icon(
                                                                  Icons.star,
                                                                  color: Colors
                                                                      .orange,
                                                                ),
                                                                itemCount: 5,
                                                                itemSize: 10,
                                                                direction: Axis
                                                                    .horizontal,
                                                              ),
                                                              Text(
                                                                  ' ${(marketModel.totalRating! / marketModel.totalNumberOfUserRating!).roundToDouble()}',
                                                                  style: const TextStyle(
                                                                      fontSize:
                                                                          14,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold)),
                                                              const SizedBox(
                                                                width: 5,
                                                              )
                                                            ]))
                                              ],
                                            ),
                                          ),
                                          const SizedBox(height: 1),
                                          Padding(
                                            padding:
                                                const EdgeInsets.only(left: 10),
                                            child: Row(
                                              children: [
                                                Flexible(
                                                  flex: 6,
                                                  child: Text(
                                                      marketModel.address,
                                                      overflow: TextOverflow
                                                          .ellipsis),
                                                ),
                                              ],
                                            ),
                                          )
                                        ],
                                      ),
                                    )
                                  : InkWell(
                                      onTap: () async {
                                        Fluttertoast.showToast(
                                            msg: "Market is closed".tr(),
                                            toastLength: Toast.LENGTH_SHORT,
                                            gravity: ToastGravity.TOP,
                                            timeInSecForIosWeb: 1,
                                            fontSize: 14.0);
                                      },
                                      child: Column(
                                        children: [
                                          Stack(
                                            children: [
                                              Container(
                                                  height: 80,
                                                  width: double.infinity,
                                                  decoration: BoxDecoration(
                                                    image: DecorationImage(
                                                        image: NetworkImage(
                                                          marketModel.image1,
                                                        ),
                                                        fit: BoxFit.fill),
                                                    borderRadius:
                                                        const BorderRadius.only(
                                                            topLeft:
                                                                Radius.circular(
                                                                    15),
                                                            topRight:
                                                                Radius.circular(
                                                                    15)),
                                                  ),
                                                  child: Center(
                                                      child: const Text(
                                                              'Closed',
                                                              style: TextStyle(
                                                                  fontSize: 18,
                                                                  color: Colors
                                                                      .white,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold))
                                                          .tr())),
                                              // Padding(
                                              //   padding: const EdgeInsets.only(
                                              //       top: 8, right: 8),
                                              //   child: Align(
                                              //     alignment: Alignment.topRight,
                                              //     child: Container(
                                              //         height: 30,
                                              //         width: 70,
                                              //         decoration: const BoxDecoration(
                                              //             color: Colors.orange,
                                              //             shape: BoxShape
                                              //                 .rectangle),
                                              //         child: marketModel
                                              //                     .openStatus ==
                                              //                 true
                                              //             ? Center(
                                              //                 child:
                                              //                     const Text('Open', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))
                                              //                         .tr())
                                              //             : Center(
                                              //                 child: const Text(
                                              //                         'Closed',
                                              //                         style: TextStyle(
                                              //                             color: Colors.white,
                                              //                             fontWeight: FontWeight.bold))
                                              //                     .tr())),
                                              //   ),
                                              // ),
                                            ],
                                          ),
                                          const SizedBox(height: 10),
                                          Padding(
                                            padding:
                                                const EdgeInsets.only(left: 10),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Flexible(
                                                  flex: 4,
                                                  child: Text(
                                                      marketModel.marketName,
                                                      style: TextStyle(
                                                          fontSize: MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .width >=
                                                                  1100
                                                              ? 15
                                                              : MediaQuery.of(context)
                                                                              .size
                                                                              .width >
                                                                          600 &&
                                                                      MediaQuery.of(context)
                                                                              .size
                                                                              .width <
                                                                          1200
                                                                  ? 15
                                                                  : 12,
                                                          fontWeight:
                                                              FontWeight.bold),
                                                      overflow: TextOverflow
                                                          .ellipsis),
                                                ),
                                                marketModel.totalNumberOfUserRating ==
                                                        0
                                                    ? Container()
                                                    : Flexible(
                                                        flex: 2,
                                                        child: Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .end,
                                                            children: [
                                                              RatingBarIndicator(
                                                                rating: (marketModel
                                                                            .totalRating! /
                                                                        marketModel
                                                                            .totalNumberOfUserRating!)
                                                                    .roundToDouble(),
                                                                itemBuilder: (context,
                                                                        index) =>
                                                                    const Icon(
                                                                  Icons.star,
                                                                  color: Colors
                                                                      .orange,
                                                                ),
                                                                itemCount: 5,
                                                                itemSize: 10,
                                                                direction: Axis
                                                                    .horizontal,
                                                              ),
                                                              Text(
                                                                  ' ${(marketModel.totalRating! / marketModel.totalNumberOfUserRating!).roundToDouble()}',
                                                                  style: const TextStyle(
                                                                      fontSize:
                                                                          14,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold)),
                                                              const SizedBox(
                                                                width: 5,
                                                              )
                                                            ]))
                                              ],
                                            ),
                                          ),
                                          const SizedBox(height: 1),
                                          Padding(
                                            padding:
                                                const EdgeInsets.only(left: 10),
                                            child: Row(
                                              children: [
                                                Flexible(
                                                  flex: 6,
                                                  child: Text(
                                                      marketModel.address,
                                                      overflow: TextOverflow
                                                          .ellipsis),
                                                ),
                                              ],
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                            )),
                      );
                    },
                    options: CarouselOptions(
                      enlargeStrategy: CenterPageEnlargeStrategy.height,
                      initialPage: MediaQuery.of(context).size.width >= 1100
                          ? 1
                          : MediaQuery.of(context).size.width > 600 &&
                                  MediaQuery.of(context).size.width < 1200
                              ? 1
                              : 0,
                      disableCenter: true,
                      enableInfiniteScroll: false,
                      viewportFraction:
                          MediaQuery.of(context).size.width >= 1100
                              ? 0.3
                              : MediaQuery.of(context).size.width > 600 &&
                                      MediaQuery.of(context).size.width < 1200
                                  ? 0.4
                                  : 0.8,
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
            return Container(
              width: double.infinity,
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
              child: Column(
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  Expanded(
                    child: Shimmer.fromColors(
                      baseColor: Colors.grey[300]!,
                      highlightColor: Colors.grey[100]!,
                      enabled: true,
                      child: ListView.builder(
                        shrinkWrap: true,
                        scrollDirection: Axis.horizontal,
                        itemBuilder: (_, __) => SizedBox(
                            height: 120,
                            width: 250,
                            child: Padding(
                              padding:
                                  const EdgeInsets.only(left: 10, right: 10),
                              child: Column(
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    height: 80,
                                  ),
                                  const SizedBox(height: 10),
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        left: 10, right: 10),
                                    child: Row(
                                      children: [
                                        Flexible(
                                          flex: 5,
                                          child: Container(
                                              height: 10,
                                              width: 200,
                                              color: Colors.white),
                                        ),
                                        const SizedBox(width: 10),
                                        Flexible(
                                          flex: 3,
                                          child: Container(
                                              height: 10,
                                              width: 200,
                                              color: Colors.white),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 10),
                                    child: Row(
                                      children: [
                                        Container(
                                            height: 10,
                                            width: 100,
                                            color: Colors.white),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            )),
                        itemCount: 5,
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

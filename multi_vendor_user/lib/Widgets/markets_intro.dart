// ignore_for_file: avoid_print

import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shimmer/shimmer.dart';
import '../Model/market.dart';
import '../Pages/market_detail.dart';

class MarketsIntro extends StatefulWidget {
  const MarketsIntro({Key? key}) : super(key: key);

  @override
  State<MarketsIntro> createState() => _MarketsIntroState();
}

class _MarketsIntroState extends State<MarketsIntro> {
  Future<List<MarketModel>> getAllMarkets() {
    return FirebaseFirestore.instance
        .collection('Markets')
        .limit(10)
        .where('Approval', isEqualTo: true)
        .get()
        .then((event) => event.docs
            .map((e) => MarketModel.fromMap(e.data(), e.id))
            .toList());
  }

  final CarouselController controller = CarouselController();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<MarketModel>>(
        future: getAllMarkets(),
        builder: (context, snapshot) {
          if (snapshot.data?.isEmpty ?? true) {
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
                      child: GridView.builder(
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: MediaQuery.of(context).size.width >= 1100
                              ? 10
                              : 12,
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
                                    ? (1 / 0.9)
                                    : (1 / 0.8),
                          ),
                          itemBuilder: (BuildContext buildContext, int index) {
                            return SizedBox(
                              width: MediaQuery.of(context).size.width >= 1100
                                  ? MediaQuery.of(context).size.width / 9
                                  : MediaQuery.of(context).size.width / 1.2,
                              height: MediaQuery.of(context).size.width >= 1100
                                  ? MediaQuery.of(context).size.width / 9
                                  : MediaQuery.of(context).size.width / 4,
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
                                  ],
                                ),
                              ),
                            );
                          }),
                    ),
                  ),
                ],
              ),
            );
          } else if (snapshot.hasData) {
            return AlignedGridView.count(
              padding: const EdgeInsets.only(bottom: 20),
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: MediaQuery.of(context).size.width >= 1100 ? 4 : 2,
              mainAxisSpacing: 5,
              crossAxisSpacing: 5,
              itemCount: snapshot.data!.length,
              itemBuilder: (
                BuildContext buildContext,
                int index,
              ) {
                MarketModel marketModel = snapshot.data![index];
                return AnimationConfiguration.staggeredGrid(
                  position: index,
                  duration: const Duration(milliseconds: 500),
                  columnCount:
                      MediaQuery.of(context).size.width >= 1100 ? 4 : 2,
                  child: ScaleAnimation(
                    child: FadeInAnimation(
                      child: SizedBox(
                        width: MediaQuery.of(context).size.width >= 1100
                            ? MediaQuery.of(context).size.width / 9
                            : MediaQuery.of(context).size.width / 1.2,
                        height: MediaQuery.of(context).size.width >= 1100
                            ? MediaQuery.of(context).size.width / 9
                            : MediaQuery.of(context).size.width / 2.5,
                        child: marketModel.openStatus == true
                            ? InkWell(
                                onTap: () async {
                                  Navigator.of(context).push(MaterialPageRoute(
                                      builder: (context) => MarketDetail(
                                          marketModel: marketModel)));
                                },
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Stack(
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              left: 8, right: 8),
                                          child: ClipRRect(
                                            borderRadius:
                                                const BorderRadius.all(
                                                    Radius.circular(15)),
                                            child: Image.network(
                                              marketModel.image1,
                                              fit: BoxFit.cover,
                                              width: MediaQuery.of(context)
                                                          .size
                                                          .width >=
                                                      1100
                                                  ? MediaQuery.of(context)
                                                          .size
                                                          .width /
                                                      9
                                                  : MediaQuery.of(context)
                                                          .size
                                                          .width /
                                                      1.5,
                                              height: MediaQuery.of(context)
                                                          .size
                                                          .width >=
                                                      1100
                                                  ? MediaQuery.of(context)
                                                          .size
                                                          .width /
                                                      9
                                                  : MediaQuery.of(context)
                                                          .size
                                                          .width /
                                                      4,
                                            ),
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
                                                    shape: BoxShape.rectangle),
                                                child: marketModel.openStatus == true
                                                    ? Center(
                                                        child: const Text('Open',
                                                                style: TextStyle(
                                                                    color: Colors
                                                                        .white,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold))
                                                            .tr())
                                                    : Center(
                                                        child: const Text(
                                                                'Closed',
                                                                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))
                                                            .tr())),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(
                                      height: 5,
                                    ),
                                    SizedBox(
                                      width: double.infinity,
                                      child: Center(
                                        child: Text(
                                          marketModel.marketName,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.bold),
                                          textAlign: TextAlign.start,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 5,
                                    ),
                                    SizedBox(
                                      width: double.infinity,
                                      child: Padding(
                                        padding: const EdgeInsets.only(
                                            left: 10, right: 10),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              marketModel.category,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                fontSize: 12,
                                              ),
                                            ),
                                            Flexible(
                                              child: RatingBarIndicator(
                                                rating: marketModel
                                                            .totalRating ==
                                                        0
                                                    ? 0
                                                    : marketModel.totalRating! /
                                                        marketModel
                                                            .totalNumberOfUserRating!,
                                                itemBuilder: (context, index) =>
                                                    const Icon(
                                                  Icons.star,
                                                  color: Colors.orange,
                                                ),
                                                itemCount: 5,
                                                itemSize: 15,
                                                direction: Axis.horizontal,
                                              ),
                                            ),
                                          ],
                                        ),
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
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Stack(
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              left: 8, right: 8),
                                          child: Container(
                                            width: MediaQuery.of(context)
                                                        .size
                                                        .width >=
                                                    1100
                                                ? MediaQuery.of(context)
                                                        .size
                                                        .width /
                                                    9
                                                : MediaQuery.of(context)
                                                        .size
                                                        .width /
                                                    1.5,
                                            height: MediaQuery.of(context)
                                                        .size
                                                        .width >=
                                                    1100
                                                ? MediaQuery.of(context)
                                                        .size
                                                        .width /
                                                    9
                                                : MediaQuery.of(context)
                                                        .size
                                                        .width /
                                                    4,
                                            decoration: BoxDecoration(
                                                borderRadius:
                                                    const BorderRadius.all(
                                                        Radius.circular(15)),
                                                image: DecorationImage(
                                                    image: NetworkImage(
                                                      marketModel.image1,
                                                    ),
                                                    fit: BoxFit.fill)),
                                            child: Center(
                                                child: const Text('Closed',
                                                        style: TextStyle(
                                                            color: Colors.white,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold))
                                                    .tr()),
                                          ),
                                        ),
                                        // Align(
                                        //   alignment: Alignment.center,
                                        //   child: Container(
                                        //       height: double.infinity,
                                        //       width: double.infinity,
                                        //       decoration: const BoxDecoration(
                                        //           color: Colors.orange,
                                        //           shape: BoxShape.rectangle),
                                        //       child: marketModel.openStatus == true
                                        //           ? Center(
                                        //               child: const Text('Open',
                                        //                       style: TextStyle(
                                        //                           color: Colors
                                        //                               .white,
                                        //                           fontWeight:
                                        //                               FontWeight
                                        //                                   .bold))
                                        //                   .tr())
                                        //           : Center(
                                        //               child: const Text(
                                        //                       'Closed',
                                        //                       style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))
                                        //                   .tr())),
                                        // ),
                                      ],
                                    ),
                                    const SizedBox(
                                      height: 5,
                                    ),
                                    SizedBox(
                                      width: double.infinity,
                                      child: Center(
                                        child: Text(
                                          marketModel.marketName,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.bold),
                                          textAlign: TextAlign.start,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 5,
                                    ),
                                    SizedBox(
                                      width: double.infinity,
                                      child: Padding(
                                        padding: const EdgeInsets.only(
                                            left: 10, right: 10),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              marketModel.category,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                fontSize: 12,
                                              ),
                                            ),
                                            RatingBarIndicator(
                                              rating: marketModel.totalRating ==
                                                      0
                                                  ? 0
                                                  : marketModel.totalRating! /
                                                      marketModel
                                                          .totalNumberOfUserRating!,
                                              itemBuilder: (context, index) =>
                                                  const Icon(
                                                Icons.star,
                                                color: Colors.orange,
                                              ),
                                              itemCount: 5,
                                              itemSize: 15,
                                              direction: Axis.horizontal,
                                            ),
                                          ],
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                      ),
                    ),
                  ),
                );
              },
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
                      child: GridView.builder(
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: MediaQuery.of(context).size.width >= 1100
                              ? 10
                              : 12,
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
                                    ? (1 / 0.9)
                                    : (1 / 0.8),
                          ),
                          itemBuilder: (BuildContext buildContext, int index) {
                            return SizedBox(
                              width: MediaQuery.of(context).size.width >= 1100
                                  ? MediaQuery.of(context).size.width / 9
                                  : MediaQuery.of(context).size.width / 1.2,
                              height: MediaQuery.of(context).size.width >= 1100
                                  ? MediaQuery.of(context).size.width / 9
                                  : MediaQuery.of(context).size.width / 4,
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
                                  ],
                                ),
                              ),
                            );
                          }),
                    ),
                  ),
                ],
              ),
            );
          }
        });
  }
}

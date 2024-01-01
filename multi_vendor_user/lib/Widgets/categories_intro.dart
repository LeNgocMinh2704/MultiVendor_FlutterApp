// ignore_for_file: avoid_print

import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:marquee/marquee.dart';
import 'package:shimmer/shimmer.dart';

import '../Model/categories.dart';
import '../Pages/markets_by_categories_page.dart';

class CategoriesIntro extends StatefulWidget {
  const CategoriesIntro({Key? key}) : super(key: key);

  @override
  State<CategoriesIntro> createState() => _CategoriesIntroState();
}

class _CategoriesIntroState extends State<CategoriesIntro> {
  Future<List<CategoriesModel>> getCategories() {
    return FirebaseFirestore.instance
        .collection('Categories')
        .limit(12)
        .get()
        .then((event) => event.docs
            .map((e) => CategoriesModel.fromMap(e.data(), e.id))
            .toList());
  }

  final CarouselController controller = CarouselController();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<CategoriesModel>>(
        future: getCategories(),
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
                      child: GridView.builder(
                          padding: const EdgeInsets.only(bottom: 20),
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: MediaQuery.of(context).size.width >= 1100
                              ? 12
                              : 12,
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: MediaQuery.of(context).size.width >=
                                    1100
                                ? 4
                                : MediaQuery.of(context).size.width > 600 &&
                                        MediaQuery.of(context).size.width < 1200
                                    ? 4
                                    : 4,
                          ),
                          itemBuilder: (BuildContext buildContext, int index) {
                            return SizedBox(
                              width: 100,
                              height: 80,
                              child: Padding(
                                padding:
                                    const EdgeInsets.only(left: 10, right: 10),
                                child: Column(
                                  children: [
                                    Card(
                                      elevation: 0,
                                      shape: const RoundedRectangleBorder(
                                          borderRadius: BorderRadius.all(
                                        Radius.circular(20),
                                      )),
                                      child: Container(
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius:
                                                BorderRadius.circular(20),
                                          ),
                                          width: 40,
                                          height: 40),
                                    ),
                                    const SizedBox(height: 10),
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          left: 10, right: 10),
                                      child: Container(
                                          height: 10,
                                          width: 60,
                                          color: Colors.white),
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
              crossAxisCount: MediaQuery.of(context).size.width >= 1100 ? 4 : 4,
              mainAxisSpacing: 0,
              crossAxisSpacing: 0,
              itemCount: snapshot.data!.length,
              itemBuilder: (
                BuildContext buildContext,
                int index,
              ) {
                CategoriesModel marketModel = snapshot.data![index];
                return AnimationConfiguration.staggeredGrid(
                  position: index,
                  duration: const Duration(milliseconds: 500),
                  columnCount:
                      MediaQuery.of(context).size.width >= 1100 ? 4 : 4,
                  child: ScaleAnimation(
                    child: FadeInAnimation(
                      child: SizedBox(
                        width: 100,
                        height: 80,
                        child: InkWell(
                          onTap: () async {
                            Navigator.of(context)
                                .push(MaterialPageRoute(builder: ((context) {
                              return MarketsByCategoriesPage(
                                  selectedCategory: marketModel.category);
                            })));
                          },
                          child: Card(
                              elevation: 0,
                              color: Colors.white,
                              shape: const RoundedRectangleBorder(
                                  borderRadius: BorderRadius.all(
                                Radius.circular(20),
                              )),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Center(
                                    child: Image.network(
                                      marketModel.image,
                                      width: 40,
                                      height: 40,
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 5,
                                  ),
                                  SizedBox(
                                    width: double.infinity,
                                    child: Center(
                                      child: marketModel.category.length >= 10
                                          ? SizedBox(
                                              height: 12,
                                              child: Marquee(
                                                text: marketModel.category,
                                                style: TextStyle(
                                                    color: Colors.black,
                                                    fontSize:
                                                        MediaQuery.of(context)
                                                                    .size
                                                                    .width >=
                                                                1100
                                                            ? 15
                                                            : 12),
                                                scrollAxis: Axis.horizontal,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                blankSpace: 20,
                                                velocity: 100,
                                                pauseAfterRound:
                                                    const Duration(seconds: 1),
                                                showFadingOnlyWhenScrolling:
                                                    true,
                                                fadingEdgeStartFraction: 0.1,
                                                fadingEdgeEndFraction: 0.1,
                                                numberOfRounds: 3,
                                                startPadding: 10,
                                                accelerationDuration:
                                                    const Duration(seconds: 1),
                                                accelerationCurve:
                                                    Curves.linear,
                                                decelerationDuration:
                                                    const Duration(
                                                        milliseconds: 500),
                                                decelerationCurve:
                                                    Curves.easeOut,
                                              ),
                                            )
                                          : Text(
                                              marketModel.category,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                  color: Colors.black,
                                                  fontSize:
                                                      MediaQuery.of(context)
                                                                  .size
                                                                  .width >=
                                                              1100
                                                          ? 15
                                                          : 12),
                                            ),
                                    ),
                                  )
                                ],
                              )),
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          } else {
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
                      child: GridView.builder(
                          padding: const EdgeInsets.only(bottom: 20),
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: MediaQuery.of(context).size.width >= 1100
                              ? 12
                              : 12,
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: MediaQuery.of(context).size.width >=
                                    1100
                                ? 4
                                : MediaQuery.of(context).size.width > 600 &&
                                        MediaQuery.of(context).size.width < 1200
                                    ? 4
                                    : 4,
                          ),
                          itemBuilder: (BuildContext buildContext, int index) {
                            return SizedBox(
                              width: 100,
                              height: 80,
                              child: Padding(
                                padding:
                                    const EdgeInsets.only(left: 10, right: 10),
                                child: Card(
                                  elevation: 0,
                                  shape: const RoundedRectangleBorder(
                                      borderRadius: BorderRadius.all(
                                    Radius.circular(20),
                                  )),
                                  child: Column(
                                    children: [
                                      Container(
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius:
                                                BorderRadius.circular(20),
                                          ),
                                          height: 40,
                                          width: 40),
                                      const SizedBox(height: 10),
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            left: 10, right: 10),
                                        child: Container(
                                            height: 10,
                                            width: 60,
                                            color: Colors.white),
                                      ),
                                    ],
                                  ),
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

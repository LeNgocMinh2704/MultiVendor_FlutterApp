// ignore_for_file: avoid_print

import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:marquee/marquee.dart';
import 'package:user_1/Pages/markets_by_categories_page.dart';
import '../Model/categories.dart';

class CategoriesPage extends StatefulWidget {
  const CategoriesPage({Key? key}) : super(key: key);

  @override
  State<CategoriesPage> createState() => _CategoriesPageState();
}

class _CategoriesPageState extends State<CategoriesPage> {
  Future<List<CategoriesModel>> getCategories() {
    return FirebaseFirestore.instance.collection('Categories').get().then(
        (event) => event.docs
            .map((e) => CategoriesModel.fromMap(e.data(), e.id))
            .toList());
  }

  final CarouselController controller = CarouselController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: Theme.of(context).iconTheme,
        titleTextStyle: TextStyle(color: Theme.of(context).indicatorColor),
        backgroundColor: Theme.of(context).colorScheme.background,
        centerTitle: true,
        elevation: 0,
        title: const Text('Categories').tr(),
      ),
      body: FutureBuilder<List<CategoriesModel>>(
          future: getCategories(),
          builder: (context, snapshot) {
            if (snapshot.data?.isEmpty ?? true) {
              return const Center(
                child: SpinKitCircle(
                  color: Colors.orange,
                ),
              );
            } else if (snapshot.hasData) {
              return AlignedGridView.count(
                physics: const BouncingScrollPhysics(),
                crossAxisCount:
                    MediaQuery.of(context).size.width >= 1100 ? 4 : 3,
                mainAxisSpacing: 5,
                crossAxisSpacing: 5,
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
                        MediaQuery.of(context).size.width >= 1100 ? 4 : 3,
                    child: ScaleAnimation(
                      child: FadeInAnimation(
                        child: SizedBox(
                          width: MediaQuery.of(context).size.width >= 1100
                              ? MediaQuery.of(context).size.width / 9
                              : MediaQuery.of(context).size.width / 1.2,
                          height: MediaQuery.of(context).size.width >= 1100
                              ? MediaQuery.of(context).size.width / 9
                              : MediaQuery.of(context).size.width / 4,
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
                                        width: 50,
                                        height: 50,
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 5,
                                    ),
                                    SizedBox(
                                      width: double.infinity,
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
                                          : Center(
                                        child: Text(
                                          marketModel.category,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                              color: Colors.black,
                                              fontSize: MediaQuery.of(context)
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
              return const Center(
                child: SpinKitCircle(
                  color: Colors.orange,
                ),
              );
            }
          }),
    );
  }
}

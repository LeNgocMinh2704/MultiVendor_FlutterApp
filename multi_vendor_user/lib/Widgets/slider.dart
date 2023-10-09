// ignore_for_file: avoid_print

import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:shimmer/shimmer.dart';
import '../Model/feeds.dart';
import '../Pages/markets_by_categories_page.dart';

class SliderWidget extends StatefulWidget {
  final String category;
  const SliderWidget({Key? key, required this.category}) : super(key: key);

  @override
  State<SliderWidget> createState() => _SliderWidgetState();
}

class _SliderWidgetState extends State<SliderWidget> {
  Future<List<FeedsModel>> getFeeds() {
    return FirebaseFirestore.instance
        .collection('Feeds')
        .where('slider', isEqualTo: true)
        .where('category', isEqualTo: widget.category)
        .get()
        .then((event) {
      return event.docs.map((e) => FeedsModel.fromMap(e.data(), e.id)).toList();
    });
  }

  Future<List<FeedsModel>> getFeedsAll() {
    return FirebaseFirestore.instance
        .collection('Feeds')
        .where('slider', isEqualTo: true)
        .limit(4)
        .get()
        .then((event) {
      return event.docs.map((e) => FeedsModel.fromMap(e.data(), e.id)).toList();
    });
  }

  int _current = 0;
  final CarouselController _controller = CarouselController();
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<FeedsModel>>(
        future: widget.category == '' ? getFeedsAll() : getFeeds(),
        builder: (context, snapshot) {
          if (snapshot.data?.isEmpty ?? true) {
            return const Center(
              child: SpinKitCircle(
                color: Colors.orange,
              ),
            );
          } else if (snapshot.hasData) {
            return Stack(
              children: [
                CarouselSlider.builder(
                  carouselController: _controller,
                  itemCount: snapshot.data!.length,
                  itemBuilder:
                      (BuildContext context, int itemIndex, int pageViewIndex) {
                    FeedsModel feedsModel = snapshot.data![itemIndex];
                    return InkWell(
                      onTap: () async {
                        if (widget.category == '') {
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => MarketsByCategoriesPage(
                                  selectedCategory: feedsModel.category)));
                        }
                      },
                      child: Image.network(
                        feedsModel.image,
                        fit: MediaQuery.of(context).size.width >= 1100
                            ? BoxFit.fill
                            : MediaQuery.of(context).size.width > 600 &&
                                    MediaQuery.of(context).size.width < 1200
                                ? BoxFit.fill
                                : BoxFit.fill,
                        height: MediaQuery.of(context).size.height / 1,
                        width: MediaQuery.of(context).size.width >= 1100
                            ? MediaQuery.of(context).size.width / 1
                            : MediaQuery.of(context).size.width > 600 &&
                                    MediaQuery.of(context).size.width < 1200
                                ? MediaQuery.of(context).size.width / 1
                                : MediaQuery.of(context).size.width / 1,
                      ),
                    );
                  },
                  options: CarouselOptions(
                      height: MediaQuery.of(context).size.width >= 1100
                          ? MediaQuery.of(context).size.height / 2.5
                          : MediaQuery.of(context).size.height / 3.5,
                      aspectRatio: 1,
                      viewportFraction: 1,
                      initialPage: 0,
                      enableInfiniteScroll: true,
                      reverse: false,
                      autoPlay: true,
                      autoPlayInterval: const Duration(seconds: 3),
                      autoPlayAnimationDuration:
                          const Duration(milliseconds: 800),
                      autoPlayCurve: Curves.fastOutSlowIn,
                      enlargeCenterPage: true,
                      // onPageChanged: callbackFunction,
                      scrollDirection: Axis.horizontal,
                      onPageChanged: (index, reason) {
                        setState(() {
                          _current = index;
                        });
                      }),
                ),
                Align(
                    alignment: Alignment.bottomCenter,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: snapshot.data!.asMap().entries.map((entry) {
                        return GestureDetector(
                          onTap: () => _controller.animateToPage(entry.key),
                          child: Container(
                            width: 12.0,
                            height: 12.0,
                            margin: const EdgeInsets.symmetric(
                                vertical: 8.0, horizontal: 4.0),
                            decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: (Theme.of(context).brightness ==
                                            Brightness.dark
                                        ? Colors.white
                                        : Colors.black)
                                    .withOpacity(
                                        _current == entry.key ? 0.9 : 0.4)),
                          ),
                        );
                      }).toList(),
                    ))
              ],
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
                      child: CarouselSlider.builder(
                        options: CarouselOptions(
                          height: MediaQuery.of(context).size.height / 1,
                          aspectRatio: 1,
                          viewportFraction: 1,
                          initialPage: 0,
                          enableInfiniteScroll: true,
                          reverse: false,
                          autoPlay: true,
                          autoPlayInterval: const Duration(seconds: 3),
                          autoPlayAnimationDuration:
                              const Duration(milliseconds: 800),
                          autoPlayCurve: Curves.fastOutSlowIn,
                          enlargeCenterPage: true,
                          // onPageChanged: callbackFunction,
                          scrollDirection: Axis.horizontal,
                        ),
                        itemBuilder: (_, __, int pageViewIndex) => SizedBox(
                            height: MediaQuery.of(context).size.height / 2,
                            width: MediaQuery.of(context).size.width / 2,
                            child: Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(0.0),
                              ),
                            )),
                        itemCount: 1,
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

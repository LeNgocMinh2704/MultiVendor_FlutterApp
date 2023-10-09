// ignore_for_file: avoid_print
import 'package:badges/badges.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart' hide Badge;
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shimmer/shimmer.dart';
import 'package:multi_vendor_user/Pages/products_by_categories.dart';
import '../Model/market.dart';
import '../Widgets/flash_sales_slides.dart';
import '../Widgets/market_widget_slider.dart';
import '../Widgets/product_slide_1.dart';
import '../Widgets/search.dart';
import '../Widgets/slider.dart';
import '../Widgets/sub_categories.dart';
import '../Widgets/sub_categories_moblie.dart';
import 'flash_sales_by_category.dart';
import 'market_detail.dart';

class MarketsByCategoriesPage extends StatefulWidget {
  final String selectedCategory;
  const MarketsByCategoriesPage({Key? key, required this.selectedCategory})
      : super(key: key);

  @override
  State<MarketsByCategoriesPage> createState() =>
      _MarketsByCategoriesPageState();
}

class _MarketsByCategoriesPageState extends State<MarketsByCategoriesPage>
    with TickerProviderStateMixin {
  final ScrollController sc = ScrollController();
  num cartQuantity = 0;
  DocumentReference? userRef;
  getCart() {
    if (userRef != null) {
      userRef!.collection('Cart').snapshots().listen((val) {
        num tempTotal =
            val.docs.fold(0, (tot, doc) => tot + doc.data()['quantity']);
        setState(() {
          cartQuantity = tempTotal;
        });
      });
    }
  }

  Future<void> _getUserDoc() async {
    final FirebaseAuth auth = FirebaseAuth.instance;
    final FirebaseFirestore firestore = FirebaseFirestore.instance;

    User? user = auth.currentUser;
    setState(() {
      userRef = firestore.collection('users').doc(user!.uid);
    });
  }

  @override
  void initState() {
    _getUserDetails();
    _getUserDoc();
    super.initState();
  }

  String fullname = '';
  String email = '';
  String userPic = '';
  DocumentReference? userDetails;

  Future<void> _getUserDetails() async {
    final FirebaseAuth auth = FirebaseAuth.instance;
    final FirebaseFirestore firestore = FirebaseFirestore.instance;

    User? user = auth.currentUser;
    setState(() {
      userDetails = firestore
          .collection('users')
          .doc(user!.uid)
          .snapshots()
          .listen((value) {
        setState(() {
          fullname = value['fullname'].split(' ')[0].trim();
          email = value['email'];
          userPic = value['photoUrl'];
        });
        if (fullname != '') {
          getCart();
        }
      }) as DocumentReference<Object?>?;
    });
  }

  @override
  void dispose() {
    sc.dispose();
    super.dispose();
  }

  Future<List<MarketModel>> getMarketsByCategories(String category) {
    return FirebaseFirestore.instance
        .collection('Markets')
        .where('Approval', isEqualTo: true)
        .where('Category', isEqualTo: category)
        .get()
        .then((event) => event.docs
            .map((e) => MarketModel.fromMap(e.data(), e.id))
            .toList());
  }

  String search = "Search For Markets on".tr();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: Theme.of(context).iconTheme,
        titleTextStyle: TextStyle(color: Theme.of(context).indicatorColor),
        backgroundColor: Theme.of(context).colorScheme.background,
        elevation: 0,
        centerTitle: true,
        title: SizedBox(
            width: MediaQuery.of(context).size.width / 1.2,
            height: 40,
            child: TextField(
              readOnly: true,
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) =>
                        const SearchPage(category: "Markets")));
              },
              decoration: InputDecoration(
                filled: true,
                fillColor: const Color.fromARGB(255, 236, 230, 230),
                hintText: '$search Olivette',
                hintStyle: const TextStyle(color: Colors.black),
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.white),
                  borderRadius: BorderRadius.circular(15),
                ),
                enabledBorder: UnderlineInputBorder(
                  borderSide: const BorderSide(color: Colors.white),
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
            )),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: InkWell(
              onTap: () {
                if (userRef == null) {
                  Navigator.of(context).pushNamed('/login');
                } else {
                  Navigator.of(context).pushNamed('/cart');
                }
              },
              child: Container(
                height: 40,
                width: 40,
                decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color.fromARGB(255, 236, 230, 230)),
                child: Center(
                  child: Badge(
                    badgeStyle: const BadgeStyle(
                      badgeColor: Colors.orange,
                    ),
                    badgeContent: Text(cartQuantity.toString(),
                        style: const TextStyle(color: Colors.white)),
                    child: const Icon(
                      Icons.shopping_cart,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
            ),
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              height: 150,
              child: SliderWidget(
                category: widget.selectedCategory,
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              title: Text(
                'Categories',
                style: TextStyle(
                    fontSize:
                        MediaQuery.of(context).size.width >= 1100 ? 20 : 13,
                    fontWeight: FontWeight.bold),
              ).tr(),
              trailing: InkWell(
                onTap: () {
                  showDialog(
                    builder: ((context) {
                      return Material(
                          child: SingleChildScrollView(
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: InkWell(
                                    onTap: () {
                                      Navigator.of(context).pop();
                                    },
                                    child: Container(
                                      height: 40,
                                      width: 40,
                                      decoration: const BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Color.fromARGB(
                                              255, 236, 230, 230)),
                                      child: const Icon(
                                        Icons.cancel,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            SizedBox(
                              height: MediaQuery.of(context).size.height,
                              child: SubCategoriesWidget(
                                category: widget.selectedCategory,
                              ),
                            ),
                          ],
                        ),
                      ));
                    }),
                    context: context,
                  );
                },
                child: Text(
                  'View All',
                  style: TextStyle(
                      fontSize:
                          MediaQuery.of(context).size.width >= 1100 ? 20 : 13,
                      color: Colors.orange),
                ).tr(),
              ),
            ),
            SizedBox(
                height: 86,
                child: SubCategoriesWidgetMoblie(
                  category: widget.selectedCategory,
                )),
            ListTile(
              title: Text(
                'Popular Markets',
                style: TextStyle(
                    fontSize:
                        MediaQuery.of(context).size.width >= 1100 ? 20 : 13,
                    fontWeight: FontWeight.bold),
              ).tr(),
            ),
            SizedBox(
                height: 160,
                child: MarketWidgetSlider(
                  category: widget.selectedCategory,
                )),
            ListTile(
              title: Text(
                'Products',
                style: TextStyle(
                    fontSize:
                        MediaQuery.of(context).size.width >= 1100 ? 20 : 13,
                    fontWeight: FontWeight.bold),
              ).tr(),
              trailing: InkWell(
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => ProductsByCategories(
                          collection: widget.selectedCategory)));
                },
                child: Text(
                  'View All',
                  style: TextStyle(
                      fontSize:
                          MediaQuery.of(context).size.width >= 1100 ? 20 : 13,
                      color: Colors.orange),
                ).tr(),
              ),
            ),
            SizedBox(
              height: 230,
              child: ProductSlide(
                category: widget.selectedCategory,
              ),
            ),
            ListTile(
              title: Text(
                'Flash Sales',
                style: TextStyle(
                    fontSize:
                        MediaQuery.of(context).size.width >= 1100 ? 20 : 13,
                    fontWeight: FontWeight.bold),
              ).tr(),
              trailing: InkWell(
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => FlashSalesByCategories(
                          category: widget.selectedCategory)));
                },
                child: Text(
                  'View All',
                  style: TextStyle(
                      fontSize:
                          MediaQuery.of(context).size.width >= 1100 ? 20 : 13,
                      color: Colors.orange),
                ).tr(),
              ),
            ),
            SizedBox(
                height: 230,
                child: FlashSalesSlides(
                  category: widget.selectedCategory,
                )),
            ListTile(
              title: Text(
                'All Markets',
                style: TextStyle(
                    fontSize:
                        MediaQuery.of(context).size.width >= 1100 ? 20 : 13,
                    fontWeight: FontWeight.bold),
              ).tr(),
            ),
            FutureBuilder<List<MarketModel>>(
                future: getMarketsByCategories(widget.selectedCategory),
                builder: (context, snapshot) {
                  if (snapshot.data?.isEmpty ?? true) {
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
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount:
                                      MediaQuery.of(context).size.width >= 1100
                                          ? 40
                                          : 12,
                                  gridDelegate:
                                      SliverGridDelegateWithFixedCrossAxisCount(
                                    mainAxisSpacing: 10,
                                    crossAxisSpacing: 10,
                                    crossAxisCount: MediaQuery.of(context)
                                                .size
                                                .width >=
                                            1100
                                        ? 4
                                        : MediaQuery.of(context).size.width >
                                                    600 &&
                                                MediaQuery.of(context)
                                                        .size
                                                        .width <
                                                    1200
                                            ? 3
                                            : 2,
                                    childAspectRatio:
                                        MediaQuery.of(context).size.width >=
                                                1100
                                            ? (1 / 0.9)
                                            : (1 / 0.8),
                                  ),
                                  itemBuilder:
                                      (BuildContext buildContext, int index) {
                                    return SizedBox(
                                      width:
                                          MediaQuery.of(context).size.width >=
                                                  1100
                                              ? MediaQuery.of(context)
                                                      .size
                                                      .width /
                                                  9
                                              : MediaQuery.of(context)
                                                      .size
                                                      .width /
                                                  1.2,
                                      height: MediaQuery.of(context)
                                                  .size
                                                  .width >=
                                              1100
                                          ? MediaQuery.of(context).size.width /
                                              9
                                          : MediaQuery.of(context).size.width /
                                              4,
                                      child: Padding(
                                        padding: const EdgeInsets.only(
                                            left: 10, right: 10),
                                        child: Column(
                                          children: [
                                            Container(
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                              ),
                                              height: 80,
                                            ),
                                            const SizedBox(height: 10),
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 10),
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
                      shrinkWrap: true,
                      physics: const BouncingScrollPhysics(),
                      crossAxisCount:
                          MediaQuery.of(context).size.width >= 1100 ? 4 : 2,
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
                                height: MediaQuery.of(context).size.width >=
                                        1100
                                    ? MediaQuery.of(context).size.height / 4
                                    : MediaQuery.of(context).size.width / 2.5,
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
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Stack(
                                              children: [
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          left: 8, right: 8),
                                                  child: ClipRRect(
                                                    borderRadius:
                                                        const BorderRadius.all(
                                                            Radius.circular(
                                                                15)),
                                                    child: Image.network(
                                                      marketModel.image1,
                                                      fit: BoxFit.cover,
                                                      width: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .width >=
                                                              1100
                                                          ? MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .width /
                                                              9
                                                          : MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .width /
                                                              1.5,
                                                      height: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .width >=
                                                              1100
                                                          ? MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .width /
                                                              9
                                                          : MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .width /
                                                              4,
                                                    ),
                                                  ),
                                                ),
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          top: 8, right: 8),
                                                  child: Align(
                                                    alignment:
                                                        Alignment.topRight,
                                                    child: Container(
                                                        height: 30,
                                                        width: 70,
                                                        decoration:
                                                            const BoxDecoration(
                                                                color: Colors
                                                                    .orange,
                                                                shape: BoxShape
                                                                    .rectangle),
                                                        child: marketModel.openStatus ==
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
                                            const SizedBox(
                                              height: 5,
                                            ),
                                            SizedBox(
                                              width: double.infinity,
                                              child: Center(
                                                child: Text(
                                                  marketModel.marketName,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: const TextStyle(
                                                      fontSize: 15,
                                                      fontWeight:
                                                          FontWeight.bold),
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
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Text(
                                                      marketModel.category,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      style: const TextStyle(
                                                        fontSize: 12,
                                                      ),
                                                    ),
                                                    RatingBarIndicator(
                                                      rating: marketModel
                                                                  .totalRating ==
                                                              0
                                                          ? 0
                                                          : marketModel
                                                                  .totalRating! /
                                                              marketModel
                                                                  .totalNumberOfUserRating!,
                                                      itemBuilder:
                                                          (context, index) =>
                                                              const Icon(
                                                        Icons.star,
                                                        color: Colors.orange,
                                                      ),
                                                      itemCount: 5,
                                                      itemSize: 15,
                                                      direction:
                                                          Axis.horizontal,
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
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Stack(
                                              children: [
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          left: 8, right: 8),
                                                  child: Container(
                                                    width: MediaQuery.of(
                                                                    context)
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
                                                    height: MediaQuery.of(
                                                                    context)
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
                                                            const BorderRadius
                                                                    .all(
                                                                Radius.circular(
                                                                    15)),
                                                        image: DecorationImage(
                                                            image: NetworkImage(
                                                              marketModel
                                                                  .image1,
                                                            ),
                                                            fit: BoxFit.fill)),
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
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: const TextStyle(
                                                      fontSize: 15,
                                                      fontWeight:
                                                          FontWeight.bold),
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
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Text(
                                                      marketModel.category,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      style: const TextStyle(
                                                        fontSize: 12,
                                                      ),
                                                    ),
                                                    RatingBarIndicator(
                                                      rating: marketModel
                                                                  .totalRating ==
                                                              0
                                                          ? 0
                                                          : marketModel
                                                                  .totalRating! /
                                                              marketModel
                                                                  .totalNumberOfUserRating!,
                                                      itemBuilder:
                                                          (context, index) =>
                                                              const Icon(
                                                        Icons.star,
                                                        color: Colors.orange,
                                                      ),
                                                      itemCount: 5,
                                                      itemSize: 15,
                                                      direction:
                                                          Axis.horizontal,
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
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount:
                                      MediaQuery.of(context).size.width >= 1100
                                          ? 40
                                          : 12,
                                  gridDelegate:
                                      SliverGridDelegateWithFixedCrossAxisCount(
                                    mainAxisSpacing: 10,
                                    crossAxisSpacing: 10,
                                    crossAxisCount: MediaQuery.of(context)
                                                .size
                                                .width >=
                                            1100
                                        ? 4
                                        : MediaQuery.of(context).size.width >
                                                    600 &&
                                                MediaQuery.of(context)
                                                        .size
                                                        .width <
                                                    1200
                                            ? 3
                                            : 2,
                                    childAspectRatio:
                                        MediaQuery.of(context).size.width >=
                                                1100
                                            ? (1 / 0.9)
                                            : (1 / 0.8),
                                  ),
                                  itemBuilder:
                                      (BuildContext buildContext, int index) {
                                    return SizedBox(
                                      width:
                                          MediaQuery.of(context).size.width >=
                                                  1100
                                              ? MediaQuery.of(context)
                                                      .size
                                                      .width /
                                                  9
                                              : MediaQuery.of(context)
                                                      .size
                                                      .width /
                                                  1.2,
                                      height: MediaQuery.of(context)
                                                  .size
                                                  .width >=
                                              1100
                                          ? MediaQuery.of(context).size.width /
                                              9
                                          : MediaQuery.of(context).size.width /
                                              4,
                                      child: Padding(
                                        padding: const EdgeInsets.only(
                                            left: 10, right: 10),
                                        child: Column(
                                          children: [
                                            Container(
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                              ),
                                              height: 80,
                                            ),
                                            const SizedBox(height: 10),
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 10),
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
                }),
          ],
        ),
      ),
    );
  }
}

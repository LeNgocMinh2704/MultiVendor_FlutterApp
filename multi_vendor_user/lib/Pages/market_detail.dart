import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart' hide Badge;
import 'package:tab_indicator_styler/tab_indicator_styler.dart';
import 'package:user_1/Model/market.dart';
import 'package:badges/badges.dart';
import '../Widgets/flash_sales_list.dart';
import '../Widgets/products_list.dart';
import '../Widgets/search_products.dart';

class MarketDetail extends StatefulWidget {
  final MarketModel marketModel;
  const MarketDetail({Key? key, required this.marketModel}) : super(key: key);

  @override
  State<MarketDetail> createState() => _MarketDetailState();
}

class _MarketDetailState extends State<MarketDetail> {
  String currencySymbol = '';
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
    _getUserDoc();
    getCurrencySymbol();
    getCart();
    getSubCollections();
    super.initState();
  }

  getSubCollections() {
    FirebaseFirestore.instance
        .collection('Sub Categories')
        .where('category', isEqualTo: widget.marketModel.category)
        .snapshots()
        .listen((event) {
      for (var element in event.docs) {
        data.add(element['name']);
      }
    });
  }

  List<String> data = ["All", 'Flash sales'];
  String search = 'Search on'.tr();
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: data.length,
      child: SafeArea(
        child: Material(
          child: CustomScrollView(
            slivers: [
              SliverPersistentHeader(
                delegate: MySliverAppBar(
                    userRef: userRef,
                    cartQuantity: cartQuantity,
                    currency: currencySymbol,
                    expandedHeight: 200,
                    marketModel: widget.marketModel),
                pinned: true,
              ),
              SliverFillRemaining(
                child: Column(
                  children: [
                    const SizedBox(
                      height: 130,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: SizedBox(
                          width: MediaQuery.of(context).size.width / 1.2,
                          height: 40,
                          child: TextField(
                            onTap: () {
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) => SearchProductPage(
                                        category: widget.marketModel.category,
                                        marketID: widget.marketModel.uid,
                                      )));
                            },
                            readOnly: true,
                            decoration: InputDecoration(
                              filled: true,
                              prefixIcon: const Icon(Icons.search),
                              fillColor:
                                  const Color.fromARGB(255, 235, 229, 229),
                              hintText:
                                  '$search ${widget.marketModel.marketName}...',
                              hintStyle: const TextStyle(color: Colors.black),
                              focusedBorder: OutlineInputBorder(
                                borderSide:
                                    const BorderSide(color: Colors.white),
                                borderRadius: BorderRadius.circular(15),
                              ),
                              enabledBorder: UnderlineInputBorder(
                                borderSide:
                                    const BorderSide(color: Colors.white),
                                borderRadius: BorderRadius.circular(15),
                              ),
                            ),
                          )),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Material(
                      color: const Color.fromARGB(255, 235, 229, 229),
                      child: TabBar(
                        isScrollable: true,
                        tabs: List.generate(data.length, (int index) {
                          return Tab(text: data[index]);
                        }),
                        unselectedLabelColor: Colors.black,
                        labelColor: Colors.black,
                        indicator: DotIndicator(
                          color: Colors.black,
                          distanceFromCenter: 16,
                          radius: 3,
                          paintingStyle: PaintingStyle.fill,
                        ),
                      ),
                    ),
                    Expanded(
                        child: TabBarView(
                      children: List<Widget>.generate(data.length, (int index) {
                        return data[index] == 'Flash sales'
                            ? FlashSales(marketID: widget.marketModel.uid!)
                            : ProductList(
                                marketID: widget.marketModel.uid!,
                                collection: data[index]);
                      }),
                    )),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class MySliverAppBar extends SliverPersistentHeaderDelegate {
  final double expandedHeight;
  final MarketModel marketModel;
  final String currency;
  final num cartQuantity;
  final DocumentReference? userRef;

  MySliverAppBar(
      {required this.marketModel,
      required this.expandedHeight,
      required this.userRef,
      required this.cartQuantity,
      required this.currency});

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Stack(
      clipBehavior: Clip.none,
      fit: StackFit.expand,
      children: [
        Opacity(
          opacity: (1 - shrinkOffset / expandedHeight),
          child: CarouselSlider(
            options: CarouselOptions(
              height: 200.0,
              initialPage: 0,
              enableInfiniteScroll: true,
              reverse: false,
              autoPlay: true,
              autoPlayInterval: const Duration(seconds: 3),
              autoPlayAnimationDuration: const Duration(milliseconds: 800),
              autoPlayCurve: Curves.fastOutSlowIn,
              enlargeCenterPage: true,
              scrollDirection: Axis.horizontal,
            ),
            items: [marketModel.image1, marketModel.image2, marketModel.image3]
                .map((i) {
              return Builder(
                builder: (BuildContext context) {
                  return Container(
                      width: MediaQuery.of(context).size.width,
                      margin: const EdgeInsets.symmetric(horizontal: 5.0),
                      child: Image.network(i));
                },
              );
            }).toList(),
          ),
        ),
        Center(
          child: Opacity(
            opacity: shrinkOffset / expandedHeight,
            child: Text(
              marketModel.marketName,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 23,
              ),
            ),
          ),
        ),
        Positioned(
          top: expandedHeight / 2 - shrinkOffset,
          left: MediaQuery.of(context).size.width / 13,
          child: Opacity(
            opacity: shrinkOffset / expandedHeight,
            child: SizedBox(
              height: 230,
              width: MediaQuery.of(context).size.width / 1.2,
              child: Column(
                children: [
                  const SizedBox(
                    height: 150,
                  ),
                  Text(
                    marketModel.address,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      'Category: ${marketModel.category}',
                      style: const TextStyle(
                          fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Opening time: ${marketModel.openingTime}am',
                            style: const TextStyle(
                              fontSize: 10,
                            )),
                        const SizedBox(width: 10),
                        Text('Closing time: ${marketModel.openingTime}pm',
                            style: const TextStyle(fontSize: 10))
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        Positioned(
          top: expandedHeight / 2 - shrinkOffset,
          left: MediaQuery.of(context).size.width / 13,
          child: Opacity(
            opacity: (1 - shrinkOffset / expandedHeight),
            child: Card(
              elevation: 10,
              child: SizedBox(
                height: expandedHeight,
                width: MediaQuery.of(context).size.width / 1.2,
                child: Column(
                  children: [
                    const SizedBox(
                      height: 10,
                    ),
                    Text(
                      marketModel.marketName,
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 10, right: 10),
                      child: Text(
                        marketModel.address,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Text(
                      'Category: ${marketModel.category}',
                      style: const TextStyle(
                          fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Opening time: ${marketModel.openingTime}am',
                            style: const TextStyle(fontSize: 10),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            'Closing time: ${marketModel.openingTime}pm',
                            style: const TextStyle(fontSize: 10),
                          )
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                              'Rating: ${marketModel.totalRating! / marketModel.totalNumberOfUserRating!}'),
                          Text(
                              'Delivery Fee:$currency${marketModel.deliveryFee}')
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Phone: ${marketModel.phonenumber}'),
                          Container(
                            width: 50,
                            height: 20,
                            decoration: const BoxDecoration(
                                color: Colors.blue,
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10))),
                            child: Center(
                              child: Text(
                                marketModel.openStatus == false
                                    ? 'Close'
                                    : 'Open',
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 10, top: 10),
          child: Align(
              alignment: Alignment.topLeft,
              child: InkWell(
                onTap: () {
                  Navigator.of(context).pop();
                },
                child: Container(
                  height: 40,
                  width: 40,
                  decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color.fromARGB(255, 236, 230, 230)),
                  child: const Icon(
                    Icons.arrow_back,
                    color: Colors.black,
                  ),
                ),
              )),
        ),
        Padding(
          padding: const EdgeInsets.only(right: 10, top: 10),
          child: Align(
              alignment: Alignment.topRight,
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
              )),
        )
      ],
    );
  }

  @override
  double get maxExtent => expandedHeight;

  @override
  double get minExtent => kToolbarHeight;

  @override
  bool shouldRebuild(SliverPersistentHeaderDelegate oldDelegate) => true;
}

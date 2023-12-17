import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../Model/market.dart';
import '../Pages/market_detail.dart';

class SearchPage extends StatefulWidget {
  final String? category;
  const SearchPage({Key? key, required this.category}) : super(key: key);

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final _searchController = TextEditingController();
  ListView? _listView;

  Future<List<MarketModel>> getMarkets() {
    return FirebaseFirestore.instance
        .collection('Markets')
        .where('Approval', isEqualTo: true)
        .get()
        .then((event) => event.docs
            .map((e) => MarketModel.fromMap(e.data(), e.id))
            .toList());
  }

  Future<List<MarketModel>> getMarketsByCategory() {
    return FirebaseFirestore.instance
        .collection('Markets')
        .where('Approval', isEqualTo: true)
        .where('Category', isEqualTo: widget.category)
        .get()
        .then((event) => event.docs
            .map((e) => MarketModel.fromMap(e.data(), e.id))
            .toList());
  }

  @override
  void initState() {
    super.initState();
  }

  String displayName = '';
  getList(int itemList) {
    if (displayName == '') {
      return 0;
    } else {
      return itemList;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            actions: const [],
            automaticallyImplyLeading: false,
            backgroundColor: Colors.white12,
            expandedHeight: 200,
            flexibleSpace: FlexibleSpaceBar(
              collapseMode: CollapseMode.pin,
              centerTitle: true,
              background: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(
                      height: 50,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.fromLTRB(5, 0, 97, 0),
                              child: const Text(
                                'search',
                                style: TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.bold),
                                textAlign: TextAlign.start,
                              ).tr(),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child:
                                  const Text('ordered by markets nearby').tr(),
                            ),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.only(right: 30),
                          child: InkWell(
                            onTap: () {
                              Navigator.of(context).pop();
                            },
                            child: const Icon(
                              Icons.close,
                              size: 30,
                            ),
                          ),
                        )
                      ],
                    ),
                    const SizedBox(height: 30),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
                      child: SizedBox(
                        height: 50,
                        width: MediaQuery.of(context).size.width / 1,
                        child: TextField(
                            onChanged: (value) {
                              setState(() {
                                displayName = value.toLowerCase();
                              });
                            },
                            controller: _searchController,
                            autofocus: true,
                            style: const TextStyle(color: Colors.grey),
                            decoration: InputDecoration(
                              focusColor: Colors.grey,
                              hintText: 'search for markets'.tr(),
                              hintStyle: const TextStyle(color: Colors.grey),
                              prefixIcon: Icon(
                                Icons.search,
                                size: 30,
                                color: Colors.blue.shade800,
                              ),
                              filled: true,
                              fillColor: Colors.white10,
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: const BorderSide(
                                    color: Colors.grey, width: 1.0),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(
                                    color: Colors.grey, width: 1.0),
                              ),
                            )),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SliverFillRemaining(
              child: ListView(
            shrinkWrap: true,
            scrollDirection: Axis.vertical,
            physics: const BouncingScrollPhysics(),
            children: [
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: const Text(
                  'Search Results',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.start,
                ).tr(),
              ),
              displayName == ''
                  ? Container()
                  : FutureBuilder<List<MarketModel>>(
                      future: widget.category == "Markets"
                          ? getMarkets()
                          : getMarketsByCategory(),
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          _listView = ListView.builder(
                              physics: const BouncingScrollPhysics(),
                              shrinkWrap: true,
                              itemCount: snapshot.data!.length,
                              itemBuilder: (context, i) {
                                MarketModel marketModel = snapshot.data![i];
                                return marketModel.marketName
                                        .toLowerCase()
                                        .contains(displayName)
                                    ? Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: marketModel.openStatus == true
                                            ? InkWell(
                                                onTap: () {
                                                  Navigator.of(context).push(
                                                      MaterialPageRoute(
                                                          builder: (context) =>
                                                              MarketDetail(
                                                                marketModel:
                                                                    marketModel,
                                                              )));
                                                },
                                                child: SizedBox(
                                                    height: 170,
                                                    width: 300,
                                                    child: Card(
                                                        elevation: 0,
                                                        shape:
                                                            RoundedRectangleBorder(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      15.0),
                                                        ),
                                                        child: Column(
                                                          children: [
                                                            Stack(
                                                              children: [
                                                                ClipRRect(
                                                                  borderRadius: const BorderRadius
                                                                          .only(
                                                                      topLeft: Radius
                                                                          .circular(
                                                                              15),
                                                                      topRight:
                                                                          Radius.circular(
                                                                              15)),
                                                                  child: Image
                                                                      .network(
                                                                    marketModel
                                                                        .image1,
                                                                    height: 100,
                                                                    fit: BoxFit
                                                                        .cover,
                                                                    width: double
                                                                        .infinity,
                                                                  ),
                                                                ),
                                                                Padding(
                                                                  padding: const EdgeInsets
                                                                          .only(
                                                                      top: 8,
                                                                      right: 8),
                                                                  child: Align(
                                                                    alignment:
                                                                        Alignment
                                                                            .topRight,
                                                                    child:
                                                                        InkWell(
                                                                      onTap:
                                                                          () {},
                                                                      child: Container(
                                                                          height:
                                                                              30,
                                                                          width:
                                                                              70,
                                                                          decoration: const BoxDecoration(
                                                                              color: Colors
                                                                                  .orange,
                                                                              shape: BoxShape
                                                                                  .rectangle),
                                                                          child: marketModel.openStatus == true
                                                                              ? Center(child: const Text('Open', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)).tr())
                                                                              : Center(child: const Text('Closed', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)).tr())),
                                                                    ),
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                            const SizedBox(
                                                                height: 10),
                                                            Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                          .only(
                                                                      left: 10),
                                                              child: Row(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .spaceBetween,
                                                                children: [
                                                                  Flexible(
                                                                    flex: 4,
                                                                    child: Text(
                                                                        marketModel
                                                                            .marketName,
                                                                        style: const TextStyle(
                                                                            fontSize:
                                                                                15,
                                                                            fontWeight: FontWeight
                                                                                .bold),
                                                                        overflow:
                                                                            TextOverflow.ellipsis),
                                                                  ),
                                                                  marketModel.totalNumberOfUserRating ==
                                                                          0
                                                                      ? Container()
                                                                      : Flexible(
                                                                          flex:
                                                                              2,
                                                                          child:
                                                                              Row(children: [
                                                                            const SizedBox(width: 20),
                                                                            RatingBarIndicator(
                                                                              rating: (marketModel.totalRating! / marketModel.totalNumberOfUserRating!).roundToDouble(),
                                                                              itemBuilder: (context, index) => const Icon(
                                                                                Icons.star,
                                                                                color: Colors.orange,
                                                                              ),
                                                                              itemCount: 5,
                                                                              itemSize: 12,
                                                                              direction: Axis.horizontal,
                                                                            ),
                                                                            Text(' ${(marketModel.totalRating! / marketModel.totalNumberOfUserRating!).roundToDouble()}',
                                                                                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold))
                                                                          ]))
                                                                ],
                                                              ),
                                                            ),
                                                            const SizedBox(
                                                                height: 1),
                                                            Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                          .only(
                                                                      left: 10),
                                                              child: Row(
                                                                children: [
                                                                  Flexible(
                                                                    flex: 6,
                                                                    child: Text(
                                                                        marketModel
                                                                            .address,
                                                                        overflow:
                                                                            TextOverflow.ellipsis),
                                                                  ),
                                                                ],
                                                              ),
                                                            )
                                                          ],
                                                        ))),
                                              )
                                            : InkWell(
                                                onTap: () {
                                                  Fluttertoast.showToast(
                                                      msg: "Market is closed"
                                                          .tr(),
                                                      toastLength:
                                                          Toast.LENGTH_SHORT,
                                                      gravity: ToastGravity.TOP,
                                                      timeInSecForIosWeb: 1,
                                                      fontSize: 14.0);
                                                },
                                                child: SizedBox(
                                                    height: 170,
                                                    width: 300,
                                                    child: Card(
                                                        elevation: 0,
                                                        shape:
                                                            RoundedRectangleBorder(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      15.0),
                                                        ),
                                                        child: Column(
                                                          children: [
                                                            Container(
                                                              height: 100,
                                                              width: double
                                                                  .infinity,
                                                              decoration:
                                                                  BoxDecoration(
                                                                image:
                                                                    DecorationImage(
                                                                  fit: BoxFit
                                                                      .fill,
                                                                  image:
                                                                      NetworkImage(
                                                                    marketModel
                                                                        .image1,
                                                                  ),
                                                                ),
                                                                borderRadius: const BorderRadius
                                                                        .only(
                                                                    topLeft: Radius
                                                                        .circular(
                                                                            15),
                                                                    topRight: Radius
                                                                        .circular(
                                                                            15)),
                                                              ),
                                                              child: Center(
                                                                  child: const Text(
                                                                          'Closed',
                                                                          style: TextStyle(
                                                                              color: Colors.white,
                                                                              fontWeight: FontWeight.bold,
                                                                              fontSize: 18))
                                                                      .tr()),
                                                            ),
                                                            const SizedBox(
                                                                height: 10),
                                                            Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                          .only(
                                                                      left: 10),
                                                              child: Row(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .spaceBetween,
                                                                children: [
                                                                  Flexible(
                                                                    flex: 4,
                                                                    child: Text(
                                                                        marketModel
                                                                            .marketName,
                                                                        style: const TextStyle(
                                                                            fontSize:
                                                                                15,
                                                                            fontWeight: FontWeight
                                                                                .bold),
                                                                        overflow:
                                                                            TextOverflow.ellipsis),
                                                                  ),
                                                                  marketModel.totalNumberOfUserRating ==
                                                                          0
                                                                      ? Container()
                                                                      : Flexible(
                                                                          flex:
                                                                              2,
                                                                          child:
                                                                              Row(children: [
                                                                            const SizedBox(width: 20),
                                                                            RatingBarIndicator(
                                                                              rating: (marketModel.totalRating! / marketModel.totalNumberOfUserRating!).roundToDouble(),
                                                                              itemBuilder: (context, index) => const Icon(
                                                                                Icons.star,
                                                                                color: Colors.orange,
                                                                              ),
                                                                              itemCount: 5,
                                                                              itemSize: 12,
                                                                              direction: Axis.horizontal,
                                                                            ),
                                                                            Text(' ${(marketModel.totalRating! / marketModel.totalNumberOfUserRating!).roundToDouble()}',
                                                                                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold))
                                                                          ]))
                                                                ],
                                                              ),
                                                            ),
                                                            const SizedBox(
                                                                height: 1),
                                                            Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                          .only(
                                                                      left: 10),
                                                              child: Row(
                                                                children: [
                                                                  Flexible(
                                                                    flex: 6,
                                                                    child: Text(
                                                                        marketModel
                                                                            .address,
                                                                        overflow:
                                                                            TextOverflow.ellipsis),
                                                                  ),
                                                                ],
                                                              ),
                                                            )
                                                          ],
                                                        ))),
                                              ),
                                      )
                                    : Container();
                              });
                          return _listView!;
                        } else {
                          return const Center(
                              child: SpinKitCircle(color: Colors.orange));
                        }
                      })
            ],
          ))
        ],
      ),
    );
  }
}

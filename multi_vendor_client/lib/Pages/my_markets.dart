import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:vendor/Model/market.dart';
import 'package:vendor/Pages/market_detail.dart';
import 'package:vendor/Widget/edit_market.dart';
import 'package:shimmer/shimmer.dart';
import 'package:easy_localization/easy_localization.dart';

class MyMarketsPage extends StatefulWidget {
  final String vendorID;
  const MyMarketsPage({Key? key, required this.vendorID}) : super(key: key);

  @override
  State<MyMarketsPage> createState() => _MyMarketsPageState();
}

class _MyMarketsPageState extends State<MyMarketsPage> {
  Stream<List<MarketModel>> getMyMarkets() {
    return FirebaseFirestore.instance
        .collection('Markets')
        .where('Vendor ID', isEqualTo: widget.vendorID)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => MarketModel.fromMap(doc.data(), doc.id))
          .toList();
    });
  }

  deleteMarket(String marketID) {
    FirebaseFirestore.instance
        .collection('Markets')
        .doc(marketID)
        .delete()
        .then((value) {
      Fluttertoast.showToast(
          msg: "Market has been deleted Successfully",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.TOP,
          timeInSecForIosWeb: 1,
         
          fontSize: 14.0);
    });
    Navigator.of(context).pop();
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          elevation: 0,
        //  backgroundColor: Colors.blue,
          title: const Text(
            'My Markets',
          ).tr(),
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.orange,
          onPressed: () {
            Navigator.of(context).pushNamed('/add-market');
          },
          child: const Icon(Icons.add, color: Colors.white),
        ),
        body: StreamBuilder<List<MarketModel>>(
            stream: getMyMarkets(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return const Text('Something went wrong');
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
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
                          child: ListView.builder(
                            itemBuilder: (_, __) => Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: SizedBox(
                                  height: 190,
                                  width: double.infinity,
                                  child: Card(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15.0),
                                    ),
                                  )),
                            ),
                            itemCount: 10,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }
              return ListView.builder(
                itemCount: snapshot.data!.length,
                physics: const BouncingScrollPhysics(),
                shrinkWrap: true,
                itemBuilder: (BuildContext buildContext, int index) {
                  MarketModel marketModel = snapshot.data![index];
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: InkWell(
                      onTap: () {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => MarketDetail(
                                marketModel: marketModel,
                                vendorID: widget.vendorID)));
                      },
                      child: SizedBox(
                          height: 190,
                          width: double.infinity,
                          child: Card(
                              elevation: 1,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15.0),
                              ),
                              child: Column(
                                children: [
                                  Stack(
                                    children: [
                                      ClipRRect(
                                        borderRadius: const BorderRadius.only(
                                            topLeft: Radius.circular(15),
                                            topRight: Radius.circular(15)),
                                        child: CachedNetworkImage(
                                          height: 120,
                                          fit: BoxFit.cover,
                                          width: double.infinity,
                                          imageUrl: marketModel.image1,
                                          placeholder: (context, url) =>
                                              const SpinKitRing(
                                            color: Colors.orange,
                                            size: 30,
                                            lineWidth: 3,
                                          ),
                                          errorWidget: (context, url, error) =>
                                              const Icon(Icons.error),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            top: 8, right: 8),
                                        child: Align(
                                          alignment: Alignment.topRight,
                                          child: InkWell(
                                            onTap: () {
                                              Navigator.of(context).push(
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          EditMarket(
                                                            marketModel:
                                                                marketModel,
                                                          )));
                                            },
                                            child: Container(
                                                height: 30,
                                                width: 30,
                                                decoration: const BoxDecoration(
                                                    color: Colors.orange,
                                                    shape: BoxShape.circle),
                                                child: const Icon(Icons.edit,
                                                    color: Colors.white)),
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            top: 8, left: 8),
                                        child: Align(
                                          alignment: Alignment.topLeft,
                                          child: InkWell(
                                            onTap: () {
                                              showDialog(
                                                  context: context,
                                                  builder: (builder) {
                                                    return AlertDialog(
                                                      title: const Text(
                                                              'Delete Market')
                                                          .tr(),
                                                      content: const Text(
                                                              'Are you sure you want to delete this Market?')
                                                          .tr(),
                                                      actions: [
                                                        InkWell(
                                                            onTap: () {
                                                              deleteMarket(
                                                                  marketModel
                                                                      .uid!);
                                                            },
                                                            child: const Text(
                                                                    'Yes')
                                                                .tr()),
                                                        const SizedBox(
                                                            width: 50),
                                                        InkWell(
                                                            onTap: () {
                                                              Navigator.of(
                                                                      context)
                                                                  .pop();
                                                            },
                                                            child:
                                                                const Text('No')
                                                                    .tr())
                                                      ],
                                                    );
                                                  });
                                            },
                                            child: Container(
                                                height: 30,
                                                width: 30,
                                                decoration: const BoxDecoration(
                                                    color: Colors.orange,
                                                    shape: BoxShape.circle),
                                                child: const Icon(Icons.delete,
                                                    color: Colors.white)),
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 10),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Flexible(
                                          flex: 4,
                                          child: Text(marketModel.marketName,
                                              style: const TextStyle(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.bold),
                                              overflow: TextOverflow.ellipsis),
                                        ),
                                        marketModel.totalNumberOfUserRating == 0
                                            ? Container()
                                            : Flexible(
                                                flex: 2,
                                                child: Row(children: [
                                                  const SizedBox(width: 20),
                                                  RatingBarIndicator(
                                                    rating: 5,
                                                    itemBuilder:
                                                        (context, index) =>
                                                            const Icon(
                                                      Icons.star,
                                                      color: Colors.orange,
                                                    ),
                                                    itemCount: 5,
                                                    itemSize: 12,
                                                    direction: Axis.horizontal,
                                                  ),
                                                  Text(
                                                      ' ${(marketModel.totalRating! / marketModel.totalNumberOfUserRating!).roundToDouble()}',
                                                      style: const TextStyle(
                                                          fontSize: 14,
                                                          fontWeight:
                                                              FontWeight.bold))
                                                ]))
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 1),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 10),
                                    child: Row(
                                      children: [
                                        Flexible(
                                          flex: 6,
                                          child: Text(marketModel.address,
                                              overflow: TextOverflow.ellipsis),
                                        ),
                                      ],
                                    ),
                                  )
                                ],
                              ))),
                    ),
                  );
                },
              );
            }));
  }
}

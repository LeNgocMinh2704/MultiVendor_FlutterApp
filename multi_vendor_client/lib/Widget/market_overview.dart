import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:vendor/Model/market.dart';
import 'package:vendor/Model/rating.dart';
import 'package:easy_localization/easy_localization.dart';

class MarketOverview extends StatefulWidget {
  final MarketModel marketModel;
  const MarketOverview({Key? key, required this.marketModel}) : super(key: key);

  @override
  State<MarketOverview> createState() => _MarketOverviewState();
}

class _MarketOverviewState extends State<MarketOverview> {
  Future<List<RatingModel>> getRating() {
    return FirebaseFirestore.instance
        .collection('Markets')
        .doc(widget.marketModel.uid)
        .collection('Ratings')
        .get()
        .then((event) => event.docs
            .map((e) => RatingModel.fromMap(e.data(), e.id))
            .toList());
  }

  bool status = false;
  getMarketStatus() {
    FirebaseFirestore.instance
        .collection('Markets')
        .doc(widget.marketModel.uid)
        .snapshots()
        .listen((v) {
      setState(() {
        status = v['Open Status'];
      });
    });
  }

  @override
  void initState() {
    getMarketStatus();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      shrinkWrap: true,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Market Status',
              style: TextStyle(fontSize: 16),
            ).tr(),
            FlutterSwitch(
              width: 110.0,
              height: 35.0,
              valueFontSize: 18.0,
              toggleSize: 25.0,
              value: status,
              borderRadius: 30.0,
              // padding: 8.0,
              activeText: 'Opened'.tr(),
              inactiveText: 'Closed'.tr(),
              showOnOff: true,
              onToggle: (val) {
                setState(() {
                  status = val;
                });
                FirebaseFirestore.instance
                    .collection('Markets')
                    .doc(widget.marketModel.uid)
                    .update({'Open Status': status});
              },
            ),
          ],
        ),
        const SizedBox(height: 20),
        ListTile(
          title: const Text('Market Approval Status').tr(),
          leading: const Icon(Icons.call_made),
          subtitle: Text(widget.marketModel.approval == true
              ? "Approved".tr()
              : "Not Approved".tr()),
        ),
        ListTile(
          title: const Text('Market Commission').tr(),
          leading: const Icon(Icons.monetization_on),
          subtitle: Text('${widget.marketModel.commission}%'),
        ),
        ListTile(
          title: const Text('Market Address').tr(),
          leading: const Icon(Icons.room),
          subtitle: Text(widget.marketModel.address),
        ),
        ListTile(
          title: const Text('Market Phonenumber').tr(),
          leading: const Icon(Icons.phone),
          subtitle: Text(widget.marketModel.phonenumber),
        ),
        ListTile(
          title: const Text('Market Opening Time').tr(),
          leading: const Icon(Icons.timer),
          subtitle: Text('${widget.marketModel.openingTime}am'),
        ),
        ListTile(
          title: const Text('Market Closing Time').tr(),
          leading: const Icon(Icons.timer),
          subtitle: Text('${widget.marketModel.closingTime}pm'),
        ),
        ListTile(
          title: const Text('Market Rating').tr(),
          leading: const Icon(Icons.rate_review),
        ),
        FutureBuilder<List<RatingModel>>(
            future: getRating(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return ListView.builder(
                    shrinkWrap: true,
                    physics: const BouncingScrollPhysics(),
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      RatingModel ratingModel = snapshot.data![index];
                      return Column(
                        children: [
                          ListTile(
                            leading: ratingModel.profilePicture == ''
                                ? ClipOval(
                                    child: CachedNetworkImage(
                                    height: 50,
                                    fit: BoxFit.cover,
                                    width: 50,
                                    imageUrl:
                                        "https://eitrawmaterials.eu/wp-content/uploads/2016/09/person-icon.png",
                                    placeholder: (context, url) =>
                                        const SpinKitRing(
                                      color: Colors.orange,
                                      size: 30,
                                      lineWidth: 3,
                                    ),
                                    errorWidget: (context, url, error) =>
                                        const Icon(Icons.error),
                                  ))
                                : ClipOval(
                                    child: CachedNetworkImage(
                                      height: 50,
                                      fit: BoxFit.cover,
                                      width: 50,
                                      imageUrl: ratingModel.profilePicture,
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
                            title: Text(ratingModel.fullname),
                            subtitle: widget
                                        .marketModel.totalNumberOfUserRating ==
                                    0
                                ? Container()
                                : RatingBarIndicator(
                                    rating: widget.marketModel.totalRating! /
                                        widget.marketModel
                                            .totalNumberOfUserRating!,
                                    itemBuilder: (context, index) => const Icon(
                                      Icons.star,
                                      color: Colors.orange,
                                    ),
                                    itemCount: 5,
                                    itemSize: 20,
                                    direction: Axis.horizontal,
                                  ),
                            trailing: Text(ratingModel.timeCreated),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Container(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                ratingModel.review,
                                textAlign: TextAlign.left,
                              ),
                            ),
                          ),
                        ],
                      );
                    });
              } else {
                return const Center(child: CircularProgressIndicator());
              }
            })
      ],
    );
  }
}

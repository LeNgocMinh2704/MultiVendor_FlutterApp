import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:vendor/Model/products.dart';
import 'package:carousel_pro_nullsafety/carousel_pro_nullsafety.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vendor/Model/rating.dart';

import '../Model/formatter.dart';

class ProductDetailsPage extends StatefulWidget {
  final String marketID;
  final ProductsModel productsModel;
  final String currency;
  const ProductDetailsPage(
      {Key? key,
      required this.marketID,
      required this.productsModel,
      required this.currency})
      : super(key: key);

  @override
  State<ProductDetailsPage> createState() => _ProductDetailsPageState();
}

class _ProductDetailsPageState extends State<ProductDetailsPage> {
  String doorDelivery = '';
  String pickUpDelivery = '';

  getMarketDetails() {
    FirebaseFirestore.instance
        .collection('Markets')
        .doc(widget.marketID)
        .get()
        .then((val) {
      setState(() {
        doorDelivery = val['doorDeliveryDetails'];
        pickUpDelivery = val['pickupDeliveryDetails'];
      });
    });
  }

  Future<List<RatingModel>> getRating() {
    return FirebaseFirestore.instance
        .collection('Markets')
        .doc(widget.productsModel.marketID)
        .collection('Products')
        .doc(widget.productsModel.productID)
        .collection('Ratings')
        .get()
        .then((event) => event.docs
            .map((e) => RatingModel.fromMap(e.data(), e.id))
            .toList());
  }

  num ratingAndReview = 0;
  num totalUser = 0;
  getRatingAndReview() {
    FirebaseFirestore.instance
        .collection('Markets')
        .doc(widget.productsModel.marketID)
        .collection('Products')
        .doc(widget.productsModel.productID)
        .collection('Ratings')
        .get()
        .then((val) {
      num rating = val.docs.fold(0, (tot, doc) => tot + doc.data()['rating']);
      num totalUserRating = val.docs.length;
      setState(() {
        ratingAndReview = (rating / totalUserRating).roundToDouble();
        totalUser = totalUserRating;
      });
    });
    //print('$ratingAndReview is the average rating');
    return ratingAndReview;
  }

  @override
  void initState() {
    getMarketDetails();
    getRatingAndReview();
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
            'Product Details',
          ).tr(),
        ),
        body: SingleChildScrollView(
            child: Column(children: [
          SizedBox(
              height: MediaQuery.of(context).size.height / 2.5,
              width: double.infinity,
              child: Container(
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.only(
                      bottomRight: Radius.circular(40.0),
                      bottomLeft: Radius.circular(40.0)),
                ),
                child: Carousel(
                  dotSize: 5,
                  animationDuration: const Duration(seconds: 10),
                  showIndicator: true,
                  images: [
                    widget.productsModel.image1 == ''
                        ? Image.network(
                            'https://cdn.iconscout.com/icon/free/png-256/gallery-187-902099.png',
                            fit: BoxFit.cover)
                        : Image.network(widget.productsModel.image1),
                    widget.productsModel.image2 == ''
                        ? Image.network(
                            'https://cdn.iconscout.com/icon/free/png-256/gallery-187-902099.png',
                            fit: BoxFit.cover)
                        : Image.network(widget.productsModel.image2),
                    widget.productsModel.image3 == ''
                        ? Image.network(
                            'https://cdn.iconscout.com/icon/free/png-256/gallery-187-902099.png',
                            fit: BoxFit.cover)
                        : Image.network(widget.productsModel.image3),
                  ],
                ),
              )),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                SizedBox(
                  width: MediaQuery.of(context).size.width / 1.1,
                  child: Text(widget.productsModel.name,
                      maxLines: 2,
                      style: const TextStyle(
                          fontSize: 15, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.start,
                      overflow: TextOverflow.ellipsis),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.only(left: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                    '${widget.currency}${Formatter().converter(widget.productsModel.unitPrice1.toDouble())}',
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold)),
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Row(
                    children: [
                      RatingBarIndicator(
                        rating: totalUser == 0
                            ? 0
                            : getRatingAndReview().toDouble(),
                        itemBuilder: (context, index) => const Icon(
                          Icons.star,
                          color: Colors.orange,
                        ),
                        itemCount: 5,
                        itemSize: 20,
                        direction: Axis.horizontal,
                      ),
                      const SizedBox(width: 5),
                      Text('(${totalUser.toString()})',
                          style: const TextStyle(color: Colors.grey)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 5),
          Padding(
            padding: const EdgeInsets.only(left: 8),
            child: Row(
              children: [
                Text(
                  '${widget.currency}${Formatter().converter(widget.productsModel.unitOldPrice1.toDouble())}',
                  style: const TextStyle(
                      fontSize: 13,
                      color: Colors.grey,
                      decoration: TextDecoration.lineThrough),
                ),
                const SizedBox(width: 5),
                Text(
                  '-${widget.productsModel.percantageDiscount.toString()}',
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.orange,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          ExpansionTile(
            leading: const Icon(Icons.list),
            initiallyExpanded: true,
            title: const Text('Other Variants',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))
                .tr(),
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 10, right: 10),
                child: SizedBox(
                  height: 60,
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(widget.productsModel.unitname1,
                                style: const TextStyle(
                                  color: Colors.grey,
                                )),
                            Row(children: [
                              Text(
                                  '${widget.currency}${Formatter().converter(widget.productsModel.unitPrice1.toDouble())}',
                                  style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold)),
                              const SizedBox(width: 5),
                              Text(
                                '${widget.currency}${Formatter().converter(widget.productsModel.unitOldPrice1.toDouble())}',
                                style: const TextStyle(
                                    fontSize: 15,
                                    color: Colors.grey,
                                    decoration: TextDecoration.lineThrough),
                              ),
                            ])
                          ]),
                    ),
                  ),
                ),
              ),
              widget.productsModel.unitname2 == ''
                  ? Container()
                  : Padding(
                      padding: const EdgeInsets.only(left: 10, right: 10),
                      child: SizedBox(
                        height: 60,
                        child: Card(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(widget.productsModel.unitname2,
                                      style: const TextStyle(
                                        color: Colors.grey,
                                      )),
                                  Row(children: [
                                    Text(
                                        '${widget.currency}${Formatter().converter(widget.productsModel.unitPrice2.toDouble())}',
                                        style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold)),
                                    const SizedBox(width: 5),
                                    Text(
                                      '${widget.currency}${Formatter().converter(widget.productsModel.unitOldPrice2.toDouble())}',
                                      style: const TextStyle(
                                          fontSize: 15,
                                          color: Colors.grey,
                                          decoration:
                                              TextDecoration.lineThrough),
                                    ),
                                  ])
                                ]),
                          ),
                        ),
                      ),
                    ),
              widget.productsModel.unitname3 == ''
                  ? Container()
                  : Padding(
                      padding: const EdgeInsets.only(left: 10, right: 10),
                      child: SizedBox(
                        height: 60,
                        child: Card(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(widget.productsModel.unitname3,
                                      style: const TextStyle(
                                        color: Colors.grey,
                                      )),
                                  Row(children: [
                                    Text(
                                        '${widget.currency}${Formatter().converter(widget.productsModel.unitPrice3.toDouble())}',
                                        style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold)),
                                    const SizedBox(width: 5),
                                    Text(
                                      '${widget.currency}${Formatter().converter(widget.productsModel.unitOldPrice3.toDouble())}',
                                      style: const TextStyle(
                                          fontSize: 15,
                                          color: Colors.grey,
                                          decoration:
                                              TextDecoration.lineThrough),
                                    ),
                                  ])
                                ]),
                          ),
                        ),
                      ),
                    ),
              widget.productsModel.unitname4 == ''
                  ? Container()
                  : Padding(
                      padding: const EdgeInsets.only(left: 10, right: 10),
                      child: SizedBox(
                        height: 60,
                        child: Card(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(widget.productsModel.unitname4,
                                      style: const TextStyle(
                                        color: Colors.grey,
                                      )),
                                  Row(children: [
                                    Text(
                                        '${widget.currency}${Formatter().converter(widget.productsModel.unitPrice4.toDouble())}',
                                        style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold)),
                                    const SizedBox(width: 5),
                                    Text(
                                      '${widget.currency}${Formatter().converter(widget.productsModel.unitOldPrice4.toDouble())}',
                                      style: const TextStyle(
                                          fontSize: 15,
                                          color: Colors.grey,
                                          decoration:
                                              TextDecoration.lineThrough),
                                    ),
                                  ])
                                ]),
                          ),
                        ),
                      ),
                    ),
              widget.productsModel.unitname5 == ''
                  ? Container()
                  : Padding(
                      padding: const EdgeInsets.only(left: 10, right: 10),
                      child: SizedBox(
                        height: 60,
                        child: Card(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(widget.productsModel.unitname5,
                                      style: const TextStyle(
                                        color: Colors.grey,
                                      )),
                                  Row(children: [
                                    Text(
                                        '${widget.currency}${Formatter().converter(widget.productsModel.unitPrice5.toDouble())}',
                                        style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold)),
                                    const SizedBox(width: 5),
                                    Text(
                                      '${widget.currency}${Formatter().converter(widget.productsModel.unitOldPrice5.toDouble())}',
                                      style: const TextStyle(
                                          fontSize: 15,
                                          color: Colors.grey,
                                          decoration:
                                              TextDecoration.lineThrough),
                                    ),
                                  ])
                                ]),
                          ),
                        ),
                      ),
                    ),
              widget.productsModel.unitname6 == ''
                  ? Container()
                  : Padding(
                      padding: const EdgeInsets.only(left: 10, right: 10),
                      child: SizedBox(
                        height: 60,
                        child: Card(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(widget.productsModel.unitname6,
                                      style: const TextStyle(
                                        color: Colors.grey,
                                      )),
                                  Row(children: [
                                    Text(
                                        '${widget.currency}${Formatter().converter(widget.productsModel.unitPrice6.toDouble())}',
                                        style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold)),
                                    const SizedBox(width: 5),
                                    Text(
                                      '${widget.currency}${Formatter().converter(widget.productsModel.unitOldPrice6.toDouble())}',
                                      style: const TextStyle(
                                          fontSize: 15,
                                          color: Colors.grey,
                                          decoration:
                                              TextDecoration.lineThrough),
                                    ),
                                  ])
                                ]),
                          ),
                        ),
                      ),
                    ),
              widget.productsModel.unitname7 == ''
                  ? Container()
                  : Padding(
                      padding: const EdgeInsets.only(left: 10, right: 10),
                      child: SizedBox(
                        height: 60,
                        child: Card(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(widget.productsModel.unitname7,
                                      style: const TextStyle(
                                        color: Colors.grey,
                                      )),
                                  Row(children: [
                                    Text(
                                        '${widget.currency}${Formatter().converter(widget.productsModel.unitPrice7.toDouble())}',
                                        style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold)),
                                    const SizedBox(width: 5),
                                    Text(
                                      '${widget.currency}${Formatter().converter(widget.productsModel.unitOldPrice7.toDouble())}',
                                      style: const TextStyle(
                                          fontSize: 15,
                                          color: Colors.grey,
                                          decoration:
                                              TextDecoration.lineThrough),
                                    ),
                                  ])
                                ]),
                          ),
                        ),
                      ),
                    )
            ],
          ),
          ExpansionTile(
              initiallyExpanded: true,
              leading: const Icon(Icons.assignment),
              title: const Text('Product Description',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold))
                  .tr(),
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Text(widget.productsModel.description),
                    ],
                  ),
                ),
              ]),
          ExpansionTile(
              initiallyExpanded: true,
              leading: const Icon(
                Icons.rate_review,
              ),
              title: const Text('Product Review',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold))
                  .tr(),
              children: [
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
                                            errorWidget:
                                                (context, url, error) =>
                                                    const Icon(Icons.error),
                                          ))
                                        : ClipOval(
                                            child: CachedNetworkImage(
                                              height: 50,
                                              fit: BoxFit.cover,
                                              width: 50,
                                              imageUrl:
                                                  ratingModel.profilePicture,
                                              placeholder: (context, url) =>
                                                  const SpinKitRing(
                                                color: Colors.orange,
                                                size: 30,
                                                lineWidth: 3,
                                              ),
                                              errorWidget:
                                                  (context, url, error) =>
                                                      const Icon(Icons.error),
                                            ),
                                          ),
                                    title: Text(ratingModel.fullname),
                                    subtitle: RatingBarIndicator(
                                      rating: ratingModel.rating.toDouble(),
                                      itemBuilder: (context, index) =>
                                          const Icon(
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
              ])
        ])));
  }
}

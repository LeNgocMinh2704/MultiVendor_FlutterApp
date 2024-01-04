import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:rider/Model/rating.dart';

class ReviewsPage extends StatefulWidget {
  const ReviewsPage({Key? key}) : super(key: key);

  @override
  State<ReviewsPage> createState() => _ReviewsPageState();
}

class _ReviewsPageState extends State<ReviewsPage> {
  DocumentReference? userRef;

  Future<List<RatingModel>> getRating() {
    return userRef!.collection('Ratings').get().then((event) =>
        event.docs.map((e) => RatingModel.fromMap(e.data(), e.id)).toList());
  }

  Future<void> _getUserDoc() async {
    final FirebaseAuth auth = FirebaseAuth.instance;
    final FirebaseFirestore firestore = FirebaseFirestore.instance;

    User? user = auth.currentUser;
    setState(() {
      userRef = firestore.collection('drivers').doc(user!.uid);
    });
  }

  @override
  void initState() {
    _getUserDoc();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            centerTitle: true,
            elevation: 0,
            title: const Text(
              'Reviews',
            ).tr()),
        body: FutureBuilder<List<RatingModel>>(
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
                            subtitle: RatingBarIndicator(
                              rating: ratingModel.rating.toDouble(),
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
            }));
  }
}

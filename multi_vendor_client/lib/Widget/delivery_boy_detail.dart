import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:vendor/Model/other_users.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:vendor/Model/rating.dart';
import 'package:url_launcher/url_launcher.dart';

class DeliveryBoyDetail extends StatefulWidget {
  final OtherUserModel otherUserModel;
  const DeliveryBoyDetail({Key? key, required this.otherUserModel})
      : super(key: key);

  @override
  State<DeliveryBoyDetail> createState() => _DeliveryBoyDetailState();
}

class _DeliveryBoyDetailState extends State<DeliveryBoyDetail> {
  String userID = '';
  bool confirmFav = false;
  DocumentReference? userRef;

  Future<void> _getUserDetails() async {
    final FirebaseAuth auth = FirebaseAuth.instance;
    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    User? user = auth.currentUser;
    setState(() {
      userRef =
          firestore.collection('vendors').doc(user!.uid).get().then((value) {
        setState(() {
          userID = value['id'];
        });
        if (userID != '') {
          FirebaseFirestore.instance
              .collection('vendors')
              .doc(userID)
              .collection('Delivery Boys')
              .where('id', isEqualTo: widget.otherUserModel.uid)
              .get()
              .then((value) {
            setState(() {
              confirmFav = value.docs.isNotEmpty;
              //print('Confirmation is $confirmFav');
            });
          });
        }
      }) as DocumentReference<Object?>?;
    });
  }

  addToFvorite(OtherUserModel otherUserModel) {
    FirebaseFirestore.instance
        .collection('vendors')
        .doc(userID)
        .collection('Delivery Boys')
        .doc(widget.otherUserModel.uid)
        .set(otherUserModel.toMap())
        .then((value) {
      Fluttertoast.showToast(
          msg: "Rider Added To Favorite",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.TOP,
          timeInSecForIosWeb: 1,
          
          fontSize: 14.0);
      Navigator.of(context).pop();
    });
  }

  @override
  void initState() {
    _getUserDetails();
    super.initState();
  }

  void _launchURL() async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: widget.otherUserModel.phonenumber,
    );
    await launchUrl(launchUri);
    // if (!await launch(widget.otherUserModel.phonenumber))
    //   throw 'Could not launch ${widget.otherUserModel.phonenumber}';
  }

  Future<List<RatingModel>> getRating() {
    return FirebaseFirestore.instance
        .collection('drivers')
        .doc(widget.otherUserModel.uid)
        .collection('Ratings')
        .get()
        .then((event) => event.docs
            .map((e) => RatingModel.fromMap(e.data(), e.id))
            .toList());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          centerTitle: true,
          elevation: 0,
          title: const Text('Delivery Boy Profile').tr()),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  const Text('RIDER PERSONAL DATA',
                          style: TextStyle(
                              color: Colors.grey, fontWeight: FontWeight.bold))
                      .tr(),
                ],
              ),
            ),
            Column(
              children: [
                const SizedBox(height: 20),
                ClipOval(
                  child: CachedNetworkImage(
                    height: 120,
                    fit: BoxFit.cover,
                    width: 120,
                    imageUrl: widget.otherUserModel.photoUrl == ''
                        ? "https://eitrawmaterials.eu/wp-content/uploads/2016/09/person-icon.png"
                        : widget.otherUserModel.photoUrl,
                    placeholder: (context, url) => const SpinKitRing(
                      color: Colors.orange,
                      size: 30,
                      lineWidth: 3,
                    ),
                    errorWidget: (context, url, error) =>
                        const Icon(Icons.error),
                  ),
                ),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    children: [
                      const Flexible(
                          flex: 1,
                          child: Icon(
                            Icons.person,
                            size: 40,
                            color: Colors.grey,
                          )),
                      const SizedBox(
                        width: 10,
                      ),
                      Flexible(
                        flex: 6,
                        child: TextFormField(
                          readOnly: true,
                          keyboardType: TextInputType.name,
                          initialValue: widget.otherUserModel.displayName,
                          decoration:
                              const InputDecoration(focusColor: Colors.orange),
                        ),
                      )
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    children: [
                      const Flexible(
                          flex: 1,
                          child: Icon(
                            Icons.email_outlined,
                            size: 40,
                            color: Colors.grey,
                          )),
                      const SizedBox(
                        width: 10,
                      ),
                      Flexible(
                        flex: 6,
                        child: TextFormField(
                          readOnly: true,
                          keyboardType: TextInputType.emailAddress,
                          initialValue: widget.otherUserModel.email,
                          decoration:
                              const InputDecoration(focusColor: Colors.orange),
                        ),
                      )
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    children: [
                      const Flexible(
                          flex: 1,
                          child: Icon(
                            Icons.phone,
                            size: 40,
                            color: Colors.grey,
                          )),
                      const SizedBox(
                        width: 10,
                      ),
                      Flexible(
                        flex: 6,
                        child: TextFormField(
                          readOnly: true,
                          keyboardType: TextInputType.phone,
                          initialValue: widget.otherUserModel.phonenumber,
                          decoration:
                              const InputDecoration(focusColor: Colors.orange),
                        ),
                      )
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    children: [
                      const Flexible(
                          flex: 1,
                          child: Icon(
                            Icons.location_city,
                            size: 40,
                            color: Colors.grey,
                          )),
                      const SizedBox(
                        width: 10,
                      ),
                      Flexible(
                          flex: 6,
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                    width: 2, color: Colors.grey.shade400),
                              ),
                            ),
                            child: ListTile(
                              onTap: () {},
                              title: Text(widget.otherUserModel.address,
                                  style: TextStyle(color: Colors.grey[600])),
                            ),
                          ))
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                        onPressed: () {
                          _launchURL();
                        },
                        child: const Text('Call Rider').tr()),
                  ),
                ),
                confirmFav == true
                    ? Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                              onPressed: () {
                                FirebaseFirestore.instance
                                    .collection('vendors')
                                    .doc(userID)
                                    .collection('Delivery Boys')
                                    .doc(widget.otherUserModel.uid)
                                    .delete()
                                    .then((value) {
                                  Fluttertoast.showToast(
                                      msg: "Rider Removed From Favorite".tr(),
                                      toastLength: Toast.LENGTH_SHORT,
                                      gravity: ToastGravity.TOP,
                                      timeInSecForIosWeb: 1,
                                    
                                      fontSize: 14.0);
                                  Navigator.of(context).pop();
                                });
                              },
                              child: const Text('Remove From Favorite').tr()),
                        ),
                      )
                    : Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                              onPressed: () {
                                addToFvorite(OtherUserModel(
                                    uid: widget.otherUserModel.uid,
                                    email: widget.otherUserModel.email,
                                    displayName:
                                        widget.otherUserModel.displayName,
                                    id: widget.otherUserModel.uid,
                                    photoUrl: widget.otherUserModel.photoUrl,
                                    phonenumber:
                                        widget.otherUserModel.phonenumber,
                                    address: widget.otherUserModel.address));
                              },
                              child: const Text('Add To Favorite').tr()),
                        ),
                      ),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(children: [
                    const Text('Review And Rating',
                            style: TextStyle(fontWeight: FontWeight.bold))
                        .tr()
                  ]),
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
              ],
            )
          ],
        ),
      ),
    );
  }
}

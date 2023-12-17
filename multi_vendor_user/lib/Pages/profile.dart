import 'dart:async';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_custom_clippers/flutter_custom_clippers.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import '../Providers/auth.dart';
import '../Widgets/autocomplete.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  DocumentReference? userRef;
  DocumentReference? userDetails;
  String fullname = '';
  String email = '';
  String phone = '';
  String password = '';
  final _formKey = GlobalKey<FormState>();
  String userPic = '';
  String address = 'Address';
  String userPicMain = '';
  String addressMain = '';
  num cartQuantity = 0;
  String referralCode = '';

  @override
  void initState() {
    super.initState();
    _getUserDetails();
    _getUserDoc();
  }

  Future<void> _getUserDoc() async {
    final FirebaseAuth auth = FirebaseAuth.instance;
    final FirebaseFirestore firestore = FirebaseFirestore.instance;

    User? user = auth.currentUser;
    setState(() {
      userRef = firestore.collection('users').doc(user!.uid);
    });
  }

  Future<void> _getUserDetails() async {
    final FirebaseAuth auth = FirebaseAuth.instance;
    final FirebaseFirestore firestore = FirebaseFirestore.instance;

    User? user = auth.currentUser;
    setState(() {
      userDetails =
          firestore.collection('users').doc(user!.uid).get().then((value) {
        setState(() {
          email = value['email'];
          fullname = value['fullname'];
          phone = value['phone'];
          userPic = value['photoUrl'];
          addressMain = value['address'];
          referralCode = value['personalReferralCode'];
        });
      }) as DocumentReference<Object?>?;
    });
  }

  _navigateAndDisplaySelection(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => CustomSearchScaffold()),
    );
    setState(() {
      address = result ?? '';
      debugPrint(address);
    });
  }

  // Select and image from the gallery or take a picture with the camera
  // Then upload to Firebase Storage

  XFile? imageFile;
  bool? loading;
  Future<void> _upload() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    setState(() {
      imageFile = image;
      loading = true;
    });
    if (imageFile != null) {
      var snapshot = await FirebaseStorage.instance
          .ref()
          .child(imageFile!.path)
          .putFile(File(imageFile!.path));
      String downloadUrl =
          await snapshot.ref.getDownloadURL().whenComplete(() => setState(() {
                loading = false;
              }));

      setState(() {
        userPicMain = downloadUrl;
      });
      debugPrint(userPicMain);
    }
  }

  whenAddressIsEmpty() {
    if (addressMain == '') {
      return address;
    } else {
      return addressMain;
    }
  }

  whenProfilePicIsempty() {
    if (userPicMain == '') {
      return userPic;
    } else {
      return userPicMain;
    }
  }

  getCart() {
    if (userRef == null) {
      return null;
    } else {
      userRef!.collection('Cart').get().then((val) {
        num tempTotal =
            val.docs.fold(0, (tot, doc) => tot + doc.data()['quantity']);

        setState(() {
          cartQuantity = tempTotal;
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        iconTheme: Theme.of(context).iconTheme,
        titleTextStyle: TextStyle(color: Theme.of(context).indicatorColor),
        backgroundColor: Theme.of(context).colorScheme.background,
        centerTitle: true,
        elevation: 0,
        title: const Text(
          'Profile',
        ).tr(),
      ),
      body: SingleChildScrollView(
        child: SizedBox(
          height: MediaQuery.of(context).size.height,
          child: Column(
            children: [
              Form(
                key: _formKey,
                child: Expanded(
                  flex: 7,
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          children: [
                            const Text('YOUR PERSONAL DATA',
                                    style: TextStyle(
                                        color: Colors.grey,
                                        fontWeight: FontWeight.bold))
                                .tr(),
                          ],
                        ),
                      ),
                      Stack(
                        children: [
                          imageFile != null
                              ? ClipOval(
                                  child: Image.file(
                                  File(imageFile!.path),
                                  fit: BoxFit.cover,
                                  height: 120,
                                  width: 120,
                                ))
                              : ClipOval(
                                  child: CachedNetworkImage(
                                    height: 120,
                                    fit: BoxFit.cover,
                                    width: 120,
                                    imageUrl: userPic == ''
                                        ? "https://eitrawmaterials.eu/wp-content/uploads/2016/09/person-icon.png"
                                        : userPic,
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
                          Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.orange,
                                ),
                                child: IconButton(
                                  icon: const Icon(
                                    Icons.camera_alt,
                                    color: Colors.white,
                                  ),
                                  onPressed: () async {
                                    _upload();
                                  },
                                ),
                              ))
                        ],
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
                                keyboardType: TextInputType.name,
                                validator: (value) {
                                  if (value!.isEmpty && fullname.isEmpty) {
                                    return 'Required field'.tr();
                                  } else {
                                    return null;
                                  }
                                },
                                decoration: InputDecoration(
                                    hintText: fullname,
                                    focusColor: Colors.orange),
                                onChanged: (value) {
                                  setState(() {
                                    fullname = value;
                                  });
                                },
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
                                decoration: InputDecoration(
                                    hintText: email, focusColor: Colors.orange),
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
                                onTap: () {
                                  Fluttertoast.showToast(
                                      msg: "Phone number can't be changed".tr(),
                                      toastLength: Toast.LENGTH_SHORT,
                                      gravity: ToastGravity.CENTER,
                                      timeInSecForIosWeb: 1,
                                      fontSize: 14.0);
                                },
                                readOnly: true,
                                validator: (value) {
                                  if (value!.isEmpty && phone.isEmpty) {
                                    return 'Required field'.tr();
                                  } else {
                                    return null;
                                  }
                                },
                                keyboardType: TextInputType.phone,
                                onChanged: (value) {
                                  setState(() {
                                    phone = value;
                                  });
                                },
                                decoration: InputDecoration(
                                    hintText: phone, focusColor: Colors.orange),
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
                                          width: 2,
                                          color: Colors.grey.shade400),
                                    ),
                                  ),
                                  child: ListTile(
                                    onTap: () {
                                      _navigateAndDisplaySelection(context);
                                    },
                                    title: Text(
                                            addressMain == ''
                                                ? address
                                                : addressMain,
                                            style: TextStyle(
                                                color: Colors.grey[600]))
                                        .tr(),
                                  ),
                                ))
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      loading == true
                          ? Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: SizedBox(
                                  height: 50,
                                  width: double.infinity,
                                  child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.orange),
                                      onPressed: null,
                                      child: const Text('Save',
                                              style: TextStyle(
                                                  fontSize: 20,
                                                  color: Colors.white))
                                          .tr())),
                            )
                          : Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: SizedBox(
                                  height: 50,
                                  width: double.infinity,
                                  child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.orange),
                                      onPressed: () async {
                                        if (_formKey.currentState!.validate()) {
                                          AuthService().updateProfile(
                                              fullname,
                                              phone,
                                              context,
                                              userPicMain,
                                              whenAddressIsEmpty());
                                        }
                                      },
                                      child: const Text('Save',
                                              style: TextStyle(
                                                  fontSize: 20,
                                                  color: Colors.white))
                                          .tr())),
                            ),
                    ],
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: ClipPath(
                  clipper: OvalTopBorderClipper(),
                  child: Container(
                    color: Colors.blue,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

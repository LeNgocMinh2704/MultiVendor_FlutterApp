import 'dart:io';
import 'package:date_time_picker/date_time_picker.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geocode/geocode.dart';
import 'package:image_picker/image_picker.dart';
import 'package:vendor/Model/market.dart';
import 'package:vendor/Pages/my_markets.dart';
import 'package:vendor/Widget/autocomplete.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EditMarket extends StatefulWidget {
  final MarketModel marketModel;
  const EditMarket({Key? key, required this.marketModel}) : super(key: key);

  @override
  State<EditMarket> createState() => _EditMarketState();
}

class _EditMarketState extends State<EditMarket> {
  XFile? _image1;
  XFile? _image2;
  XFile? _image3;
  String marketName = '';
  String description = '';
  num deliveryFee = 0;
  String openingTime = '';
  String closingTime = '';
  String image1 = '';
  String image2 = '';
  String image3 = '';
  String timeCreated = '';
  String vendorID = '';
  String phoneNumber = '';
  String marketID = '';
  bool openedMarket = false;
  List<String> categories = [];
  String category = '';
  String address = 'Address';
  final _formKey = GlobalKey<FormState>();
  DocumentReference? userDetails;
  num addressLat = 0;
  num addressLong = 0;

  bool? loading;

  Future<void> _uploadImage1() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    //print(image);
    setState(() {
      _image1 = image;
      loading = true;
    });
    if (_image1 != null) {
      var snapshot = await FirebaseStorage.instance
          .ref()
          .child(_image1!.path)
          .putFile(File(_image1!.path));
      String downloadUrl =
          await snapshot.ref.getDownloadURL().whenComplete(() => setState(() {
                loading = false;
              }));

      setState(() {
        image1 = downloadUrl;
      });
      //print(image1);
    }
  }

  Future<void> _uploadImage2() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    //print(image);
    setState(() {
      _image2 = image;
      loading = true;
    });
    if (_image2 != null) {
      var snapshot = await FirebaseStorage.instance
          .ref()
          .child(_image2!.path)
          .putFile(File(_image2!.path));
      String downloadUrl =
          await snapshot.ref.getDownloadURL().whenComplete(() => setState(() {
                loading = false;
              }));

      setState(() {
        image2 = downloadUrl;
      });
      //print(image2);
    }
  }

  Future<void> _uploadImage3() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    //print(image);
    setState(() {
      _image3 = image;
      loading = true;
    });
    if (_image3 != null) {
      var snapshot = await FirebaseStorage.instance
          .ref()
          .child(_image3!.path)
          .putFile(File(_image3!.path));
      String downloadUrl =
          await snapshot.ref.getDownloadURL().whenComplete(() => setState(() {
                loading = false;
              }));

      setState(() {
        image3 = downloadUrl;
      });
      //print(image3);
    }
  }

  Future<void> _getUserDetails() async {
    final FirebaseAuth auth = FirebaseAuth.instance;
    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    User? user = auth.currentUser;
    setState(() {
      userDetails =
          firestore.collection('vendors').doc(user!.uid).get().then((value) {
        setState(() {
          vendorID = value['id'];
        });
      }) as DocumentReference<Object?>?;
    });
  }

  getCategories() {
    FirebaseFirestore.instance.collection('Categories').get().then((value) {
      //print('Length is ${value.docs.length}');
      for (var element in value.docs) {
        categories.add(element.data()['category']);
      }
    });
  }

  addMarket(MarketModel marketModel) {
    FirebaseFirestore.instance
        .collection('Markets')
        .doc(widget.marketModel.uid)
        .update(marketModel.toMap())
        .then((value) {
      Navigator.of(context).push(MaterialPageRoute(
          builder: (context) =>
              MyMarketsPage(vendorID: widget.marketModel.vendorId)));
      Fluttertoast.showToast(
          msg: "Market updated successfully".tr(),
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.TOP,
          timeInSecForIosWeb: 1,
       
          fontSize: 14.0);
    });
  }

  @override
  void initState() {
    getCategories();
    getCity();
    _getUserDetails();
    super.initState();
  }

  List<String> cities = [];
  String city = '';
  getCity() {
    FirebaseFirestore.instance.collection('Cities').get().then((value) {
      // ignore: avoid_function_literals_in_foreach_calls
      return value.docs.forEach((element) {
        cities.add(element.data()['cityName']);
      });
    });
  }

  _navigateAndDisplaySelection(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => CustomSearchScaffold()),
    );
    setState(() {
      address = result ?? '';
      //print(address);
    });
  }

  dynamic themeMode;
  getThemeDetail() async {
    SharedPreferences.getInstance().then((prefs) {
      var lightModeOn = prefs.getBool('lightMode');
      setState(() {
        themeMode = lightModeOn!;
      });
    });
  }

  getMarketLatAndLong() async {
    GeoCode geoCode = GeoCode();
    if (address != 'Address') {
      //print('Address is empty');
    } else {
      try {
        Coordinates coordinates =
            await geoCode.forwardGeocoding(address: address);
        setState(() {
          addressLat = coordinates.latitude!;
          addressLong = coordinates.longitude!;
        });
      } catch (e) {
        //print(e);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    //print('Market UID ${widget.marketModel.uid}');
    getThemeDetail();
    getMarketLatAndLong();
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        elevation: 0,
        title: const Text(
          'Edit market',
        ).tr(),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(
                height: 20,
              ),
              Padding(
                padding: const EdgeInsets.only(left: 20, right: 20, bottom: 10),
                child: Row(
                  children: [const Text('Market name').tr(), const Text('*')],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 20, right: 20),
                child: SizedBox(
                  height: 45,
                  child: TextFormField(
                    onSaved: (value) {
                      setState(() {
                        marketName = value!;
                      });
                    },
                    onChanged: (value) {
                      setState(() {
                        marketName = value;
                      });
                    },
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Required field'.tr();
                      } else {
                        return null;
                      }
                    },
                    decoration: InputDecoration(
                      hintText: widget.marketModel.marketName,
                      focusColor: Colors.grey,
                      filled: true,
                      fillColor: Colors.white10,
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide:
                            const BorderSide(color: Colors.grey, width: 1.0),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide:
                            const BorderSide(color: Colors.grey, width: 1.0),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide:
                            const BorderSide(color: Colors.grey, width: 1.0),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              Padding(
                padding: const EdgeInsets.only(left: 20, right: 20, bottom: 10),
                child: Row(
                  children: [const Text('Address').tr(), const Text('*')],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 20, right: 20),
                child: SizedBox(
                  height: 45,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                        side: const BorderSide(width: 1.0, color: Colors.grey)),
                    onPressed: () {
                      _navigateAndDisplaySelection(context);
                    },
                    child: Row(
                      children: [
                        Flexible(
                          flex: 6,
                          child: Text(
                              address == 'Address'
                                  ? widget.marketModel.address
                                  : address,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  color: themeMode == null
                                      ? Colors.black
                                      : themeMode == true
                                          ? Colors.black
                                          : Colors.white)),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              Padding(
                padding: const EdgeInsets.only(left: 20, right: 20, bottom: 10),
                child: Row(
                  children: [
                    const Text(
                      'Phone number',
                    ).tr(),
                    const Text('*')
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 20, right: 20),
                child: SizedBox(
                  height: 45,
                  child: TextFormField(
                    onSaved: (value) {
                      setState(() {
                        phoneNumber = value!;
                      });
                    },
                    onChanged: (value) {
                      setState(() {
                        phoneNumber = value;
                      });
                    },
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Required field'.tr();
                      } else {
                        return null;
                      }
                    },
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      hintText: widget.marketModel.phonenumber,
                      focusColor: Colors.grey,
                      filled: true,
                      fillColor: Colors.white10,
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide:
                            const BorderSide(color: Colors.grey, width: 1.0),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide:
                            const BorderSide(color: Colors.grey, width: 1.0),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide:
                            const BorderSide(color: Colors.grey, width: 1.0),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              Padding(
                padding: const EdgeInsets.only(left: 20, right: 20, bottom: 10),
                child: Row(
                  children: [
                    const Text(
                      'Category',
                    ).tr(),
                    const Text('*')
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 20, right: 20),
                child: SizedBox(
                  height: 45,
                  child: DropdownSearch<String>(
                    validator: (v) => v == null ? "Required field".tr() : null,
                    dropdownDecoratorProps: DropDownDecoratorProps(
                        dropdownSearchDecoration: InputDecoration(
                      hintText: widget.marketModel.category,
                    )),
                    popupProps:
                        const PopupProps.bottomSheet(showSelectedItems: true),
                    // dropdownSearchDecoration: InputDecoration(
                    //   border: OutlineInputBorder(
                    //     borderRadius: BorderRadius.circular(8),
                    //     borderSide: BorderSide(color: Colors.grey, width: 1.0),
                    //   ),
                    // ),

                    items: categories,
                    // label: "Categories *",

                    onSaved: (value) {
                      setState(() {
                        category = value!;
                        //print(category);
                      });
                    },
                    onChanged: (value) {
                      setState(() {
                        category = value!;
                        //print(category);
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              Padding(
                padding: const EdgeInsets.only(left: 20, right: 20, bottom: 10),
                child: Row(
                  children: [const Text('Delivery Fee').tr(), const Text('*')],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 20, right: 20),
                child: SizedBox(
                  height: 70,
                  child: TextFormField(
                    onSaved: (value) {
                      setState(() {
                        deliveryFee = int.parse(value!);
                      });
                    },
                    onChanged: (value) {
                      setState(() {
                        deliveryFee = int.parse(value);
                      });
                    },
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Required field'.tr();
                      } else {
                        return null;
                      }
                    },
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                        helperText:
                            'Insert your preferred delivery fee per (Km,m. etc).'
                                .tr(),
                        focusColor: Colors.grey,
                        filled: true,
                        fillColor: Colors.white10,
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide:
                              const BorderSide(color: Colors.grey, width: 1.0),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide:
                              const BorderSide(color: Colors.grey, width: 1.0),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide:
                              const BorderSide(color: Colors.grey, width: 1.0),
                        ),
                        hintText: '${widget.marketModel.deliveryFee}'),
                  ),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              Padding(
                padding: const EdgeInsets.only(left: 20, right: 20, bottom: 10),
                child: Row(
                  children: [const Text('Opening Time').tr(), const Text('*')],
                ),
              ),
              SizedBox(
                height: 45,
                child: Padding(
                  padding: const EdgeInsets.only(left: 20, right: 20),
                  child: DateTimePicker(
                    decoration: InputDecoration(
                      hintText: '${widget.marketModel.openingTime}:AM',
                      focusColor: Colors.grey,
                      filled: true,
                      fillColor: Colors.white10,
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide:
                            const BorderSide(color: Colors.grey, width: 1.0),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide:
                            const BorderSide(color: Colors.grey, width: 1.0),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide:
                            const BorderSide(color: Colors.grey, width: 1.0),
                      ),
                    ),
                    type: DateTimePickerType.time,
                    icon: const Icon(Icons.access_time),
                    timeLabelText: '${widget.marketModel.openingTime}:AM',
                    use24HourFormat: false,
                    locale: const Locale('pt', 'BR'),
                    onSaved: (val) => setState(() => openingTime = val!),
                    onChanged: (val) => setState(() => openingTime = val),
                    // validator: (val) {
                    //   setState(() => _valueToValidate4 = val ?? '');
                    //   return null;
                    // },
                    // onSaved: (val) => setState(() => _valueSaved4 = val ?? ''),
                  ),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              Padding(
                padding: const EdgeInsets.only(left: 20, right: 20, bottom: 10),
                child: Row(
                  children: [const Text('Closing Time').tr(), const Text('*')],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 20, right: 20),
                child: DateTimePicker(
                  decoration: InputDecoration(
                    hintText: '${widget.marketModel.closingTime}:PM',
                    focusColor: Colors.grey,
                    filled: true,
                    fillColor: Colors.white10,
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide:
                          const BorderSide(color: Colors.grey, width: 1.0),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide:
                          const BorderSide(color: Colors.grey, width: 1.0),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide:
                          const BorderSide(color: Colors.grey, width: 1.0),
                    ),
                  ),
                  type: DateTimePickerType.time,
                  icon: const Icon(Icons.access_time),
                  timeLabelText: '${widget.marketModel.closingTime}:PM',
                  use24HourFormat: false,
                  locale: const Locale('pt', 'BR'),
                  onSaved: (val) => setState(() => closingTime = val!),
                  onChanged: (val) => setState(() => closingTime = val),
                  // validator: (val) {
                  //   setState(() => _valueToValidate4 = val ?? '');
                  //   return null;
                  // },
                  // onSaved: (val) => setState(() => _valueSaved4 = val ?? ''),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              CheckboxListTile(
                title: const Text('Opened Market').tr(),
                value: openedMarket,
                onChanged: (bool? value) {
                  setState(() {
                    openedMarket = !openedMarket;
                  });
                },
              ),
              const SizedBox(
                height: 20,
              ),
              Padding(
                padding: const EdgeInsets.only(left: 20, right: 20, bottom: 10),
                child: Row(
                  children: [
                    const Text('Market Gallery').tr(),
                    const Text('*')
                  ],
                ),
              ),
              _image1 == null
                  ? widget.marketModel.image1 == ''
                      ? const Icon(Icons.image, color: Colors.grey, size: 120)
                      : Image.network(widget.marketModel.image1,
                          width: 120, height: 120)
                  : Image.file(File(_image1!.path), width: 120, height: 120),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                        style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.orange),
                        onPressed: () {
                          _uploadImage1();
                        },
                        child: const Text('Add Image 1',
                                style: TextStyle(color: Colors.white))
                            .tr()),
                  ],
                ),
              ),
              _image2 == null
                  ? widget.marketModel.image2 == ''
                      ? const Icon(Icons.image, color: Colors.grey, size: 120)
                      : Image.network(widget.marketModel.image2,
                          width: 120, height: 120)
                  : Image.file(File(_image2!.path), width: 120, height: 120),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                        style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.orange),
                        onPressed: () {
                          _uploadImage2();
                        },
                        child: const Text('Add Image 2',
                                style: TextStyle(color: Colors.white))
                            .tr()),
                  ],
                ),
              ),
              _image3 == null
                  ? widget.marketModel.image3 == ''
                      ? const Icon(Icons.image, color: Colors.grey, size: 120)
                      : Image.network(widget.marketModel.image3,
                          width: 120, height: 120)
                  : Image.file(File(_image3!.path), width: 120, height: 120),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                        style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.orange),
                        onPressed: () {
                          _uploadImage3();
                        },
                        child: const Text('Add Image 3',
                                style: TextStyle(color: Colors.white))
                            .tr()),
                  ],
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              loading == true
                  ? Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ElevatedButton(
                          style:
                              ElevatedButton.styleFrom(
                                              backgroundColor: Colors.orange),
                          onPressed: null,
                          child: const Text('Update market',
                                  style: TextStyle(color: Colors.white))
                              .tr()),
                    )
                  : Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.orange),
                            onPressed: () {
                              addMarket(MarketModel(
                                  city: city == ''
                                      ? widget.marketModel.city
                                      : city,
                                  commission: widget.marketModel.commission,
                                  lat: address == 'Address'
                                      ? widget.marketModel.lat
                                      : addressLat,
                                  long: address == 'Address'
                                      ? widget.marketModel.long
                                      : addressLong,
                                  doorDeliveryDetails: '',
                                  pickupDeliveryDetails: '',
                                  totalNumberOfUserRating: widget
                                      .marketModel.totalNumberOfUserRating,
                                  totalRating: widget.marketModel.totalRating,
                                  category: whenCategoryIsNull(),
                                  marketName: whenMarketNameIsNull(),
                                  phonenumber: whenPhonenumberIsNull(),
                                  address: whenAddressIsNull(),
                                  description: whenDescriptionIsNull(),
                                  deliveryFee: whenDeliveryFeeIsNull(),
                                  openingTime: whenOpeningTimeIsNull(),
                                  closingTime: whenClosingTimeIsNull(),
                                  openStatus: openedMarket,
                                  vendorId: widget.marketModel.vendorId,
                                  image1: whenImage1Null(),
                                  image2: whenImage2Null(),
                                  image3: whenImage3Null(),
                                  timeCreated: widget.marketModel.timeCreated,
                                  approval: widget.marketModel.approval));
                            },
                            child: const Text('Create market',
                                    style: TextStyle(color: Colors.white))
                                .tr()),
                      ),
                    )
            ],
          ),
        ),
      ),
    );
  }

  whenCategoryIsNull() {
    if (category == '') {
      return widget.marketModel.category;
    } else {
      return category;
    }
  }

  whenMarketNameIsNull() {
    if (marketName == '') {
      return widget.marketModel.marketName;
    } else {
      return marketName;
    }
  }

  whenPhonenumberIsNull() {
    if (phoneNumber == '') {
      return widget.marketModel.phonenumber;
    } else {
      return phoneNumber;
    }
  }

  whenAddressIsNull() {
    if (address == 'Address') {
      return widget.marketModel.address;
    } else {
      return address;
    }
  }

  whenDescriptionIsNull() {
    if (description == '') {
      return widget.marketModel.description;
    } else {
      return description;
    }
  }

  whenDeliveryFeeIsNull() {
    if (deliveryFee == 0) {
      return widget.marketModel.deliveryFee;
    } else {
      return deliveryFee;
    }
  }

  whenOpeningTimeIsNull() {
    if (openingTime == '') {
      return widget.marketModel.openingTime;
    } else {
      return openingTime;
    }
  }

  whenClosingTimeIsNull() {
    if (closingTime == '') {
      return widget.marketModel.closingTime;
    } else {
      return closingTime;
    }
  }

  whenImage1Null() {
    if (image1 == '') {
      return widget.marketModel.image1;
    } else {
      return image1;
    }
  }

  whenImage2Null() {
    if (image2 == '') {
      return widget.marketModel.image2;
    } else {
      return image2;
    }
  }

  whenImage3Null() {
    if (image3 == '') {
      return widget.marketModel.image3;
    } else {
      return image3;
    }
  }
}

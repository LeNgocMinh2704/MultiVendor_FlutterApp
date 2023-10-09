import 'dart:async';

import 'package:extended_nested_scroll_view/extended_nested_scroll_view.dart';
import 'package:flutter/material.dart' hide Badge;
import 'package:flutter_close_app/flutter_close_app.dart';
import 'package:flutter_custom_clippers/flutter_custom_clippers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:list_tile_switch/list_tile_switch.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../Providers/auth.dart';
import '../../../Theme/theme.dart';
import '../../../Theme/theme_data.dart';
import '../../../Widgets/add_delivery_address.dart';
import '../../../Widgets/categories_intro.dart';
import '../../../Widgets/drawer_clippath.dart';
import '../../../Widgets/markets_intro.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:badges/badges.dart';
import 'package:geocoding/geocoding.dart';
import '../../../Widgets/search.dart';
import '../../../Widgets/search_products.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  final ScrollController sc = ScrollController();
  final GlobalKey<ScaffoldState> _scaffoldHome = GlobalKey<ScaffoldState>();
  DocumentReference? userRef;
  DocumentReference? userDetails;
  String fullname = '';
  String email = '';
  String userPic = '';
  num wallet = 0;
  String currencySymbol = '';
  bool courier = false;
  num cartQuantity = 0;
  String deliveryAddress = '';
  String address = '';
  double addressLat = 0;
  double addressLong = 0;
  String search = 'Search on'.tr();

  Future<void> _getUserDoc() async {
    final FirebaseAuth auth = FirebaseAuth.instance;
    final FirebaseFirestore firestore = FirebaseFirestore.instance;

    User? user = auth.currentUser;
    setState(() {
      userRef = firestore.collection('users').doc(user!.uid);
    });
  }

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

  getCourierStatus() {
    FirebaseFirestore.instance
        .collection('Courier System')
        .doc('Courier System')
        .get()
        .then((v) {
      setState(() {
        courier = v['Enable Courier'];
      });
    });
  }

  Timer? _timer;
  @override
  void initState() {
    getCourierStatus();
    _getUserDetails();
    _getUserDeliveryStatus();
    getLocation();
    getReferralStatus();
    EasyLoading.addStatusCallback((status) {
      if (status == EasyLoadingStatus.dismiss) {
        _timer?.cancel();
      }
    });
    getAuth();
    _getUserDoc();
    super.initState();
  }

  @override
  void dispose() {
    sc.dispose();

    super.dispose();
  }

  openDrawerHome() {
    _scaffoldHome.currentState!.openDrawer();
  }

  launchLoader() async {
    _timer?.cancel();
    await EasyLoading.show(
      status: 'Please wait...',
      maskType: EasyLoadingMaskType.black,
    );
  }

  Future<void> _getUserDeliveryStatus() async {
    final FirebaseAuth auth = FirebaseAuth.instance;
    final FirebaseFirestore firestore = FirebaseFirestore.instance;

    User? user = auth.currentUser;
    setState(() {
      userDetails =
          firestore.collection('users').doc(user!.uid).get().then((value) {
        getCart();
        if (value['DeliveryAddress'] == '') {
          launchLoader();
          Future.delayed(const Duration(seconds: 3), () async {
            _timer?.cancel();
            await EasyLoading.dismiss().then((value) {
              Fluttertoast.showToast(
                  msg: "Please Add Your Delivery Address.".tr(),
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.TOP,
                  timeInSecForIosWeb: 1,
                  fontSize: 14.0);
              showDialog(
                  context: context,
                  builder: (context) {
                    return const Material(child: AddDeliveryAddress());
                  });
            });
          });
        }
      }) as DocumentReference<Object?>?;
    });
  }

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
          wallet = value['wallet'];
          deliveryAddress = value['DeliveryAddress'];
        });
      }) as DocumentReference<Object?>?;
    });
  }

  bool isLogged = false;
  getAuth() {
    FirebaseAuth.instance.authStateChanges().listen((User? user) async {
      if (user == null) {
        setState(() {
          isLogged = false;
        });
      } else {
        setState(() {
          isLogged = true;
        });
      }
    });
  }

  getLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.best)
        .then((value) async {
      getAddress(value.latitude, value.longitude);
      setState(() {
        addressLat = value.latitude;
        addressLong = value.longitude;
      });
    });
  }

  getAddress(double lat, double long) async {
    List<Placemark> placemarks = await placemarkFromCoordinates(lat, long);
    for (var element in placemarks) {
      setState(() {
        address = element.street!;
      });
    }
  }

  bool referralStatus = false;
  getReferralStatus() {
    FirebaseFirestore.instance
        .collection('Referral System')
        .doc('Referral System')
        .snapshots()
        .listen((value) {
      setState(() {
        referralStatus = value['Status'];
      });
    });
  }

  dynamic themeMode;
  var _lightTheme = true;
  void onThemeChanged(bool value, ThemeNotifier themeNotifier) async {
    (value)
        ? themeNotifier.setTheme(lightTheme)
        : themeNotifier.setTheme(darkTheme);
    var prefs = await SharedPreferences.getInstance();
    prefs.setBool('lightMode', value);
  }

  getThemeDetail() async {
    SharedPreferences.getInstance().then((prefs) {
      var lightModeOn = prefs.getBool('lightMode');
      setState(() {
        themeMode = lightModeOn!;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    getThemeDetail();
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    return WillPopScope(
      onWillPop: () async {
        if (_scaffoldHome.currentState!.isDrawerOpen) {
          Navigator.of(context).pop();
          return false;
        }
        return true;
      },
      child: Scaffold(
        key: _scaffoldHome,
        drawer: SizedBox(
          width: double.infinity,
          child: Drawer(
            child: ListView(children: [
              DrawerHeader(
                padding: EdgeInsets.zero,
                child: ClipPath(
                  clipper: CustomClipPath(),
                  child: Container(
                    height: 200,
                    color: Colors.blue,
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            IconButton(
                                color: Colors.black,
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                icon: const Icon(Icons.arrow_back)),
                            // IconButton(
                            //     color: Colors.black,
                            //     onPressed: () {},
                            //     icon: const Icon(Icons.call)),
                          ],
                        ),
                        isLogged == false
                            ? const Text('Hello, Guest',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 25,
                                )).tr()
                            : Text('Hello, $fullname',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 25,
                                ))
                      ],
                    ),
                  ),
                ),
              ),
              ListTile(
                  title: const Text(
                "Account",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ).tr()),
              ListTile(
                onTap: () {
                  if (userRef == null) {
                    Navigator.of(context).pushNamed('/login');
                  } else {
                    Navigator.of(context).pushNamed('/orders');
                  }
                },
                leading: const Icon(Icons.shopping_bag),
                title: const Text(
                  "Orders",
                  style: TextStyle(
                    fontSize: 18,
                  ),
                ).tr(),
                trailing: const Icon(Icons.chevron_right),
              ),
              ListTile(
                onTap: () {
                  if (userRef == null) {
                    Navigator.of(context).pushNamed('/login');
                  } else {
                    Navigator.of(context).pushNamed('/courier');
                  }
                },
                leading: const Icon(Icons.delivery_dining),
                title: const Text(
                  "Logistics/Courier",
                  style: TextStyle(
                    fontSize: 18,
                  ),
                ).tr(),
                trailing: const Icon(Icons.chevron_right),
              ),
              ListTile(
                onTap: () {
                  if (userRef == null) {
                    Navigator.of(context).pushNamed('/login');
                  } else {
                    Navigator.of(context).pushNamed('/profile');
                  }
                },
                leading: const Icon(Icons.person),
                title: const Text(
                  "Profile",
                  style: TextStyle(
                    fontSize: 18,
                  ),
                ).tr(),
                trailing: const Icon(Icons.chevron_right),
              ),
              ListTile(
                onTap: () {
                  if (userRef == null) {
                    Navigator.of(context).pushNamed('/login');
                  } else {
                    Navigator.of(context).pushNamed('/delivery-address');
                  }
                },
                leading: const Icon(Icons.room),
                title: const Text(
                  "Delivery Address",
                  style: TextStyle(
                    fontSize: 18,
                  ),
                ).tr(),
                trailing: const Icon(Icons.chevron_right),
              ),
              ListTile(
                onTap: () {
                  if (userRef == null) {
                    Navigator.of(context).pushNamed('/login');
                  } else {
                    Navigator.of(context).pushNamed('/wallet');
                  }
                },
                leading: const Icon(Icons.wallet),
                title: const Text(
                  "Wallet",
                  style: TextStyle(
                    fontSize: 18,
                  ),
                ).tr(),
                trailing: const Icon(Icons.chevron_right),
              ),
              ListTile(
                onTap: () {
                  if (userRef == null) {
                    Navigator.of(context).pushNamed('/login');
                  } else {
                    Navigator.of(context).pushNamed('/favorites');
                  }
                },
                leading: const Icon(Icons.favorite),
                title: const Text(
                  "Favorites",
                  style: TextStyle(
                    fontSize: 18,
                  ),
                ).tr(),
                trailing: const Icon(Icons.chevron_right),
              ),
              const Divider(
                endIndent: 10,
                indent: 10,
                color: Colors.grey,
                thickness: 1,
              ),
              referralStatus == false
                  ? const SizedBox()
                  : ListTile(
                      onTap: () {
                        if (userRef == null) {
                          Navigator.of(context).pushNamed('/login');
                        } else {
                          Navigator.of(context).pushNamed('/referral-page');
                        }
                      },
                      leading: const Icon(Icons.wallet_giftcard),
                      title: const Text(
                        "Share and earn",
                        style: TextStyle(
                          fontSize: 18,
                        ),
                      ).tr(),
                      trailing: const Icon(Icons.chevron_right),
                    ),
              ListTile(
                onTap: () {
                  Navigator.of(context).pushNamed('/coupon');
                },
                leading: const Icon(Icons.card_giftcard),
                title: const Text(
                  "Promo Code",
                  style: TextStyle(
                    fontSize: 18,
                  ),
                ).tr(),
                trailing: const Icon(Icons.chevron_right),
              ),
              ListTile(
                onTap: () {
                  Navigator.of(context).pushNamed('/faq');
                },
                leading: const Icon(Icons.help_center_rounded),
                title: const Text(
                  "F.A.Q.",
                  style: TextStyle(
                    fontSize: 18,
                  ),
                ).tr(),
                trailing: const Icon(Icons.chevron_right),
              ),
              ListTile(
                onTap: () {
                  if (userRef == null) {
                    Navigator.of(context).pushNamed('/login');
                  } else {
                    Navigator.of(context).pushNamed('/notifications');
                  }
                },
                leading: const Icon(Icons.notifications),
                title: const Text(
                  "Notifications",
                  style: TextStyle(
                    fontSize: 18,
                  ),
                ).tr(),
                trailing: const Icon(Icons.chevron_right),
              ),
              ListTile(
                onTap: () {
                  Navigator.of(context).pushNamed('/language');
                },
                leading: const Icon(Icons.language),
                title: const Text(
                  "Language",
                  style: TextStyle(
                    fontSize: 18,
                  ),
                ).tr(),
                trailing: const Icon(Icons.chevron_right),
              ),
              ListTileSwitch(
                  leading: const Icon(Icons.color_lens),
                  title: const Text('Theme Mode',
                      style: TextStyle(
                        fontSize: 18,
                      )).tr(),
                  // ignore: prefer_if_null_operators
                  value: themeMode == null ? true : themeMode,
                  onChanged: (val) {
                    setState(() {
                      _lightTheme = val;
                      themeMode = val;
                    });
                    onThemeChanged(val, themeNotifier);
                    debugPrint(_lightTheme.toString());
                  }),
              isLogged == true
                  ? ListTile(
                      onTap: () {
                        AuthService().signOut(context);
                      },
                      leading: const Icon(Icons.logout),
                      title: const Text(
                        "Log out",
                        style: TextStyle(
                          fontSize: 18,
                        ),
                      ).tr(),
                    )
                  : ListTile(
                      onTap: () {
                        Navigator.of(context).pushNamed('/login');
                      },
                      leading: const Icon(Icons.login),
                      title: const Text(
                        "Log in",
                        style: TextStyle(
                          fontSize: 18,
                        ),
                      ).tr(),
                    ),
            ]),
          ),
        ),
        backgroundColor: themeMode == true || themeMode == null
            ? Colors.blue
            : const Color(0xFF362F2F),
        body: FlutterCloseAppPage(
            interval: 2,
            condition: true,
            onCloseFailed: () {
              // The interval is more than 2 seconds, or the return key is pressed for the first time
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                content: Text('Press again to exit'),
              ));
            },
            child: _buildScaffoldBody(openDrawerHome)),
      ),
    );
  }

  late double pinnedHeaderHeight;
  Widget _buildScaffoldBody(Function openDrawerHome) {
    final double statusBarHeight = MediaQuery.of(context).padding.top;
    pinnedHeaderHeight = statusBarHeight + kToolbarHeight;
    return ExtendedNestedScrollView(
      controller: sc,
      headerSliverBuilder: (BuildContext c, bool f) {
        return <Widget>[
          SliverAppBar(
              backgroundColor: themeMode == true || themeMode == null
                  ? Colors.blue
                  : const Color(0xFF362F2F),
              automaticallyImplyLeading: false,
              pinned: true,
              centerTitle: true,
              expandedHeight: 420,
              leading: InkWell(
                onTap: () {
                  openDrawerHome();
                },
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    height: 70,
                    width: 70,
                    decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color.fromARGB(255, 236, 230, 230)),
                    child: const Icon(
                      Icons.person,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
              actions: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
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
                ),
              ],
              title: SizedBox(
                  width: MediaQuery.of(context).size.width / 1.2,
                  height: 40,
                  child: TextField(
                    readOnly: true,
                    onTap: () {
                      showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              title: Column(
                                children: const [
                                  Text('Select your search category'),
                                ],
                              ),
                              content: SizedBox(
                                height: 150,
                                width: 100,
                                child: Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: [
                                      OutlinedButton(
                                          onPressed: () {
                                            Navigator.of(context)
                                                .push(MaterialPageRoute(
                                                    builder: (context) =>
                                                        const SearchProductPage(
                                                          category: "",
                                                          marketID: '',
                                                        )))
                                                .then((value) =>
                                                    Navigator.of(context)
                                                        .pop());
                                          },
                                          child: const Text('Products')),
                                      OutlinedButton(
                                          onPressed: () {
                                            Navigator.of(context)
                                                .push(MaterialPageRoute(
                                                    builder: (context) =>
                                                        const SearchPage(
                                                            category:
                                                                "Markets")))
                                                .then((value) =>
                                                    Navigator.of(context)
                                                        .pop());
                                          },
                                          child: const Text('Markets')),
                                    ]),
                              ),
                            );
                          });
                    },
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.search),
                      filled: true,
                      fillColor: Colors.white,
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
              flexibleSpace: FlexibleSpaceBar(
                background: SingleChildScrollView(
                  physics: const NeverScrollableScrollPhysics(),
                  child: Column(
                    children: [
                      const SizedBox(height: 110),
                      TextButton(
                        onPressed: () {
                          if (userRef == null) {
                            Navigator.of(context).pushNamed('/login');
                          } else {
                            Navigator.of(context)
                                .pushNamed('/delivery-address');
                          }
                        },
                        child: Text(
                          userRef == null ? '$address ▼' : '$deliveryAddress ▼',
                          style: TextStyle(
                              color: themeMode == true || themeMode == null
                                  ? Colors.black
                                  : Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 20, right: 20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Choose a category',
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                              textAlign: TextAlign.center,
                            ).tr(),
                            TextButton(
                                child: const Text(
                                  'View All',
                                  style: TextStyle(
                                      color: Colors.orange,
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold),
                                  textAlign: TextAlign.center,
                                ).tr(),
                                onPressed: () {
                                  Navigator.pushNamed(context, '/categories');
                                })
                          ],
                        ),
                      ),
                      Padding(
                        padding: MediaQuery.of(context).size.width >= 1100
                            ? const EdgeInsets.only(left: 200, right: 200)
                            : const EdgeInsets.only(left: 8, right: 8),
                        child: SizedBox(
                            height: 250,
                            width: double.infinity,
                            child: Padding(
                                padding:
                                    MediaQuery.of(context).size.width >= 1100
                                        ? const EdgeInsets.only(
                                            left: 200, right: 200)
                                        : const EdgeInsets.all(0),
                                child: const CategoriesIntro())),
                      ),
                    ],
                  ),
                ),
              ))
        ];
      },
      //1.[pinned sliver header issue](https://github.com/flutter/flutter/issues/22393)
      pinnedHeaderSliverHeightBuilder: () {
        return pinnedHeaderHeight;
      },
      body: ClipPath(
        clipper: OvalTopBorderClipper(),
        child: Container(
            color: Theme.of(context).primaryColor,
            child: SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  const SizedBox(
                    height: 30,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 20, right: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Available Markets',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ).tr(),
                        TextButton(
                            child: const Text(
                              'View All',
                              style: TextStyle(
                                  color: Colors.orange,
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold),
                              textAlign: TextAlign.center,
                            ).tr(),
                            onPressed: () {
                              Navigator.pushNamed(context, '/markets');
                            })
                      ],
                    ),
                  ),
                  SizedBox(
                      height: MediaQuery.of(context).size.height / 1,
                      width: double.infinity,
                      child: Padding(
                          padding: MediaQuery.of(context).size.width >= 1100
                              ? const EdgeInsets.only(left: 200, right: 200)
                              : const EdgeInsets.all(0),
                          child: const MarketsIntro())),
                  const SizedBox(
                    height: 100,
                  )
                ],
              ),
            )),
      ),
    );
  }
}

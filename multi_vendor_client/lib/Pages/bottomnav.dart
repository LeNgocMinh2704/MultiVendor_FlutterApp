// import 'package:animations/animations.dart';
import 'package:badges/badges.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart' hide Badge;
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:list_tile_switch/list_tile_switch.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:vendor/Pages/flash_sales_widget.dart';
import 'package:vendor/Pages/home.dart';
import 'package:vendor/Pages/products_widget.dart';
import '../Providers/auth.dart';
import '../Theme/theme.dart';
import '../Theme/theme_data.dart';
import '../Widget/drawer_clippath.dart';
// import 'categories.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter_close_app/flutter_close_app.dart';
import 'my_markets.dart';
// import 'search.dart';

class BottomNav extends StatefulWidget {
  const BottomNav({Key? key}) : super(key: key);

  @override
  State<BottomNav> createState() => _BottomNavState();
}

class _BottomNavState extends State<BottomNav> {
  int _currentIndex = 0;

  String pageName = 'Feeds'.tr();
  DocumentReference? userRef;
  DocumentReference? userDetails;
  String fullname = 'fetching data...'.tr();
  String email = 'fetching data...'.tr();
  String appName = 'Olivette';
  String vendorID = '';
  final GlobalKey<CurvedNavigationBarState> _bottomNavigationKey = GlobalKey();

  Future<void> _getUserDoc() async {
    final FirebaseAuth auth = FirebaseAuth.instance;
    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    User? user = auth.currentUser;
    setState(() {
      userRef = firestore.collection('vendors').doc(user!.uid);
    });
  }

  void _handleGetDeviceState() async {
    //print("Getting DeviceState");
    var deviceState = await OneSignal.shared.getDeviceState();
    // ignore: unused_local_variable
    dynamic playerId = deviceState!.userId;
    //print(playerId);
  }

  Future<void> _getUserDetails() async {
    final FirebaseAuth auth = FirebaseAuth.instance;
    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    User? user = auth.currentUser;
    setState(() {
      userDetails = firestore
          .collection('vendors')
          .doc(user!.uid)
          .snapshots()
          .listen((value) {
        setState(() {
          fullname = value['fullname'].split(' ')[0].trim();
          email = value['email'];
          vendorID = value['id'];
        });
      }) as DocumentReference<Object?>?;
    });
  }

  @override
  void initState() {
    super.initState();
    _getUserDoc();
    getAuth();
    getHistory();
    _getUserDetails();
  }

  channgeCurrentPage() {
    setState(() {
      _currentIndex = 1;
      final CurvedNavigationBarState? navBarState =
          _bottomNavigationKey.currentState;
      navBarState?.setPage(1);
    });
  }

  @override
  void dispose() {
    super.dispose();
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

  bool verification = true;

  verificationStatus() {
    final FirebaseAuth auth = FirebaseAuth.instance;
    User? user = auth.currentUser;
    if (userRef == null) {
      return null;
    } else {
      return user!.reload().then((value) {
        setState(() {
          verification = user.emailVerified;
          //print(user.emailVerified);
        });
      });
    }
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

  openDrawerHome() {
    _scaffoldHome.currentState!.openDrawer();
  }

  final GlobalKey<ScaffoldState> _scaffoldHome = GlobalKey<ScaffoldState>();
  num notification = 0;
  getHistory() {
    return userRef!
        .collection('Notifications')
        .orderBy('timeCreated', descending: true)
        .snapshots()
        .listen((snapshot) {
      setState(() {
        notification = snapshot.docs.length;
      });
    });
  }

  String hello = 'Hello'.tr();
  @override
  Widget build(BuildContext context) {
    getThemeDetail();
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    _handleGetDeviceState();
    return WillPopScope(
      onWillPop: () async {
        if (_scaffoldHome.currentState!.isDrawerOpen) {
          Navigator.of(context).pop();
          return false;
        }
        return true;
      },
      child: DefaultTabController(
        length: _currentIndex == 0 ? 5 : 0,
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
                              : Text('$hello, $fullname',
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
                      Navigator.of(context).pushNamed('/bottomNav');
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
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) =>
                                MyMarketsPage(vendorID: vendorID)));
                      }
                    },
                    leading: const Icon(Icons.local_mall),
                    title: const Text(
                      'My Markets',
                      style: TextStyle(
                        fontSize: 18,
                      ),
                    ).tr(),
                    trailing: const Icon(Icons.chevron_right)),
                ListTile(
                    onTap: () {
                      if (userRef == null) {
                        Navigator.of(context).pushNamed('/login');
                      } else {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) =>
                                ProductPage(vendorID: vendorID)));
                      }
                    },
                    leading: const Icon(Icons.local_mall),
                    title: const Text(
                      'Products',
                      style: TextStyle(
                        fontSize: 18,
                      ),
                    ).tr(),
                    trailing: const Icon(Icons.chevron_right)),
                ListTile(
                    onTap: () {
                      if (userRef == null) {
                        Navigator.of(context).pushNamed('/login');
                      } else {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) =>
                                FlashSalePage(vendorID: vendorID)));
                      }
                    },
                    leading: const Icon(Icons.local_mall),
                    title: const Text(
                      'Flash Sales',
                      style: TextStyle(
                        fontSize: 18,
                      ),
                    ).tr(),
                    trailing: const Icon(Icons.chevron_right)),
                ListTile(
                  onTap: () {
                    if (userRef == null) {
                      Navigator.of(context).pushNamed('/login');
                    } else {
                      Navigator.of(context).pushNamed('/delivery-boys');
                    }
                  },
                  leading: const Icon(Icons.delivery_dining),
                  title: const Text(
                    "Favorite Delivery boys",
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
                const Divider(
                  endIndent: 10,
                  indent: 10,
                  color: Colors.grey,
                  thickness: 1,
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
                      Navigator.of(context).pushNamed('/inbox');
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
                    Navigator.of(context).pushNamed('/language-settings');
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
                          "Log Out",
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
          appBar: AppBar(
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
              // backgroundColor: Colors.blue,
              centerTitle: true,
              elevation: 0,
              automaticallyImplyLeading: false,
              bottom: _currentIndex == 0
                  ? TabBar(
                      isScrollable: true,
                      indicatorColor: Colors.white,
                      labelColor: Colors.white,
                      tabs: [
                        Tab(text: 'All'.tr()),
                        Tab(text: 'Received'.tr()),
                        Tab(text: 'Processing'.tr()),
                        Tab(text: 'Completed'.tr()),
                        Tab(text: 'Cancelled'.tr()),
                      ],
                    )
                  : null,
              actions: [
                InkWell(
                  onTap: () {
                    Navigator.pushNamed(context, '/inbox');
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      height: 50,
                      width: 50,
                      decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color.fromARGB(255, 236, 230, 230)),
                      child: Badge(
                        badgeStyle: const BadgeStyle(
                          badgeColor: Colors.orange,
                        ),
                        badgeContent: Text(
                          notification.toString(),
                          style: const TextStyle(color: Colors.white),
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.notifications,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                  ),
                )
              ]),
          body: FlutterCloseAppPage(
              interval: 2,
              condition: true,
              onCloseFailed: () {
                // The interval is more than 2 seconds, or the return key is pressed for the first time
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text('Press again to exit'),
                ));
              },
              child: const HomePage()),
        ),
      ),
    );
  }
}

DateTime? backbuttonpressedTime;
Future<bool> onWillPop() async {
  DateTime currentTime = DateTime.now();
  //Statement 1 Or statement2
  bool backButton = currentTime.difference(backbuttonpressedTime!) >
      const Duration(seconds: 1);
  if (backButton) {
    backbuttonpressedTime = currentTime;
    Fluttertoast.showToast(
        msg: "Tap again to leave",
        backgroundColor: Colors.black,
        textColor: Colors.white);

    return false;
  }

  SystemChannels.platform.invokeMethod('SystemNavigator.pop');

  return true;
}

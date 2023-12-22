import 'dart:async';
import 'dart:math';
import 'package:extended_nested_scroll_view/extended_nested_scroll_view.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' hide Badge;
import 'package:flutter/services.dart';
// import 'package:flutter/material.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

import 'package:flutter_close_app/flutter_close_app.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:user_1/Model/formatter.dart';
import 'package:user_1/Model/products.dart';
import 'package:user_1/Model/rating1.dart';
import 'package:user_1/Pages/product_detail.dart';
import 'package:user_1/Providers/auth.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Theme/theme.dart';
import '../Theme/theme_data.dart';
import '../Widgets/add_delivery_address.dart';
import '../Widgets/categories_intro.dart';
import '../Widgets/drawer_clippath.dart';
import '../Widgets/markets_intro.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:badges/badges.dart';
import 'package:geocoding/geocoding.dart';
import '../Widgets/search.dart';
import '../Widgets/search_products.dart';
import '../Widgets/slider.dart';
import 'package:list_tile_switch/list_tile_switch.dart';

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
  // late List<Rating1> ratingList;
  late Future<List<Rating1>> ratingsFuture;
  late List<String> productIds;
  Random random = Random();
  late int randomNumber;

  Future<List<Rating1>> fetchProductRatings() async {
    // Lấy tham chiếu đến collection "Products"
    CollectionReference productsCollection =
        FirebaseFirestore.instance.collection('Products');

    // Lấy danh sách tất cả các sản phẩm
    QuerySnapshot productsSnapshot = await productsCollection.get();
    List<QueryDocumentSnapshot> productsDocs = productsSnapshot.docs;

    List<Rating1> ratings = [];

    // Duyệt qua từng sản phẩm
    for (QueryDocumentSnapshot productDoc in productsDocs) {
      // Lấy tham chiếu đến collection "Ratings" của sản phẩm hiện tại
      CollectionReference ratingsCollection =
          productDoc.reference.collection('Ratings');

      // Lấy danh sách tất cả các document trong collection "Ratings"
      QuerySnapshot ratingsSnapshot = await ratingsCollection.get();
      List<QueryDocumentSnapshot> ratingsDocs = ratingsSnapshot.docs;

      // Duyệt qua từng document trong collection "Ratings"
      for (QueryDocumentSnapshot ratingDoc in ratingsDocs) {
        // Thực hiện các thao tác với document trong collection "Ratings" ở đây
        // Ví dụ: lấy dữ liệu, tạo đối tượng Rating và thêm vào danh sách ratings
        Map<String, dynamic> ratingData =
            ratingDoc.data() as Map<String, dynamic>;
        Rating1 rating = Rating1(
            userId: ratingData['userId'],
            productId: ratingData['productId'],
            rating: ratingData['rating'],
            timeCreated: ratingData["timeCreated"]);
        ratings.add(rating);
      }
    }

    return ratings;
  }

  List<String> getUnratedProductIds(String userId, List<Rating1> ratings) {
    Set<String> ratedProductIds = ratings
        .where((rating) => rating.userId == userId)
        .map((rating) => rating.productId!)
        .toSet();

    List<String> allProductIds =
        ratings.map((rating) => rating.productId!).toList();

    return allProductIds
        .where((productId) => !ratedProductIds.contains(productId))
        .toList();
  }

  // List getSlopeOneRecommendations(String userId, List<Rating1> ratings) {
  //   Map<String, Map<String, double>> evalMat = {};
  //   Map<String, Map<String, int>> evalCount = {};

  //   for (Rating1 rating in ratings) {
  //     String user = rating.userId!;
  //     String product = rating.productId!;
  //     double score = rating.rating!;

  //     if (!evalMat.containsKey(user)) {
  //       evalMat[user] = {};
  //       evalCount[user] = {};
  //     }

  //     if (!evalMat[user]!.containsKey(product)) {
  //       evalMat[user]![product] = 0;
  //       evalCount[user]![product] = 0;
  //     }

  //     evalMat[user]![product] = score + evalMat[user]![product]!;
  //     evalCount[user]![product] = evalCount[user]![product]! + 1;
  //   }

  //   Map<String, double> recommendations = {};

  //   String user = userId;
  //   if (evalMat.containsKey(user)) {
  //     Map<String, double> userRatings = evalMat[user]!;
  //     Map<String, int> userCount = evalCount[user]!;

  //     for (String productA in userRatings.keys) {
  //       for (String productB in evalMat.keys) {
  //         if (productA != productB &&
  //             evalMat[productB]!.containsKey(productA)) {
  //           double dev = (evalMat[productB]![productA]! -
  //                   evalMat[productB]![productA]! / userCount[productA]!) /
  //               userCount[productA]!;

  //           if (!userRatings.containsKey(productB)) {
  //             if (!recommendations.containsKey(productB)) {
  //               recommendations[productB] = 0;
  //             }
  //             recommendations[productB] = recommendations[productB]! +
  //                 (dev + userRatings[productA]!) * userCount[productA]!;
  //           }
  //         }
  //       }
  //     }
  //   }

  //   List<String> recommendedProducts = (recommendations.entries.toList()
  //         ..sort((a, b) => b.value.compareTo(a.value)))
  //       .cast<String>();

  //   return recommendedProducts.map((entry) => entry).toList();
  // }

  List<String> getSlopeOneRecommendations(
      String userId, List<Rating1> ratings) {
    Map<String, Map<String, double>> evalMat = {};
    Map<String, Map<String, int>> evalCount = {};

    for (Rating1 rating in ratings) {
      // Lặp qua danh sách các đánh giá
      String user = rating.userId!;
      String product = rating.productId!;
      double score = rating.rating!;

      // Khởi tạo ma trận đánh giá và ma trận đếm nếu chưa tồn tại cho người dùng
      if (!evalMat.containsKey(user)) {
        evalMat[user] = {};
        evalCount[user] = {};
      }

      // Khởi tạo đánh giá và số lần đếm nếu chưa tồn tại cho sản phẩm của người dùng
      if (!evalMat[user]!.containsKey(product)) {
        evalMat[user]![product] = 0;
        evalCount[user]![product] = 0;
      }

      // Tính tổng điểm đánh giá và số lần đếm cho sản phẩm của người dùng
      evalMat[user]![product] = score + evalMat[user]![product]!;
      evalCount[user]![product] = evalCount[user]![product]! + 1;
    }

    Map<String, double> recommendations = {};

    String user = userId;
    // Kiểm tra nếu có đánh giá của người dùng trong ma trận đánh giá
    if (evalMat.containsKey(user)) {
      Map<String, double> userRatings = evalMat[user]!;
      Map<String, int> userCount = evalCount[user]!;

      // Lặp qua tất cả các sản phẩm đã được người dùng đánh giá
      for (String productA in userRatings.keys) {
        // Lặp qua tất cả các sản phẩm trong ma trận đánh giá
        for (String productB in evalMat.keys) {
          // Kiểm tra nếu sản phẩm A và sản phẩm B khác nhau và sản phẩm B đã được đánh giá bởi người dùng khác
          if (productA != productB &&
              evalMat[productB]!.containsKey(productA)) {
            // Tính độ chênh lệch (deviation)
            double dev = (evalMat[productB]![productA]! -
                    evalMat[productB]![productA]! / userCount[productA]!) /
                userCount[productA]!;

            // Kiểm tra nếu sản phẩm B chưa được người dùng đánh giá, thì cập nhật đề xuất cho sản phẩm B
            if (!userRatings.containsKey(productB)) {
              if (!recommendations.containsKey(productB)) {
                recommendations[productB] = 0;
              }
              recommendations[productB] = recommendations[productB]! +
                  (dev + userRatings[productA]!) * userCount[productA]!;
            }
          }
        }
      }
    }

    // Sắp xếp các sản phẩm đề xuất dựa trên giá trị đánh giá
    List<String> recommendedProducts = (recommendations.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value)))
        .cast<String>();

    // Trả về danh sách sản phẩm đề xuất
    return recommendedProducts.map((entry) => entry).toList();
  }

  // Future<List<ProductsModel>> getMyProducts() {
  //   return FirebaseFirestore.instance
  //       .collection('Products')
  //       .get()
  //       .then((snapshot) {
  //     return snapshot.docs
  //         .map((doc) => ProductsModel.fromMap(doc.data(), doc.id))
  //         .toList();
  //   });
  // }

  Future<List<ProductsModel>> getMyProducts() {
    Random random = Random(randomNumber); //
    return FirebaseFirestore.instance
        .collection('Products')
        .get()
        .then((snapshot) {
      List<ProductsModel> productList = snapshot.docs
          .map((doc) => ProductsModel.fromMap(doc.data(), doc.id))
          .toList();

      List<ProductsModel> shuffledList = List.from(productList);
      shuffledList.shuffle(random);

      return shuffledList.take(4).toList();
    });
  }

  final ScrollController _scrollController = ScrollController();

  final FocusNode _focusNode = FocusNode();
  void _handleKeyEvent(RawKeyEvent event) {
    var offset = _scrollController.offset;
    if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
      setState(() {
        if (kReleaseMode) {
          _scrollController.animateTo(offset - 200,
              duration: const Duration(milliseconds: 30), curve: Curves.ease);
        } else {
          _scrollController.animateTo(offset - 200,
              duration: const Duration(milliseconds: 30), curve: Curves.ease);
        }
      });
    } else if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
      setState(() {
        if (kReleaseMode) {
          _scrollController.animateTo(offset + 200,
              duration: const Duration(milliseconds: 30), curve: Curves.ease);
        } else {
          _scrollController.animateTo(offset + 200,
              duration: const Duration(milliseconds: 30), curve: Curves.ease);
        }
      });
    }
  }

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
    randomNumber = random.nextInt(100) + 1;
    getCourierStatus();
    _getUserDetails();
    _getUserDeliveryStatus();
    getLocation();
    ratingsFuture = fetchProductRatings();
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
    _focusNode.dispose();
    _scrollController.dispose(); // dispose the controller
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
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                icon: Icon(Icons.arrow_back,
                                    color:
                                        themeMode == true || themeMode == null
                                            ? Colors.black
                                            : Colors.white)),
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
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Text('Hello,',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 25,
                                      )).tr(),
                                  Text(' $fullname',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 25,
                                      )),
                                ],
                              )
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
        //  backgroundColor: Colors.blue,
        body: Column(
          children: [
            Flexible(
              child: FlutterCloseAppPage(
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
            Container(),
          ],
        ),
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
              backgroundColor: Theme.of(context).colorScheme.background,
              automaticallyImplyLeading: false,
              pinned: true,
              centerTitle: true,
              expandedHeight: 280,
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
                      prefixIcon: const Icon(
                        Icons.search,
                        color: Colors.black,
                      ),
                      filled: true,
                      fillColor: const Color.fromARGB(255, 236, 230, 230),
                      hintText: '$search Olivette',
                      hintStyle: const TextStyle(
                        color: Colors.black,
                      ),
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
                      const SizedBox(height: 100),
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
                              color: Theme.of(context).indicatorColor,
                              fontSize: 12,
                              fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Padding(
                        padding: EdgeInsets.only(left: 8, right: 8),
                        child: SizedBox(
                            height: 150, child: SliderWidget(category: '')),
                      ),
                      const SizedBox(height: 20),
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
      body: Container(
          color: Theme.of(context).colorScheme.background,
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(left: 20, right: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Choose a category',
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ).tr(),
                      TextButton(
                          child: const Text(
                            'View All',
                            style: TextStyle(
                                color: Colors.orange,
                                fontSize: 13,
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
                      : const EdgeInsets.only(left: 8, right: 8, bottom: 20),
                  child: SizedBox(
                      height: 260,
                      width: double.infinity,
                      child: Padding(
                          padding: MediaQuery.of(context).size.width >= 1100
                              ? const EdgeInsets.only(left: 200, right: 200)
                              : const EdgeInsets.only(bottom: 20),
                          child: const CategoriesIntro())),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 20, right: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Available Markets',
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ).tr(),
                      TextButton(
                          child: const Text(
                            'View All',
                            style: TextStyle(
                                color: Colors.orange,
                                fontSize: 13,
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
                    height: MediaQuery.of(context).size.height / 2.4,
                    width: double.infinity,
                    child: Padding(
                        padding: MediaQuery.of(context).size.width >= 1100
                            ? const EdgeInsets.only(left: 200, right: 200)
                            : const EdgeInsets.all(0),
                        child: const MarketsIntro())),
                const SizedBox(
                  height: 10,
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 15),
                  alignment: Alignment.centerLeft,
                  child: const Text(
                    'Suggest Product',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ),
                Padding(
                  padding: MediaQuery.of(context).size.width >= 1100
                      ? const EdgeInsets.only(left: 200, right: 200)
                      : const EdgeInsets.only(left: 8, right: 8),
                  child: FutureBuilder<List<ProductsModel>>(
                      future: getMyProducts(),
                      builder: (context, snapshot) {
                        if (snapshot.hasError) {
                          return Text('Error: ${snapshot.error}');
                        } else if (snapshot.hasData) {
                          List<ProductsModel> productList = snapshot.data!;

                          return RawKeyboardListener(
                            autofocus: true,
                            focusNode: _focusNode,
                            onKey: _handleKeyEvent,
                            child: GridView.builder(
                              controller: _scrollController,
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                mainAxisSpacing: MediaQuery.of(context)
                                            .size
                                            .width >=
                                        1100
                                    ? 10
                                    : MediaQuery.of(context).size.width > 600 &&
                                            MediaQuery.of(context).size.width <
                                                1200
                                        ? 5
                                        : 0,
                                crossAxisSpacing: MediaQuery.of(context)
                                            .size
                                            .width >=
                                        1100
                                    ? 10
                                    : MediaQuery.of(context).size.width > 600 &&
                                            MediaQuery.of(context).size.width <
                                                1200
                                        ? 5
                                        : 0,
                                crossAxisCount: MediaQuery.of(context)
                                            .size
                                            .width >=
                                        1100
                                    ? 4
                                    : MediaQuery.of(context).size.width > 600 &&
                                            MediaQuery.of(context).size.width <
                                                1200
                                        ? 3
                                        : 2,
                                childAspectRatio: MediaQuery.of(context)
                                            .size
                                            .width >=
                                        1100
                                    ? 1
                                    : MediaQuery.of(context).size.width > 600 &&
                                            MediaQuery.of(context).size.width <
                                                1200
                                        ? 0.9
                                        : 0.8,
                              ),
                              itemCount: productList.length,
                              physics: const BouncingScrollPhysics(),
                              shrinkWrap: true,
                              itemBuilder:
                                  (BuildContext buildContext, int index) {
                                ProductsModel productModel = productList[index];
                                return Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: InkWell(
                                    onTap: () {
                                      if (MediaQuery.of(context).size.width >=
                                          1100) {
                                        showDialog(
                                          context: context,
                                          builder: (context) {
                                            return AlertDialog(
                                              content: SizedBox(
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width /
                                                    1.5,
                                                child: ProductDetailsPage(
                                                  currency: currencySymbol,
                                                  marketID:
                                                      productModel.marketID,
                                                  productsModel: productModel,
                                                ),
                                              ),
                                            );
                                          },
                                        );
                                      } else {
                                        showMaterialModalBottomSheet(
                                          bounce: true,
                                          expand: true,
                                          context: context,
                                          backgroundColor: Colors.transparent,
                                          builder: (context) => Padding(
                                            padding: MediaQuery.of(context)
                                                        .size
                                                        .width >=
                                                    1100
                                                ? const EdgeInsets.only(
                                                    left: 200, right: 200)
                                                : const EdgeInsets.only(
                                                    left: 0, right: 0),
                                            child: ProductDetailsPage(
                                              currency: currencySymbol,
                                              marketID: productModel.marketID,
                                              productsModel: productModel,
                                            ),
                                          ),
                                        );
                                      }
                                    },
                                    child: Card(
                                      elevation: 0,
                                      child: Stack(
                                        children: [
                                          Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceAround,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.stretch,
                                            children: [
                                              Image.network(
                                                productModel.image1,
                                                height: MediaQuery.of(context)
                                                            .size
                                                            .width >=
                                                        1100
                                                    ? 120
                                                    : MediaQuery.of(context)
                                                                    .size
                                                                    .width >
                                                                600 &&
                                                            MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width <
                                                                1200
                                                        ? 120
                                                        : 120,
                                                width: double.infinity,
                                                fit: BoxFit.cover,
                                              ),
                                              Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: Column(
                                                  children: [
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: [
                                                        Flexible(
                                                          flex: 5,
                                                          child: Text(
                                                            productModel.name,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                            style: TextStyle(
                                                              fontSize: MediaQuery.of(
                                                                              context)
                                                                          .size
                                                                          .width >=
                                                                      1100
                                                                  ? 13
                                                                  : 10,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                            ),
                                                          ),
                                                        ),
                                                        if (productModel
                                                                    .totalNumberOfUserRating !=
                                                                0 &&
                                                            productModel
                                                                    .totalRating !=
                                                                0)
                                                          Flexible(
                                                            flex: MediaQuery.of(
                                                                            context)
                                                                        .size
                                                                        .width >=
                                                                    1100
                                                                ? 3
                                                                : MediaQuery.of(context).size.width >
                                                                            600 &&
                                                                        MediaQuery.of(context).size.width <
                                                                            1200
                                                                    ? 3
                                                                    : 4,
                                                            child: Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .end,
                                                              children: [
                                                                RatingBarIndicator(
                                                                  rating: (productModel
                                                                              .totalRating /
                                                                          productModel
                                                                              .totalNumberOfUserRating)
                                                                      .roundToDouble(),
                                                                  itemBuilder: (context,
                                                                          index) =>
                                                                      const Icon(
                                                                    Icons.star,
                                                                    color: Colors
                                                                        .orange,
                                                                  ),
                                                                  itemCount: 5,
                                                                  itemSize: 6,
                                                                  direction: Axis
                                                                      .horizontal,
                                                                ),
                                                                Text(
                                                                  ' ${(productModel.totalRating / productModel.totalNumberOfUserRating).roundToDouble()}',
                                                                  style:
                                                                      TextStyle(
                                                                    fontSize: MediaQuery.of(context).size.width >=
                                                                            1100
                                                                        ? 10
                                                                        : MediaQuery.of(context).size.width > 600 &&
                                                                                MediaQuery.of(context).size.width < 1200
                                                                            ? 10
                                                                            : 8,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                      ],
                                                    ),
                                                    Row(
                                                      children: [
                                                        Flexible(
                                                          flex: 5,
                                                          child: Text(
                                                            productModel
                                                                .description,
                                                            maxLines: 1,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                            style: TextStyle(
                                                              fontSize: MediaQuery.of(
                                                                              context)
                                                                          .size
                                                                          .width >=
                                                                      1100
                                                                  ? 10
                                                                  : 8,
                                                            ),
                                                          ),
                                                        ),
                                                        const Flexible(
                                                          flex: 1,
                                                          child: Text(''),
                                                        ),
                                                      ],
                                                    ),
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: [
                                                        Text(
                                                          '$currencySymbol${Formatter().converter(productModel.unitPrice1.toDouble())}',
                                                          style: TextStyle(
                                                            fontSize: MediaQuery.of(
                                                                            context)
                                                                        .size
                                                                        .width >=
                                                                    1100
                                                                ? 13
                                                                : 10,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                        ),
                                                        const SizedBox(
                                                            width: 20),
                                                        Text(
                                                          '$currencySymbol${Formatter().converter(productModel.unitOldPrice1.toDouble())}',
                                                          style: TextStyle(
                                                            fontSize: MediaQuery.of(
                                                                            context)
                                                                        .size
                                                                        .width >=
                                                                    1100
                                                                ? 13
                                                                : 10,
                                                            decoration:
                                                                TextDecoration
                                                                    .lineThrough,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                          Align(
                                            alignment: Alignment.topRight,
                                            child: Padding(
                                              padding: const EdgeInsets.only(
                                                  top: 10, right: 10),
                                              child: IconButton(
                                                icon: const Icon(
                                                    Icons.favorite_border),
                                                onPressed: () {
                                                  // Add code to handle favorite button press
                                                },
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          );
                        }
                        return const Center(child: CircularProgressIndicator());
                      }),
                ),
                const SizedBox(
                  height: 30,
                ),
              ],
            ),
          )),
    );
  }
}

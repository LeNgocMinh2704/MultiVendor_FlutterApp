import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:admin_web/Pages/home_main.dart';
import 'package:shared_preferences/shared_preferences.dart';
// import 'Pages/Categories Settings/brands.dart';
import 'Pages/Categories Settings/categories.dart';
// import 'Pages/Categories Settings/sub_categories_collections.dart';
import 'Pages/Categories Settings/sub_categories.dart';
import 'Pages/Courier Settings/complete_deliveries.dart';
import 'Pages/Courier Settings/courier_settings.dart';
import 'Pages/Courier Settings/new_deliveries.dart';
import 'Pages/Payout Settings/completed_payouts.dart';
import 'Pages/Payout Settings/payout_request.dart';
import 'Pages/Profile Settings/app_settings.dart';
import 'Pages/Profile Settings/edit_profile.dart';
import 'Pages/Profile Settings/profile.dart';
import 'Pages/Users Settings/deliveryboys_page.dart';
import 'Pages/Users Settings/vendors_page.dart';
import 'Pages/Users Settings/user_settings.dart';
import 'Pages/Users Settings/users_page.dart';
//import 'Pages/cities.dart';
import 'Pages/coupon_page.dart';
import 'Pages/feeds.dart';
import 'Pages/home.dart';
import 'Pages/Login/login.dart';
import 'Pages/markets.dart';
import 'Pages/notifications.dart';
import 'Pages/orders.dart';
import 'Pages/products.dart';
import 'Pages/reviews.dart';

int? initScreen;
bool? seen;
String? newPassword;
String? adminUsername;
String? adminImage;
num? commission;

updateAdmin() {
  FirebaseFirestore.instance
      .collection('Admin')
      .doc('Admin')
      .get()
      .then((value) {
    if (!value.exists) {
      defaultUpdate();
    }
  });
}

defaultUpdate() {
  if (newPassword == null && adminImage == null && adminUsername == null) {
    FirebaseFirestore.instance.collection('Admin').doc('Admin').set({
      'password': '123456',
      'ProfilePic': 'https://img.icons8.com/officel/2x/person-male.png',
      'username': 'admin123@gmail.com',
      'commission': 0,
      'ParcelID': 0
    });

    FirebaseFirestore.instance
        .collection('Product Slide')
        .doc('Product Slide')
        .set({
      'Product Slide 1': '',
      'Product Slide 2': '',
      'Product Slide 3': '',
      'Product Slide 4': '',
      'Product Slide 5': ''
    });
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: "AIzaSyAxIv-Esi1r6LucIpMb7fD4oXfnXs4AL_4",
        authDomain: "multivendor-773b9.firebaseapp.com",
        projectId: "multivendor-773b9",
        storageBucket: "multivendor-773b9.appspot.com",
        messagingSenderId: "544492785321",
        appId: "1:544492785321:web:a0afe5580901efd582a3b8"));
  var all = await SharedPreferences.getInstance();
  all.clear();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  updateAdmin();
  await prefs.setBool("seen", true);
  seen = prefs.getBool("seen");

  await prefs.clear();

  seen = prefs.getBool("seen");

  await EasyLocalization.ensureInitialized();
  EasyLocalization.logger.enableBuildModes = [];

  runApp(ModularApp(
    module: AppModule(),
    child: EasyLocalization(
        supportedLocales: const [
          Locale('es', 'ES'),
          Locale('en', 'US'),
          Locale('pt', 'PT')
        ],
        path: 'assets/languagesFile',
        fallbackLocale: const Locale('en', 'US'),
        child: const MyApp()),
  ));
}

class AppModule extends Module {
  @override
  List<Bind> get binds => [];

  @override
  List<ModularRoute> get routes => [
        ChildRoute('/login', child: (context, args) => const Login()),
        ChildRoute('/',
            child: (context, args) => const HomePageMain(),
            children: [
              ChildRoute('/home', child: (context, args) => const HomePage()),
              //    ChildRoute('/brands', child: (context, args) => const Brands()),
              ChildRoute('/categories',
                  child: (context, args) => const Categories()),
              ChildRoute('/sub-categories',
                  child: (context, args) => const SubCategories()),
              // ChildRoute('/sub-categories-collections',
              //     child: (context, args) => const SubCategoriesCollections()),
              ChildRoute('/completed-deliveries',
                  child: (context, args) => const CompletedDeliveries()),
              ChildRoute('/new-deliveries',
                  child: (context, args) => const NewDeliveries()),
              ChildRoute('/completed-payouts',
                  child: (context, args) => const CompletedPayout()),
              ChildRoute('/coupon',
                  child: (context, args) => const CouponPage()),
              ChildRoute('/payout-requests',
                  child: (context, args) => const PayoutRequest()),
              ChildRoute('/settings',
                  child: (context, args) => const AppSettings()),
              ChildRoute('/edit-profile',
                  child: (context, args) => const EditProfile()),
              ChildRoute('/profile', child: (context, args) => const Profile()),
              ChildRoute('/delivery-boys',
                  child: (context, args) => const ApprovedDeliveryboys()),
              ChildRoute('/users', child: (context, args) => const Users()),
              ChildRoute('/vendors',
                  child: (context, args) => const ApprovedVendors()),
              // ChildRoute('/cities', child: (context, args) => const Cities()),
              ChildRoute('/feeds', child: (context, args) => const Feeds()),
              ChildRoute('/markets', child: (context, args) => const Markets()),
              ChildRoute('/notifications',
                  child: (context, args) => const Notifications()),
              ChildRoute('/orders', child: (context, args) => const Orders()),
              ChildRoute('/products',
                  child: (context, args) => const Products()),
              ChildRoute('/reviews', child: (context, args) => const Reviews()),
              ChildRoute('/users-settings',
                  child: (context, args) => const UsersSettings()),
              ChildRoute('/courier-settings',
                  child: (context, args) => const CourierSettings()),
            ]),
      ];
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    Modular.setInitialRoute('/login');
    return MaterialApp.router(
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
      debugShowCheckedModeBanner: false,
      title: 'Olivette Admin',
      theme: ThemeData(
        primaryColor: Colors.blue,
        textTheme: GoogleFonts.robotoCondensedTextTheme(
          Theme.of(context).textTheme,
        ),
      ),
      routeInformationParser: Modular.routeInformationParser,
      routerDelegate: Modular.routerDelegate,
    );
  }
}

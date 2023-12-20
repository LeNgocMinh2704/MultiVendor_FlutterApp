import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:vendor/Providers/auth.dart';
import 'package:vendor/route_generator.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'Model/user.dart';
import 'Theme/theme.dart';
import 'Theme/theme_data.dart';
import 'Widget/custom_animation.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';

int? initScreen;

void main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  SharedPreferences.getInstance().then((prefs) {
    initScreen = prefs.getInt("initScreen");
    prefs.setInt("initScreen", 1);
    //print('initScreen $initScreen');
  });
  await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: "AIzaSyDqQFBmItGZNv0gIRKR2W1ZSOE9qBNel2Q",
        authDomain: "multivendor-c4d09.firebaseapp.com",
        projectId: "multivendor-c4d09",
        storageBucket: "multivendor-c4d09.appspot.com",
        messagingSenderId: "926136734127",
        appId: "1:926136734127:web:2330aa90dc6faaf9715f5a"
    ));
  await EasyLocalization.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
      .then((value) async {
    SharedPreferences.getInstance().then((prefs) {
      var lightModeOn = prefs.getBool('lightMode') ?? true;
      runApp(MultiProvider(
          providers: [
            StreamProvider<UserModel>.value(
              value: AuthService().user,
              initialData: UserModel(
                  displayName: '',
                  email: '',
                  phonenumber: '',
                  photoUrl: '',
                  uid: '',
                  address: ''),
            ),
            ChangeNotifierProvider<ThemeNotifier>.value(
                value: ThemeNotifier(lightModeOn ? lightTheme : darkTheme)),
          ],
          child: EasyLocalization(
              supportedLocales: const [
                Locale('es', 'ES'),
                Locale('en', 'US'),
                Locale('pt', 'PT'),
                Locale('ar', 'AE')
              ],
              path:
                  'assets/languagesFile', // <-- change the path of the translation files
              fallbackLocale: const Locale('en', 'US'),
              child: const MyApp())));
    });
  });
}

void configLoading() {
  EasyLoading.instance
    ..displayDuration = const Duration(milliseconds: 2000)
    ..indicatorType = EasyLoadingIndicatorType.fadingCircle
    ..loadingStyle = EasyLoadingStyle.dark
    ..indicatorSize = 45.0
    ..radius = 10.0
    ..progressColor = Colors.yellow
    ..backgroundColor = Colors.green
    ..indicatorColor = Colors.yellow
    ..textColor = Colors.yellow
    ..maskColor = Colors.blue.withOpacity(0.5)
    ..userInteractions = true
    ..dismissOnTap = false
    ..customAnimation = CustomAnimation();
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    initialization();
  }

  void initialization() async {
    FlutterNativeSplash.remove();
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    return MaterialApp(
        localizationsDelegates: context.localizationDelegates,
        supportedLocales: context.supportedLocales,
        locale: context.locale,
        onGenerateRoute: RouteGenerator.generateRoute,
        initialRoute: initScreen == 0 || initScreen == null
            ? '/screenOnboarding'
            : '/network',
        debugShowCheckedModeBanner: false,
        theme: themeNotifier.getTheme(),
        builder: EasyLoading.init());
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:vendor/Theme/theme.dart';
import 'package:vendor/Theme/theme_data.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:easy_localization/easy_localization.dart';

class HelpPage extends StatefulWidget {
  const HelpPage({Key? key}) : super(key: key);

  @override
  State<HelpPage> createState() => _HelpPageState();
}

class _HelpPageState extends State<HelpPage> {
  var _lightTheme = true;
  DocumentReference? userRef;
  // ignore: prefer_typing_uninitialized_variables
  var themeMode;
  dynamic selectedLanguage;
  dynamic language;

  Future<void> _getUserDoc() async {
    final FirebaseAuth auth = FirebaseAuth.instance;
    final FirebaseFirestore firestore = FirebaseFirestore.instance;

    User? user = auth.currentUser;
    setState(() {
      userRef = firestore.collection('vendors').doc(user!.uid);
    });
  }

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

  getSelectedLanguage() {
    SharedPreferences.getInstance().then((prefs) {
      var language = prefs.getString('language_selected');
      setState(() {
        selectedLanguage = language;
      });
    });
  }

  showLanguage() {
    if (selectedLanguage == 'PT') {
      //print(selectedLanguage == 'PT');
      return 'Portuguese';
    } else if (selectedLanguage == 'ES') {
      return 'Spanish';
    } else {
      return 'English';
    }
  }

  @override
  void initState() {
    _getUserDoc();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    getSelectedLanguage();
    getThemeDetail();
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    return ListView(
      shrinkWrap: true,
      children: [
        const SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              const Text('About', style: TextStyle(color: Colors.grey)).tr(),
              const SizedBox(width: 5),
              const Text('Olivette', style: TextStyle(color: Colors.grey)),
            ],
          ),
        ),
        Card(
          elevation: 0,
          child: Column(
            children: [
              ListTile(
                  onTap: () {
                    Navigator.of(context).pushNamed('/about');
                  },
                  title: Row(
                    children: [
                      Text(
                        'About',
                        style: TextStyle(
                            fontSize: Theme.of(context)
                                .textTheme
                                .titleLarge!
                                .fontSize),
                      ).tr(),
                      const SizedBox(width: 5),
                      Text(
                        'Olivette',
                        style: TextStyle(
                            fontSize: Theme.of(context)
                                .textTheme
                                .titleLarge!
                                .fontSize),
                      ),
                    ],
                  ),
                  trailing: const Icon(Icons.chevron_right)),
              ListTile(
                  onTap: () {
                    Navigator.of(context).pushNamed('/faq');
                  },
                  title: Text(
                    'Faq',
                    style: TextStyle(
                        fontSize:
                            Theme.of(context).textTheme.titleLarge!.fontSize),
                  ).tr(),
                  trailing: const Icon(Icons.chevron_right))
            ],
          ),
        ),
        const Padding(
          padding: EdgeInsets.all(8.0),
          child: Text('Settings', style: TextStyle(color: Colors.grey)),
        ),
        Card(
          elevation: 0,
          child: Column(
            children: [
              // userRef == null
              //     ? Container()
              //     : SwitchListTile(
              //         activeColor: Colors.orange,
              //         title: Text(
              //           'Push-Notifications',
              //           style: TextStyle(
              //               fontSize: Theme.of(context)
              //                   .textTheme
              //                   .headline6!
              //                   .fontSize),
              //         ).tr(),
              //         value: _lightTheme,
              //         onChanged: (val) {
              //           setState(() {
              //             _lightTheme = val;
              //           });
              //           onThemeChanged(val, themeNotifier);
              //           //print(_lightTheme);
              //         }),
              ListTile(
                  onTap: () {
                    Navigator.of(context).pushNamed('/language-settings');
                  },
                  title: Text(
                    'Language',
                    style: TextStyle(
                        fontSize:
                            Theme.of(context).textTheme.titleLarge!.fontSize),
                  ).tr(),
                  trailing: Text(showLanguage(),
                      style: TextStyle(
                          color: Colors.grey,
                          fontSize: Theme.of(context)
                              .textTheme
                              .titleLarge!
                              .fontSize))),
              SwitchListTile(
                  title: Text(
                    'Theme Mode',
                    style: TextStyle(
                        fontSize:
                            Theme.of(context).textTheme.titleLarge!.fontSize),
                  ).tr(),
                  // ignore: prefer_if_null_operators
                  value: themeMode == null ? true : themeMode,
                  onChanged: (val) {
                    setState(() {
                      _lightTheme = val;
                      themeMode = val;
                    });
                    onThemeChanged(val, themeNotifier);
                    debugPrint(_lightTheme.toString());
                  })
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child:
              const Text('App Info', style: TextStyle(color: Colors.grey)).tr(),
        ),
        Card(
          elevation: 0,
          child: Column(
            children: [
              ListTile(
                  title: Text('App Version',
                          style: TextStyle(
                              fontSize: Theme.of(context)
                                  .textTheme
                                  .titleLarge!
                                  .fontSize))
                      .tr(),
                  trailing: Text('1.0.0',
                      style: TextStyle(
                          color: Colors.grey,
                          fontSize:
                              Theme.of(context).textTheme.titleLarge!.fontSize)))
            ],
          ),
        )
      ],
    );
  }
}

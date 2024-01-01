import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'dart:developer';

import 'package:shared_preferences/shared_preferences.dart';

class LanguageSettingsPage extends StatefulWidget {
  const LanguageSettingsPage({Key? key}) : super(key: key);

  @override
  State<LanguageSettingsPage> createState() => _LanguageSettingsPageState();
}

class _LanguageSettingsPageState extends State<LanguageSettingsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          elevation: 0,
          centerTitle: true,
          //    backgroundColor: Colors.blue,
          title: const Text('Language').tr()),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.only(top: 26),
            margin: const EdgeInsets.symmetric(
              horizontal: 24,
            ),
            child: Row(
              children: [
                const Icon(Icons.language, size: 40, color: Colors.grey),
                const SizedBox(width: 20),
                Text(
                  'Select your preferred language'.tr(),
                  style: const TextStyle(
                    color: Colors.blue,
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          _SwitchListTileMenuItem(
              flag: 'assets/image/usa.png',
              subtitle: 'English',
              title: 'USA',
              locale:
                  context.supportedLocales[1] //BuildContext extension method
              ),
          // _SwitchListTileMenuItem(
          //     flag: 'assets/image/spanish.gif',
          //     title: 'PARAGUAY',
          //     subtitle: 'Spanish',
          //     locale: context.supportedLocales[0]),
          // _SwitchListTileMenuItem(
          //     flag: 'assets/image/portugal.png',
          //     subtitle: 'Portueges',
          //     title: 'BRAZIL- PORTUGUÉS',
          //     locale: context.supportedLocales[2]),
          // _SwitchListTileMenuItem(
          //     flag: 'assets/image/uae.png',
          //     subtitle: 'Arabic',
          //     title: 'UAE',
          //     locale:
          //         context.supportedLocales[3] //BuildContext extension method
          //     ),
        ],
      ),
    );
  }
}

class _SwitchListTileMenuItem extends StatefulWidget {
  const _SwitchListTileMenuItem({
    Key? key,
    required this.title,
    required this.subtitle,
    required this.locale,
    required this.flag,
  }) : super(key: key);

  final String title;
  final String subtitle;
  final Locale locale;
  final String flag;

  @override
  State<_SwitchListTileMenuItem> createState() =>
      __SwitchListTileMenuItemState();
}

class __SwitchListTileMenuItemState extends State<_SwitchListTileMenuItem> {
  bool isSelected(BuildContext context) => widget.locale == context.locale;

  dynamic themeMode;

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
    return Container(
      margin: const EdgeInsets.only(left: 10, right: 10, top: 10),
      child: Card(
        elevation: 3,
        child: ListTile(
            tileColor: isSelected(context) ? Colors.grey[300] : null,
            leading: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Image.asset(
                widget.flag,
                height: 40,
                width: 40,
                fit: BoxFit.cover,
              ),
            ),
            dense: true,
            // isThreeLine: true,
            title: Text(
              widget.title,
              style: TextStyle(
                  color: isSelected(context)
                      ? Colors.black
                      : themeMode == null
                          ? Colors.black
                          : themeMode == true
                              ? Colors.black
                              : Colors.white),
            ),
            subtitle: Text(
              widget.subtitle,
              style: TextStyle(
                  color: isSelected(context)
                      ? Colors.black
                      : themeMode == null
                          ? Colors.black
                          : themeMode == true
                              ? Colors.black
                              : Colors.white),
            ),
            onTap: () async {
              log(widget.locale.toString(), name: toString());
              //print('Country code is ${widget.locale.countryCode}');
              await context.setLocale(widget.locale);
              var prefs = await SharedPreferences.getInstance();
              prefs
                  .setString(
                      'language_selected', widget.locale.countryCode.toString())
                  .then((value) => Navigator.pushNamed(context, '/bottomNav'));
            }),
      ),
    );
  }
}

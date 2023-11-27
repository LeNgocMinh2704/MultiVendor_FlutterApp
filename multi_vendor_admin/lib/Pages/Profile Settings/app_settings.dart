import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:admin_web/Widget/currency_settings.dart';
//import 'package:admin_web/Widget/home_screen_settings.dart';
import 'package:admin_web/Widget/one_signal_settings.dart';
import 'package:admin_web/Widget/payment_settings.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../Widget/coupon_system.dart';
import '../../Widget/islogged_widget.dart';
import '../../Widget/referral_system.dart';

class AppSettings extends StatefulWidget {
  const AppSettings({Key? key}) : super(key: key);

  @override
  State<AppSettings> createState() => _AppSettingsState();
}

class _AppSettingsState extends State<AppSettings> {
  DocumentReference? userRef;

  @override
  void initState() {
    super.initState();
  }

  bool? loggedIn;

  getSelectedRoute() {
    SharedPreferences.getInstance().then((prefs) {
      var log = prefs.getBool('logged in');
      if (mounted) {
        setState(() {
          loggedIn = log!;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    getSelectedRoute();
    return loggedIn == false || loggedIn == null
        ? const IsLoggedWidget()
        : Scaffold(
            body: SafeArea(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 5,
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: ListView(
                        shrinkWrap: true,
                        children: const [
                          CouponSystem(),
                          ReferralSystem(),
                          //   HomeScreenSettings(),
                          // Divider(
                          //   color: Colors.grey,
                          //   thickness: 2,
                          // ),
                          PaymentSettings(),
                          Divider(
                            color: Colors.grey,
                            thickness: 2,
                          ),
                          CurrencySettings(),
                          Divider(
                            color: Colors.grey,
                            thickness: 2,
                          ),
                          OneSignalSettings()
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
  }
}

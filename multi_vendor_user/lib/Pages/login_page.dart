import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import '../Providers/auth.dart';
import 'package:flutter_custom_clippers/flutter_custom_clippers.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';
import 'package:flutter_close_app/flutter_close_app.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  Timer? oneSignalTimer;
  String playerId = '';
  String getOnesignalKey = '';
  bool showPassword = true;
  String email = '';
  String password = '';
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _btnController1.stateStream.listen((value) {});
    getOneSignalDetails();

    oneSignalTimer = Timer.periodic(
        const Duration(milliseconds: 100), (Timer t) => initOneSignal());
  }

  initOneSignal() {
    if (getOnesignalKey != '') {
      OneSignal.shared.setLogLevel(OSLogLevel.verbose, OSLogLevel.none);
      debugPrint('One singal app id is jjjjjj');
      OneSignal.shared.setAppId(getOnesignalKey);
      debugPrint('$getOnesignalKey is firebase oneSignal key');
      OneSignal.shared
          .promptUserForPushNotificationPermission()
          .then((accepted) {
        debugPrint("Accepted permission: $accepted");
      });
      oneSignalTimer!.cancel();
    }
  }

  void _handleGetDeviceState() async {
    debugPrint("Getting DeviceState");
    var deviceState = await OneSignal.shared.getDeviceState();
    setState(() {
      playerId = deviceState!.userId!;
    });

    debugPrint('$playerId is your player ID');
  }

  getOneSignalDetails() {
    if (getOnesignalKey == '') {
      debugPrint('$getOnesignalKey is firebase oneSignal key');
      FirebaseFirestore.instance
          .collection('Push notification Settings')
          .doc('OneSignal')
          .snapshots()
          .listen((value) {
        setState(() {
          getOnesignalKey = value['OnesignalKey'];
        });
      });
    }
  }

  final RoundedLoadingButtonController _btnController1 =
      RoundedLoadingButtonController();

  void _doSomething(RoundedLoadingButtonController controller, String email,
      String password, BuildContext context, String playerId) async {
    AuthService().signIn(email, password, context, playerId).then((value) {
      if (AuthService().loginStatus == true) {
        controller.success();
      } else {
        controller.reset();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    _handleGetDeviceState();
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: FlutterCloseAppPage(
        interval: 2,
        condition: true,
        onCloseFailed: () {
          // The interval is more than 2 seconds, or the return key is pressed for the first time
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Press again to exit'),
          ));
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const SizedBox(height: 100),
            Expanded(
              flex: 1,
              child: Image.asset(
                'assets/image/splash-new.png',
                height: 220,
                width: 220,
                fit: BoxFit.cover,
              ),
            ),
            Flexible(
              flex: 5,
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(0.0),
                      child: const Text('Login to your account',
                              style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold))
                          .tr(),
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
                              keyboardType: TextInputType.emailAddress,
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return 'Required field'.tr();
                                } else {
                                  return null;
                                }
                              },
                              onChanged: (value) {
                                setState(() {
                                  email = value;
                                });
                              },
                              decoration: InputDecoration(
                                  hintText: 'Email'.tr(),
                                  focusColor: Colors.orange),
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
                                Icons.lock_open_outlined,
                                size: 40,
                                color: Colors.grey,
                              )),
                          const SizedBox(
                            width: 10,
                          ),
                          Flexible(
                            flex: 6,
                            child: TextFormField(
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return 'Required field'.tr();
                                } else {
                                  return null;
                                }
                              },
                              onChanged: (value) {
                                setState(() {
                                  password = value;
                                });
                              },
                              obscureText: showPassword,
                              decoration: InputDecoration(
                                hintText: 'Password'.tr(),
                                suffixIcon: showPassword == true
                                    ? InkWell(
                                        onTap: () {
                                          setState(() {
                                            showPassword = false;
                                          });
                                        },
                                        child: const Icon(
                                          Icons.visibility,
                                          color: Colors.grey,
                                          size: 30,
                                        ),
                                      )
                                    : InkWell(
                                        onTap: () {
                                          setState(() {
                                            showPassword = true;
                                          });
                                        },
                                        child: const Icon(
                                          Icons.visibility_off,
                                          color: Colors.grey,
                                          size: 30,
                                        ),
                                      ),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          InkWell(
                            onTap: () {
                              Navigator.pushNamed(context, '/forgot-password');
                            },
                            child: Row(
                              children: [
                                Text('FORGOT PASSWORD',
                                        style: TextStyle(
                                            color: Colors.blue.shade800))
                                    .tr(),
                                Text('?',
                                    style:
                                        TextStyle(color: Colors.blue.shade800))
                              ],
                            ),
                          ),
                          const SizedBox(
                            width: 20,
                          )
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    RoundedLoadingButton(
                      color: Colors.blue,
                      successIcon: Icons.done,
                      failedIcon: Icons.error,
                      controller: _btnController1,
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          _doSomething(_btnController1, email, password,
                              context, playerId);
                        } else {
                          _btnController1.reset();
                        }
                      },
                      child: const Text('Login',
                              style: TextStyle(color: Colors.white))
                          .tr(),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          children: [
                            const Text(
                              'New on',
                              style: TextStyle(color: Colors.grey),
                            ).tr(),
                            const SizedBox(
                              width: 5,
                            ),
                            const Text(
                              'Olivette?',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                        const SizedBox(width: 10),
                        InkWell(
                          onTap: () {
                            Navigator.of(context).pushNamed('/signup');
                          },
                          child: Text(
                            'CREATE AN ACCOUNT',
                            style: TextStyle(
                                color: Colors.blue.shade800,
                                fontWeight: FontWeight.bold),
                          ).tr(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Continue as a',
                          style: TextStyle(color: Colors.grey),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pushNamed('/home');
                          },
                          child: Text(
                            'Guest',
                            style: TextStyle(
                                fontSize: 20,
                                color: Colors.blue.shade800,
                                fontWeight: FontWeight.bold),
                          ).tr(),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
            Flexible(
              flex: 1,
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
    );
  }
}

import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_custom_clippers/flutter_custom_clippers.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';
import 'package:country_pickers/country.dart';
import '../Providers/auth.dart';
import 'package:country_pickers/country_pickers.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({Key? key}) : super(key: key);

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  String fullname = '';
  String email = '';
  String phone = '';
  String password = '';
  final _formKey = GlobalKey<FormState>();
  Timer? oneSignalTimer;
  String playerId = '';
  String getOnesignalKey = '';
  String referralCode = '';
  bool referralStatus = false;
  num? reward;
  bool showPassword = true;

  @override
  void initState() {
    _btnController1.stateStream.listen((value) {});
    super.initState();
    getReferralStatus();
    getOneSignalDetails();
    _handleGetDeviceState();

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

  getReferralStatus() {
    FirebaseFirestore.instance
        .collection('Referral System')
        .doc('Referral System')
        .snapshots()
        .listen((value) {
      setState(() {
        referralStatus = value['Status'];
        reward = value['Referral Amount'];
      });
    });
  }

  final RoundedLoadingButtonController _btnController1 =
      RoundedLoadingButtonController();

  void _doSomething(
      RoundedLoadingButtonController controller,
      String email,
      dynamic password,
      String fullname,
      String phone,
      BuildContext context,
      String referralCode,
      num? reward,
      bool referralStatus,
      String playerId) async {
    AuthService()
        .signUp(email, password, fullname, phone, context, referralCode, reward,
            referralStatus, playerId)
        .then((value) {
      if (AuthService().signupStatus == true) {
        controller.success();
      } else {
        controller.reset();
      }
    });
  }

  Widget _buildDialogItem(Country country) => Row(
        mainAxisAlignment: MainAxisAlignment.start,
        // mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          // CountryPickerUtils.getDefaultFlagImage(country),
          Text("+${country.phoneCode}", style: const TextStyle(fontSize: 13)),
          const SizedBox(width: 8.0),
          Flexible(
              child:
                  Text(country.isoCode, style: const TextStyle(fontSize: 13))),
          // const SizedBox(width: 8.0),
        ],
      );
  void _openCountryPickerDialog() => showDialog(
        context: context,
        builder: (context) => Theme(
          data: Theme.of(context).copyWith(primaryColor: Colors.pink),
          child: CountryPickerDialog(
            titlePadding: const EdgeInsets.all(8.0),
            searchCursorColor: Colors.pinkAccent,
            searchInputDecoration: const InputDecoration(hintText: 'Search...'),
            isSearchable: true,
            title: const Text('Select your phone code'),
            onValuePicked: (Country country) {
              setState(() {
                _selectedDialogCountry = country;
                selectedCode = country.phoneCode;
              });
            },
            itemBuilder: _buildDialogItem,
            priorityList: [
              CountryPickerUtils.getCountryByIsoCode('TR'),
              CountryPickerUtils.getCountryByIsoCode('US'),
            ],
          ),
        ),
      );

  String selectedCode = '234';
  Country _selectedDialogCountry =
      CountryPickerUtils.getCountryByPhoneCode('234');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        iconTheme: Theme.of(context).iconTheme,
        backgroundColor: Theme.of(context).cardColor,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pushNamed(context, '/login');
            },
            child: Text(
              'Login',
              style: TextStyle(color: Theme.of(context).iconTheme.color),
            ).tr(),
          )
        ],
      ),
      body: SingleChildScrollView(
        child: SizedBox(
          height: MediaQuery.of(context).size.height / 1,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
   Expanded(
                  flex: 1,
                  child: Image.asset(
                    'assets/image/splash-new.png',
                    height: 220,
                    width: 220,
                    fit: BoxFit.cover,
                  ),
                ),
              Expanded(
                flex: 4,
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('Create a new account',
                              style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold))
                          .tr(),
                      Padding(
                        padding: const EdgeInsets.only(left: 12, right: 12),
                        child: Row(
                          children: [
                            const Flexible(
                                flex: 1,
                                child: Icon(
                                  Icons.person,
                                  size: 40,
                                  color: Colors.grey,
                                )),
                            const SizedBox(
                              width: 10,
                            ),
                            Flexible(
                              flex: 6,
                              child: TextFormField(
                                keyboardType: TextInputType.name,
                                validator: (value) {
                                  if (value!.isEmpty) {
                                    return 'Required field'.tr();
                                  } else {
                                    return null;
                                  }
                                },
                                decoration: InputDecoration(
                                    hintText: 'Full name'.tr(),
                                    focusColor: Colors.orange),
                                onChanged: (value) {
                                  setState(() {
                                    fullname = value;
                                  });
                                },
                              ),
                            )
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 12, right: 12),
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
                        padding: const EdgeInsets.only(left: 12, right: 12),
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
                                obscureText: showPassword,
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
                                decoration:
                                    InputDecoration(hintText: 'Password'.tr(), suffixIcon: showPassword == true
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
                                          ),),
                              ),
                            )
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 6, right: 12),
                        child: Row(
                          children: [
                            Flexible(
                              flex: 4,
                              child: ListTile(
                                onTap: _openCountryPickerDialog,
                                title: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Flexible(
                                        flex: 2,
                                        child: _buildDialogItem(
                                            _selectedDialogCountry)),
                                    const Flexible(flex: 1, child: Text('▼')),
                                  ],
                                ),
                              ),
                            ),
                            Flexible(
                              flex: 7,
                              child: Padding(
                                padding: const EdgeInsets.only(right: 10),
                                child: TextFormField(
                                  maxLength: 10,
                                  validator: (value) {
                                    if (value!.isEmpty) {
                                      return 'Required field'.tr();
                                    } else {
                                      return null;
                                    }
                                  },
                                  keyboardType: TextInputType.phone,
                                  onChanged: (value) {
                                    setState(() {
                                      phone = value;
                                    });
                                  },
                                  decoration: InputDecoration(
                                      counterText: '',
                                      hintText: 'Mobile phone number'.tr(),
                                      focusColor: Colors.orange),
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                      referralStatus == false
                          ? const SizedBox()
                          : Padding(
                              padding:
                                  const EdgeInsets.only(left: 12, right: 12),
                              child: Row(
                                children: [
                                  const Flexible(
                                      flex: 1,
                                      child: Icon(
                                        Icons.person_add,
                                        size: 40,
                                        color: Colors.grey,
                                      )),
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  Flexible(
                                    flex: 6,
                                    child: TextFormField(
                                      onChanged: (value) {
                                        setState(() {
                                          referralCode = value;
                                        });
                                      },
                                      decoration: InputDecoration(
                                          hintText: 'Referral Code'.tr(),
                                          focusColor: Colors.orange),
                                    ),
                                  )
                                ],
                              ),
                            ),

                      // Padding(
                      //   padding: const EdgeInsets.all(8.0),
                      //   child: SizedBox(
                      //       height: 50,
                      //       width: double.infinity,
                      //       child: ElevatedButton(
                      //           style: ElevatedButton.styleFrom(
                      //               primary: Colors.blue),
                      //           onPressed: () async {
                      //             if (_formKey.currentState!.validate()) {
                      //               AuthService().signUp(
                      //                   email,
                      //                   password,
                      //                   fullname,
                      //                   phone,
                      //                   context,
                      //                   referralCode,
                      //                   reward,
                      //                   referralStatus,
                      //                   playerId);
                      //             }
                      //           },
                      //           child: const Text('Create Account',
                      //                   style: TextStyle(
                      //                       fontSize: 20, color: Colors.white))
                      //               .tr())),
                      // ),
                      const SizedBox(
                        height: 20,
                      ),
                      RoundedLoadingButton(
                        color: Colors.blue,
                        successIcon: Icons.done,
                        failedIcon: Icons.error,
                        controller: _btnController1,
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            _doSomething(
                                _btnController1,
                                email,
                                password,
                                fullname,
                                '+$selectedCode$phone',
                                context,
                                referralCode,
                                reward,
                                referralStatus,
                                playerId);
                          } else {
                            _btnController1.reset();
                          }
                        },
                        child: const Text('Create Account',
                                style: TextStyle(color: Colors.white))
                            .tr(),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              Expanded(
                flex: 2,
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
      ),
    );
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DesktopLogin extends StatefulWidget {
  const DesktopLogin({Key? key}) : super(key: key);

  @override
  State<DesktopLogin> createState() => _DesktopLoginState();
}

class _DesktopLoginState extends State<DesktopLogin>
    with SingleTickerProviderStateMixin {
  String email = '';
  String password = '';
  String firebasePassword = '';
  String firebaseUsername = '';
  bool loading = false;
  String error = '';
  String fullname = '';
  final _formKey = GlobalKey<FormState>();
  bool showPassword = true;
  late AnimationController controller;

  loginDetails() {
    FirebaseFirestore.instance
        .collection('Admin')
        .doc('Admin')
        .get()
        .then((value) {
      setState(() {
        firebasePassword = value['password'];
        firebaseUsername = value['username'];
        //print(firebasePassword);
        //print(firebaseUsername);
      });
    });
  }

  @override
  void initState() {
    loginDetails();
    controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..addListener(() {
        setState(() {});
      });
    controller.repeat(reverse: true);
    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  bool? loggedIn;
  getSelectedRoute() {
    SharedPreferences.getInstance().then((prefs) {
      var log = prefs.getBool('logged in');
      setState(() {
        loggedIn = log!;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    getSelectedRoute();

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white24,
        title: loading == true
            ? LinearProgressIndicator(
                color: Colors.blue.shade800,
                value: controller.value,
                semanticsLabel: 'Linear progress indicator',
              )
            : Container(),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 25),
                child: Text(
                  "OLIVETTE ADMIN",
                  style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade800),
                  textAlign: TextAlign.start,
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                height: MediaQuery.of(context).size.width >= 1100
                    ? MediaQuery.of(context).size.height / 1.8
                    : MediaQuery.of(context).size.height / 2,
                width: MediaQuery.of(context).size.width >= 1100
                    ? MediaQuery.of(context).size.width / 3
                    : MediaQuery.of(context).size.width / 1.2,
                child: Card(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18.0),
                        side: const BorderSide(color: Colors.white)),
                    elevation: 20,
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              const SizedBox(
                                height: 40,
                              ),
                              Padding(
                                padding: const EdgeInsets.all(5.0),
                                child: TextFormField(
                                  validator: (value) {
                                    Pattern pattern =
                                        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
                                    RegExp regex = RegExp(pattern.toString());
                                    if (!regex.hasMatch(value!) ||
                                        value != firebaseUsername) {
                                      return 'Enter a valid Email';
                                    } else {
                                      return null;
                                    }
                                  },
                                  decoration: InputDecoration(
                                    focusColor: Colors.grey,
                                    labelText: "Email".tr(),
                                    hintStyle:
                                        TextStyle(color: Colors.blue.shade800),
                                    prefixIcon: Icon(
                                      Icons.alternate_email,
                                      size: 30,
                                      color: Colors.blue.shade800,
                                    ),
                                    filled: true,
                                    fillColor: Colors.white10,
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: const BorderSide(
                                          color: Colors.grey, width: 1.0),
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: const BorderSide(
                                          color: Colors.grey, width: 1.0),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: const BorderSide(
                                          color: Colors.grey, width: 1.0),
                                    ),
                                  ),
                                  onChanged: (value) {
                                    setState(() {
                                      email = value;
                                    });
                                  },
                                ),
                              ),
                              const SizedBox(
                                height: 20,
                              ),
                              Padding(
                                padding: const EdgeInsets.all(5.0),
                                child: TextFormField(
                                    validator: (arg) {
                                      if (arg!.length <= 5 ||
                                          arg != firebasePassword) {
                                        return 'Pasword must be up to 6 digits';
                                      } else {
                                        return null;
                                      }
                                    },
                                    obscureText: showPassword,
                                    onChanged: (value) {
                                      setState(() {
                                        password = value;
                                      });
                                    },
                                    decoration: InputDecoration(
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        borderSide: const BorderSide(
                                            color: Colors.grey, width: 1.0),
                                      ),
                                      focusColor: Colors.grey,
                                      labelText: "password".tr(),
                                      hintStyle: TextStyle(
                                          color: Colors.blue.shade800),
                                      prefixIcon: Icon(
                                        Icons.lock,
                                        size: 30,
                                        color: Colors.blue.shade800,
                                      ),
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
                                      filled: true,
                                      fillColor: Colors.white10,
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                        borderSide: const BorderSide(
                                            color: Colors.grey, width: 1.0),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        borderSide: const BorderSide(
                                            color: Colors.grey, width: 1.0),
                                      ),
                                    )),
                              ),
                              const SizedBox(
                                height: 20,
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: SizedBox(
                                  height: 45,
                                  width: double.infinity,
                                  child: loading
                                      ? ElevatedButton(
                                          style: ButtonStyle(
                                            elevation:
                                                MaterialStateProperty.all(10),
                                            backgroundColor:
                                                MaterialStateProperty.all<
                                                    Color>(
                                              Colors.orange,
                                            ),
                                          ),
                                          onPressed: () {},
                                          child: const Text(
                                            "Logging in...",
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold),
                                          ).tr(),
                                        )
                                      : ElevatedButton(
                                          style: ButtonStyle(
                                            elevation:
                                                MaterialStateProperty.all(10),
                                            backgroundColor:
                                                MaterialStateProperty.all<
                                                    Color>(
                                              Colors.orange,
                                            ),
                                          ),
                                          onPressed: () async {
                                            if (_formKey.currentState!
                                                .validate()) {
                                              setState(() {
                                                loading = true;
                                              });
                                              Future.delayed(
                                                  const Duration(seconds: 3),
                                                  () async {
                                                var prefs =
                                                    await SharedPreferences
                                                        .getInstance();
                                                prefs.setBool(
                                                    'logged in', true);
                                                Modular.to
                                                    .pushNamedAndRemoveUntil(
                                                        '/home', (p0) => false);
                                              });
                                            }
                                          },
                                          child: const Text(
                                            "Login",
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold),
                                          ).tr(),
                                        ),
                                ),
                              ),
                            ],
                          )),
                    )),
              )
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class VerificationPage extends StatefulWidget {
  const VerificationPage({Key? key}) : super(key: key);

  @override
  State<VerificationPage> createState() => _VerificationPageState();
}

class _VerificationPageState extends State<VerificationPage> {
  bool verification = false;
  verificationStatus() {
    final FirebaseAuth auth = FirebaseAuth.instance;
    User? user = auth.currentUser;
    setState(() {
      verification = user!.emailVerified;
    });
  }

  @override
  void initState() {
    verificationStatus();

    super.initState();
  }

  whenVerificationIsTrue() {
    if (verification == true) {
      Navigator.of(context).pushNamed('/bottomNav');
    }
  }

  sendVerification() {
    final FirebaseAuth auth = FirebaseAuth.instance;
    User? user = auth.currentUser;
    user!.sendEmailVerification().then((value) {
      try {
        Fluttertoast.showToast(
            msg: 'Verification sent to your email...',
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
            timeInSecForIosWeb: 1,
      
            fontSize: 14.0);
      } catch (value) {
        Fluttertoast.showToast(
            msg: value.toString(),
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
            timeInSecForIosWeb: 1,
       
            fontSize: 14.0);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('Please check your email to verify your account.'),
          const SizedBox(
            height: 20,
          ),
          ElevatedButton(
              onPressed: () {
                sendVerification();
              },
              child: const Text('Resend Verification'))
        ],
      )),
    );
  }
}

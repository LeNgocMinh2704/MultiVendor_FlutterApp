import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';
import 'dart:developer' as developer;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:user_1/Pages/connectivity.dart';
import 'package:user_1/Pages/home_page.dart';
import 'package:user_1/Pages/login_page.dart';

class Wrapper extends StatefulWidget {
  const Wrapper({Key? key}) : super(key: key);

  @override
  State<Wrapper> createState() => _WrapperState();
}

class _WrapperState extends State<Wrapper> {
  ConnectivityResult _connectionStatus = ConnectivityResult.mobile;
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<ConnectivityResult> _connectivitySubscription;
  bool isLogged = true;
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

  @override
  void initState() {
    initConnectivity();
    getAuth();
    _connectivitySubscription =
        _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
    super.initState();
  }

  @override
  void dispose() {
    _connectivitySubscription.cancel();
    super.dispose();
  }

  Future<void> initConnectivity() async {
    late ConnectivityResult result;
    try {
      result = await _connectivity.checkConnectivity();
    } on PlatformException catch (e) {
      developer.log('Couldn\'t check connectivity status', error: e);
      return;
    }
    if (!mounted) {
      return Future.value(null);
    }

    return _updateConnectionStatus(result);
  }

  Future<void> _updateConnectionStatus(ConnectivityResult result) async {
    setState(() {
      _connectionStatus = result;
    });
  }

  bool? connectionStatus;
  getConnectionStatus() {
    if (_connectionStatus == ConnectivityResult.mobile ||
        _connectionStatus == ConnectivityResult.ethernet ||
        _connectionStatus == ConnectivityResult.wifi) {
      setState(() {
        connectionStatus = true;
      });
    } else if (_connectionStatus == ConnectivityResult.none) {
      setState(() {
        connectionStatus = false;
      });
    }
    debugPrint(connectionStatus.toString());
  }

  @override
  Widget build(BuildContext context) {
    getConnectionStatus();
    if (connectionStatus == true) {
      return isLogged == true ? const HomePage() : const LoginPage();
    } else {
      return const NetworkError();
    }
  }
}

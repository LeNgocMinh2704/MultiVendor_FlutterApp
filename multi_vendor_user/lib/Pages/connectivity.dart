import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class NetworkError extends StatefulWidget {
  const NetworkError({Key? key}) : super(key: key);

  @override
  State<NetworkError> createState() => _NetworkErrorState();
}

class _NetworkErrorState extends State<NetworkError> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Flexible(flex: 12, child: Image.asset('assets/image/error.jpg')),
            const SizedBox(
              height: 20,
            ),
            Text(
              'Network is lost please make sure your network is on',
              style: TextStyle(color: Theme.of(context).iconTheme.color),
            ).tr()
          ],
        ));
  }
}

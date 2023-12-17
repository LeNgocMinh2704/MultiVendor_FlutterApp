import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class ConnectivityError extends StatefulWidget {
  const ConnectivityError({Key? key}) : super(key: key);

  @override
  State<ConnectivityError> createState() => _ConnectivityErrorState();
}

class _ConnectivityErrorState extends State<ConnectivityError> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          iconTheme: Theme.of(context).iconTheme,
          backgroundColor: Theme.of(context).cardColor,
          elevation: 0,
          automaticallyImplyLeading: false,
          title: const Text(
            'Network Error',
          ).tr(),
        ),
        body: Center(
          child: Column(
            children: <Widget>[
              const SizedBox(
                height: 40,
              ),
              Icon(
                Icons.network_wifi,
                size: 100,
                color: Colors.grey[300],
              ),
              const SizedBox(height: 10),
              const Text('Please Check Your Network Connection').tr(),
            ],
          ),
        ));
  }
}

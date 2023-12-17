import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class DeliveryAddressesPage extends StatefulWidget {
  const DeliveryAddressesPage({Key? key}) : super(key: key);

  @override
  State<DeliveryAddressesPage> createState() => _DeliveryAddressesPageState();
}

class _DeliveryAddressesPageState extends State<DeliveryAddressesPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          iconTheme: Theme.of(context).iconTheme,
          backgroundColor: Theme.of(context).cardColor,
          title: const Text('Delivery Addresses').tr()),
    );
  }
}

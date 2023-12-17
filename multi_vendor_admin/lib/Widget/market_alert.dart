import 'package:another_flushbar/flushbar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../Models/market_model.dart';

class MarketAlert extends StatefulWidget {
  final MarketModel result;
  const MarketAlert({Key? key, required this.result}) : super(key: key);

  @override
  State<MarketAlert> createState() => _MarketAlertState();
}

class _MarketAlertState extends State<MarketAlert> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: SizedBox(
        height: 200,
        width: 200,
        child: Column(
          children: [const Text("Are You Sure You Want To Delete Market?").tr()],
        ),
      ),
      actions: [
        InkWell(
            onTap: () {
              FirebaseFirestore.instance
                  .collection('Markets')
                  .doc(widget.result.uid)
                  .delete()
                  .then((val) => Navigator.of(context).pop());
              Flushbar(
                flushbarPosition: FlushbarPosition.TOP,
                title: "Market Update".tr(),
                message: "Market has been deleted successfully!!!".tr(),
                duration: const Duration(seconds: 3),
              ).show(context);
            },
            child: const Text("Yes").tr()),
        const SizedBox(width: 20),
        InkWell(
            onTap: () {
              Navigator.of(context).pop();
            },
            child: const Text('No').tr())
      ],
    );
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../Model/market.dart';

class SelectMarket extends StatefulWidget {
  final String vendorID;
  const SelectMarket({Key? key, required this.vendorID}) : super(key: key);

  @override
  State<SelectMarket> createState() => _SelectMarketState();
}

class _SelectMarketState extends State<SelectMarket> {
  Stream<List<MarketModel>> getMyMarkets() {
    return FirebaseFirestore.instance
        .collection('Markets')
        .where('Vendor ID', isEqualTo: widget.vendorID)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => MarketModel.fromMap(doc.data(), doc.id))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<MarketModel>>(
        stream: getMyMarkets(),
        builder: ((context, snapshot) {
          if (snapshot.hasData) {
            return ListView.separated(
                itemBuilder: (context, index) {
                  MarketModel marketModel = snapshot.data![index];
                  return ListTile(
                    onTap: () {
                      Navigator.of(context).pop(marketModel);
                    },
                    title: Text(marketModel.marketName),
                    subtitle: Text(marketModel.category),
                  );
                },
                separatorBuilder: (context, index) {
                  return const Divider(
                    color: Colors.black,
                    thickness: 1,
                  );
                },
                itemCount: snapshot.data!.length);
          } else {
            return const SpinKitCircle(
              color: Colors.orange,
            );
          }
        }));
  }
}

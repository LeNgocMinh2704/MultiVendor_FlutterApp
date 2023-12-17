import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:vendor/Pages/cashout.dart';

class MarketOverviewDetails extends StatefulWidget {
  final String id;
  const MarketOverviewDetails({Key? key, required this.id}) : super(key: key);

  @override
  State<MarketOverviewDetails> createState() => _MarketOverviewDetailsState();
}

class _MarketOverviewDetailsState extends State<MarketOverviewDetails> {
  int marketLength = 0;
  int orderLength = 0;
  DocumentReference? userRef;
  String id = '';

  getMarketLength() {
    final FirebaseAuth auth = FirebaseAuth.instance;
    final FirebaseFirestore firestore = FirebaseFirestore.instance;

    User? user = auth.currentUser;
    firestore.collection('vendors').doc(user!.uid).snapshots().listen((event) {
      setState(() {
        id = event['id'];
      });
      if (id != '') {
        //print('done');
        FirebaseFirestore.instance
            .collection('Markets')
            .where('Vendor ID', isEqualTo: id)
            .where('Approval', isEqualTo: true)
            .snapshots()
            .listen((value) {
          setState(() {
            marketLength = value.docs.length;
          });
        });
      }
    });
  }

  getOrderLength() {
    final FirebaseAuth auth = FirebaseAuth.instance;
    final FirebaseFirestore firestore = FirebaseFirestore.instance;

    User? user = auth.currentUser;
    firestore.collection('vendors').doc(user!.uid).snapshots().listen((event) {
      setState(() {
        id = event['id'];
        if (id != '') {
          FirebaseFirestore.instance
              .collection('Orders')
              .where('vendorID', isEqualTo: id)
              .snapshots()
              .listen((value) {
            setState(() {
              orderLength = value.docs.length;
            });
          });
        }
      });
    });
  }

  @override
  void initState() {
    getOrderLength();
    getMarketLength();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    //print('your id is ${widget.id}');
    return ListView(
      scrollDirection: Axis.horizontal,
      shrinkWrap: true,
      children: [
        InkWell(
          onTap: () {},
          child: SizedBox(
            height: 120,
            width: 180,
            child: Card(
              elevation: 10,
              child: Center(
                child: Column(children: [
                  const SizedBox(height: 10),
                  const Text(
                    'Number of Approved Markets',
                    textAlign: TextAlign.center,
                  ).tr(),
                  Text(
                    '$marketLength',
                    style: const TextStyle(
                        fontSize: 40, fontWeight: FontWeight.bold),
                  )
                ]),
              ),
            ),
          ),
        ),
        InkWell(
          onTap: () {},
          child: SizedBox(
            height: 120,
            width: 180,
            child: Card(
              elevation: 10,
              child: Center(
                child: Column(children: [
                  const SizedBox(height: 10),
                  const Text(
                    'Number of Completed Orders',
                    textAlign: TextAlign.center,
                  ).tr(),
                  Text(
                    '$orderLength',
                    style: const TextStyle(
                        fontSize: 40, fontWeight: FontWeight.bold),
                  )
                ]),
              ),
            ),
          ),
        ),
        InkWell(
          onTap: () {
            Navigator.of(context)
                .push(MaterialPageRoute(builder: (context) => const Cashout()));
          },
          child: SizedBox(
            height: 120,
            width: 180,
            child: Card(
              elevation: 10,
              child: Column(children: [
                const SizedBox(height: 10),
                const Text(
                  'Tap To Cash Out',
                  textAlign: TextAlign.center,
                ).tr(),
                Image.network(
                    'https://play-lh.googleusercontent.com/NncHrhT1YP_h5_w3IvAR4MeJJTQocjtAvGCvEfdwU2oko7JF2NigxP81RtZPA_nMA0M',
                    width: 70,
                    height: 70),
                const Text('Cash out').tr(),
              ]),
            ),
          ),
        )
      ],
    );
  }
}

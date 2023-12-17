import 'package:another_flushbar/flushbar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../Models/market_model.dart';

class MarketDetail extends StatefulWidget {
  final MarketModel marketModel;
  const MarketDetail({Key? key, required this.marketModel}) : super(key: key);

  @override
  State<MarketDetail> createState() => _MarketDetailState();
}

class _MarketDetailState extends State<MarketDetail> {
  String vendorName = '';
  String vendorPhone = '';
  getVendorDetails() {
    FirebaseFirestore.instance
        .collection('vendors')
        .doc(widget.marketModel.vendorId)
        .get()
        .then((val) {
      setState(() {
        vendorName = val['fullname'];
        vendorPhone = val['phone'];
      });
    });
  }

  @override
  void initState() {
    getVendorDetails();
    super.initState();
  }

  num commission = 0;

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Container(
        padding: const EdgeInsets.all(16.0),
        width: double.infinity,
        height: double.infinity,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Market Detail').tr(),
                  InkWell(
                      onTap: () {
                        Navigator.of(context).pop();
                      },
                      child: const Icon(Icons.clear))
                ],
              ),
              const SizedBox(height: 20),
              Image.network(widget.marketModel.image1, height: 200, width: 200),
              const SizedBox(height: 20),
              Row(
                children: [
                  const Text('Market Name:',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 20))
                      .tr(),
                  const SizedBox(
                    width: 10,
                  ),
                  Text(widget.marketModel.marketName,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 20)),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  const Text('Market Phone:',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 20))
                      .tr(),
                  const SizedBox(
                    width: 10,
                  ),
                  Text(widget.marketModel.phonenumber,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 20)),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  const Text('Market Category:',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 20))
                      .tr(),
                  const SizedBox(
                    width: 10,
                  ),
                  Text(widget.marketModel.category,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 20)),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  const Text('Market Address:',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 20))
                      .tr(),
                  const SizedBox(
                    width: 10,
                  ),
                  MediaQuery.of(context).size.width >= 1100
                      ? Align(
                          alignment: Alignment.centerLeft,
                          child: Text(widget.marketModel.address,
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 20)),
                        )
                      : const SizedBox(),
                ],
              ),
              MediaQuery.of(context).size.width >= 1100
                  ? const SizedBox()
                  : Text(widget.marketModel.address,
                      style: const TextStyle(fontSize: 10)),
              const SizedBox(height: 20),
              Row(
                children: [
                  const Text("Vendor's name:",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 20))
                      .tr(),
                  const SizedBox(
                    width: 10,
                  ),
                  Text(vendorName,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 20)),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  const Text("Vendor's phone:",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 20))
                      .tr(),
                  const SizedBox(
                    width: 10,
                  ),
                  Text(vendorPhone,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 20)),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  const Text('Market Status:',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 20))
                      .tr(),
                  const SizedBox(
                    width: 10,
                  ),
                  Text(
                      widget.marketModel.approval == true
                          ? 'Approved'.tr()
                          : 'Not Approved'.tr(),
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 20)),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    flex: 2,
                    child: const Text('Commission(%):',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 20))
                        .tr(),
                  ),
                  Flexible(
                    flex: 2,
                    child: TextField(
                      onChanged: (v) {
                        setState(() {
                          commission = int.parse(v);
                        });
                      },
                      decoration: InputDecoration(
                          hintText: widget.marketModel.commission.toString()),
                    ),
                  ),
                  MediaQuery.of(context).size.width >= 1100
                      ? Flexible(
                          child: ElevatedButton(
                          child: const Text('Set Commission'),
                          onPressed: () {
                            FirebaseFirestore.instance
                                .collection('Markets')
                                .doc(widget.marketModel.uid)
                                .update({
                              'commission': commission,
                            }).then((value) {
                              Flushbar(
                                flushbarPosition: FlushbarPosition.TOP,
                                title: "Commission update",
                                message:
                                    "Commission has been updated successfully.",
                                duration: const Duration(seconds: 3),
                              ).show(context);
                            });
                          },
                        ))
                      : const SizedBox()
                ],
              ),
              const SizedBox(height: 20),
              MediaQuery.of(context).size.width >= 1100
                  ? const SizedBox()
                  : ElevatedButton(
                      child: const Text('Set Commission'),
                      onPressed: () {
                        FirebaseFirestore.instance
                            .collection('Markets')
                            .doc(widget.marketModel.uid)
                            .update({
                          'commission': commission,
                        }).then((value) {
                          Flushbar(
                            flushbarPosition: FlushbarPosition.TOP,
                            title: "Commission update",
                            message:
                                "Commission has been updated successfully.",
                            duration: const Duration(seconds: 3),
                          ).show(context);
                        });
                      },
                    ),
              const SizedBox(height: 20),
              widget.marketModel.approval == false
                  ? ElevatedButton(
                      onPressed: () {
                        Flushbar(
                          flushbarPosition: FlushbarPosition.TOP,
                          title: "Market Status",
                          message: "Market has been approved!!!",
                          duration: const Duration(seconds: 3),
                        )
                            .show(context)
                            .then((val) => Navigator.of(context).pop());

                        FirebaseFirestore.instance
                            .collection('Markets')
                            .doc(widget.marketModel.uid)
                            .update({'Approval': true});
                      },
                      child: const Text("Approve Market").tr(),
                    )
                  : ElevatedButton(
                      onPressed: () {
                        Flushbar(
                          flushbarPosition: FlushbarPosition.TOP,
                          title: "Market Status".tr(),
                          message: "Market has been disabled!!!".tr(),
                          duration: const Duration(seconds: 3),
                        ).show(context);

                        FirebaseFirestore.instance
                            .collection('Markets')
                            .doc(widget.marketModel.uid)
                            .update({'Approval': false}).then(
                                (value) => Navigator.of(context).pop());
                      },
                      child: const Text("Disable Market").tr(),
                    )
            ],
          ),
        ),
      ),
    );
  }
}

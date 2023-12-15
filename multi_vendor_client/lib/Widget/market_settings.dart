import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class MarketSetting extends StatefulWidget {
  final String? marketID;
  const MarketSetting({Key? key, this.marketID}) : super(key: key);

  @override
  State<MarketSetting> createState() => _MarketSettingState();
}

class _MarketSettingState extends State<MarketSetting> {
  String doorDeliveryDetails = '';
  String pickupDeliveryDetails = '';

  updateMarketSettings(
    String doorDeliveryDetails,
    String pickupDeliveryDetails,
  ) {
    FirebaseFirestore.instance
        .collection('Markets')
        .doc(widget.marketID)
        .update({
      'doorDeliveryDetails': doorDeliveryDetails,
      'pickupDeliveryDetails': pickupDeliveryDetails,
    }).then((value) {
      Navigator.of(context).pop();
    });
  }

  String doorDeliveryDetailsData = '';
  String pickupDeliveryDetailData = '';

  getMarketSettings() {
    FirebaseFirestore.instance
        .collection('Markets')
        .doc(widget.marketID)
        .get()
        .then((value) {
      setState(() {
        doorDeliveryDetailsData = value['doorDeliveryDetails'];
        pickupDeliveryDetailData = value['pickupDeliveryDetails'];
      });
    });
  }

  @override
  void initState() {
    getMarketSettings();
    super.initState();
  }

  whenPickupDetailsIsNull() {
    if (pickupDeliveryDetails == '') {
      return pickupDeliveryDetailData;
    } else {
      return pickupDeliveryDetails;
    }
  }

  whenDoorDetailsIsNull() {
    if (doorDeliveryDetails == '') {
      return doorDeliveryDetailsData;
    } else {
      return doorDeliveryDetails;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          iconTheme: Theme.of(context).iconTheme,
          backgroundColor: Theme.of(context).cardColor,
          title: const Text('Market Settings'),
        ),
        body: SingleChildScrollView(
            child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              const SizedBox(height: 20),
              Row(
                children: const [
                  Text('Door Delivery Detail:',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 10),
              TextFormField(
                maxLines: 5,
                onSaved: (value) {
                  setState(() {
                    doorDeliveryDetails = value!;
                  });
                },
                onChanged: (value) {
                  setState(() {
                    doorDeliveryDetails = value;
                  });
                },
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Required field'.tr();
                  } else {
                    return null;
                  }
                },
                decoration: InputDecoration(
                  hintText: doorDeliveryDetailsData == ''
                      ? 'Door Delivery Detail'
                      : doorDeliveryDetailsData,
                  focusColor: Colors.grey,
                  filled: true,
                  fillColor: Colors.white10,
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Colors.grey, width: 1.0),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Colors.grey, width: 1.0),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Colors.grey, width: 1.0),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: const [
                  Text('Pickup Delivery Detail:',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 10),
              TextFormField(
                maxLines: 5,
                onSaved: (value) {
                  setState(() {
                    pickupDeliveryDetails = value!;
                  });
                },
                onChanged: (value) {
                  setState(() {
                    pickupDeliveryDetails = value;
                  });
                },
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Required field'.tr();
                  } else {
                    return null;
                  }
                },
                decoration: InputDecoration(
                  hintText: pickupDeliveryDetailData == ''
                      ? 'PickUp Delivery Detail'
                      : pickupDeliveryDetailData,
                  focusColor: Colors.grey,
                  filled: true,
                  fillColor: Colors.white10,
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Colors.grey, width: 1.0),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Colors.grey, width: 1.0),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Colors.grey, width: 1.0),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.orange),
                    onPressed: () {
                      updateMarketSettings(
                          whenDoorDetailsIsNull(), whenPickupDetailsIsNull());
                    },
                    child: const Text('Update Market Settings',
                        style: TextStyle(color: Colors.white))),
              )
            ],
          ),
        )));
  }
}

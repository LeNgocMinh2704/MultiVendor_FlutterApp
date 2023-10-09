import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:geocoder2/geocoder2.dart';
import '../Model/constant.dart';
import '../Model/courier.dart';
import 'map.dart';

class Tracking extends StatefulWidget {
  final CourierModel courierModel;

  const Tracking({Key? key, required this.courierModel}) : super(key: key);

  @override
  State<Tracking> createState() => _TrackingState();
}

class _TrackingState extends State<Tracking> {
  int _index = 0;

  getStatus() {
    if (widget.courierModel.deliveryBoysName == '') {
      setState(() {
        _index = 0;
      });
    } else if (widget.courierModel.deliveryBoysName != '') {
      setState(() {
        _index = 1;
      });
    } else if (widget.courierModel.status == true) {
      setState(() {
        _index = 3;
      });
    }
  }

  @override
  void initState() {
    getStatus();
    super.initState();
  }

  double deliveryAddressLat = 0;
  double deliveryAddressLong = 0;
  double userLat = 0;
  double userLong = 0;

  getDeliveryLocationLatAndLong() async {
    if (deliveryAddressLat == 0 && deliveryAddressLong == 0) {
      GeoData data = await Geocoder2.getDataFromAddress(
          address: widget.courierModel.recipientAddress,
          googleMapApiKey: googleApiKey);
      if (mounted) {
        setState(() {
          deliveryAddressLat = data.latitude;
          deliveryAddressLong = data.longitude;
        });
        // print(deliveryAddressLat);
      }
    }
  }

  getUserLatAndLong() async {
    if (userLat == 0 && userLong == 0) {
      GeoData data = await Geocoder2.getDataFromAddress(
          address: widget.courierModel.recipientAddress,
          googleMapApiKey: googleApiKey);
      if (mounted) {
        setState(() {
          userLat = data.latitude;
          userLong = data.longitude;
        });
        // print(deliveryAddressLat);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    getUserLatAndLong();
    getDeliveryLocationLatAndLong();
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Parcel Tracking',
                style: TextStyle(fontWeight: FontWeight.bold),
              ).tr(),
            ],
          ),
        ),
        const SizedBox(
          height: 20,
        ),
        Stack(
          children: [
            deliveryAddressLat != 0 && deliveryAddressLong != 0
                ? SizedBox(
                    width: double.infinity,
                    height: MediaQuery.of(context).size.height / 2.3,
                    child: MapScreen(
                        zoom: 5,
                        userLat: deliveryAddressLat,
                        address: widget.courierModel.recipientAddress,
                        userLong: deliveryAddressLong,
                        marketLong: userLong,
                        marketLat: userLat),
                  )
                : SizedBox(
                    width: double.infinity,
                    height: MediaQuery.of(context).size.height / 2.3,
                  ),
            Stepper(
              physics: const BouncingScrollPhysics(),
              controlsBuilder:
                  (BuildContext context, ControlsDetails controls) {
                return const SizedBox();
              },
              currentStep: _index,
              onStepTapped: (int index) {
                setState(() {
                  _index = index;
                });
              },
              steps: <Step>[
                Step(
                  isActive: _index == 0 && widget.courierModel.status == false
                      ? true
                      : false,
                  title: Container(
                      color: Colors.black45,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: const Text(
                          'Waiting Rider Approval',
                          style: TextStyle(color: Colors.white),
                        ).tr(),
                      )),
                  content: Container(),
                ),
                Step(
                  isActive: _index == 1 && widget.courierModel.status == false
                      ? true
                      : false,
                  title: Container(
                      color: Colors.black45,
                      child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: const Text(
                            'Rider Accept To Deliver Package',
                            style: TextStyle(color: Colors.white),
                          ).tr())),
                  content: Container(),
                ),
                Step(
                  isActive: _index == 2 && widget.courierModel.status == false
                      ? true
                      : false,
                  title: Container(
                      color: Colors.black45,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: const Text(
                          'Package Is On The Way',
                          style: TextStyle(color: Colors.white),
                        ).tr(),
                      )),
                  content: Container(),
                ),
                Step(
                  isActive: widget.courierModel.status == true ? true : false,
                  title: Container(
                    color: Colors.black45,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: const Text(
                        'Completed',
                        style: TextStyle(color: Colors.white),
                      ).tr(),
                    ),
                  ),
                  content: Container(),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}

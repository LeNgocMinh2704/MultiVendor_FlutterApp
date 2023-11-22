// import 'dart:math';
// import 'package:flutter/material.dart';
// import 'package:fluttertoast/fluttertoast.dart';
// import 'package:url_launcher/url_launcher.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:easy_localization/easy_localization.dart';
// import '../Model/courier.dart';
// import '../Widgets/tracking.dart';

// class CourierOverview extends StatefulWidget {
//   final CourierModel courierModel;
//   const CourierOverview({Key? key, required this.courierModel})
//       : super(key: key);

//   @override
//   State<CourierOverview> createState() => _CourierOverviewState();
// }

// class _CourierOverviewState extends State<CourierOverview> {
//   String getcurrencyName = '';
//   String getcurrencyCode = '';
//   String getcurrencySymbol = '';
//   getCurrencyDetails() {
//     FirebaseFirestore.instance
//         .collection('Currency Settings')
//         .doc('Currency Settings')
//         .get()
//         .then((value) {
//       setState(() {
//         getcurrencyName = value['Currency name'];
//         getcurrencyCode = value['Currency code'];
//         getcurrencySymbol = value['Currency symbol'];
//       });
//     });
//   }

//   @override
//   void initState() {
//     getCurrencyDetails();
//     getRiderDetails();
//     assignRider();
//     super.initState();
//   }

//   String deliveryBoyID = '';

//   List<String> riders = [];
//   int randomIndex = 0;
//   String deliveryBoysName = '';

//   assignRider() {
//     if (widget.courierModel.deliveryBoysName == '') {
//       Future.delayed(const Duration(minutes: 2), () {
//         FirebaseFirestore.instance
//             .collection('drivers')
//             .where('Approval', isEqualTo: true)
//             .where('open', isEqualTo: true)
//             .get()
//             .then((value) {
//           for (var element in value.docs) {
//             riders.add(element['id']);
//             debugPrint('Delivery boys are $riders');
//             setState(() {
//               randomIndex = Random().nextInt(riders.length);
//             });
//           }
//         });
//       });
//     }
//   }

//   getRiderDetails() {
//     if (riders.isNotEmpty) {
//       FirebaseFirestore.instance
//           .collection('drivers')
//           .doc(riders[randomIndex])
//           .snapshots()
//           .listen((value) {
//         setState(() {
//           deliveryBoysName = value['fullname'];
//           deliveryBoyID = value['id'];
//         });
//         if (widget.courierModel.deliveryBoysName == '') {
//           Future.delayed(const Duration(minutes: 2), () {
//             FirebaseFirestore.instance
//                 .collection('Courier')
//                 .doc(widget.courierModel.uid)
//                 .update({'deliveryBoyID': deliveryBoyID}).then((value) {
//               Fluttertoast.showToast(
//                   msg: "Rider updated",
//                   toastLength: Toast.LENGTH_SHORT,
//                   gravity: ToastGravity.TOP,
//                   timeInSecForIosWeb: 1,

//                   fontSize: 14.0);
//             });
//           });
//         }
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//         appBar: AppBar(
//           iconTheme: Theme.of(context).iconTheme,
//           titleTextStyle: TextStyle(color: Theme.of(context).indicatorColor),
//           backgroundColor: Theme.of(context).colorScheme.background,
//           centerTitle: true,
//           elevation: 0,
//           title: const Text(
//             'Courier details',
//           ).tr(),
//         ),
//         body: SingleChildScrollView(
//           child: Padding(
//             padding: const EdgeInsets.all(8.0),
//             child: Column(
//               children: [
//                 const SizedBox(height: 20),
//                 Tracking(courierModel: widget.courierModel),
//                 const SizedBox(
//                   height: 20,
//                 ),
//                 Padding(
//                   padding: const EdgeInsets.all(8.0),
//                   child: const Text(
//                     'Parcel Details',
//                     style: TextStyle(fontWeight: FontWeight.bold),
//                   ).tr(),
//                 ),
//                 Row(
//                   children: [
//                     const Text('Parcel Image',
//                             style: TextStyle(
//                                 fontWeight: FontWeight.bold, fontSize: 12))
//                         .tr(),
//                   ],
//                 ),
//                 const SizedBox(
//                   height: 20,
//                 ),
//                 SizedBox(
//                   height: MediaQuery.of(context).size.height / 3,
//                   width: double.infinity,
//                   child: Padding(
//                     padding: const EdgeInsets.all(8.0),
//                     child: Image.network(
//                       widget.courierModel.parcelImage,
//                       fit: BoxFit.cover,
//                     ),
//                   ),
//                 ),
//                 const SizedBox(
//                   height: 20,
//                 ),
//                 SizedBox(
//                   height: 75,
//                   width: double.infinity,
//                   child: Card(
//                     elevation: 0,
//                     child: Column(
//                       mainAxisAlignment: MainAxisAlignment.start,
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         const SizedBox(height: 5),
//                         Padding(
//                           padding: const EdgeInsets.only(left: 10.0),
//                           child: Text(
//                             'Parcel ID: #${widget.courierModel.parcelID}',
//                             style: const TextStyle(
//                                 fontWeight: FontWeight.bold, fontSize: 12),
//                           ),
//                         ),
//                         const SizedBox(height: 5),
//                         Padding(
//                           padding: const EdgeInsets.only(left: 10.0),
//                           child: Text(
//                             'Date: ${widget.courierModel.deliveryDate}',
//                           ),
//                         ),
//                         const SizedBox(height: 5),
//                         Padding(
//                           padding: const EdgeInsets.only(left: 10.0),
//                           child: Row(
//                             children: [
//                               const Text('Parcel Name:',
//                                       style: TextStyle(
//                                           fontWeight: FontWeight.bold,
//                                           fontSize: 12))
//                                   .tr(),
//                               const SizedBox(width: 10),
//                               Text(
//                                 widget.courierModel.parcelName,
//                               )
//                             ],
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//                 const SizedBox(
//                   height: 20,
//                 ),
//                 Card(
//                   elevation: 0,
//                   child: Column(
//                     children: [
//                       const SizedBox(height: 5),
//                       Row(
//                         children: [
//                           const Text("Sender's Name:",
//                                   style: TextStyle(
//                                       fontWeight: FontWeight.bold,
//                                       fontSize: 12))
//                               .tr(),
//                           const SizedBox(width: 10),
//                           Text(
//                             widget.courierModel.sendersName,
//                           )
//                         ],
//                       ),
//                       const SizedBox(
//                         height: 5,
//                       ),
//                       Row(
//                         children: [
//                           const Text("Sender's Address:",
//                                   style: TextStyle(
//                                       fontWeight: FontWeight.bold,
//                                       fontSize: 12))
//                               .tr(),
//                           const SizedBox(width: 10),
//                           Text(widget.courierModel.sendersAddress,
//                               style: const TextStyle(fontSize: 12))
//                         ],
//                       ),
//                       const SizedBox(height: 5),
//                       Row(
//                         children: [
//                           const Text('Pick Up Address:',
//                                   style: TextStyle(
//                                       fontWeight: FontWeight.bold,
//                                       fontSize: 12))
//                               .tr(),
//                           const SizedBox(width: 10),
//                           Text(widget.courierModel.sendersAddress,
//                               style: const TextStyle(fontSize: 12))
//                         ],
//                       ),
//                       const SizedBox(height: 5),
//                     ],
//                   ),
//                 ),
//                 const SizedBox(
//                   height: 20,
//                 ),
//                 Card(
//                   elevation: 0,
//                   child: Column(
//                     children: [
//                       Row(
//                         children: [
//                           const Text('Recipient Name:',
//                                   style: TextStyle(
//                                       fontWeight: FontWeight.bold,
//                                       fontSize: 12))
//                               .tr(),
//                           const SizedBox(width: 10),
//                           Text(
//                             widget.courierModel.recipientName,
//                           ),
//                         ],
//                       ),
//                       const SizedBox(
//                         height: 5,
//                       ),
//                       Row(
//                         children: [
//                           const Text('Recipient Address:',
//                                   style: TextStyle(
//                                       fontWeight: FontWeight.bold,
//                                       fontSize: 12))
//                               .tr(),
//                           const SizedBox(width: 10),
//                           Text(widget.courierModel.recipientAddress,
//                               style: const TextStyle(fontSize: 12)),
//                         ],
//                       ),
//                       const SizedBox(
//                         height: 5,
//                       ),
//                       Row(
//                         children: [
//                           const Text('Pick Up Address:',
//                                   style: TextStyle(
//                                       fontWeight: FontWeight.bold,
//                                       fontSize: 12))
//                               .tr(),
//                           const SizedBox(width: 10),
//                           Text(widget.courierModel.recipientAddress,
//                               style: const TextStyle(fontSize: 12)),
//                         ],
//                       ),
//                     ],
//                   ),
//                 ),
//                 const SizedBox(
//                   height: 20,
//                 ),
//                 Card(
//                   elevation: 0,
//                   child: Column(
//                     children: [
//                       Row(
//                         children: [
//                           const Text('Rider name:',
//                                   style: TextStyle(
//                                       fontWeight: FontWeight.bold,
//                                       fontSize: 12))
//                               .tr(),
//                           const SizedBox(
//                             width: 10,
//                           ),
//                           widget.courierModel.deliveryBoysName == ''
//                               ? const Text(
//                                       'Rider is yet to accept delivery please wait after 2 minutes',
//                                       style: TextStyle(fontSize: 10))
//                                   .tr()
//                               : deliveryBoysName != ''
//                                   ? Text(deliveryBoysName)
//                                   : Text(
//                                       widget.courierModel.deliveryBoysName,
//                                     ),
//                         ],
//                       ),
//                       const SizedBox(
//                         height: 5,
//                       ),
//                       Row(
//                         children: [
//                           const Text('Rider phone:',
//                                   style: TextStyle(
//                                       fontWeight: FontWeight.bold,
//                                       fontSize: 12))
//                               .tr(),
//                           const SizedBox(
//                             width: 10,
//                           ),
//                           widget.courierModel.deliveryBoysPhone == ''
//                               ? const Text('Rider is yet to accept delivery',
//                                       style: TextStyle(fontSize: 10))
//                                   .tr()
//                               : Text(
//                                   widget.courierModel.deliveryBoysPhone,
//                                 ),
//                         ],
//                       ),
//                       const SizedBox(
//                         height: 5,
//                       ),
//                       widget.courierModel.deliveryBoysPhone == ''
//                           ? Container()
//                           : ElevatedButton(
//                               onPressed: () async {
//                                 final Uri launchUri = Uri(
//                                   scheme: 'tel',
//                                   path: widget.courierModel.deliveryBoysPhone,
//                                 );
//                                 await launchUrl(launchUri);
//                               },
//                               child: const Text('Call Rider',
//                                       style: TextStyle(
//                                           fontSize: 12,
//                                           fontWeight: FontWeight.bold))
//                                   .tr(),
//                             ),
//                     ],
//                   ),
//                 ),
//                 const SizedBox(
//                   height: 20,
//                 ),
//                 Card(
//                   elevation: 0,
//                   child: Column(
//                     children: [
//                       Row(
//                         children: [
//                           const Text('Price:',
//                                   style: TextStyle(
//                                       fontWeight: FontWeight.bold,
//                                       fontSize: 12))
//                               .tr(),
//                           const SizedBox(
//                             width: 10,
//                           ),
//                           Text(
//                             '$getcurrencySymbol${widget.courierModel.price}',
//                           )
//                         ],
//                       ),
//                       const SizedBox(
//                         height: 5,
//                       ),
//                       Row(
//                         children: [
//                           const Text('Distance:',
//                                   style: TextStyle(
//                                       fontWeight: FontWeight.bold,
//                                       fontSize: 12))
//                               .tr(),
//                           const SizedBox(
//                             width: 10,
//                           ),
//                           Text('${widget.courierModel.km.toString()}Km')
//                         ],
//                       ),
//                       const SizedBox(
//                         height: 5,
//                       ),
//                       Row(
//                         children: [
//                           const Text('Weight:',
//                                   style: TextStyle(
//                                       fontWeight: FontWeight.bold,
//                                       fontSize: 12))
//                               .tr(),
//                           const SizedBox(
//                             width: 10,
//                           ),
//                           Text(
//                             '${widget.courierModel.weight.toString()}Kg',
//                           )
//                         ],
//                       ),
//                     ],
//                   ),
//                 ),
//                 const SizedBox(
//                   height: 20,
//                 ),
//                 SizedBox(
//                   height: 40,
//                   width: double.infinity,
//                   child: Card(
//                     elevation: 0,
//                     child: Row(
//                       children: [
//                         const Text('Parcel Description',
//                                 style: TextStyle(
//                                     fontWeight: FontWeight.bold, fontSize: 12))
//                             .tr(),
//                         const SizedBox(
//                           width: 10,
//                         ),
//                         Text(widget.courierModel.parcelDescription,
//                             style: const TextStyle(fontSize: 12))
//                       ],
//                     ),
//                   ),
//                 ),
//                 const SizedBox(
//                   height: 20,
//                 ),
//                 widget.courierModel.deliveryBoysName == ''
//                     ? ElevatedButton(
//                         style: ElevatedButton.styleFrom(
//                             textStyle: const TextStyle(color: Colors.white),
//                             backgroundColor: Colors.orange),
//                         onPressed: () {
//                           FirebaseFirestore.instance
//                               .collection('Courier')
//                               .doc(widget.courierModel.uid)
//                               .delete()
//                               .then((value) {
//                             Navigator.of(context).pop();
//                           });
//                         },
//                         child: const Text('Cancel Delivery',
//                                 style: TextStyle(color: Colors.white))
//                             .tr())
//                     : Container(),
//               ],
//             ),
//           ),
//         ));
//   }
// }

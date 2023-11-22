// import 'package:flutter/material.dart';
// import 'package:fluttertoast/fluttertoast.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';

// class OneSignalSettings extends StatefulWidget {
//   static const routeName = '/push-notifications-settings';

//   const OneSignalSettings({Key? key}) : super(key: key);

//   @override
//   State<OneSignalSettings> createState() => _OneSignalSettingsState();
// }

// class _OneSignalSettingsState extends State<OneSignalSettings> {
//   @override
//   void initState() {
//     getOneSignalDetails();
//     super.initState();
//   }

//   String oneSignalKey = '';

//   final _formKey = GlobalKey<FormState>();

//   String getOnesignalKey = '';

//   getOneSignalDetails() {
//     FirebaseFirestore.instance
//         .collection('Push notification Settings')
//         .doc('OneSignal')
//         .get()
//         .then((value) {
//       if (mounted) {
//         setState(() {
//           getOnesignalKey = value['OnesignalKey'];
//         });
//       }
//     });
//   }

//   whenOnesignalKeyisNull() {
//     if (oneSignalKey == '') {
//       return getOnesignalKey;
//     } else {
//       return oneSignalKey;
//     }
//   }

//   updateOneSignalKey() {
//     FirebaseFirestore.instance
//         .collection('Push notification Settings')
//         .doc('OneSignal')
//         .set({'OnesignalKey': whenOnesignalKeyisNull()});
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: [
//         Row(
//           children: const [
//             Padding(
//               padding: EdgeInsets.all(8.0),
//               child: Text(
//                 'Enter OneSignal key for push notification',
//                 style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
//               ),
//             ),
//           ],
//         ),
//         Form(
//           key: _formKey,
//           child: Column(
//             children: [
//               Padding(
//                 padding: const EdgeInsets.all(8.0),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     const Flexible(
//                         flex: 1,
//                         child: Text('OneSignal Key:',
//                             style: TextStyle(
//                               fontWeight: FontWeight.bold,
//                             ))),
//                     Flexible(
//                         flex: 4,
//                         child: TextFormField(
//                             readOnly: true,
//                             onTap: () {
//                               Fluttertoast.showToast(
//                                   msg:
//                                       "This is a test version you can't change the key",
//                                   backgroundColor: Colors.blue.shade800,
//                                   textColor: Colors.white);
//                             },
//                             validator: (value) {
//                               if (value!.isEmpty) {
//                                 return 'OneSignal key is required';
//                               } else {
//                                 return null;
//                               }
//                             },
//                             onChanged: (value) {
//                               setState(() {
//                                 oneSignalKey = value;
//                               });
//                             },
//                             decoration: InputDecoration(
//                               border: OutlineInputBorder(
//                                 borderRadius: BorderRadius.circular(8),
//                                 borderSide:
//                                     const BorderSide(color: Colors.grey, width: 1.0),
//                               ),
//                               hintText: whenOnesignalKeyisNull(),
//                               focusColor: Colors.grey,
//                               filled: true,
//                               fillColor: Colors.white10,
//                               focusedBorder: OutlineInputBorder(
//                                 borderRadius: BorderRadius.circular(10),
//                                 borderSide:
//                                     const BorderSide(color: Colors.grey, width: 1.0),
//                               ),
//                               enabledBorder: OutlineInputBorder(
//                                 borderRadius: BorderRadius.circular(8),
//                                 borderSide:
//                                     const BorderSide(color: Colors.grey, width: 1.0),
//                               ),
//                             )))
//                   ],
//                 ),
//               ),
//               Padding(
//                 padding: const EdgeInsets.all(8.0),
//                 child: ElevatedButton(
//                   style: ButtonStyle(
//                     elevation: MaterialStateProperty.all(10),
//                     backgroundColor: MaterialStateProperty.all<Color>(
//                       Colors.blue.shade800,
//                     ),
//                   ),
//                   onPressed: () {
//                     if (_formKey.currentState!.validate()) {
//                       updateOneSignalKey();
//                       _formKey.currentState!.reset();
//                       Fluttertoast.showToast(
//                           msg: "Update completed",
//                           backgroundColor: Colors.blue.shade800,
//                           textColor: Colors.white);
//                     }
//                   },
//                   child: const Text(
//                     'Update',
//                     style: TextStyle(color: Colors.white),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ],
//     );
//   }
// }

// import 'dart:typed_data';
// import 'package:another_flushbar/flushbar.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:file_picker/file_picker.dart';
// import 'package:firebase_storage/firebase_storage.dart';
// import 'package:flutter/material.dart';
// import 'package:easy_localization/easy_localization.dart';
// import '../Models/cities_model.dart';

// class EditCity extends StatefulWidget {
//   final CitiesModel citiesModel;
//   const EditCity({Key? key, required this.citiesModel}) : super(key: key);

//   @override
//   State<EditCity> createState() => _EditCityState();
// }

// class _EditCityState extends State<EditCity> {
//   String category = '';
//   String firestoreImage = '';
//   dynamic image;
//   bool loading = false;

//   Future<void> addCategory(CitiesModel citiesModel) async {
//     FirebaseFirestore.instance
//         .collection('Cities')
//         .doc(widget.citiesModel.uid)
//         .update(citiesModel.toMap())
//         .then((value) => Flushbar(
//               flushbarPosition: FlushbarPosition.TOP,
//               title: "Notification",
//               message: "Cities has been updated successfully!!!",
//               duration: const Duration(seconds: 3),
//             )..show(context));
//   }

//   getImage() async {
//     FilePickerResult? result = await FilePicker.platform.pickFiles(
//       type: FileType.custom,
//       allowedExtensions: ['jpg', 'jpeg', 'png'],
//     );

//     if (result != null) {
//       Uint8List? fileBytes = result.files.first.bytes;
//       String fileName = result.files.first.name;
//       setState(() {
//         image = fileBytes;
//         loading = true;
//       });
//       // Upload file
//       TaskSnapshot upload = await FirebaseStorage.instance
//           .ref('uploads/$fileName')
//           .putData(fileBytes!);
//       String url = await upload.ref.getDownloadURL();
//       //print(url);
//       setState(() {
//         firestoreImage = url;
//         if (firestoreImage != '') {
//           loading = false;
//         }
//       });
//     }
//   }

//   whenCategoryIsEmpty() {
//     if (category == '') {
//       return widget.citiesModel.cityName;
//     } else {
//       return category;
//     }
//   }

//   whenImageIsEmpty() {
//     if (firestoreImage == '') {
//       return widget.citiesModel.image;
//     } else {
//       return firestoreImage;
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return AlertDialog(
//       title: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           const Text('Edit city').tr(),
//           InkWell(
//               onTap: () {
//                 Navigator.of(context).pop();
//               },
//               child: const Icon(Icons.clear))
//         ],
//       ),
//       content: SizedBox(
//         width: MediaQuery.of(context).size.width / 1.5,
//         child: SingleChildScrollView(
//           child: Column(
//             children: [
//               const SizedBox(height: 20),
//               TextFormField(
//                 initialValue: widget.citiesModel.cityName,
//                 onChanged: (value) {
//                   setState(() {
//                     category = value;
//                   });
//                 },
//                 decoration: InputDecoration(hintText: "City name".tr()),
//               ),
//               const SizedBox(height: 40),
//               image == '' || image == null
//                   ? Image.network(
//                       widget.citiesModel.image,
//                       height: 300,
//                       width: 300,
//                       fit: BoxFit.fill,
//                     )
//                   : Image.memory(
//                       image,
//                       height: 300,
//                       width: 300,
//                       fit: BoxFit.fill,
//                     ),
//               const SizedBox(height: 20),
//               IconButton(
//                 onPressed: () {
//                   getImage();
//                 },
//                 icon: const Icon(Icons.add_a_photo),
//                 iconSize: 50,
//                 color: Colors.blue.shade800,
//               ),
//               const SizedBox(height: 20),
//               loading == true
//                   ? SizedBox(
//                       height: 50,
//                       child: ElevatedButton(
//                           style: ElevatedButton.styleFrom(
//                               backgroundColor: Colors.blue.shade800),
//                           onPressed: null,
//                           child: const Text('Update city').tr()))
//                   : SizedBox(
//                       height: 50,
//                       child: ElevatedButton(
//                           style: ElevatedButton.styleFrom(
//                               backgroundColor: Colors.blue.shade800),
//                           onPressed: () {
//                             addCategory(CitiesModel(
//                                     cityName: whenCategoryIsEmpty(),
//                                     image: whenImageIsEmpty()))
//                                 .then((value) => Navigator.of(context).pop());
//                           },
//                           child: const Text('Update city').tr()))
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

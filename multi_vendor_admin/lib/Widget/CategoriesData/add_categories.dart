// import 'dart:typed_data';
// import 'package:another_flushbar/flushbar.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:file_picker/file_picker.dart';
// import 'package:firebase_storage/firebase_storage.dart';
// import 'package:flutter/material.dart';
// import 'package:admin_web/Models/categories.dart';
// import 'package:easy_localization/easy_localization.dart';

// class AddCategory extends StatefulWidget {
//   const AddCategory({Key? key}) : super(key: key);

//   @override
//   State<AddCategory> createState() => _AddCategoryState();
// }

// class _AddCategoryState extends State<AddCategory> {
//   String category = '';
//   String firestoreImage = '';
//   dynamic image;

//   Future<void> addCategory(CategoriesModel categoriesModel) async {
//     FirebaseFirestore.instance
//         .collection('Categories')
//         .add(categoriesModel.toMap())
//         .then((value) => Flushbar(
//               flushbarPosition: FlushbarPosition.TOP,
//               title: "Notification",
//               message: "Category has been added successfully!!!",
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
//       });
//       // Upload file
//       TaskSnapshot upload = await FirebaseStorage.instance
//           .ref('uploads/$fileName')
//           .putData(fileBytes!);
//       String url = await upload.ref.getDownloadURL();
//       print(url);
//       setState(() {
//         firestoreImage = url;
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return AlertDialog(
//       title: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           const Text('Add a new category').tr(),
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
//                 onChanged: (value) {
//                   setState(() {
//                     category = value;
//                   });
//                 },
//                 decoration: InputDecoration(hintText: "Category name".tr()),
//               ),
//               const SizedBox(height: 40),
//               image == null
//                   ? const Icon(Icons.image, size: 300, color: Colors.grey)
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
//               firestoreImage == ''
//                   ? SizedBox(
//                       height: 50,
//                       child: ElevatedButton(
//                           style: ElevatedButton.styleFrom(
//                               backgroundColor: Colors.blue.shade800),
//                           onPressed: null,
//                           child: const Text('Add new category').tr()))
//                   : SizedBox(
//                       height: 50,
//                       child: ElevatedButton(
//                           style: ElevatedButton.styleFrom(
//                               backgroundColor: Colors.blue.shade800),
//                           onPressed: () {
//                             addCategory(CategoriesModel(
//                                     category: category, image: firestoreImage))
//                                 .then((value) => Navigator.of(context).pop());
//                           },
//                           child: const Text('Add new category').tr()))
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// // ignore_for_file: avoid_function_literals_in_foreach_calls

// import 'dart:typed_data';
// import 'package:animated_button_bar/animated_button_bar.dart';
// import 'package:another_flushbar/flushbar.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:dropdown_search/dropdown_search.dart';
// import 'package:file_picker/file_picker.dart';
// import 'package:firebase_storage/firebase_storage.dart';
// import 'package:flutter/material.dart';
// import 'package:admin_web/Models/feeds.dart';
// import 'package:easy_localization/easy_localization.dart';

// class AddFeed extends StatefulWidget {
//   const AddFeed({Key? key}) : super(key: key);

//   @override
//   State<AddFeed> createState() => _AddFeedState();
// }

// class _AddFeedState extends State<AddFeed> {
//   String subcategory = '';
//   String firestoreImage = '';
//   dynamic image;
//   String category = '';
//   String subcategorycollection = '';
//   String title = '';
//   String detail = '';
//   bool slider = true;

//   Future<void> addFeed(FeedsModel feedsModel) async {
//     FirebaseFirestore.instance
//         .collection('Feeds')
//         .add(feedsModel.toMap())
//         .then((value) => Flushbar(
//               flushbarPosition: FlushbarPosition.TOP,
//               title: "Notification",
//               message: "Feed has been added successfully!!!",
//               duration: const Duration(seconds: 3),
//             )..show(context));
//   }

//   getImage() async {
//     FilePickerResult? result = await FilePicker.platform.pickFiles(
//       type: FileType.custom,
//       allowedExtensions: ['jpg', 'jpeg', 'png', 'gif'],
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
//       //print(url);
//       setState(() {
//         firestoreImage = url;
//       });
//     }
//   }

//   List<String> categories = [];
//   getCategories() {
//     FirebaseFirestore.instance.collection('Categories').get().then((value) {
//       //print('Length is ${value.docs.length}');
//       return value.docs.forEach((element) {
//         categories.add(element.data()['category']);
//       });
//     });
//   }

//   bool selected = true;
//   List<String> subCategories = [];
//   getSubCategories() {
//     if (category != '' && selected == true) {
//       FirebaseFirestore.instance
//           .collection('Sub Categories')
//           .where('category', isEqualTo: category)
//           .get()
//           .then((value) {
//         return value.docs.forEach((element) {
//           subCategories.add(element.data()['name']);
//         });
//       });
//       subCategories.clear();
//     }
//   }

//   List<String> subCategoriesCollections = [];
//   getSubCategoriesCollections() {
//     if (category != '' && selected == false && subcategory != '') {
//       FirebaseFirestore.instance
//           .collection('Sub categories collections')
//           .where('sub-category', isEqualTo: subcategory)
//           .get()
//           .then((value) {
//         //print('Length is ${value.docs.length}');
//         return value.docs.forEach((element) {
//           subCategoriesCollections.add(element.data()['name']);
//         });
//       });
//       subCategoriesCollections.clear();
//     }
//   }

//   @override
//   void initState() {
//     getCategories();

//     super.initState();
//   }

//   @override
//   Widget build(BuildContext context) {
//     getSubCategories();
//     getSubCategoriesCollections();
//     return AlertDialog(
//       title: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           const Text('Add a new feed').tr(),
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
//               TextFormField(
//                 onChanged: (value) {
//                   setState(() {
//                     title = value;
//                   });
//                 },
//                 decoration: InputDecoration(hintText: "Feed title".tr()),
//               ),
//               const SizedBox(
//                 height: 10,
//               ),
//               TextFormField(
//                   maxLines: 4,
//                   onChanged: (value) {
//                     setState(() {
//                       detail = value;
//                     });
//                   },
//                   decoration: InputDecoration(
//                     labelText: "Feed detail".tr(),
//                     fillColor: Colors.white,
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(10.0),
//                       borderSide: const BorderSide(),
//                     ),
//                   )),
//               DropdownSearch<String>(
//                 validator: (v) => v == null ? "required field".tr() : null,
//                 popupProps: const PopupProps.menu(
//                   showSelectedItems: true,
//                 ),
//                 dropdownDecoratorProps: DropDownDecoratorProps(
//                     dropdownSearchDecoration: InputDecoration(
//                   hintText: "Select a category".tr(),
//                   labelText: "Categories *",
//                   border: const UnderlineInputBorder(
//                     borderSide: BorderSide(color: Color(0xFF01689A)),
//                   ),
//                 )),
//                 items: categories,
//                 onChanged: (value) {
//                   setState(() {
//                     category = value!;
//                     selected = true;
//                     subcategory = '';
//                   });
//                 },
//               ),
//               // DropdownSearch<String>(
//               //   validator: (v) => v == null ? "required field".tr() : null,
//               //   popupProps: const PopupProps.menu(
//               //     showSelectedItems: true,
//               //   ),
//               //   dropdownDecoratorProps: DropDownDecoratorProps(
//               //       dropdownSearchDecoration: InputDecoration(
//               //     labelText: "Sub Categories *",
//               //     hintText: "Select a sub category".tr(),
//               //     border: const UnderlineInputBorder(
//               //       borderSide: BorderSide(color: Color(0xFF01689A)),
//               //     ),
//               //   )),
//               //   items: subCategories,
//               //   onChanged: (value) {
//               //     setState(() {
//               //       subcategory = value!;
//               //       selected = false;
//               //     });
//               //   },
//               // ),
//               // DropdownSearch<String>(
//               //   validator: (v) => v == null ? "required field" : null,
//               //   popupProps: const PopupProps.menu(
//               //     showSelectedItems: true,
//               //   ),
//               //   dropdownDecoratorProps: const DropDownDecoratorProps(
//               //       dropdownSearchDecoration: InputDecoration(
//               //     labelText: "Sub categories collections *",
//               //     hintText: "Select a sub category collections",
//               //     border: UnderlineInputBorder(
//               //       borderSide: BorderSide(color: Color(0xFF01689A)),
//               //     ),
//               //   )),
//               //   items: subCategoriesCollections,
//               //   onChanged: (value) {
//               //     setState(() {
//               //       subcategorycollection = value!;
//               //     });
//               //   },
//               // ),
//               const SizedBox(height: 20),
//               Text('Enable Slider'.tr(),
//                   style: const TextStyle(fontWeight: FontWeight.bold)),
//               AnimatedButtonBar(
//                 radius: 32.0,
//                 padding: const EdgeInsets.all(20.0),
//                 backgroundColor: Colors.blueGrey.shade800,
//                 foregroundColor: Colors.blueGrey.shade300,
//                 elevation: 0,
//                 borderColor: Colors.white,
//                 borderWidth: 2,
//                 innerVerticalPadding: 16,
//                 children: [
//                   ButtonBarEntry(
//                       onTap: () {
//                         slider = true;
//                       },
//                       child: const Text('Yes').tr()),
//                   ButtonBarEntry(
//                       onTap: () {
//                         setState(() {
//                           slider = false;
//                         });
//                       },
//                       child: const Text('No').tr()),
//                 ],
//               ),
//               image == null
//                   ? const Icon(Icons.image, size: 200, color: Colors.grey)
//                   : Image.memory(
//                       image,
//                       height: 200,
//                       width: 200,
//                       fit: BoxFit.cover,
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
//               firestoreImage == '' ||
//                       category == '' ||
//                       title == '' ||
//                       detail == ''
//                   ? SizedBox(
//                       height: 50,
//                       child: ElevatedButton(
//                           style: ElevatedButton.styleFrom(
//                               backgroundColor: Colors.blue.shade800),
//                           onPressed: null,
//                           child: const Text('Add new feed').tr()))
//                   : SizedBox(
//                       height: 50,
//                       child: ElevatedButton(
//                           style: ElevatedButton.styleFrom(
//                               backgroundColor: Colors.blue.shade800),
//                           onPressed: () {
//                             addFeed(FeedsModel(
//                                     slider: slider,
//                                     title: title,
//                                     category: category,
//                                     image: firestoreImage,
//                                     subCategoryCollections:
//                                         subcategorycollection,
//                                     subCategory: subcategory,
//                                     detail: detail))
//                                 .then((value) => Navigator.of(context).pop());
//                           },
//                           child: const Text('Add new feed').tr()))
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

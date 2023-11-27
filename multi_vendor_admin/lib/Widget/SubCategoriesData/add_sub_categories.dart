// ignore_for_file: avoid_function_literals_in_foreach_calls

import 'dart:typed_data';
import 'package:another_flushbar/flushbar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../Models/sub_category_model.dart';

class AddSubCategory extends StatefulWidget {
  const AddSubCategory({Key? key}) : super(key: key);

  @override
  State<AddSubCategory> createState() => _AddSubCategoryState();
}

class _AddSubCategoryState extends State<AddSubCategory> {
  String subcategory = '';
  String firestoreImage = '';
  dynamic image;
  String category = '';

  Future<void> addSubCategory(SubCategoriesModel categoriesModel) async {
    FirebaseFirestore.instance
        .collection('Sub Categories')
        .add(categoriesModel.toMap())
        .then((value) => Flushbar(
              flushbarPosition: FlushbarPosition.TOP,
              title: "Notification",
              message: "Sub Category has been added successfully!!!",
              duration: const Duration(seconds: 3),
            )..show(context));
  }

  getImage() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png'],
    );

    if (result != null) {
      Uint8List? fileBytes = result.files.first.bytes;
      String fileName = result.files.first.name;
      setState(() {
        image = fileBytes;
      });
      // Upload file
      TaskSnapshot upload = await FirebaseStorage.instance
          .ref('uploads/$fileName')
          .putData(fileBytes!);
      String url = await upload.ref.getDownloadURL();
      //print(url);
      setState(() {
        firestoreImage = url;
      });
    }
  }

  List<String> categories = [];
  getCategories() {
    FirebaseFirestore.instance.collection('Categories').get().then((value) {
      //print('Length is ${value.docs.length}');
      return value.docs.forEach((element) {
        categories.add(element.data()['category']);
      });
    });
  }

  @override
  void initState() {
    getCategories();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text('Add a new sub-category').tr(),
          InkWell(
              onTap: () {
                Navigator.of(context).pop();
              },
              child: const Icon(Icons.clear))
        ],
      ),
      content: SizedBox(
        width: MediaQuery.of(context).size.width / 1.5,
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 20),
              TextFormField(
                onChanged: (value) {
                  setState(() {
                    subcategory = value;
                  });
                },
                decoration: InputDecoration(hintText: "Sub category name".tr()),
              ),
              const SizedBox(height: 20),
              DropdownSearch<String>(
                validator: (v) => v == null ? "required field".tr() : null,
                popupProps: const PopupProps.menu(
                  showSelectedItems: true,
                ),
                dropdownDecoratorProps: DropDownDecoratorProps(
                    dropdownSearchDecoration: InputDecoration(
                  hintText: "Select a category".tr(),
                  labelText: "Categories *",
                  border: const UnderlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF01689A)),
                  ),
                )),
                items: categories,
                onChanged: (value) {
                  setState(() {
                    category = value!;
                  });
                },
              ),
              const SizedBox(height: 40),
              image == null
                  ? const Icon(Icons.image, size: 300, color: Colors.grey)
                  : Image.memory(
                      image,
                      height: 300,
                      width: 300,
                      fit: BoxFit.cover,
                    ),
              const SizedBox(height: 20),
              IconButton(
                onPressed: () {
                  getImage();
                },
                icon: const Icon(Icons.add_a_photo),
                iconSize: 50,
                color: Colors.blue.shade800,
              ),
              const SizedBox(height: 20),
              firestoreImage == '' || category == '' || subcategory == ''
                  ? SizedBox(
                      height: 50,
                      child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue.shade800),
                          onPressed: null,
                          child: const Text('Add new sub category')))
                  : SizedBox(
                      height: 50,
                      child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue.shade800),
                          onPressed: () {
                            addSubCategory(SubCategoriesModel(
                                    category: category,
                                    image: firestoreImage,
                                    name: subcategory))
                                .then((value) => Navigator.of(context).pop());
                          },
                          child: const Text('Add new sub category').tr()))
            ],
          ),
        ),
      ),
    );
  }
}

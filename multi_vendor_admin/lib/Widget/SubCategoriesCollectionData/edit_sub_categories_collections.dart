// ignore_for_file: avoid_function_literals_in_foreach_calls

import 'dart:typed_data';
import 'package:another_flushbar/flushbar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../Models/sub_category_collections.dart';

class EditSubCategoriesCollections extends StatefulWidget {
  final SubCategoriesCollectionsModel categoriesModel;
  const EditSubCategoriesCollections({Key? key, required this.categoriesModel})
      : super(key: key);

  @override
  State<EditSubCategoriesCollections> createState() =>
      _EditSubCategoriesCollectionsState();
}

class _EditSubCategoriesCollectionsState
    extends State<EditSubCategoriesCollections> {
  String subCategory = '';
  String category = '';
  String name = '';
  String firestoreImage = '';
  dynamic image;

  Future<void> addSubCategoryCollections(
      SubCategoriesCollectionsModel subCategoriesModel) async {
    FirebaseFirestore.instance
        .collection('Sub categories collections')
        .doc(widget.categoriesModel.uid)
        .update(subCategoriesModel.toMap())
        .then((value) => Flushbar(
              flushbarPosition: FlushbarPosition.TOP,
              title: "Notification",
              message: "Sub Category has been updated successfully!!!",
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

  whenCategoryIsEmpty() {
    if (category == '') {
      return widget.categoriesModel.category;
    } else {
      return category;
    }
  }

  whennameIsEmpty() {
    if (name == '') {
      return widget.categoriesModel.name;
    } else {
      return name;
    }
  }

  whenSubCategoryIsEmpty() {
    if (selected != true) {
      return widget.categoriesModel.subCategory;
    } else {
      return subCategory;
    }
  }

  whenImageIsEmpty() {
    if (firestoreImage == '') {
      return widget.categoriesModel.image;
    } else {
      return firestoreImage;
    }
  }

  List<String> categories = [];
  bool selected = true;

  getCategories() {
    FirebaseFirestore.instance.collection('Categories').get().then((value) {
      //print('Length is ${value.docs.length}');
      return value.docs.forEach((element) {
        categories.add(element.data()['category']);
      });
    });
  }

  List<String> subCategories = [];
  String subcategory = '';
  getSubCategories() {
    FirebaseFirestore.instance
        .collection('Sub Categories')
        .where('category', isEqualTo: whenCategoryIsEmpty())
        .get()
        .then((value) {
      //print('Length is ${value.docs.length}');
      return value.docs.forEach((element) {
        subCategories.add(element.data()['name']);
      });
    });
    subCategories.clear();
  }

  @override
  void initState() {
    getCategories();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    getSubCategories();
    return AlertDialog(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text('Edit Sub-category').tr(),
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
              const SizedBox(height: 10),
              TextFormField(
                initialValue: widget.categoriesModel.name,
                onChanged: (value) {
                  setState(() {
                    name = value;
                  });
                },
                decoration: InputDecoration(
                    hintText: "Sub category category name".tr()),
              ),
              const SizedBox(height: 10),
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
                selectedItem:
                    category == '' ? widget.categoriesModel.category : category,
                onChanged: (value) {
                  setState(() {
                    category = value!;
                    selected = true;
                    subcategory = '';
                  });
                },
              ),
              const SizedBox(height: 10),
              DropdownSearch<String>(
                validator: (v) => v == null ? "required field".tr() : null,
                popupProps: const PopupProps.menu(
                  showSelectedItems: true,
                ),
                dropdownDecoratorProps: DropDownDecoratorProps(
                    dropdownSearchDecoration: InputDecoration(
                  hintText: "Select a sub category".tr(),
                  labelText: "Sub Categories *",
                  border: const UnderlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF01689A)),
                  ),
                )),
                items: subCategories,
                selectedItem: subCategory == ''
                    ? widget.categoriesModel.subCategory
                    : subCategory,
                onChanged: (value) {
                  setState(() {
                    subCategory = value!;
                    selected = false;
                  });
                },
              ),
              const SizedBox(height: 20),
              widget.categoriesModel.image == ''
                  ? const Icon(Icons.image, size: 200, color: Colors.grey)
                  : Image.network(
                      widget.categoriesModel.image,
                      height: 200,
                      width: 200,
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
              // widget.categoriesModel.category == '' ||
              //         widget.categoriesModel.image == '' ||
              //         widget.categoriesModel.name == '' ||
              //         widget.categoriesModel.subCategory == ''
              //     ? Container(
              //         height: 50,
              //         child: ElevatedButton(
              //             style: ElevatedButton.styleFrom(
              //                 primary: Colors.blue.shade800),
              //             onPressed: null,
              //             child: Text('Update sub category collection'))):
              SizedBox(
                  height: 50,
                  child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue.shade800),
                      onPressed: () {
                        addSubCategoryCollections(SubCategoriesCollectionsModel(
                                category: whenCategoryIsEmpty(),
                                image: whenImageIsEmpty(),
                                name: whennameIsEmpty(),
                                subCategory: whenSubCategoryIsEmpty()))
                            .then((value) => Navigator.of(context).pop());
                      },
                      child: const Text('Update sub category collection').tr()))
            ],
          ),
        ),
      ),
    );
  }
}

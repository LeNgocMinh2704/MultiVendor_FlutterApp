import 'dart:typed_data';
import 'package:another_flushbar/flushbar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

import '../../Models/sub_category_collections.dart';

class AddBrand extends StatefulWidget {
  const AddBrand({Key? key}) : super(key: key);

  @override
  State<AddBrand> createState() => _AddBrandState();
}

class _AddBrandState extends State<AddBrand> {
  String subcategory = '';
  String firestoreImage = '';
  dynamic image;
  String category = '';
  String brandName = '';

  Future<void> addSubCategory(
      SubCategoriesCollectionsModel categoriesModel) async {
    FirebaseFirestore.instance
        .collection('Brands')
        .add(categoriesModel.toMap())
        .then((value) => Flushbar(
              flushbarPosition: FlushbarPosition.TOP,
              title: "Notification",
              message: "Brand has been added successfully!!!",
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
      setState(() {
        firestoreImage = url;
      });
    }
  }

  List<String> categories = [];
  getCategories() {
    FirebaseFirestore.instance.collection('Categories').get().then((value) {
      // ignore: avoid_function_literals_in_foreach_calls
      return value.docs.forEach((element) {
        categories.add(element.data()['category']);
      });
    });
  }

  List<String> subCategories = [];
  getSubCategories() {
    if (category != '' && selected == true) {
      FirebaseFirestore.instance
          .collection('Sub Categories')
          .where('category', isEqualTo: category)
          .get()
          .then((value) {
        // ignore: avoid_function_literals_in_foreach_calls
        return value.docs.forEach((element) {
          subCategories.add(element.data()['name']);
        });
      });
      subCategories.clear();
    }
  }

  bool selected = true;
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
          const Text('Add a new brand collection'),
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
                    brandName = value;
                  });
                },
                decoration: const InputDecoration(hintText: "Brand name"),
              ),
              const SizedBox(height: 20),
              DropdownSearch<String>(
                validator: (v) => v == null ? "required field" : null,
                popupProps: const PopupProps.menu(
                  showSelectedItems: true,
                ),
                dropdownDecoratorProps: const DropDownDecoratorProps(
                    dropdownSearchDecoration: InputDecoration(
                  hintText: "Select a category",
                  labelText: "Categories *",
                  border: UnderlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF01689A)),
                  ),
                )),
                items: categories,
                onChanged: (value) {
                  setState(() {
                    category = value!;
                    selected = true;
                    subcategory = '';
                  });
                },
              ),
              const SizedBox(height: 20),
              DropdownSearch<String>(
                validator: (v) => v == null ? "required field" : null,
                popupProps: const PopupProps.menu(
                  showSelectedItems: true,
                ),
                dropdownDecoratorProps: const DropDownDecoratorProps(
                    dropdownSearchDecoration: InputDecoration(
                  hintText: "Select a sub category",
                  labelText: "Sub Categories *",
                  border: UnderlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF01689A)),
                  ),
                )),
                items: subCategories,
                onChanged: (value) {
                  setState(() {
                    subcategory = value!;
                    selected = false;
                  });
                },
              ),
              const SizedBox(height: 40),
              image == null
                  ? const Icon(Icons.image, size: 200, color: Colors.grey)
                  : Image.memory(
                      image,
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
              firestoreImage == '' ||
                      category == '' ||
                      subcategory == '' ||
                      brandName == ''
                  ? SizedBox(
                      height: 50,
                      child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue.shade800),
                          onPressed: null,
                          child: const Text('Add new brand')))
                  : SizedBox(
                      height: 50,
                      child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue.shade800),
                          onPressed: () {
                            addSubCategory(SubCategoriesCollectionsModel(
                                    category: category,
                                    image: firestoreImage,
                                    name: brandName,
                                    subCategory: subcategory))
                                .then((value) => Navigator.of(context).pop());
                          },
                          child: const Text('Add new brand')))
            ],
          ),
        ),
      ),
    );
  }
}

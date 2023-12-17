import 'dart:typed_data';
import 'package:another_flushbar/flushbar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../Models/sub_category_model.dart';

class EditSubCategories extends StatefulWidget {
  final SubCategoriesModel categoriesModel;
  const EditSubCategories({Key? key, required this.categoriesModel})
      : super(key: key);

  @override
  State<EditSubCategories> createState() => _EditSubCategoriesState();
}

class _EditSubCategoriesState extends State<EditSubCategories> {
  String subCategory = '';
  String category = '';
  String name = '';
  String firestoreImage = '';
  dynamic image;
  bool loading = false;

  Future<void> addCategory(SubCategoriesModel subCategoriesModel) async {
    FirebaseFirestore.instance
        .collection('Sub Categories')
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
        loading = true;
      });
      // Upload file
      TaskSnapshot upload = await FirebaseStorage.instance
          .ref('uploads/$fileName')
          .putData(fileBytes!);
      String url = await upload.ref.getDownloadURL();
      //print(url);
      setState(() {
        firestoreImage = url;
        if (firestoreImage != '') {
          loading = false;
        }
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

  whenImageIsEmpty() {
    if (firestoreImage == '') {
      return widget.categoriesModel.image;
    } else {
      return firestoreImage;
    }
  }

  List<String> categories = [];
  getCategories() {
    FirebaseFirestore.instance.collection('Categories').get().then((value) {
      //print('Length is ${value.docs.length}');
      // ignore: avoid_function_literals_in_foreach_calls
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
              const SizedBox(height: 20),
              TextFormField(
                initialValue: widget.categoriesModel.name,
                onChanged: (value) {
                  setState(() {
                    name = value;
                  });
                },
                decoration:
                    const InputDecoration(hintText: "Sub category name"),
              ),
              const SizedBox(height: 20),
              DropdownSearch<String>(
                validator: (v) => v == null ? "required field".tr() : null,
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
                selectedItem: widget.categoriesModel.name,
                onChanged: (value) {
                  setState(() {
                    category = value!;
                  });
                },
              ),
              const SizedBox(height: 40),
              image == '' || image == null
                  ? Image.network(
                      widget.categoriesModel.image,
                      height: 300,
                      width: 300,
                      fit: BoxFit.cover,
                    )
                  : Image.memory(
                      image,
                      height: 300,
                      width: 300,
                      fit: BoxFit.fill,
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
              loading == true
                  ? SizedBox(
                      height: 50,
                      child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue.shade800),
                          onPressed: null,
                          child: const Text('Update sub category')))
                  : SizedBox(
                      height: 50,
                      child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue.shade800),
                          onPressed: () {
                            addCategory(SubCategoriesModel(
                                    category: whenCategoryIsEmpty(),
                                    image: whenImageIsEmpty(),
                                    name: whennameIsEmpty()))
                                .then((value) => Navigator.of(context).pop());
                          },
                          child: const Text('Update sub category').tr()))
            ],
          ),
        ),
      ),
    );
  }
}

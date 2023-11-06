import 'dart:typed_data';

import 'package:another_flushbar/flushbar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

import '../Models/cities_model.dart';

class AddCity extends StatefulWidget {
  const AddCity({Key? key}) : super(key: key);

  @override
  State<AddCity> createState() => _AddCityState();
}

class _AddCityState extends State<AddCity> {
  String city = '';
  String firestoreImage = '';
  dynamic image;

  Future<void> addCategory(CitiesModel citiesModel) async {
    FirebaseFirestore.instance
        .collection('Cities')
        .add(citiesModel.toMap())
        .then((value) => Flushbar(
              flushbarPosition: FlushbarPosition.TOP,
              title: "Notification",
              message: "City has been added successfully!!!",
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

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 20),
          TextFormField(
            onChanged: (value) {
              setState(() {
                city = value;
              });
            },
            decoration: InputDecoration(hintText: "City name".tr()),
          ),
          const SizedBox(height: 40),
          image == null
              ? const Icon(Icons.image, size: 300, color: Colors.grey)
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
          firestoreImage == ''
              ? SizedBox(
                  height: 50,
                  child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue.shade800),
                      onPressed: null,
                      child: const Text('Add new city').tr()))
              : SizedBox(
                  height: 50,
                  child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue.shade800),
                      onPressed: () {
                        addCategory(CitiesModel(
                                cityName: city, image: firestoreImage))
                            .then((value) => Navigator.of(context).pop());
                      },
                      child: const Text('Add new city').tr()))
        ],
      ),
    );
  }
}

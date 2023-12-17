// ignore_for_file: avoid_function_literals_in_foreach_calls

import 'package:another_flushbar/flushbar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class HomeScreenSettings extends StatefulWidget {
  const HomeScreenSettings({Key? key}) : super(key: key);

  @override
  State<HomeScreenSettings> createState() => _HomeScreenSettingsState();
}

class _HomeScreenSettingsState extends State<HomeScreenSettings> {
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
    getProductSlide();
    super.initState();
  }

  String productSlide1 = '';
  String productSlide2 = '';
  String productSlide3 = '';
  String productSlide4 = '';
  String productSlide5 = '';

  String productSlideData1 = '';
  String productSlideData2 = '';
  String productSlideData3 = '';
  String productSlideData4 = '';
  String productSlideData5 = '';

  getProductSlide() {
    FirebaseFirestore.instance
        .collection('Product Slide')
        .doc('Product Slide')
        .get()
        .then((e) {
      if (mounted) {
        setState(() {
          productSlideData1 = e['Product Slide 1'];
          productSlideData2 = e['Product Slide 2'];
          productSlideData3 = e['Product Slide 3'];
          productSlideData4 = e['Product Slide 4'];
          productSlideData5 = e['Product Slide 5'];
        });
      }
    });
  }

  setProductSlide(
      String prod1, String prod2, String prod3, String prod4, String prod5) {
    FirebaseFirestore.instance
        .collection('Product Slide')
        .doc('Product Slide')
        .update({
      'Product Slide 1': prod1,
      'Product Slide 2': prod2,
      'Product Slide 3': prod3,
      'Product Slide 4': prod4,
      'Product Slide 5': prod5
    }).then((value) => Flushbar(
              flushbarPosition: FlushbarPosition.TOP,
              title: "Notification",
              message: "Successful update...",
              duration: const Duration(seconds: 3),
            )..show(context));
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          const SizedBox(height: 20),
          Row(
            children: const [
              Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  'Home Screen Product Slide Selection',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          DropdownSearch<String>(
            selectedItem: productSlideData1,
            validator: (v) => v == null ? "required field".tr() : null,
            popupProps: const PopupProps.menu(
              showSelectedItems: true,
            ),
            items: categories,
            dropdownDecoratorProps: DropDownDecoratorProps(
                dropdownSearchDecoration: InputDecoration(
              labelText: "Select Categories For First Product Slide",
              hintText: "Select a category".tr(),
              border: const UnderlineInputBorder(
                borderSide: BorderSide(color: Color(0xFF01689A)),
              ),
            )),
            onChanged: (value) {
              setState(() {
                productSlide1 = value!;
              });
            },
          ),
          const SizedBox(height: 20),
          DropdownSearch<String>(
            selectedItem: productSlideData2,
            validator: (v) => v == null ? "required field".tr() : null,
            popupProps: const PopupProps.menu(
              showSelectedItems: true,
            ),
            dropdownDecoratorProps: DropDownDecoratorProps(
                dropdownSearchDecoration: InputDecoration(
              labelText: "Select Categories For Second Product Slide",
              hintText: "Select a category".tr(),
              border: const UnderlineInputBorder(
                borderSide: BorderSide(color: Color(0xFF01689A)),
              ),
            )),
            items: categories,
            onChanged: (value) {
              setState(() {
                productSlide2 = value!;
              });
            },
          ),
          const SizedBox(height: 20),
          DropdownSearch<String>(
            dropdownDecoratorProps: DropDownDecoratorProps(
                dropdownSearchDecoration: InputDecoration(
              hintText: "Select a category".tr(),
              labelText: "Select Categories For Third Product Slide",
            )),
            selectedItem: productSlideData3,
            validator: (v) => v == null ? "required field".tr() : null,
            popupProps: const PopupProps.menu(
              showSelectedItems: true,
            ),
            items: categories,
            onChanged: (value) {
              setState(() {
                productSlide3 = value!;
              });
            },
          ),
          const SizedBox(height: 20),
          DropdownSearch<String>(
            selectedItem: productSlideData4,
            validator: (v) => v == null ? "required field".tr() : null,
            popupProps: const PopupProps.menu(
              showSelectedItems: true,
            ),
            dropdownDecoratorProps: DropDownDecoratorProps(
                dropdownSearchDecoration: InputDecoration(
              hintText: "Select a category".tr(),
              labelText: "Select Categories For Fourth Product Slide",
            )),
            items: categories,
            onChanged: (value) {
              setState(() {
                productSlide4 = value!;
              });
            },
          ),
          const SizedBox(height: 20),
          DropdownSearch<String>(
            dropdownDecoratorProps: DropDownDecoratorProps(
                dropdownSearchDecoration: InputDecoration(
              hintText: "Select a category".tr(),
              labelText: "Select Categories For Fifth Product Slide",
            )),
            selectedItem: productSlideData5,
            validator: (v) => v == null ? "required field".tr() : null,
            popupProps: const PopupProps.menu(
              showSelectedItems: true,
            ),
            items: categories,
            onChanged: (value) {
              setState(() {
                productSlide5 = value!;
              });
            },
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              style: ButtonStyle(
                elevation: MaterialStateProperty.all(10),
                backgroundColor: MaterialStateProperty.all<Color>(
                  Colors.blue.shade800,
                ),
              ),
              onPressed: () {
                setProductSlide(
                    productSlide1 == '' ? productSlideData1 : productSlide1,
                    productSlide2 == '' ? productSlideData2 : productSlide2,
                    productSlide3 == '' ? productSlideData3 : productSlide3,
                    productSlide4 == '' ? productSlideData4 : productSlide4,
                    productSlide5 == '' ? productSlideData5 : productSlide5);
              },
              child: const Text(
                'Update',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

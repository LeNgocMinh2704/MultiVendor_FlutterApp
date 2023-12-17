import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:vendor/Model/products.dart';
import 'package:uuid/uuid.dart';

class AddProducts extends StatefulWidget {
  final String? marketID;
  final String marketName;
  final String vendorID;
  final String marketCategory;
  const AddProducts(
      {Key? key,
      required this.marketCategory,
      required this.marketID,
      required this.vendorID,
      required this.marketName})
      : super(key: key);

  @override
  State<AddProducts> createState() => _AddProductsState();
}

class _AddProductsState extends State<AddProducts> {
  String uid = '';
  String description = '';
  String name = '';
  String category = '';
  String subCategory = '';
  String subSubCategory = '';
  String image1 = '';
  String image2 = '';
  String image3 = '';
  String unitname1 = '';
  String unitname2 = '';
  String unitname3 = '';
  String unitname4 = '';
  String unitname5 = '';
  String unitname6 = '';
  String unitname7 = '';
  num unitPrice1 = 0;
  num unitPrice2 = 0;
  num unitPrice3 = 0;
  num unitPrice4 = 0;
  num unitPrice5 = 0;
  num unitPrice6 = 0;
  num unitPrice7 = 0;
  num unitOldPrice1 = 0;
  num unitOldPrice2 = 0;
  num unitOldPrice3 = 0;
  num unitOldPrice4 = 0;
  num unitOldPrice5 = 0;
  num unitOldPrice6 = 0;
  num unitOldPrice7 = 0;
  num percantageDiscount = 0;
  String productId = '';
  String vendorId = '';
  String vendorName = '';
  String brandName = '';
  String marketID = '';
  String marketName = '';
  bool selected = true;
  XFile? _image1;
  XFile? _image2;
  XFile? _image3;
  bool? loading;
  final _formKey = GlobalKey<FormState>();
  String id = '';
  int quantity = 0;

  Future<void> _uploadImage1() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    //print(image);
    setState(() {
      _image1 = image;
      loading = true;
    });
    if (_image1 != null) {
      var snapshot = await FirebaseStorage.instance
          .ref()
          .child(_image1!.path)
          .putFile(File(_image1!.path));
      String downloadUrl =
          await snapshot.ref.getDownloadURL().whenComplete(() => setState(() {
                loading = false;
              }));

      setState(() {
        image1 = downloadUrl;
      });
      //print(image1);
    }
  }

  Future<void> _uploadImage2() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    //print(image);
    setState(() {
      _image2 = image;
      loading = true;
    });
    if (_image2 != null) {
      var snapshot = await FirebaseStorage.instance
          .ref()
          .child(_image2!.path)
          .putFile(File(_image2!.path));
      String downloadUrl =
          await snapshot.ref.getDownloadURL().whenComplete(() => setState(() {
                loading = false;
              }));

      setState(() {
        image2 = downloadUrl;
      });
      //print(image2);
    }
  }

  Future<void> _uploadImage3() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    //print(image);
    setState(() {
      _image3 = image;
      loading = true;
    });
    if (_image3 != null) {
      var snapshot = await FirebaseStorage.instance
          .ref()
          .child(_image3!.path)
          .putFile(File(_image3!.path));
      String downloadUrl =
          await snapshot.ref.getDownloadURL().whenComplete(() => setState(() {
                loading = false;
              }));

      setState(() {
        image3 = downloadUrl;
      });
      //print(image3);
    }
  }

  List<String> categories = [];
  getCategories() {
    FirebaseFirestore.instance.collection('Categories').get().then((value) {
      //print('Length is ${value.docs.length}');
      for (var element in value.docs) {
        categories.add(element.data()['category']);
      }
    });
  }

  List<String> subCategories = [];
  getSubCategories() {
    if (widget.marketCategory != '') {
      FirebaseFirestore.instance
          .collection('Sub Categories')
          .where('category', isEqualTo: widget.marketCategory)
          .get()
          .then((value) {
        for (var element in value.docs) {
          subCategories.add(element.data()['name']);
        }
      });
      subCategories.clear();
    }
  }

  List<String> brands = [];
  getBrand() {
    if (subCategory != '' && widget.marketCategory != '') {
      FirebaseFirestore.instance
          .collection('Brands')
          .where('category', isEqualTo: widget.marketCategory)
          .where('sub-category', isEqualTo: subCategory)
          .get()
          .then((value) {
        for (var element in value.docs) {
          brands.add(element.data()['name']);
        }
      });
      brands.clear();
    }
  }

  List<String> subCategoriesCollection = [];
  getsubCategoriesCollection() {
    if (subCategory != '' && widget.marketCategory != '') {
      FirebaseFirestore.instance
          .collection('Sub categories collections')
          .where('category', isEqualTo: widget.marketCategory)
          .where('sub-category', isEqualTo: subCategory)
          .get()
          .then((value) {
        for (var element in value.docs) {
          subCategoriesCollection.add(element.data()['name']);
        }
      });
      subCategoriesCollection.clear();
    }
  }

  addProduct(ProductsModel products, String id) {
    FirebaseFirestore.instance
        .collection('Products')
        .doc(id)
        .set(products.toMap())
        .then((value) {
      Fluttertoast.showToast(
          msg: "Product Added Successfully...".tr(),
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.TOP,
          timeInSecForIosWeb: 1,
      
          fontSize: 14.0);
      Navigator.of(context).pop();
    });
  }

  @override
  Widget build(BuildContext context) {
    var uuid = const Uuid();
    String id = uuid.v1();
    getSubCategories();
    return Scaffold(
      appBar: AppBar(
          centerTitle: true,
          elevation: 0,
          title: const Text(
            'Add A New Product',
          )),
      // floatingActionButton: FloatingActionButton(
      //     backgroundColor: Colors.orange,
      //     onPressed: () {},
      //     child: Text('Add on')),
      body: SingleChildScrollView(
          child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Form(
          key: _formKey,
          child: Column(children: [
            const SizedBox(height: 20),
            const Text('Add a new product under the market',
                    style: TextStyle(fontWeight: FontWeight.bold))
                .tr(),
            Text(widget.marketName,
                style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            Row(children: [
              const Text('Produt Name:').tr(),
            ]),
            const SizedBox(height: 10),
            SizedBox(
              height: 45,
              child: TextFormField(
                onSaved: (value) {
                  setState(() {
                    name = value!;
                  });
                },
                onChanged: (value) {
                  setState(() {
                    name = value;
                  });
                },
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Required field'.tr();
                  } else {
                    return null;
                  }
                },
                decoration: InputDecoration(
                  hintText: 'Product name'.tr(),
                  focusColor: Colors.grey,
                  filled: true,
                  fillColor: Colors.white10,
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide:
                        const BorderSide(color: Colors.grey, width: 1.0),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide:
                        const BorderSide(color: Colors.grey, width: 1.0),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide:
                        const BorderSide(color: Colors.grey, width: 1.0),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),
            Row(children: [
              const Text('Market Category:').tr(),
            ]),
            const SizedBox(height: 10),
            SizedBox(
              height: 45,
              child: TextFormField(
                readOnly: true,
                initialValue: widget.marketCategory,
                onSaved: (value) {
                  setState(() {
                    name = value!;
                  });
                },
                onChanged: (value) {
                  setState(() {
                    name = value;
                  });
                },
                decoration: InputDecoration(
                  focusColor: Colors.grey,
                  filled: true,
                  fillColor: Colors.white10,
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide:
                        const BorderSide(color: Colors.grey, width: 1.0),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide:
                        const BorderSide(color: Colors.grey, width: 1.0),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide:
                        const BorderSide(color: Colors.grey, width: 1.0),
                  ),
                ),
              ),
            ),  const SizedBox(height: 20),
            Row(children: [
              const Text('Produt Description:').tr(),
            ]),
            const SizedBox(height: 10),
            TextFormField(
              maxLines: 5,
              onSaved: (value) {
                setState(() {
                  description = value!;
                });
              },
              onChanged: (value) {
                setState(() {
                  description = value;
                });
              },
              validator: (value) {
                if (value!.isEmpty) {
                  return 'Required field'.tr();
                } else {
                  return null;
                }
              },
              decoration: InputDecoration(
                hintText: 'Product Description'.tr(),
                focusColor: Colors.grey,
                filled: true,
                fillColor: Colors.white10,
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Colors.grey, width: 1.0),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Colors.grey, width: 1.0),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Colors.grey, width: 1.0),
                ),
              ),
            ),
           
            const SizedBox(height: 20),
            Row(children: [
              const Text('Sub Category:').tr(),
            ]),
            const SizedBox(height: 10),
            SizedBox(
              height: 45,
              child: DropdownSearch<String>(
                validator: (v) => v == null ? "Required field".tr() : null,
                dropdownDecoratorProps: DropDownDecoratorProps(
                    dropdownSearchDecoration: InputDecoration(
                  hintText: "Select a sub category".tr(),
                )),
                popupProps: const PopupProps.menu(showSelectedItems: true),
                items: subCategories,
                onChanged: (value) {
                  setState(() {
                    subCategory = value!;
                  });
                },
              ),
            ),

            const SizedBox(height: 20),
            Row(children: [
              const Text('Product Price:').tr(),
            ]),
            const SizedBox(height: 10),
            SizedBox(
              height: 45,
              child: TextFormField(
                keyboardType: TextInputType.number,
                onSaved: (value) {
                  setState(() {
                    unitPrice1 = int.parse(value!);
                  });
                },
                onChanged: (value) {
                  setState(() {
                    unitPrice1 = int.parse(value);
                  });
                },
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Required field'.tr();
                  } else {
                    return null;
                  }
                },
                decoration: InputDecoration(
                  hintText: 'Product Price'.tr(),
                  focusColor: Colors.grey,
                  filled: true,
                  fillColor: Colors.white10,
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide:
                        const BorderSide(color: Colors.grey, width: 1.0),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide:
                        const BorderSide(color: Colors.grey, width: 1.0),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide:
                        const BorderSide(color: Colors.grey, width: 1.0),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(children: [
              const Text('Produt Initial Price:').tr(),
            ]),
            const SizedBox(height: 10),
            SizedBox(
              height: 45,
              child: TextFormField(
                keyboardType: TextInputType.number,
                onSaved: (value) {
                  setState(() {
                    unitOldPrice1 = int.parse(value!);
                  });
                },
                onChanged: (value) {
                  setState(() {
                    unitOldPrice1 = int.parse(value);
                  });
                },
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Required field'.tr();
                  } else {
                    return null;
                  }
                },
                decoration: InputDecoration(
                  hintText: 'Product Initial Price'.tr(),
                  focusColor: Colors.grey,
                  filled: true,
                  fillColor: Colors.white10,
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide:
                        const BorderSide(color: Colors.grey, width: 1.0),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide:
                        const BorderSide(color: Colors.grey, width: 1.0),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide:
                        const BorderSide(color: Colors.grey, width: 1.0),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(children: [
              const Text('Quantity:').tr(),
            ]),
            const SizedBox(height: 10),
            SizedBox(
              height: 45,
              child: TextFormField(
                onSaved: (value) {
                  setState(() {
                    quantity = int.parse(value!);
                  });
                },
                onChanged: (value) {
                  setState(() {
                    quantity = int.parse(value);
                  });
                },
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Required field'.tr();
                  } else {
                    return null;
                  }
                },
                decoration: InputDecoration(
                  hintText: 'Product Quantity'.tr(),
                  focusColor: Colors.grey,
                  filled: true,
                  fillColor: Colors.white10,
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide:
                        const BorderSide(color: Colors.grey, width: 1.0),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide:
                        const BorderSide(color: Colors.grey, width: 1.0),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide:
                        const BorderSide(color: Colors.grey, width: 1.0),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(children: [
              const Text('Produt Discount (%):').tr(),
            ]),
            const SizedBox(height: 10),
            SizedBox(
              height: 45,
              child: TextFormField(
                keyboardType: TextInputType.number,
                onSaved: (value) {
                  setState(() {
                    percantageDiscount = int.parse(value!);
                  });
                },
                onChanged: (value) {
                  setState(() {
                    percantageDiscount = int.parse(value);
                  });
                },
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Required field'.tr();
                  } else {
                    return null;
                  }
                },
                decoration: InputDecoration(
                  hintText: 'Product Discount'.tr(),
                  focusColor: Colors.grey,
                  filled: true,
                  fillColor: Colors.white10,
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide:
                        const BorderSide(color: Colors.grey, width: 1.0),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide:
                        const BorderSide(color: Colors.grey, width: 1.0),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide:
                        const BorderSide(color: Colors.grey, width: 1.0),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(children: [
              const Text('Produt Unit:').tr(),
            ]),
            const SizedBox(height: 10),
            SizedBox(
              height: 45,
              child: TextFormField(
                onSaved: (value) {
                  setState(() {
                    unitname1 = value!;
                  });
                },
                onChanged: (value) {
                  setState(() {
                    unitname1 = value;
                  });
                },
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Required field'.tr();
                  } else {
                    return null;
                  }
                },
                decoration: InputDecoration(
                  hintText: 'Kg/mil/gram/pkts',
                  focusColor: Colors.grey,
                  filled: true,
                  fillColor: Colors.white10,
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide:
                        const BorderSide(color: Colors.grey, width: 1.0),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide:
                        const BorderSide(color: Colors.grey, width: 1.0),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide:
                        const BorderSide(color: Colors.grey, width: 1.0),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Card(
              elevation: 0,
              child: Column(children: [
                const SizedBox(height: 20),
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  const Text('Add on',
                          style: TextStyle(fontWeight: FontWeight.bold))
                      .tr()
                ]),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(flex: 1, child: const Text('Unit').tr()),
                        Flexible(
                            flex: 1, child: const Text('Initial Price').tr()),
                        Flexible(flex: 1, child: const Text('Price').tr())
                      ]),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                            flex: 1,
                            child: TextField(
                              onChanged: (value) {
                                setState(() {
                                  unitname2 = value;
                                });
                              },
                            )),
                        const SizedBox(width: 10),
                        Flexible(
                            flex: 1,
                            child: TextField(
                              keyboardType: TextInputType.number,
                              onChanged: (value) {
                                setState(() {
                                  unitOldPrice2 = int.parse(value);
                                });
                              },
                            )),
                        const SizedBox(width: 10),
                        Flexible(
                            flex: 1,
                            child: TextField(
                              keyboardType: TextInputType.number,
                              onChanged: (value) {
                                setState(() {
                                  unitPrice2 = int.parse(value);
                                });
                              },
                            ))
                      ]),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                            flex: 1,
                            child: TextField(
                              onChanged: (value) {
                                setState(() {
                                  unitname3 = value;
                                });
                              },
                            )),
                        const SizedBox(width: 10),
                        Flexible(
                            flex: 1,
                            child: TextField(
                              keyboardType: TextInputType.number,
                              onChanged: (value) {
                                setState(() {
                                  unitOldPrice3 = int.parse(value);
                                });
                              },
                            )),
                        const SizedBox(width: 10),
                        Flexible(
                            flex: 1,
                            child: TextField(
                              keyboardType: TextInputType.number,
                              onChanged: (value) {
                                setState(() {
                                  unitPrice3 = int.parse(value);
                                });
                              },
                            ))
                      ]),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                            flex: 1,
                            child: TextField(
                              onChanged: (value) {
                                setState(() {
                                  unitname4 = value;
                                });
                              },
                            )),
                        const SizedBox(width: 10),
                        Flexible(
                            flex: 1,
                            child: TextField(
                              keyboardType: TextInputType.number,
                              onChanged: (value) {
                                setState(() {
                                  unitOldPrice4 = int.parse(value);
                                });
                              },
                            )),
                        const SizedBox(width: 10),
                        Flexible(
                            flex: 1,
                            child: TextField(
                              onChanged: (value) {
                                setState(() {
                                  unitPrice4 = int.parse(value);
                                });
                              },
                              keyboardType: TextInputType.number,
                            ))
                      ]),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                            flex: 1,
                            child: TextField(
                              onChanged: (value) {
                                setState(() {
                                  unitname5 = value;
                                });
                              },
                            )),
                        const SizedBox(width: 10),
                        Flexible(
                            flex: 1,
                            child: TextField(
                              keyboardType: TextInputType.number,
                              onChanged: (value) {
                                setState(() {
                                  unitOldPrice5 = int.parse(value);
                                });
                              },
                            )),
                        const SizedBox(width: 10),
                        Flexible(
                            flex: 1,
                            child: TextField(
                              keyboardType: TextInputType.number,
                              onChanged: (value) {
                                setState(() {
                                  unitPrice5 = int.parse(value);
                                });
                              },
                            ))
                      ]),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                            flex: 1,
                            child: TextField(
                              onChanged: (value) {
                                setState(() {
                                  unitname6 = value;
                                });
                              },
                            )),
                        const SizedBox(width: 10),
                        Flexible(
                            flex: 1,
                            child: TextField(
                              keyboardType: TextInputType.number,
                              onChanged: (value) {
                                setState(() {
                                  unitOldPrice6 = int.parse(value);
                                });
                              },
                            )),
                        const SizedBox(width: 10),
                        Flexible(
                            flex: 1,
                            child: TextField(
                              keyboardType: TextInputType.number,
                              onChanged: (value) {
                                setState(() {
                                  unitPrice6 = int.parse(value);
                                });
                              },
                            ))
                      ]),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                            flex: 1,
                            child: TextField(
                              onChanged: (value) {
                                setState(() {
                                  unitname7 = value;
                                });
                              },
                            )),
                        const SizedBox(width: 10),
                        Flexible(
                            flex: 1,
                            child: TextField(
                              keyboardType: TextInputType.number,
                              onChanged: (value) {
                                setState(() {
                                  unitOldPrice7 = int.parse(value);
                                });
                              },
                            )),
                        const SizedBox(width: 10),
                        Flexible(
                            flex: 1,
                            child: TextField(
                              onChanged: (value) {
                                setState(() {
                                  unitPrice7 = int.parse(value);
                                });
                              },
                              keyboardType: TextInputType.number,
                            ))
                      ]),
                ),
                const SizedBox(height: 20),
              ]),
            ),
            const SizedBox(height: 20),
            _image1 == null
                ? const Icon(Icons.image, color: Colors.grey, size: 120)
                : Image.file(File(_image1!.path), width: 120, height: 120),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                      style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.orange),
                      onPressed: () {
                        _uploadImage1();
                      },
                      child: const Text('Add Image 1',
                              style: TextStyle(color: Colors.white))
                          .tr()),
                ],
              ),
            ),
            _image2 == null
                ? const Icon(Icons.image, color: Colors.grey, size: 120)
                : Image.file(File(_image2!.path), width: 120, height: 120),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                      style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.orange),
                      onPressed: () {
                        _uploadImage2();
                      },
                      child: const Text('Add Image 2',
                              style: TextStyle(color: Colors.white))
                          .tr()),
                ],
              ),
            ),
            _image3 == null
                ? const Icon(Icons.image, color: Colors.grey, size: 120)
                : Image.file(File(_image3!.path), width: 120, height: 120),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                      style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.orange),
                      onPressed: () {
                        _uploadImage3();
                      },
                      child: const Text('Add Image 3',
                              style: TextStyle(color: Colors.white))
                          .tr()),
                ],
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            // Row(
            //   children: [
            //     Text(
            //         'NB: You can add variant after adding the product successfully',
            //         style: TextStyle(fontWeight: FontWeight.bold)),
            //   ],
            // ),
            // SizedBox(
            //   height: 20,
            // ),
            loading == true
                ? Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.orange),
                        onPressed: null,
                        child: const Text('Add Product',
                                style: TextStyle(color: Colors.white))
                            .tr()),
                  )
                : Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                          style:
                              ElevatedButton.styleFrom(
                                              backgroundColor: Colors.orange),
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              addProduct(
                                  ProductsModel(
                                      quantity: quantity,
                                      totalRating: 0,
                                      productID: id,
                                      description: description,
                                      marketID: widget.marketID!,
                                      marketName: widget.marketName,
                                      uid: uid,
                                      name: name,
                                      category: widget.marketCategory,
                                      subCategory: subCategory,
                                      subSubCategory: subSubCategory,
                                      image1: image1,
                                      image2: image2,
                                      image3: image3,
                                      unitname1: unitname1,
                                      unitname2: unitname2,
                                      unitname3: unitname3,
                                      unitname4: unitname4,
                                      unitname5: unitname5,
                                      unitname6: unitname6,
                                      unitname7: unitname7,
                                      unitPrice1: unitPrice1,
                                      unitPrice2: unitPrice2,
                                      unitPrice3: unitPrice3,
                                      unitPrice4: unitPrice4,
                                      unitPrice5: unitPrice5,
                                      unitPrice6: unitPrice6,
                                      unitPrice7: unitPrice7,
                                      unitOldPrice1: unitOldPrice1,
                                      unitOldPrice2: unitOldPrice2,
                                      unitOldPrice3: unitOldPrice3,
                                      unitOldPrice4: unitOldPrice4,
                                      unitOldPrice5: unitOldPrice5,
                                      unitOldPrice6: unitOldPrice6,
                                      unitOldPrice7: unitOldPrice7,
                                      percantageDiscount: percantageDiscount,
                                      vendorId: widget.vendorID,
                                      brandName: brandName,
                                      totalNumberOfUserRating: 0),
                                  id);
                            } else {
                              Fluttertoast.showToast(
                                  msg: "Some Fields Are Required".tr(),
                                  toastLength: Toast.LENGTH_SHORT,
                                  gravity: ToastGravity.TOP,
                                  timeInSecForIosWeb: 1,
                              
                                  fontSize: 14.0);
                            }
                          },
                          child: const Text('Add Product',
                                  style: TextStyle(color: Colors.white))
                              .tr()),
                    ),
                  )
          ]),
        ),
      )),
    );
  }
}

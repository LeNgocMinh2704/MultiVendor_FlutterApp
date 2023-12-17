import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:admin_web/Models/feeds.dart';
import 'package:easy_localization/easy_localization.dart';

class ViewFeed extends StatefulWidget {
  final FeedsModel categoriesModel;
  const ViewFeed({Key? key, required this.categoriesModel}) : super(key: key);

  @override
  State<ViewFeed> createState() => _ViewFeedState();
}

class _ViewFeedState extends State<ViewFeed> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text('Add a new feed').tr(),
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
              TextFormField(
                readOnly: true,
                initialValue: widget.categoriesModel.title,
                decoration: InputDecoration(hintText: "Feed title".tr()),
              ),
              const SizedBox(
                height: 10,
              ),
              TextFormField(
                  initialValue: widget.categoriesModel.detail,
                  readOnly: true,
                  maxLines: 4,
                  decoration: InputDecoration(
                    labelText: "Feed detail".tr(),
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: const BorderSide(),
                    ),
                  )),
              DropdownSearch<String>(
                validator: (v) => v == null ? "required field".tr() : null,
                popupProps: const PopupProps.menu(
                  showSelectedItems: true,
                ),
                dropdownDecoratorProps: DropDownDecoratorProps(
                    dropdownSearchDecoration: InputDecoration(
                  hintText: "Select a category".tr(),
                  labelText: "Categories*",
                  border: const UnderlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF01689A)),
                  ),
                )),
                items: const [],
                selectedItem: widget.categoriesModel.category,
              ),
              // DropdownSearch<String>(
              //   validator: (v) => v == null ? "required field".tr() : null,
              //   popupProps: const PopupProps.menu(
              //     showSelectedItems: true,
              //   ),
              //   dropdownDecoratorProps: DropDownDecoratorProps(
              //       dropdownSearchDecoration: InputDecoration(
              //     hintText: "Select a sub category".tr(),
              //     labelText: "Sub Categories*",
              //     border: const UnderlineInputBorder(
              //       borderSide: BorderSide(color: Color(0xFF01689A)),
              //     ),
              //   )),
              //   items: const [],
              //   selectedItem: widget.categoriesModel.subCategory,
              // ),
              // DropdownSearch<String>(
              //   validator: (v) => v == null ? "required field".tr() : null,
              //   popupProps: const PopupProps.menu(
              //     showSelectedItems: true,
              //   ),
              //   dropdownDecoratorProps: DropDownDecoratorProps(
              //       dropdownSearchDecoration: InputDecoration(
              //     hintText: "Select a sub category collections".tr(),
              //     labelText: "Sub categories collections *",
              //     border: const UnderlineInputBorder(
              //       borderSide: BorderSide(color: Color(0xFF01689A)),
              //     ),
              //   )),
              //   items: const [],
              //   selectedItem: widget.categoriesModel.subCategoryCollections,
              // ),
              const SizedBox(height: 10),
              Image.network(
                widget.categoriesModel.image,
                height: 200,
                width: 200,
                fit: BoxFit.cover,
              ),
              const SizedBox(height: 20),
              IconButton(
                onPressed: null,
                icon: const Icon(Icons.add_a_photo),
                iconSize: 50,
                color: Colors.blue.shade800,
              ),
              SizedBox(
                  height: 50,
                  child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue.shade800),
                      onPressed: null,
                      child: const Text('Add new feed').tr()))
            ],
          ),
        ),
      ),
    );
  }
}

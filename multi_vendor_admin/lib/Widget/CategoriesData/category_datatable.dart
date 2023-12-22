import 'package:another_flushbar/flushbar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:admin_web/Models/categories.dart';
import 'package:easy_localization/easy_localization.dart';
import 'add_categories.dart';
import 'edit_category.dart';

class CategoriessData extends StatefulWidget {
  const CategoriessData({Key? key}) : super(key: key);

  @override
  State<CategoriessData> createState() => _CategoriessDataState();
}

class _CategoriessDataState extends State<CategoriessData> {
  bool isLoaded = false;
  int _rowsPerPage = PaginatedDataTable.defaultRowsPerPage;
  int? _sortColumnIndex;
  final bool _sortAscending = true;

  Stream<QuerySnapshot>? yourStream;
  @override
  void initState() {
    yourStream =
        FirebaseFirestore.instance.collection('Categories').snapshots();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    List<CategoriesModel> vendor;
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: StreamBuilder<QuerySnapshot>(
          stream: yourStream,
          builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
            vendor = snapshot.data!.docs
                .map((e) => CategoriesModel.fromMap(e.data(), e.id))
                .toList();
            var vendorData = VendorDataSource(vendor, context);
            if (snapshot.hasData) {
              return ListView(
                shrinkWrap: true,
                children: [
                  PaginatedDataTable(
                    header: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Categories').tr(),
                        ElevatedButton(
                            onPressed: () {
                              showDialog(
                                  context: context,
                                  builder: (builder) {
                                    return const AddCategory();
                                  });
                            },
                            child: const Text('Add new category').tr())
                      ],
                    ),
                    rowsPerPage: _rowsPerPage,
                    onRowsPerPageChanged: (int? value) {
                      setState(() {
                        _rowsPerPage = value!;
                      });
                    },
                    source: vendorData,
                    sortColumnIndex: _sortColumnIndex,
                    sortAscending: _sortAscending,
                    columns: <DataColumn>[
                      DataColumn(
                        label: const Text('Index').tr(),
                      ),
                      DataColumn(
                        label: const Text('CategoryImage').tr(),
                      ),
                      DataColumn(
                        label: const Text('Name').tr(),
                      ),
                      DataColumn(
                        label: const Text('Manage').tr(),
                      ),
                    ],
                  ),
                ],
              );
            } else {
              return Container();
            }
          }),
    );
  }
}

int numberOfdelivery = 0;

List<int> categoriesAmount = [];

class VendorDataSource extends DataTableSource {
  final List<CategoriesModel> vendor;
  final BuildContext context;
  VendorDataSource(this.vendor, this.context);

  final int _selectedCount = 0;

  @override
  DataRow? getRow(int index) {
    assert(index >= 0);
    if (index >= vendor.length) return null;
    final CategoriesModel result = vendor[index];
    return DataRow.byIndex(index: index, cells: <DataCell>[
      DataCell(Text('${index + 1}')),
      DataCell(
        result.image == ''
            ? Container()
            : Image.network(
                result.image,
                width: 50,
                height: 50,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 50,
                    height: 50,
                    color: Colors.grey, // Placeholder color
                    child: const Icon(Icons.error), // Placeholder icon
                  );
                },
              ),
      ),
      DataCell(Text(result.category)),
      DataCell(Row(
        children: [
          OutlinedButton(
              onPressed: () {
                showDialog(
                    context: context,
                    builder: (builder) {
                      return EditCategories(
                        categoriesModel: result,
                      );
                    });
              },
              child: const Text('Edit').tr()),
          const SizedBox(
            width: 5,
          ),
          OutlinedButton(
              onPressed: () {
                FirebaseFirestore.instance
                    .collection('Categories')
                    .doc(result.uid)
                    .delete()
                    .then((value) {
                  Flushbar(
                    flushbarPosition: FlushbarPosition.TOP,
                    title: "Notification",
                    message: "Categgory deleted successfully!!!",
                    duration: const Duration(seconds: 3),
                  ).show(context);
                });
              },
              child: const Text('Delete').tr()),
        ],
      )),
    ]);
  }

  @override
  int get rowCount => vendor.length;

  @override
  bool get isRowCountApproximate => false;

  @override
  int get selectedRowCount => _selectedCount;
}

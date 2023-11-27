import 'package:another_flushbar/flushbar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../Models/sub_category_collections.dart';
import 'add_sub_categories_collections.dart';
import 'package:easy_localization/easy_localization.dart';

class SubCategoriesCollectionsData extends StatefulWidget {
  const SubCategoriesCollectionsData({Key? key}) : super(key: key);

  @override
  State<SubCategoriesCollectionsData> createState() =>
      _SubCategoriesCollectionsDataState();
}

class _SubCategoriesCollectionsDataState
    extends State<SubCategoriesCollectionsData> {
  bool isLoaded = false;
  int _rowsPerPage = PaginatedDataTable.defaultRowsPerPage;
  int? _sortColumnIndex;
  final bool _sortAscending = true;

  Stream<QuerySnapshot>? yourStream;
  @override
  void initState() {
    yourStream = FirebaseFirestore.instance
        .collection('Sub categories collections')
        .snapshots();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    List<SubCategoriesCollectionsModel> vendor;
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: StreamBuilder<QuerySnapshot>(
          stream: yourStream,
          builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
            vendor = snapshot.data!.docs
                .map((e) =>
                    SubCategoriesCollectionsModel.fromMap(e.data(), e.id))
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
                        const Text('Sub Categories collections'),
                        ElevatedButton(
                            onPressed: () {
                              showDialog(
                                  context: context,
                                  builder: (builder) {
                                    return const AddSubCategoryCollection();
                                  });
                            },
                            child: const Text('Add new Sub category collection'))
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
                        label: const Text('Image').tr(),
                      ),
                      DataColumn(
                        label: const Text('Name').tr(),
                      ),
                      DataColumn(
                        label: const Text('Sub category').tr(),
                      ),
                      DataColumn(
                        label: const Text('Category').tr(),
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
  final List<SubCategoriesCollectionsModel> vendor;
  final BuildContext context;
  VendorDataSource(this.vendor, this.context);

  final int _selectedCount = 0;

  @override
  DataRow? getRow(int index) {
    assert(index >= 0);
    if (index >= vendor.length) return null;
    final SubCategoriesCollectionsModel result = vendor[index];
    return DataRow.byIndex(index: index, cells: <DataCell>[
      DataCell(Text('${index + 1}')),
      DataCell(result.image == ''
          ? Container()
          : Image.network(result.image, width: 50, height: 50)),
      DataCell(Text(result.name)),
      DataCell(Text(result.subCategory)),
      DataCell(Text(result.category)),
      DataCell(Row(
        children: [
          // OutlinedButton(
          //     onPressed: () {
          //       showDialog(
          //           context: context,
          //           builder: (builder) {
          //             return EditSubCategoriesCollections(
          //               categoriesModel: result,
          //             );
          //           });
          //     },
          //     child: Text('Edit')),
          // SizedBox(
          //   width: 5,
          // ),
          OutlinedButton(
              onPressed: () {
                FirebaseFirestore.instance
                    .collection('Sub categories collections')
                    .doc(result.uid)
                    .delete()
                    .then((value) {
                  Flushbar(
                    flushbarPosition: FlushbarPosition.TOP,
                    title: "Notification",
                    message: "Sub category collection deleted successfully!!!",
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

import 'package:another_flushbar/flushbar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:admin_web/Widget/BrandsData/add_brand.dart';

import '../../Models/sub_category_collections.dart';

class BrandsData extends StatefulWidget {
  const BrandsData({Key? key}) : super(key: key);

  @override
  State<BrandsData> createState() => _BrandsDataState();
}

class _BrandsDataState extends State<BrandsData> {
  bool isLoaded = false;
  int _rowsPerPage = PaginatedDataTable.defaultRowsPerPage;
  int? _sortColumnIndex;
  final bool _sortAscending = true;

  Stream<QuerySnapshot>? yourStream;
  @override
  void initState() {
    yourStream = FirebaseFirestore.instance.collection('Brands').snapshots();
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
                        const Text('Brands'),
                        ElevatedButton(
                            onPressed: () {
                              showDialog(
                                  context: context,
                                  builder: (builder) {
                                    return const AddBrand();
                                  });
                            },
                            child: const Text('Add a new brand'))
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
                    columns: const <DataColumn>[
                      DataColumn(
                        label: Text('Index'),
                      ),
                      DataColumn(
                        label: Text('Image'),
                      ),
                      DataColumn(
                        label: Text('Name'),
                      ),
                      DataColumn(
                        label: Text('Sub collections'),
                      ),
                      DataColumn(
                        label: Text('Category'),
                      ),
                      DataColumn(
                        label: Text('Manage'),
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
          //             return EditBrand(categoriesModel: result);
          //           });
          //     },
          //     child: Text('Edit')),
          // SizedBox(
          //   width: 5,
          // ),
          OutlinedButton(
              onPressed: () {
                FirebaseFirestore.instance
                    .collection('Brands')
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
              child: const Text('Delete')),
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

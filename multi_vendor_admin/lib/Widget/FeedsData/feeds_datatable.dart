import 'package:another_flushbar/flushbar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:admin_web/Models/feeds.dart';
import 'package:admin_web/Widget/FeedsData/add_feeds.dart';
import 'package:easy_localization/easy_localization.dart';

import 'view_feeds.dart';

class FeedsData extends StatefulWidget {
  const FeedsData({Key? key}) : super(key: key);

  @override
  State<FeedsData> createState() => _FeedsDataState();
}

class _FeedsDataState extends State<FeedsData> {
  bool isLoaded = false;
  int _rowsPerPage = PaginatedDataTable.defaultRowsPerPage;
  int? _sortColumnIndex;
  final bool _sortAscending = true;

  Stream<QuerySnapshot>? yourStream;
  @override
  void initState() {
    yourStream = FirebaseFirestore.instance.collection('Feeds').snapshots();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    List<FeedsModel> feeds;
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: StreamBuilder<QuerySnapshot>(
          stream: yourStream,
          builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
            feeds = snapshot.data!.docs
                .map((e) => FeedsModel.fromMap(e.data(), e.id))
                .toList();
            var vendorData = VendorDataSource(feeds, context);
            if (snapshot.hasData) {
              return ListView(
                shrinkWrap: true,
                children: [
                  PaginatedDataTable(
                    header: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Feeds').tr(),
                        ElevatedButton(
                            onPressed: () {
                              showDialog(
                                  context: context,
                                  builder: (builder) {
                                    return const AddFeed();
                                  });
                            },
                            child: const Text('Add new feed').tr())
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
                        label: const Text('Title').tr(),
                      ),
                      DataColumn(
                        label: const Text('Banner').tr(),
                      ),
                      DataColumn(
                        label: const Text('Category').tr(),
                      ),
                      DataColumn(
                        label: const Text('Slider').tr(),
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
  final List<FeedsModel> vendor;
  final BuildContext context;
  VendorDataSource(this.vendor, this.context);

  final int _selectedCount = 0;

  @override
  DataRow? getRow(int index) {
    assert(index >= 0);
    if (index >= vendor.length) return null;
    final FeedsModel result = vendor[index];
    return DataRow.byIndex(index: index, cells: <DataCell>[
      DataCell(Text('${index + 1}')),
      DataCell(Text(result.title)),
      DataCell(result.image == ''
          ? Container()
          : Image.network(result.image, width: 50, height: 50)),
      DataCell(Text(result.category)),
      DataCell(Text(result.slider.toString())),
      DataCell(Row(
        children: [
          OutlinedButton(
              onPressed: () {
                showDialog(
                    context: context,
                    builder: (builder) {
                      return ViewFeed(
                        categoriesModel: result,
                      );
                    });
              },
              child: const Text('View details').tr()),
          const SizedBox(
            width: 5,
          ),
          OutlinedButton(
              onPressed: () {
                FirebaseFirestore.instance
                    .collection('Feeds')
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

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:admin_web/Widget/market_alert.dart';
import 'package:admin_web/Widget/market_detail.dart';

import '../Models/market_model.dart';

class MarketsData extends StatefulWidget {
  const MarketsData({Key? key}) : super(key: key);

  @override
  State<MarketsData> createState() => _MarketsDataState();
}

class _MarketsDataState extends State<MarketsData> {
  bool isLoaded = false;
  int _rowsPerPage = PaginatedDataTable.defaultRowsPerPage;
  int? _sortColumnIndex;
  final bool _sortAscending = true;

  Stream<QuerySnapshot>? yourStream;
  @override
  void initState() {
    yourStream = FirebaseFirestore.instance.collection('Markets').snapshots();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    List<MarketModel> vendor;
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: StreamBuilder<QuerySnapshot>(
          stream: yourStream,
          builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
            vendor = snapshot.data!.docs
                .map((e) => MarketModel.fromMap(e.data(), e.id))
                .toList();
            var vendorData = VendorDataSource(vendor, context);
            if (snapshot.hasData) {
              return ListView(
                shrinkWrap: true,
                children: [
                  PaginatedDataTable(
                    header: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Text('Markets'),
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
                        label: Text('Time Created'),
                      ),
                      DataColumn(
                        label: Text('Category'),
                      ),
                      DataColumn(
                        label: Text('Commission'),
                      ),
                      DataColumn(
                        label: Text('Status'),
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
  final List<MarketModel> vendor;
  VendorDataSource(this.vendor, this.context);
  final BuildContext context;
  final int _selectedCount = 0;

  @override
  DataRow? getRow(int index) {
    assert(index >= 0);
    if (index >= vendor.length) return null;
    final MarketModel result = vendor[index];
    return DataRow.byIndex(index: index, cells: <DataCell>[
      DataCell(Text('${index + 1}')),
      DataCell(result.image1 == ''
          ? Container()
          : Image.network(result.image1, width: 50, height: 50)),
      DataCell(Text(result.marketName)),
      DataCell(Text(result.timeCreated)),
      DataCell(Text(result.category)),
      DataCell(Text('${result.commission}%')),
      DataCell(result.approval == true
          ? const Text('Approved')
          : const Text('Not Approved')),
      DataCell(Row(
        children: [
          OutlinedButton(
              onPressed: () {
                showDialog(
                    context: context,
                    builder: (builder) {
                      return MarketDetail(
                        marketModel: result,
                      );
                    });
              },
              child: const Text('View Details')),
          const SizedBox(
            width: 5,
          ),
          OutlinedButton(
              onPressed: () {
                showDialog(
                    context: context,
                    builder: (builder) {
                      return MarketAlert(
                        result: result,
                      );
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

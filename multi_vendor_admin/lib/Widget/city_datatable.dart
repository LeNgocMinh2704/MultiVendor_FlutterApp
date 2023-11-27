import 'package:another_flushbar/flushbar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:admin_web/Widget/edit_city.dart';
import '../Models/cities_model.dart';
import 'add_city.dart';

class CitiesData extends StatefulWidget {
  const CitiesData({Key? key}) : super(key: key);

  @override
  State<CitiesData> createState() => _CitiesDataState();
}

class _CitiesDataState extends State<CitiesData> {
  bool isLoaded = false;
  int _rowsPerPage = PaginatedDataTable.defaultRowsPerPage;
  int? _sortColumnIndex;
  final bool _sortAscending = true;

  Stream<QuerySnapshot>? yourStream;
  @override
  void initState() {
    yourStream = FirebaseFirestore.instance.collection('Cities').snapshots();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    List<CitiesModel> vendor;
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: StreamBuilder<QuerySnapshot>(
          stream: yourStream,
          builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
            vendor = snapshot.data!.docs
                .map((e) => CitiesModel.fromMap(e.data(), e.id))
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
                        const Text('Cities'),
                        ElevatedButton(
                            onPressed: () {
                              showDialog(
                                  context: context,
                                  builder: (context) => const AlertDialog(
                                      title: Text('Add a new city'),
                                      content: SizedBox(
                                          height: 700,
                                          width: 400,
                                          child: AddCity())));
                            },
                            child: const Text('Add a new city'))
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
                        label: Text('City Name'),
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
  final List<CitiesModel> vendor;
  final BuildContext context;
  VendorDataSource(this.vendor, this.context);

  final int _selectedCount = 0;

  @override
  DataRow? getRow(int index) {
    assert(index >= 0);
    if (index >= vendor.length) return null;
    final CitiesModel result = vendor[index];
    return DataRow.byIndex(index: index, cells: <DataCell>[
      DataCell(Text('${index + 1}')),
      DataCell(SizedBox(
          height: 100, width: 100, child: Image.network(result.image))),
      DataCell(Text(result.cityName)),
      DataCell(Row(
        children: [
          OutlinedButton(
              onPressed: () {
                showDialog(
                    context: context,
                    builder: (builder) {
                      return EditCity(
                        citiesModel: result,
                      );
                    });
              },
              child: const Text('Edit')),
          const SizedBox(
            width: 5,
          ),
          OutlinedButton(
              onPressed: () {
                FirebaseFirestore.instance
                    .collection('Cities')
                    .doc(result.uid)
                    .delete()
                    .then((value) {
                  Flushbar(
                    flushbarPosition: FlushbarPosition.TOP,
                    title: "Notification",
                    message: "${result.cityName} deleted successfully!!!",
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

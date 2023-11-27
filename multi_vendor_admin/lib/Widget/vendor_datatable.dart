import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:admin_web/Models/user.dart';


class ApprovedVendorsData extends StatefulWidget {
  const ApprovedVendorsData({Key? key}) : super(key: key);

  @override
  State<ApprovedVendorsData> createState() => _ApprovedVendorsDataState();
}

class _ApprovedVendorsDataState extends State<ApprovedVendorsData> {
  bool isLoaded = false;
  int _rowsPerPage = PaginatedDataTable.defaultRowsPerPage;
  int? _sortColumnIndex;
  final bool _sortAscending = true;
  String deliveryBoyID = '';
  Future<QuerySnapshot>? yourStream;
  @override
  void initState() {
    yourStream = FirebaseFirestore.instance.collection('vendors').get();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    List<UserModel> vendor;
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: FutureBuilder<QuerySnapshot>(
          future: yourStream,
          builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
            vendor = snapshot.data!.docs
                .map((e) => UserModel.fromMap(e.data(), e.id))
                .toList();
            var vendorData = VendorDataSource(vendor, context);
            if (snapshot.hasData) {
              return ListView(
                shrinkWrap: true,
                children: [
                  PaginatedDataTable(
                    header: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Text('Vendors'),
                        // SizedBox(
                        //   height: 40,
                        //   width: MediaQuery.of(context).size.width / 4,
                        //   child: TextField(
                        //       onTap: () {
                        //         Navigator.of(context).push(MaterialPageRoute(
                        //           builder: (context) => const Search(
                        //             collectionName: 'vendors',
                        //           ),
                        //         ));
                        //       },
                        //       readOnly: true,
                        //       decoration: InputDecoration(
                        //         border: OutlineInputBorder(
                        //           borderRadius: BorderRadius.circular(8),
                        //           borderSide: const BorderSide(
                        //               color: Colors.grey, width: 1.0),
                        //         ),
                        //         focusColor: Colors.grey,
                        //         labelText: "Search",
                        //         hintStyle:
                        //             TextStyle(color: Colors.blue.shade800),
                        //         prefixIcon: Icon(
                        //           Icons.search,
                        //           size: 30,
                        //           color: Colors.blue.shade800,
                        //         ),
                        //         filled: true,
                        //         fillColor: Colors.white10,
                        //         focusedBorder: OutlineInputBorder(
                        //           borderRadius: BorderRadius.circular(10),
                        //           borderSide: const BorderSide(
                        //               color: Colors.grey, width: 1.0),
                        //         ),
                        //         enabledBorder: OutlineInputBorder(
                        //           borderRadius: BorderRadius.circular(8),
                        //           borderSide: const BorderSide(
                        //               color: Colors.grey, width: 1.0),
                        //         ),
                        //       )),
                        // )
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
                        label: Text('Profile Picture'),
                      ),
                      DataColumn(
                        label: Text('Name'),
                      ),
                      DataColumn(
                        label: Text('Email'),
                      ),
                      DataColumn(
                        label: Text('Phone number'),
                        numeric: true,
                      ),
                      DataColumn(
                        label: Text('Address'),
                        numeric: true,
                      ),
                      DataColumn(
                        label: Text('Profile'),
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

List<int> deliveryBoyAmount = [];

class VendorDataSource extends DataTableSource {
  final List<UserModel> vendor;
  final BuildContext context;
  VendorDataSource(this.vendor, this.context);

  final int _selectedCount = 0;

  @override
  DataRow? getRow(int index) {
    assert(index >= 0);
    if (index >= vendor.length) return null;
    final UserModel result = vendor[index];
    return DataRow.byIndex(
        index: index,
        selected: result.selected,
        cells: <DataCell>[
          DataCell(Text('${index + 1}')),
          DataCell(result.photoUrl == null || result.photoUrl == ''
              ? Container()
              : Image.network('${result.photoUrl}', width: 50, height: 50)),
          DataCell(Text('${result.displayName}')),
          DataCell(Text('${result.email}')),
          DataCell(result.phonenumber == null
              ? const Text('')
              : Text('${result.phonenumber}')),
          DataCell(SizedBox(width: 100, child: Text('${result.address}'))),
          DataCell(OutlinedButton(
              onPressed: () {
                showDialog(
                    context: context,
                    builder: (builder) {
                      return VendorDetail(
                        result: result,
                      );
                    });
              },
              child: const Text('View Profile'))),
        ]);
  }

  @override
  int get rowCount => vendor.length;

  @override
  bool get isRowCountApproximate => false;

  @override
  int get selectedRowCount => _selectedCount;
}

class VendorDetail extends StatefulWidget {
  final UserModel result;
  const VendorDetail({Key? key, required this.result}) : super(key: key);

  @override
  State<VendorDetail> createState() => _VendorDetailState();
}

class _VendorDetailState extends State<VendorDetail> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
        content: SizedBox(
      height: MediaQuery.of(context).size.height / 1.5,
      width: MediaQuery.of(context).size.width / 3,
      child: Column(
        children: [
          const Text('Profile Picture'),
          const SizedBox(height: 10),
          widget.result.photoUrl == null || widget.result.photoUrl == ''
              ? Container()
              : Image.network('${widget.result.photoUrl}',
                  width: 130, height: 130),
          const SizedBox(height: 20),
          Row(
            children: [
              const Text('Name:'),
              const SizedBox(
                width: 10,
              ),
              Text('${widget.result.displayName}'),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              const Text('Phone:'),
              const SizedBox(
                width: 10,
              ),
              widget.result.phonenumber == null
                  ? const Text('')
                  : Text('${widget.result.phonenumber}'),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              const Text('Address:'),
              const SizedBox(
                width: 10,
              ),
              Text('${widget.result.address}'),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: const [
              Text('Numbers of market:'),
              SizedBox(
                width: 10,
              ),
              Text('0'),
            ],
          ),
          const SizedBox(height: 50),
          ElevatedButton(
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(
                  Colors.blue.shade800,
                ),
              ),
              onPressed: () async {
                Navigator.of(context).pop();
              },
              child: const Text(
                'Back',
                style: TextStyle(color: Colors.white),
              )),
        ],
      ),
    ));
  }
}

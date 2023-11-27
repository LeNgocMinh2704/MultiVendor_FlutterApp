import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:admin_web/Models/user.dart';
import 'package:easy_localization/easy_localization.dart';

class UsersData extends StatefulWidget {
  const UsersData({Key? key}) : super(key: key);

  @override
  State<UsersData> createState() => _UsersDataState();
}

class _UsersDataState extends State<UsersData> {
  bool isLoaded = false;
  int _rowsPerPage = PaginatedDataTable.defaultRowsPerPage;
  int? _sortColumnIndex;
  final bool _sortAscending = true;
  String deliveryBoyID = '';
  Future<QuerySnapshot>? yourStream;
  @override
  void initState() {
    yourStream = FirebaseFirestore.instance.collection('users').get();
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
            var vendorData = VendorDataSource(vendor);
            if (snapshot.hasData) {
              return ListView(
                shrinkWrap: true,
                children: [
                  PaginatedDataTable(
                    header: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children:const [
                       Text('Users'),
                        // SizedBox(
                        //   height: 40,
                        //   width: MediaQuery.of(context).size.width / 4,
                        //   child: TextField(
                        //       onTap: () {
                        //         Navigator.of(context).push(MaterialPageRoute(
                        //           builder: (context) => const Search(
                        //             collectionName: 'users',
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
                    columns: <DataColumn>[
                      DataColumn(
                        label: const Text('Index').tr(),
                      ),
                      DataColumn(
                        label: const Text('Profile Picture').tr(),
                      ),
                      DataColumn(
                        label: const Text('Name').tr(),
                      ),
                      DataColumn(
                        label: const Text('Email').tr(),
                      ),
                      const DataColumn(
                        label: Text('Phone number'),
                        numeric: true,
                      ),
                      const DataColumn(
                        label: Text('Address'),
                        numeric: true,
                      ),
                      const DataColumn(
                        label: Text('Wallet'),
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
  VendorDataSource(this.vendor);

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
              ? Container()
              : Text('${result.phonenumber}')),
          DataCell(SizedBox(width: 100, child: Text('${result.address}'))),
          DataCell(result.wallet == null
              ? const Text('0')
              : Text('${result.wallet}')),
        ]);
  }

  @override
  int get rowCount => vendor.length;

  @override
  bool get isRowCountApproximate => false;

  @override
  int get selectedRowCount => _selectedCount;
}

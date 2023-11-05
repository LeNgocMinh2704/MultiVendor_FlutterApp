// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:admin_web/Models/user.dart';
// import 'package:admin_web/Utils/Database/database.dart';


// class DeliveryBoysData extends StatefulWidget {
//   const DeliveryBoysData({Key? key}) : super(key: key);

//   @override
//   State<DeliveryBoysData> createState() => _DeliveryBoysDataState();
// }

// class _DeliveryBoysDataState extends State<DeliveryBoysData> {
//   bool isLoaded = false;
//   int _rowsPerPage = PaginatedDataTable.defaultRowsPerPage;
//   int? _sortColumnIndex;
//   final bool _sortAscending = true;
//   String deliveryBoyID = '';
//   Future<QuerySnapshot>? yourStream;
//   String currencyName = '';
//   String currencyCode = '';
//   String currencySymbol = '';
//   String getcurrencyName = '';
//   String getcurrencyCode = '';
//   String getcurrencySymbol = '';

//   getCurrencyDetails() {
//     FirebaseFirestore.instance
//         .collection('Currency Settings')
//         .doc('Currency Settings')
//         .get()
//         .then((value) {
//       setState(() {
//         getcurrencyName = value['Currency name'];
//         getcurrencyCode = value['Currency code'];
//         getcurrencySymbol = value['Currency symbol'];
//       });
//     });
//   }

//   @override
//   void initState() {
//     yourStream = FirebaseFirestore.instance.collection('drivers').get();
//     super.initState();
//   }

//   @override
//   Widget build(BuildContext context) {
//     List<UserModel> vendor;
//     return Padding(
//       padding: const EdgeInsets.all(8.0),
//       child: FutureBuilder<QuerySnapshot>(
//           future: yourStream,
//           builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
//             vendor = snapshot.data!.docs
//                 .map((e) => UserModel.fromMap(e.data(), e.id))
//                 .toList();
//             var vendorData =
//                 VendorDataSource(vendor, context, getcurrencySymbol);
//             if (snapshot.hasData) {
//               return ListView(
//                 shrinkWrap: true,
//                 children: [
//                   PaginatedDataTable(
//                     header: Row(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: const[
//                         Text('Delivery boys'),
//                         // SizedBox(
//                         //   height: 40,
//                         //   width: MediaQuery.of(context).size.width / 4,
//                         //   child: TextField(
//                         //       onTap: () {
//                         //         Navigator.of(context).push(MaterialPageRoute(
//                         //           builder: (context) => const Search(
//                         //             collectionName: 'delivery boy',
//                         //           ),
//                         //         ));
//                         //       },
//                         //       readOnly: true,
//                         //       decoration: InputDecoration(
//                         //         border: OutlineInputBorder(
//                         //           borderRadius: BorderRadius.circular(8),
//                         //           borderSide: const BorderSide(
//                         //               color: Colors.grey, width: 1.0),
//                         //         ),
//                         //         focusColor: Colors.grey,
//                         //         labelText: "Search",
//                         //         hintStyle:
//                         //             TextStyle(color: Colors.blue.shade800),
//                         //         prefixIcon: Icon(
//                         //           Icons.search,
//                         //           size: 30,
//                         //           color: Colors.blue.shade800,
//                         //         ),
//                         //         filled: true,
//                         //         fillColor: Colors.white10,
//                         //         focusedBorder: OutlineInputBorder(
//                         //           borderRadius: BorderRadius.circular(10),
//                         //           borderSide: const BorderSide(
//                         //               color: Colors.grey, width: 1.0),
//                         //         ),
//                         //         enabledBorder: OutlineInputBorder(
//                         //           borderRadius: BorderRadius.circular(8),
//                         //           borderSide: const BorderSide(
//                         //               color: Colors.grey, width: 1.0),
//                         //         ),
//                         //       )),
//                         // )
//                       ],
//                     ),
//                     rowsPerPage: _rowsPerPage,
//                     onRowsPerPageChanged: (int? value) {
//                       setState(() {
//                         _rowsPerPage = value!;
//                       });
//                     },
//                     source: vendorData,
//                     sortColumnIndex: _sortColumnIndex,
//                     sortAscending: _sortAscending,
//                     columns: const <DataColumn>[
//                       DataColumn(
//                         label: Text('Index'),
//                       ),
//                       DataColumn(
//                         label: Text('Profile Picture'),
//                       ),
//                       DataColumn(
//                         label: Text('Name'),
//                       ),
//                       DataColumn(
//                         label: Text('Email'),
//                       ),
//                       DataColumn(
//                         label: Text('Phone number'),
//                         numeric: true,
//                       ),
//                       DataColumn(
//                         label: Text('Address'),
//                         numeric: true,
//                       ),
//                       DataColumn(
//                         label: Text('Profile'),
//                       ),
//                     ],
//                   ),
//                 ],
//               );
//             } else {
//               return Container();
//             }
//           }),
//     );
//   }
// }

// int numberOfdelivery = 0;

// List<int> deliveryBoyAmount = [];

// class VendorDataSource extends DataTableSource {
//   final List<UserModel> vendor;
//   final String getcurrencySymbol;
//   final BuildContext context;
//   VendorDataSource(this.vendor, this.context, this.getcurrencySymbol);

//   final int _selectedCount = 0;

//   @override
//   DataRow? getRow(int index) {
//     assert(index >= 0);
//     if (index >= vendor.length) return null;
//     final UserModel result = vendor[index];
//     return DataRow.byIndex(
//         index: index,
//         selected: result.selected,
//         cells: <DataCell>[
//           DataCell(Text('${index + 1}')),
//           DataCell(result.photoUrl == null || result.photoUrl == ''
//               ? Container()
//               : Image.network('${result.photoUrl}', width: 50, height: 50)),
//           DataCell(Text('${result.displayName}')),
//           DataCell(Text('${result.email}')),
//           DataCell(Text('${result.phonenumber}')),
//           DataCell(SizedBox(width: 100, child: Text('${result.address}'))),
//           DataCell(OutlinedButton(
//               onPressed: () {
//                 showDialog(
//                     context: context,
//                     builder: (builder) {
//                       return DeliveryboyDetails(
//                         result: result,
//                       );
//                     });
//               },
//               child: const Text('View Profile'))),
//         ]);
//   }

//   @override
//   int get rowCount => vendor.length;

//   @override
//   bool get isRowCountApproximate => false;

//   @override
//   int get selectedRowCount => _selectedCount;
// }

// class DeliveryboyDetails extends StatefulWidget {
//   final UserModel result;
//   const DeliveryboyDetails({Key? key, required this.result}) : super(key: key);

//   @override
//   State<DeliveryboyDetails> createState() => _DeliveryboyDetailsState();
// }

// class _DeliveryboyDetailsState extends State<DeliveryboyDetails> {
//   String currencyName = '';
//   String currencyCode = '';
//   String currencySymbol = '';
//   String getcurrencyName = '';
//   String getcurrencyCode = '';
//   String getcurrencySymbol = '';

//   getCurrencyDetails() {
//     FirebaseFirestore.instance
//         .collection('Currency Settings')
//         .doc('Currency Settings')
//         .get()
//         .then((value) {
//       setState(() {
//         getcurrencyName = value['Currency name'];
//         getcurrencyCode = value['Currency code'];
//         getcurrencySymbol = value['Currency symbol'];
//       });
//     });
//   }

//   @override
//   void initState() {
//     getCurrencyDetails();
//     super.initState();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return AlertDialog(
//       content: SizedBox(
//         width: MediaQuery.of(context).size.width / 1.7,
//         child: Column(
//           children: [
//             const Text('Profile Picture'),
//             const SizedBox(height: 10),
//             widget.result.photoUrl == null || widget.result.photoUrl == ''
//                 ? Container()
//                 : Image.network('${widget.result.photoUrl}',
//                     width: 100, height: 100),
//             const SizedBox(height: 20),
//             Row(
//               children: [
//                 const Text('Name:'),
//                 const SizedBox(
//                   width: 10,
//                 ),
//                 Text('${widget.result.displayName}'),
//               ],
//             ),
//             const SizedBox(height: 20),
//             Row(
//               children: [
//                 const Text('Phone:'),
//                 const SizedBox(
//                   width: 10,
//                 ),
//                 Text('${widget.result.phonenumber}'),
//               ],
//             ),
//             const SizedBox(height: 20),
//             Row(
//               children: [
//                 const Text('Address:'),
//                 const SizedBox(
//                   width: 10,
//                 ),
//                 SizedBox(
//                     width: MediaQuery.of(context).size.width / 2,
//                     child: Text('${widget.result.address}',
//                         style: const TextStyle(fontSize: 12))),
//               ],
//             ),
//             const SizedBox(height: 20),
//             // Text('License'),
//             // SizedBox(height: 10),
//             // Image.network('${widget.result.license}', width: 100, height: 100),
//             // SizedBox(height: 20),
//             const Text('Number of Orders completed'),
//             const SizedBox(height: 10),
//             FutureBuilder<List<UserModel>>(
//                 future: Clients()
//                     .deliveryBoyNumberOfOrders(widget.result.uid.toString()),
//                 builder: (context, snapshot) {
//                   if (snapshot.data?.isNotEmpty ??
//                       true && snapshot.data != null) {
//                     return Text('${snapshot.data!.length}',
//                         style: const TextStyle(
//                             fontSize: 15, fontWeight: FontWeight.bold));
//                   } else {
//                     return const Text('0',
//                         style: TextStyle(
//                             fontSize: 15, fontWeight: FontWeight.bold));
//                   }
//                 }),
//             const SizedBox(height: 20),
//             const Text('Earnings'),
//             const SizedBox(height: 10),
//             widget.result.earnings == null || widget.result.earnings == 0
//                 ? Text('$getcurrencySymbol 0')
//                 : Text('$getcurrencySymbol${widget.result.earnings}'),
//             const SizedBox(height: 10),
//             const SizedBox(height: 10),
//             ElevatedButton(
//                 style: ButtonStyle(
//                   elevation: MaterialStateProperty.all(10),
//                   backgroundColor: MaterialStateProperty.all<Color>(
//                     Colors.blue.shade800,
//                   ),
//                 ),
//                 onPressed: () async {
//                   Navigator.pop(context);
//                 },
//                 child: const Text('Back')),
//           ],
//         ),
//       ),
//     );
//   }
// }

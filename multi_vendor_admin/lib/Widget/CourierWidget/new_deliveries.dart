// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';

// import '../../Models/courier_model.dart';
// // import 'package:multivendoradminweb/Widget/Search/search.dart';

// class NewDeliveriesCourier extends StatefulWidget {
//   const NewDeliveriesCourier({
//     Key? key,
//   }) : super(key: key);
//   @override
//   State<NewDeliveriesCourier> createState() => _NewDeliveriesCourierState();
// }

// class _NewDeliveriesCourierState extends State<NewDeliveriesCourier> {
//   bool isLoaded = false;
//   int _rowsPerPage = PaginatedDataTable.defaultRowsPerPage;
//   int? _sortColumnIndex;
//   final bool _sortAscending = true;

//   String deliveryBoyID = '';
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
//     List<CourierModel> deliveryBoy;
//     return Padding(
//       padding: const EdgeInsets.all(8.0),
//       child: FutureBuilder(
//           future: FirebaseFirestore.instance
//               .collection('Courier')
//               .where('status', isEqualTo: false)
//               .get(),
//           builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
//             deliveryBoy = snapshot.data!.docs
//                 .map((e) => CourierModel.fromMap(e.data(), e.id))
//                 .toList();
//             var deliveryBoyData =
//                 DeliveryBoyDataSource(deliveryBoy, getcurrencySymbol, context);
//             return PaginatedDataTable(
//                 showCheckboxColumn: false,
//                 header: Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: const [
//                     Text('New Deliveries'),
//                     // Container(
//                     //   height: 40,
//                     //   width: MediaQuery.of(context).size.width / 3,
//                     //   child: TextField(
//                     //       onTap: () {
//                     //         Get.to(() => Search(
//                     //               authLogin: 1,
//                     //               vendorStatus: true,
//                     //               collectionName: 'delivery boy',
//                     //             ));
//                     //       },
//                     //       readOnly: true,
//                     //       decoration: InputDecoration(
//                     //         border: OutlineInputBorder(
//                     //           borderRadius: BorderRadius.circular(8),
//                     //           borderSide: BorderSide(
//                     //               color: Colors.grey, width: 1.0),
//                     //         ),
//                     //         focusColor: Colors.grey,
//                     //         labelText: "Search",
//                     //         hintStyle:
//                     //             TextStyle(color: Colors.blue.shade800),
//                     //         prefixIcon: Icon(
//                     //           Icons.search,
//                     //           size: 30,
//                     //           color: Colors.blue.shade800,
//                     //         ),
//                     //         filled: true,
//                     //         fillColor: Colors.white10,
//                     //         focusedBorder: OutlineInputBorder(
//                     //           borderRadius: BorderRadius.circular(10),
//                     //           borderSide: BorderSide(
//                     //               color: Colors.grey, width: 1.0),
//                     //         ),
//                     //         enabledBorder: OutlineInputBorder(
//                     //           borderRadius: BorderRadius.circular(8),
//                     //           borderSide: BorderSide(
//                     //               color: Colors.grey, width: 1.0),
//                     //         ),
//                     //       )),
//                     // )
//                   ],
//                 ),
//                 rowsPerPage: _rowsPerPage,
//                 onRowsPerPageChanged: (int? value) {
//                   setState(() {
//                     _rowsPerPage = value!;
//                   });
//                 },
//                 sortColumnIndex: _sortColumnIndex,
//                 sortAscending: _sortAscending,
//                 columns: const <DataColumn>[
//                   DataColumn(
//                     label: Text('Parcel Image'),
//                   ),
//                   DataColumn(
//                     label: Text('Parcel ID'),
//                   ),
//                   DataColumn(
//                     label: Text('Parcel name'),
//                   ),
//                   DataColumn(
//                     label: Text('Date created'),
//                     numeric: true,
//                   ),
//                   DataColumn(
//                     label: Text('Recipient Address'),
//                     numeric: true,
//                   ),
//                   DataColumn(
//                     label: Text('Price'),
//                     numeric: true,
//                   ),
//                   DataColumn(
//                     label: Text('Profile'),
//                   ),
//                 ],
//                 source: deliveryBoyData);
//           }),
//     );
//   }
// }

// int numberOfdelivery = 0;

// List<int> deliveryBoyAmount = [];

// class DeliveryBoyDataSource extends DataTableSource {
//   final List<CourierModel> deliveryBoy;
//   final BuildContext context;
//   final String getcurrencySymbol;
//   DeliveryBoyDataSource(this.deliveryBoy, this.getcurrencySymbol, this.context);

//   final int _selectedCount = 0;

//   @override
//   DataRow? getRow(int index) {
//     assert(index >= 0);
//     if (index >= deliveryBoy.length) return null;
//     final CourierModel result = deliveryBoy[index];
//     return DataRow.byIndex(index: index, cells: <DataCell>[
//       DataCell(Image.network(result.parcelImage, width: 50, height: 50)),
//       DataCell(Text('#${result.parcelID}')),
//       DataCell(Text(result.parcelName)),
//       DataCell(Text(result.deliveryDate)),
//       DataCell(
//           SizedBox(width: 150, child: Text(result.recipientAddress))),
//       DataCell(Text('$getcurrencySymbol${result.price}')),
//       DataCell(OutlinedButton(
//           onPressed: () {
//             showDialog(
//                 context: context,
//                 builder: (BuildContext context) {
//                   return AlertDialog(
//                     content: Column(
//                       children: [
//                         const Text('Logistics details'),
//                         const SizedBox(height: 10),
//                         result.parcelImage == ''
//                             ? Container()
//                             : Image.network(result.parcelImage,
//                                 width: 100, height: 100),
//                         const SizedBox(height: 20),
//                         Row(
//                           children: [
//                             const Text('Name:'),
//                             const SizedBox(
//                               width: 10,
//                             ),
//                             Text(result.parcelName),
//                           ],
//                         ),
//                         const SizedBox(height: 20),
//                         Row(
//                           children: [
//                             const Text('Sender Phone:'),
//                             const SizedBox(
//                               width: 10,
//                             ),
//                             Text(result.sendersName),
//                           ],
//                         ),
//                         const SizedBox(height: 20),
//                         Row(
//                           children: [
//                             const Text('Sender Address:'),
//                             const SizedBox(
//                               width: 10,
//                             ),
//                             SizedBox(
//                                 width: MediaQuery.of(context).size.width / 2,
//                                 child: Text(result.sendersAddress,
//                                     style: const TextStyle(fontSize: 12))),
//                           ],
//                         ),
//                         const SizedBox(height: 20),
//                         Row(
//                           children: [
//                             const Text('Recipient Name:'),
//                             const SizedBox(
//                               width: 10,
//                             ),
//                             Text(result.recipientName),
//                           ],
//                         ),
//                         const SizedBox(height: 20),
//                         Row(
//                           children: [
//                             const Text('Recipient Phone:'),
//                             const SizedBox(
//                               width: 10,
//                             ),
//                             Text(result.recipientPhone),
//                           ],
//                         ),
//                         const SizedBox(height: 20),
//                         Row(
//                           children: [
//                             const Text('Recipient Address:'),
//                             const SizedBox(
//                               width: 10,
//                             ),
//                             Text(result.recipientAddress),
//                           ],
//                         ),
//                         const SizedBox(height: 20),
//                         const SizedBox(height: 20),
//                         Row(
//                           children: [
//                             const Text('Price:'),
//                             const SizedBox(
//                               width: 10,
//                             ),
//                             Text('$getcurrencySymbol${result.price}'),
//                           ],
//                         ),
//                         const SizedBox(height: 20),
//                         Row(
//                           children: [
//                             const Text('Parcel Weight:'),
//                             const SizedBox(
//                               width: 10,
//                             ),
//                             Text('${result.weight}'),
//                           ],
//                         ),
//                         const SizedBox(height: 20),
//                         Row(
//                           children: [
//                             const Text('Distance:'),
//                             const SizedBox(
//                               width: 10,
//                             ),
//                             Text('${result.km}'),
//                           ],
//                         ),
//                         const SizedBox(height: 20),
//                         ElevatedButton(
//                             style: ButtonStyle(
//                               elevation: MaterialStateProperty.all(10),
//                               backgroundColor:
//                                   MaterialStateProperty.all<Color>(
//                                 Colors.blue.shade800,
//                               ),
//                             ),
//                             onPressed: () async {
//                               Navigator.of(context).pop();
//                             },
//                             child: const Text('Back')),
//                       ],
//                     ),
//                   );
//                 });
//           },
//           child: const Text('View Details'))),
//     ]);
//   }

//   @override
//   int get rowCount => deliveryBoy.length;

//   @override
//   bool get isRowCountApproximate => false;

//   @override
//   int get selectedRowCount => _selectedCount;
// }

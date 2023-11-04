// import 'dart:async';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:admin_web/Widget/order_detail.dart';

// import '../Models/order_model.dart';

// class AllOrders extends StatefulWidget {
//   const AllOrders({Key? key}) : super(key: key);

//   @override
//   State<AllOrders> createState() => _AllOrdersState();
// }

// class _AllOrdersState extends State<AllOrders> {
//   late ResultsDataSource _resultsDataSource;

//   bool isLoaded = false;
//   int _rowsPerPage = PaginatedDataTable.defaultRowsPerPage;
//   int? _sortColumnIndex;
//   bool _sortAscending = true;

//   void _sort<T>(Comparable<T> Function(OrderModel2 d) getField, int columnIndex,
//       bool ascending) {
//     _resultsDataSource._sort<T>(getField, ascending);
//     setState(() {
//       _sortColumnIndex = columnIndex;
//       _sortAscending = ascending;
//     });
//   }

//   Future<void> getData() async {
//     final results = await fetAllOrders();
//     if (!isLoaded) {
//       setState(() {
//         _resultsDataSource =
//             ResultsDataSource(results, getcurrencySymbol, context);
//         isLoaded = true;
//       });
//     }
//   }

//   String currencyName = '';
//   String currencyCode = '';
//   String currencySymbol = '';
//   String getcurrencyName = '';
//   String getcurrencyCode = '';
//   static String getcurrencySymbol = '';

//   getCurrencyDetails() {
//     FirebaseFirestore.instance
//         .collection('Currency Settings')
//         .doc('Currency Settings')
//         .get()
//         .then((value) {
//       getcurrencyName = value['Currency name'];
//       getcurrencyCode = value['Currency code'];
//       getcurrencySymbol = value['Currency symbol'];
//     });
//   }

//   String deliveryBoyID = '';

//   @override
//   void initState() {
//     getData();
//     fetAllOrders();
//     getCurrencyDetails();
//     super.initState();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.all(8.0),
//       child: SingleChildScrollView(
//         child: PaginatedDataTable(
//             showCheckboxColumn: false,
//             header: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: const [
//                 Text('Orders'),
//               ],
//             ),
//             rowsPerPage: _rowsPerPage,
//             onRowsPerPageChanged: (int? value) {
//               setState(() {
//                 _rowsPerPage = value!;
//               });
//             },
//             sortColumnIndex: _sortColumnIndex,
//             sortAscending: _sortAscending,
//             columns: <DataColumn>[
//               DataColumn(
//                   label: const Text('Order ID'),
//                   onSort: (int columnIndex, bool ascending) => _sort<String>(
//                       (OrderModel2 d) => d.orderID.toString(),
//                       columnIndex,
//                       ascending)),
//               DataColumn(
//                   label: const Text('Order status'),
//                   onSort: (int columnIndex, bool ascending) => _sort<String>(
//                       (OrderModel2 d) => d.status.toString(),
//                       columnIndex,
//                       ascending)),
//               const DataColumn(
//                 label: Text('Time created'),
//               ),
//               // DataColumn(
//               //   label: const Text('User name'),
//               // ),
//               DataColumn(
//                   label: const Text('Total price'),
//                   numeric: true,
//                   onSort: (int columnIndex, bool ascending) => _sort<String>(
//                       (OrderModel2 d) => d.total.toString(),
//                       columnIndex,
//                       ascending)),
//               const DataColumn(
//                 label: Text('Address'),
//                 numeric: true,
//               ),
//               const DataColumn(
//                 label: Text('View Orders'),
//                 numeric: true,
//               ),
//             ],
//             source: _resultsDataSource),
//       ),
//     );
//   }

//   String status = 'All';
//   Future<List<OrderModel2>> fetAllOrders() async {
//     FirebaseFirestore.instance
//         .collection('Orders')
//         .snapshots(includeMetadataChanges: true)
//         .listen((data) {
//       orders.clear();
//       for (var doc in data.docs) {
//         if (mounted) {
//           setState(() {
//             orders.add(OrderModel2(
//               orders: [
//                 ...(doc.data()['orders']).map((items) {
//                   return OrdersList.fromMap(items);
//                 })
//               ],
//               uid: doc.data()['uid'],
//               marketID: doc.data()['marketID'],
//               vendorID: doc.data()['vendorID'],
//               userID: doc.data()['userID'],
//               deliveryAddress: doc.data()['deliveryAddress'],
//               houseNumber: doc.data()['houseNumber'],
//               closesBusStop: doc.data()['closesBusStop'],
//               deliveryBoyID: doc.data()['deliveryBoyID'],
//               status: doc.data()['status'],
//               accept: doc.data()['accept'],
//               orderID: doc.data()['orderID'],
//               timeCreated: doc.data()['timeCreated'],
//               total: doc.data()['total'],
//               deliveryFee: doc.data()['deliveryFee'],
//               acceptDelivery: doc.data()['acceptDelivery'],
//               paymentType: doc.data()['paymentType'],
//             ));
//           });
//         }
//       }
//     });
//     return orders;
//   }
// }

// int numberOfdelivery = 0;

// List<OrderModel2> orders = [];
// List<int> deliveryBoyAmount = [];

// class ResultsDataSource extends DataTableSource {
//   final List<OrderModel2> orders;
//   final String getcurrencySymbol;
//   final BuildContext context;
//   ResultsDataSource(this.orders, this.getcurrencySymbol, this.context);

//   void _sort<T>(
//       Comparable<T> Function(OrderModel2 d) getField, bool ascending) {
//     orders.sort((OrderModel2 a, OrderModel2 b) {
//       if (!ascending) {
//         final OrderModel2 c = a;
//         a = b;
//         b = c;
//       }
//       final Comparable<T> aValue = getField(a);
//       final Comparable<T> bValue = getField(b);
//       return Comparable.compare(aValue, bValue);
//     });
//     notifyListeners();
//   }

//   final int _selectedCount = 0;

//   @override
//   DataRow? getRow(int index) {
//     assert(index >= 0);
//     if (index >= orders.length) return null;
//     final OrderModel2 result = orders[index];
//     return DataRow.byIndex(index: index, cells: <DataCell>[
//       DataCell(Text('#${result.orderID}')),
//       DataCell(Text(result.status)),
//       DataCell(Text('${result.timeCreated}')),
//       // DataCell(Text('${result.userID}')),
//       DataCell(Text('$getcurrencySymbol${result.total}')),
//       DataCell(result.deliveryAddress == ''
//           ? const Align(
//               alignment: Alignment.center,
//               child: Text(
//                 'Pick Up',
//                 textAlign: TextAlign.center,
//               ),
//             )
//           : SizedBox(width: 150, child: Text(result.deliveryAddress))),
//       DataCell(ElevatedButton(
//           style: ButtonStyle(
//             elevation: MaterialStateProperty.all(10),
//             backgroundColor: MaterialStateProperty.all<Color>(
//               Colors.blue.shade800,
//             ),
//           ),
//           onPressed: () {
//             showDialog(
//                 context: context,
//                 builder: (builder) {
//                   return OrderDetail(orderModel: result);
//                 });
//           },
//           child: const Text('View Orders'))),
//     ]);
//   }

//   @override
//   int get rowCount => orders.length;

//   @override
//   bool get isRowCountApproximate => false;

//   @override
//   int get selectedRowCount => _selectedCount;
// }

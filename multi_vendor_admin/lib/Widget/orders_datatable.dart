// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';

// import '../Models/order_model.dart';

// class OrdersDatatable extends StatefulWidget {
//   const OrdersDatatable({
//     Key? key,
//   }) : super(key: key);
//   @override
//   State<OrdersDatatable> createState() => _OrdersDatatableState();
// }

// class _OrdersDatatableState extends State<OrdersDatatable> {
//   List<OrderModel2> orders = [];

//   Future<List<OrderModel2>> fetAllOrders() async {
//     FirebaseFirestore.instance
//         .collection('Orders')
//         .where('status', isEqualTo: 'Received')
//         .orderBy('timeCreated')
//         .limit(8)
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

//   @override
//   void initState() {
//     fetAllOrders();
//     super.initState();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return SingleChildScrollView(
//       child: DataTable(
//           dividerThickness: 2,
//           columns: const <DataColumn>[
//             DataColumn(
//               label: Text('OrderID', style: TextStyle(color: Colors.black)),
//             ),
//             DataColumn(
//               label: Text('Order time', style: TextStyle(color: Colors.black)),
//             ),
//             DataColumn(
//               label: Text('Status', style: TextStyle(color: Colors.black)),
//             ),
//           ],
//           rows: orders.map((e) {
//             return DataRow(
//               cells: [
//                 DataCell(Text('#${e.orderID.toString()}',
//                     style: const TextStyle(color: Colors.black))),
//                 DataCell(Text(e.timeCreated.toString(),
//                     style: const TextStyle(color: Colors.black))),
//                 DataCell(Text(e.status, style: const TextStyle(color: Colors.black))),
//               ],
//             );
//           }).toList()),
//     );
//   }
// }

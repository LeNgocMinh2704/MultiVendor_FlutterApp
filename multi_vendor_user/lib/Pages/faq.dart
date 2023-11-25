// import 'package:flutter/material.dart';
// import 'package:easy_localization/easy_localization.dart';
// import 'package:flutter_ameno_ipsum/flutter_ameno_ipsum.dart';

// class FaqPage extends StatefulWidget {
//   const FaqPage({Key? key}) : super(key: key);

//   @override
//   State<FaqPage> createState() => _FaqPageState();
// }

// class _FaqPageState extends State<FaqPage> {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//           iconTheme: Theme.of(context).iconTheme,
//           titleTextStyle: TextStyle(color: Theme.of(context).indicatorColor),
//           backgroundColor: Theme.of(context).colorScheme.background,
//           centerTitle: true,
//           elevation: 0,
//           : Colors.blue,
//           successIcon: Icons.done,
//           failedIcon: Icons.error,
//           controller: _btnController1,
//           title: const Text(
//             'Faq',
//           ).tr()),
//       body: SingleChildScrollView(
//         child: Padding(
//           padding: const EdgeInsets.all(8.0),
//           child: Column(
//             children: [
//               const SizedBox(height: 20),
//               Row(
//                 children: const [
//                   Text(
//                     'How do i upload money to my wallet?',
//                     style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 10),
//               Padding(
//                 padding: const EdgeInsets.all(8.0),
//                 child: Text(ameno(paragraphs: 1, words: 200)),
//               ),
//               const SizedBox(height: 20),
//               Row(
//                 children: const [
//                   Text(
//                     'How do i make an order?',
//                     style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 10),
//               Padding(
//                 padding: const EdgeInsets.all(8.0),
//                 child: Text(ameno(paragraphs: 1, words: 200)),
//               ),
//               const SizedBox(height: 20),
//               Row(
//                 children: const [
//                   Text(
//                     'How do i contact a vendor?',
//                     style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 10),
//               Padding(
//                 padding: const EdgeInsets.all(8.0),
//                 child: Text(ameno(paragraphs: 1, words: 200)),
//               ),
//               const SizedBox(height: 20),
//               Row(
//                 children: const [
//                   Text(
//                     'How do i send a parcel?',
//                     style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 10),
//               Padding(
//                 padding: const EdgeInsets.all(8.0),
//                 child: Text(ameno(paragraphs: 1, words: 200)),
//               )
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

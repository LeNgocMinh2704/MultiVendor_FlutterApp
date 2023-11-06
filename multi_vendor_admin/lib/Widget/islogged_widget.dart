// // ignore_for_file: file_names
// import 'package:flutter/material.dart';
// import 'package:flutter_modular/flutter_modular.dart';
// import 'package:easy_localization/easy_localization.dart';

// class IsLoggedWidget extends StatelessWidget {
//   const IsLoggedWidget({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.start,
//           children: [
//             Image.asset(
//               'assets/image/login-icon.png',
//               height: MediaQuery.of(context).size.width >= 1100
//                   ? MediaQuery.of(context).size.height / 1.8
//                   : MediaQuery.of(context).size.height / 2,
//               width: MediaQuery.of(context).size.width >= 1100
//                   ? MediaQuery.of(context).size.height / 1.8
//                   : MediaQuery.of(context).size.height / 2,
//             ),
//             const SizedBox(
//               height: 20,
//             ),
//             SizedBox(
//               height: 40,
//               child: ElevatedButton(
//                   style:
//                       ElevatedButton.styleFrom(backgroundColor: Colors.orange),
//                   onPressed: () {
//                     Modular.to.navigate('/login');
//                   },
//                   child: const Text('Login to continue').tr()),
//             )
//           ],
//         ),
//       ),
//     );
//   }
// }

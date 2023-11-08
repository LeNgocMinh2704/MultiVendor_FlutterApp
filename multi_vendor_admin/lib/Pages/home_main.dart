// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:easy_localization/easy_localization.dart';
// import 'package:flutter_modular/flutter_modular.dart';
// import 'package:admin_web/Widget/languageview.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import '../Widget/drawer.dart';

// class HomePageMain extends StatefulWidget {
//   const HomePageMain({Key? key}) : super(key: key);

//   @override
//   State<HomePageMain> createState() => _HomePageMainState();
// }

// class _HomePageMainState extends State<HomePageMain> {
//   final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

//   DocumentReference? userRef;
//   String fullname = 'Olivette Admin';
//   String profilePic =
//       'https://eitrawmaterials.eu/wp-content/uploads/2016/09/person-icon.png';
//   String email = 'admin123@gmail.com';

//   @override
//   void initState() {
//     getFirebaseDetails();
//     super.initState();
//   }

//   String adminImage = '';
//   String oldPassword = '';
//   String adminUsername = '';
//   getFirebaseDetails() {
//     FirebaseFirestore.instance
//         .collection('Admin')
//         .doc('Admin')
//         .get()
//         .then((value) {
//       setState(() {
//         adminImage = value['ProfilePic'];
//         oldPassword = value['password'];
//         adminUsername = value['username'];
//       });
//     });
//   }

//   bool? loggedIn;

//   getSelectedRoute() {
//     SharedPreferences.getInstance().then((prefs) {
//       var log = prefs.getBool('logged in');
//       setState(() {
//         loggedIn = log!;
//       });
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     getSelectedRoute();
//     return Scaffold(
//       key: _scaffoldKey,
//       appBar: loggedIn == false || loggedIn == null
//           ? AppBar(
//               elevation: 0,
//               backgroundColor: Colors.white10,
//             )
//           : AppBar(
//               backgroundColor: Colors.blue.shade800,
//               elevation: 5,
//               actions: [
//                 Padding(
//                   padding: const EdgeInsets.only(left: 20),
//                   child: IconButton(
//                       color: Colors.white,
//                       onPressed: () {
//                         Navigator.of(context).pushNamed(
//                           '/notifications',
//                         );
//                       },
//                       icon: const Icon(Icons.notifications_outlined)),
//                 ),
//                 TextButton(
//                   child: const Icon(
//                     Icons.language,
//                     color: Colors.white,
//                   ),
//                   onPressed: () {
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                           builder: (_) => const LanguageView(),
//                           fullscreenDialog: true),
//                     );
//                   },
//                 ),
//                 DropdownButtonHideUnderline(
//                   child: DropdownButton<String>(
//                     iconDisabledColor: Colors.white,
//                     iconEnabledColor: Colors.white,
//                     hint: SizedBox(
//                       height: 40,
//                       child: CircleAvatar(
//                         radius: 30.0,
//                         backgroundImage: NetworkImage(adminImage),
//                         backgroundColor: Colors.transparent,
//                       ),
//                     ),
//                     items: <String>[
//                       'Profile'.tr(),
//                       'Settings'.tr(),
//                       'Log Out'.tr(),
//                     ].map((String value) {
//                       return DropdownMenuItem<String>(
//                         value: value,
//                         child: Text(value),
//                       );
//                     }).toList(),
//                     onChanged: (value) async {
//                       if (value == 'Log Out') {
//                         Modular.to
//                             .pushNamedAndRemoveUntil('/login', (p0) => false);
//                         var prefs = await SharedPreferences.getInstance();
//                         prefs.setBool('logged in', false);
//                       } else if (value == 'Profile') {
//                         Navigator.of(context).pushNamed(
//                           '/profile',
//                         );
//                       } else {
//                         Navigator.of(context).pushNamed(
//                           '/settings',
//                         );
//                       }
//                     },
//                   ),
//                 ),
//                 MediaQuery.of(context).size.width >= 1100
//                     ? const SizedBox(
//                         width: 30,
//                       )
//                     : Container(),
//               ],
//               title: MediaQuery.of(context).size.width >= 1100
//                   ? const Text(
//                       'Admin Dashboard',
//                       style: TextStyle(
//                           color: Colors.white, fontWeight: FontWeight.bold),
//                       textAlign: TextAlign.center,
//                     )
//                   : const Text(
//                       'Admin Dashboard',
//                       style: TextStyle(color: Colors.white),
//                       textAlign: TextAlign.start,
//                     ).tr(),
//               leading: MediaQuery.of(context).size.width >= 1100
//                   ? Container()
//                   : InkWell(
//                       onTap: () {
//                         _scaffoldKey.currentState!.openDrawer();
//                       },
//                       child: const Icon(
//                         Icons.menu,
//                         color: Colors.white,
//                       )),
//             ),
//       drawer: loggedIn == false || loggedIn == null
//           ? const SizedBox()
//           : const SideMenu(),
//       body: SafeArea(
//         child: Row(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             loggedIn == false || loggedIn == null
//                 ? const SizedBox()
//                 : MediaQuery.of(context).size.width >= 1100
//                     ? const Expanded(
//                         child: SideMenu(),
//                       )
//                     : const SizedBox(),
//             const Expanded(
//               flex: 5,
//               child: RouterOutlet(),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

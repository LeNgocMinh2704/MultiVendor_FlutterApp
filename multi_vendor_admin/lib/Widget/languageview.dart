// import 'dart:developer';
// import 'package:flutter/material.dart';
// import 'package:easy_localization/easy_localization.dart';

// class LanguageView extends StatelessWidget {
//   const LanguageView({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text(
//           '',
//           style: TextStyle(color: Colors.black),
//         ),
//         backgroundColor: Colors.white,
//         iconTheme: const IconThemeData(color: Colors.black),
//         elevation: 0,
//       ),
//       body: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Container(
//             padding: const EdgeInsets.only(top: 26),
//             margin: const EdgeInsets.symmetric(
//               horizontal: 24,
//             ),
//             child: Row(
//               children: [
//                 const Icon(Icons.language, size: 40, color: Colors.grey),
//                 const SizedBox(width: 20),
//                 Text(
//                   'Select your preferred language'.tr(),
//                   style: const TextStyle(
//                     color: Colors.blue,
//                     fontFamily: 'Montserrat',
//                     fontWeight: FontWeight.w700,
//                     fontSize: 18,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           const SizedBox(height: 20),
//           _SwitchListTileMenuItem(
//               flag: 'assets/image/usa.png',
//               subtitle: 'English',
//               title: 'USA',
//               locale:
//                   context.supportedLocales[1] //BuildContext extension method
//               ),
//           _SwitchListTileMenuItem(
//               flag: 'assets/image/spanish.gif',
//               title: 'PARAGUAY',
//               subtitle: 'Spanish',
//               locale: context.supportedLocales[0]),
//           _SwitchListTileMenuItem(
//               flag: 'assets/image/portugal.png',
//               subtitle: 'Portueges',
//               title: 'BRAZIL- PORTUGUÉS',
//               locale: context.supportedLocales[2]),
//         ],
//       ),
//     );
//   }
// }

// class _SwitchListTileMenuItem extends StatefulWidget {
//   const _SwitchListTileMenuItem({
//     Key? key,
//     required this.title,
//     required this.subtitle,
//     required this.locale,
//     required this.flag,
//   }) : super(key: key);

//   final String title;
//   final String subtitle;
//   final Locale locale;
//   final String flag;

//   @override
//   State<_SwitchListTileMenuItem> createState() =>
//       __SwitchListTileMenuItemState();
// }

// class __SwitchListTileMenuItemState extends State<_SwitchListTileMenuItem> {
//   bool isSelected(BuildContext context) => widget.locale == context.locale;

//   dynamic themeMode;

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       margin: const EdgeInsets.only(left: 10, right: 10, top: 10),
//       child: Card(
//         elevation: 3,
//         child: ListTile(
//             tileColor: isSelected(context) ? Colors.grey[300] : null,
//             leading: Padding(
//               padding: const EdgeInsets.all(8.0),
//               child: Image.asset(
//                 widget.flag,
//                 height: 40,
//                 width: 40,
//                 fit: BoxFit.cover,
//               ),
//             ),
//             dense: true,
//             // isThreeLine: true,
//             title: Text(
//               widget.title,
//               style: const TextStyle(color: Colors.black),
//             ),
//             subtitle: Text(
//               widget.subtitle,
//               style: const TextStyle(color: Colors.black),
//             ),
//             onTap: () async {
//               log(widget.locale.toString(), name: toString());
//               //print('Country code is ${widget.locale.countryCode}');
//               await context
//                   .setLocale(widget.locale)
//                   .then((value) => Navigator.of(context).popAndPushNamed(
//                         '/home',
//                       ));
//             }),
//       ),
//     );
//   }
// }

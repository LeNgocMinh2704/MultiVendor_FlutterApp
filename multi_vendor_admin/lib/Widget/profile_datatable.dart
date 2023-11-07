// // ignore_for_file: unnecessary_new

// import 'dart:typed_data';
// import 'package:easy_localization/easy_localization.dart';
// import 'package:another_flushbar/flushbar.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:file_picker/file_picker.dart';
// import 'package:firebase_storage/firebase_storage.dart';
// import 'package:flutter/material.dart';
// import 'package:fluttertoast/fluttertoast.dart';

// class ProfileData extends StatefulWidget {
//   const ProfileData({Key? key}) : super(key: key);

//   @override
//   State<ProfileData> createState() => _ProfileDataState();
// }

// class _ProfileDataState extends State<ProfileData> {
//   String firestoreImage = '';
//   dynamic image;
//   String newPassword = '';
//   String oldPassword = '';
//   String oldPasswordonChanged = '';
//   String adminUsernameonChanged = '';
//   String adminUsername = '';
//   String adminImage = '';

//   updateAdmin() {
//     FirebaseFirestore.instance.collection('Admin').doc('Admin').update({
//       'ProfilePic': whenProfilePics(),
//       'password': newPassword,
//       'username': whenUsername(),
//     }).then((value) {
//       Navigator.popAndPushNamed(context, '/home');
//       setState(() {
//         adminUsernameonChanged = '';
//         oldPasswordonChanged = '';
//         newPassword = '';
//       });
//       Flushbar(
//         flushbarPosition: FlushbarPosition.TOP,
//         title: "Notification",
//         message: "Admin has been updated!!!",
//         duration: const Duration(seconds: 3),
//       ).show(context);
//     });
//   }

//   whenProfilePics() {
//     if (firestoreImage == '') {
//       return adminImage;
//     } else {
//       return firestoreImage;
//     }
//   }

//   whenUsername() {
//     if (adminUsernameonChanged == '') {
//       return adminUsername;
//     } else {
//       return adminUsernameonChanged;
//     }
//   }

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
//         //print(oldPassword);
//       });
//     });
//   }

//   getImage() async {
//     FilePickerResult? result = await FilePicker.platform.pickFiles(
//       type: FileType.custom,
//       allowedExtensions: ['jpg', 'jpeg', 'png'],
//     );

//     if (result != null) {
//       Uint8List? fileBytes = result.files.first.bytes;
//       String fileName = result.files.first.name;
//       setState(() {
//         image = fileBytes;
//       });
//       // Upload file
//       TaskSnapshot upload = await FirebaseStorage.instance
//           .ref('uploads/$fileName')
//           .putData(fileBytes!);
//       String url = await upload.ref.getDownloadURL();
//       //print(url);
//       setState(() {
//         firestoreImage = url;
//       });
//     }
//   }

//   @override
//   void initState() {
//     getFirebaseDetails();
//     super.initState();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return SingleChildScrollView(
//       child: Column(
//         children: [
//           Padding(
//             padding: const EdgeInsets.all(8.0),
//             child: Row(
//               children: [
//                 const Text(
//                   'Admin Profile Settings',
//                   style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//                 ).tr(),
//               ],
//             ),
//           ),
//           const SizedBox(
//             height: 10,
//           ),
//           image == null
//               ? CircleAvatar(
//                   radius:
//                       MediaQuery.of(context).size.width >= 1100 ? 100.0 : 50,
//                   backgroundImage: NetworkImage(adminImage),
//                   backgroundColor: Colors.transparent,
//                 )
//               : CircleAvatar(
//                   radius:
//                       MediaQuery.of(context).size.width >= 1100 ? 100.0 : 50,
//                   backgroundImage: MemoryImage(image),
//                   backgroundColor: Colors.transparent,
//                 ),
//           IconButton(
//             onPressed: () {
//               getImage();
//             },
//             icon: const Icon(Icons.add_a_photo),
//             iconSize: 50,
//             color: Colors.blue.shade800,
//           ),
//           SizedBox(
//             width: MediaQuery.of(context).size.width / 2,
//             child: Padding(
//               padding: const EdgeInsets.all(8.0),
//               child: Row(
//                 children: [
//                   const Text(
//                     'Admin Username',
//                     style: TextStyle(fontWeight: FontWeight.bold),
//                   ).tr(),
//                 ],
//               ),
//             ),
//           ),
//           Padding(
//             padding: const EdgeInsets.all(8.0),
//             child: SizedBox(
//               width: MediaQuery.of(context).size.width / 2,
//               height: 40,
//               child: TextFormField(
//                   readOnly: true,
//                   onTap: () {
//                     Fluttertoast.showToast(
//                         msg:
//                             "This is a test version you can't change the details",
//                         backgroundColor: Colors.blue.shade800,
//                         textColor: Colors.white);
//                   },
//                   onChanged: (value) {
//                     setState(() {
//                       adminUsernameonChanged = value;
//                     });
//                   },
//                   decoration: new InputDecoration(
//                     hintText: adminUsername,
//                     fillColor: Colors.white,
//                     border: new OutlineInputBorder(
//                       borderRadius: new BorderRadius.circular(5.0),
//                       borderSide: const BorderSide(),
//                     ),
//                   )),
//             ),
//           ),
//           SizedBox(
//             width: MediaQuery.of(context).size.width / 2,
//             child: Padding(
//               padding: const EdgeInsets.all(8.0),
//               child: const Text(
//                 'Password',
//                 style: TextStyle(fontWeight: FontWeight.bold),
//               ).tr(),
//             ),
//           ),
//           Padding(
//             padding: const EdgeInsets.all(8.0),
//             child: SizedBox(
//               width: MediaQuery.of(context).size.width / 2,
//               height: 40,
//               child: TextFormField(
//                   readOnly: true,
//                   onTap: () {
//                     Fluttertoast.showToast(
//                         msg:
//                             "This is a test version you can't change the details",
//                         backgroundColor: Colors.blue.shade800,
//                         textColor: Colors.white);
//                   },
//                   obscureText: true,
//                   onChanged: (value) {
//                     setState(() {
//                       oldPasswordonChanged = value;
//                     });
//                   },
//                   decoration: new InputDecoration(
//                     fillColor: Colors.white,
//                     border: new OutlineInputBorder(
//                       borderRadius: new BorderRadius.circular(5.0),
//                       borderSide: const BorderSide(),
//                     ),
//                   )),
//             ),
//           ),
//           SizedBox(
//             width: MediaQuery.of(context).size.width / 2,
//             child: Padding(
//               padding: const EdgeInsets.all(8.0),
//               child: const Text(
//                 'New Password',
//                 style: TextStyle(fontWeight: FontWeight.bold),
//               ).tr(),
//             ),
//           ),
//           Padding(
//             padding: const EdgeInsets.all(8.0),
//             child: SizedBox(
//               width: MediaQuery.of(context).size.width / 2,
//               height: 40,
//               child: TextFormField(
//                   readOnly: true,
//                   onTap: () {
//                     Fluttertoast.showToast(
//                         msg:
//                             "This is a test version you can't change the details",
//                         backgroundColor: Colors.blue.shade800,
//                         textColor: Colors.white);
//                   },
//                   obscureText: true,
//                   onChanged: (value) {
//                     setState(() {
//                       newPassword = value;
//                     });
//                   },
//                   decoration: new InputDecoration(
//                     fillColor: Colors.white,
//                     border: new OutlineInputBorder(
//                       borderRadius: new BorderRadius.circular(5.0),
//                       borderSide: const BorderSide(),
//                     ),
//                   )),
//             ),
//           ),
//           const SizedBox(height: 40),
//           SizedBox(
//             height: 40,
//             child: ElevatedButton(
//               onPressed: () {
//                 if (oldPasswordonChanged == oldPassword) {
//                   updateAdmin();
//                 } else {
//                   Flushbar(
//                     flushbarPosition: FlushbarPosition.TOP,
//                     title: "Notification",
//                     message: "Please make sure your old password is correct!!!",
//                     duration: const Duration(seconds: 3),
//                   ).show(context);
//                 }
//               },
//               style: ElevatedButton.styleFrom(
//                   backgroundColor: Colors.blue.shade800),
//               child: const Text('Update admin profile').tr(),
//             ),
//           ),
//           const SizedBox(height: 20)
//         ],
//       ),
//     );
//   }
// }

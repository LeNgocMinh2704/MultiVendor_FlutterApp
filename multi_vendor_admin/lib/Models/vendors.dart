import 'package:cloud_firestore/cloud_firestore.dart';

class VendorsSnapshot {
  final int? totalrating;
  final int? numberOfUserRating;
  final String? phonenumber;
  final String? email;
  final String? photoUrl;
  final String? displayName;
  final String? address;

  final String? about;
  final String? id;

  VendorsSnapshot(
      {this.email,
      this.totalrating,
      this.numberOfUserRating,
      this.id,
      this.about,
      this.photoUrl,
      this.displayName,
      this.phonenumber,
      this.address});

  VendorsSnapshot.fromSnapshot(DocumentSnapshot snapshot)
      : displayName = snapshot['fullname'],
        totalrating = snapshot['totalrating'],
        numberOfUserRating = snapshot['numberOfUserRating'],
        id = snapshot['id'],
        email = snapshot['email'],
        phonenumber = snapshot['phone'],
        photoUrl = snapshot['photoUrl'],
        address = snapshot['address'],
        about = snapshot['about'];
}

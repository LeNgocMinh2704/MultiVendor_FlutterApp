class UserModel {
  final String phonenumber;
  final String uid;
  final String email;
  final String displayName;
  final String photoUrl;
  final String address;

  UserModel(
      {required this.email,
      required this.displayName,
      required this.uid,
      required this.photoUrl,
      required this.phonenumber,
      required this.address});

  UserModel.fromMap(Map<String, dynamic> data, this.uid)
      : displayName = data['fullname'],
        email = data['email'],
        photoUrl = data['photoUrl'],
        phonenumber = data['phone'],
        address = data['address'];
}

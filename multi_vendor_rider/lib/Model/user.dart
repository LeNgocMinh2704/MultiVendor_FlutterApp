class UserModel {
  final String phonenumber;
  final String uid;
  final String email;
  final String displayName;
  final String token;

  UserModel({
    required this.email,
    required this.displayName,
    required this.uid,
    required this.token,
    required this.phonenumber,
  });

  UserModel.fromMap(Map<String, dynamic> data, this.uid)
      : displayName = data['fullname'],
        email = data['email'],
        token = data['token'],
        phonenumber = data['phone'];
}

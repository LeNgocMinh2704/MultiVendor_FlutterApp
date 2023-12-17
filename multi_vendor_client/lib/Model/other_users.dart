class OtherUserModel {
  final String phonenumber;
  final String uid;
  final String email;
  final String displayName;
  final String photoUrl;
  final String address;
  final String id;
  final num? totalRating;
  final num? totalNumberOfUserRating;

  OtherUserModel(
      {required this.email,
      required this.displayName,
      required this.uid,
      required this.photoUrl,
      required this.phonenumber,
      this.totalRating,
      this.totalNumberOfUserRating,
      required this.id,
      required this.address});

  OtherUserModel.fromMap(Map<String, dynamic> data, this.uid)
      : displayName = data['fullname'],
        email = data['email'],
        photoUrl = data['photoUrl'],
        phonenumber = data['phone'],
        address = data['address'],
        id = data['id'],
        totalRating = data['totalRating'],
        totalNumberOfUserRating = data['totalNumberOfUserRating'];

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'fullname': displayName,
      'email': email,
      'phone': phonenumber,
      'photoUrl': photoUrl,
      'address': address,
      'totalRating': totalRating,
      'totalNumberOfUserRating': totalNumberOfUserRating
    };
  }
}

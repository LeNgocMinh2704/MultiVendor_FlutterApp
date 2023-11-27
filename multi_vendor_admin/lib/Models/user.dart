class UserModel {
  final String? phonenumber;
  final String? uid;
  final String? email;
  final String? photoUrl;
  final String? displayName;
  final String? address;
  final String? license;
  final bool? approval;
  final String? category;
  final String? about;
  final bool? open;
  final String? token;
  final num? earnings;
  final bool? trending;
  final num? wallet;
  final String? timeCreated;

  UserModel(
      {this.email,
      this.timeCreated,
      this.wallet,
      this.trending,
      this.open,
      this.earnings,
      this.about,
      this.category,
      this.approval,
      this.license,
      this.photoUrl,
      this.displayName,
      this.uid,
      this.token,
      this.phonenumber,
      this.address});
  bool selected = false;
  UserModel.fromMap(data, this.uid)
      : displayName = data['fullname'],
        approval = data['Approval'],
        timeCreated = data['time created'],
        earnings = data['Earnings'],
        token = data['token'],
        wallet = data['wallet'],
        trending = data['trending'],
        email = data['email'],
        phonenumber = data['phone'],
        photoUrl = data['photoUrl'],
        address = data['address'],
        license = data['License'],
        category = data['Category'],
        about = data['about'],
        open = data['open'];
}

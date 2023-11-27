class Rating {
  final String? uid;
  final String? productName;
  final String? fullname;
  final double? rating;
  final String? comment;
  final String? id;
  final String? profilePhoto;
  Rating(
      {this.fullname,
      this.profilePhoto,
      this.rating,
      this.comment,
      this.productName,
      this.uid,
      this.id});
  Map<String?, dynamic> toMap() {
    return {
      'productName': productName,
      'fullname': fullname,
      'rating': rating,
      'profilePhoto': profilePhoto,
      ' id': id,
      'comment': comment,
    };
  }

  Rating.fromMap(data, this.uid)
      : fullname = data['fullname'],
        rating = data['rating'],
        profilePhoto = data['profilePhoto'],
        id = data['id'],
        productName = data['productName'],
        comment = data['comment'];
}

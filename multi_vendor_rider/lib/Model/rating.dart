class RatingModel {
  final String review;
  final num rating;
  final String fullname;
  final String profilePicture;
  final String? uid;
  final String timeCreated;
  RatingModel(
      {required this.rating,
      required this.review,
      required this.timeCreated,
      this.uid,
      required this.fullname,
      required this.profilePicture});

  Map<String, dynamic> toMap() {
    return {
      'rating': rating,
      'review': review,
      'fullname': fullname,
      'profilePicture': profilePicture,
      'timeCreated': timeCreated
    };
  }

  RatingModel.fromMap(
    Map<String, dynamic> data,
    this.uid,
  )   : rating = data['rating'],
        timeCreated = data['timeCreated'],
        review = data['review'],
        fullname = data['fullname'],
        profilePicture = data['profilePicture'];
}

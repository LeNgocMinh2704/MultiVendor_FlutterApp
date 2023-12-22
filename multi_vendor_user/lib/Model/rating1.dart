class Rating1 {
  final String? userId;
  final String? productId;
  final double? rating;
  final String timeCreated;
  Rating1(
      {required this.rating,
      required this.timeCreated,
      required this.productId,
      required this.userId});

  Map<String, dynamic> toMap() {
    return {
      'rating': rating,
      'userId': userId,
      'productId': productId,
      'timeCreated': timeCreated
    };
  }

  Rating1.fromMap(
    Map<String, dynamic> data,
    this.userId,
  )   : rating = data['rating'],
        timeCreated = data['timeCreated'],
        productId = data['productId'];
}

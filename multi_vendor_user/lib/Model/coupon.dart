class CouponModel {
  final String coupon;
  final num percentage;
  final dynamic timeCreated;
  final String? title;

  final String uid;

  CouponModel(
      {required this.coupon,
      required this.uid,
      required this.percentage,
      this.timeCreated,
      this.title});

  CouponModel.fromMap(data, this.uid)
      : coupon = data['coupon'],
        percentage = data['percentage'],
        title = data['title'],
        timeCreated = data['timeCreated'];

  Map<String, dynamic> toMap() {
    return {
      'coupon': coupon,
      'percentage': percentage,
      'timeCreated': timeCreated,
      'title': title
    };
  }
}

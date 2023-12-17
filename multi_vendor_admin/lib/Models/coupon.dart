class CouponModel {
  final String coupon;
  final num percentage;
  final String? timeCreated;
  final String title;

  final String uid;

  CouponModel({
    required this.coupon,
    required this.uid,
    required this.percentage,
    required this.title,
    this.timeCreated,
  });

  CouponModel.fromMap(data, this.uid)
      : coupon = data['coupon'],
        title = data['title'],
        percentage = data['percentage'],
        timeCreated = data['timeCreated'];

  Map<String, dynamic> toMap() {
    return {
      'coupon': coupon,
      'title': title,
      'percentage': percentage,
      'timeCreated': timeCreated
    };
  }
}

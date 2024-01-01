class HistoryModel {
  final String message;
  final String amount;
  final String paymentSystem;
  final String? uid;
  final String timeCreated;

  HistoryModel({
    required this.message,
    required this.amount,
    required this.paymentSystem,
    required this.timeCreated,
    this.uid,
  });

  HistoryModel.fromMap(Map<String, dynamic> data, this.uid)
      : message = data['message'],
        amount = data['amount'],
        paymentSystem = data['paymentSystem'],
        timeCreated = data['timeCreated'];

  Map<String, dynamic> toMap() {
    return {
      'message': message,
      'amount': amount,
      'paymentSystem': paymentSystem,
      'timeCreated': timeCreated
    };
  }
}

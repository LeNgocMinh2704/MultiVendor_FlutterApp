class HistoryModel {
  final String message;
  final String amount;

  HistoryModel({
    required this.message,
    required this.amount,

  });

  HistoryModel.fromMap(Map<String, dynamic> data, this.uid)
      : message = data['message'],
        amount = data['amount'],

  Map<String, dynamic> toMap() {
    return {
      'message': message,
      'amount': amount,
      'paymentSystem': paymentSystem,
      'timeCreated': timeCreated
    };
  }
}

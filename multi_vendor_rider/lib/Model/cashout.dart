class CashOutModel {
  final String accountName;
  final num amount;
  final String bankName;
  final String? uid;
  final String timeCreated;
  final num accountNumber;
  final String vendorID;
  final String vendorsName;
  final String status;
  final bool paid;

  CashOutModel({
    required this.vendorID,
    required this.vendorsName,
    required this.status,
    required this.accountName,
    required this.amount,
    required this.bankName,
    required this.timeCreated,
    required this.accountNumber,
    required this.paid,
    this.uid,
  });

  CashOutModel.fromMap(Map<String, dynamic> data, this.uid)
      : accountName = data['accountName'],
        amount = data['amount'],
        vendorID = data['vendorID'],
        vendorsName = data['vendorsName'],
        bankName = data['bankName'],
        timeCreated = data['timeCreated'],
        accountNumber = data['accountNumber'],
        status = data['status'],
        paid = data['paid'];

  Map<String, dynamic> toMap() {
    return {
      'accountName': accountName,
      'amount': amount,
      'status': status,
      'vendorID': vendorID,
      'paid': paid,
      'vendorsName': vendorsName,
      'bankName': bankName,
      'timeCreated': timeCreated,
      'accountNumber': accountNumber
    };
  }
}

class CourierModel {
  final String parcelName;
  final String sendersName;
  final String sendersPhone;
  final String sendersAddress;
  final String recipientName;
  final String recipientAddress;
  final String recipientPhone;
  final String deliveryDate;
  final String deliveryBoyID;
  final String deliveryBoysName;
  final String deliveryBoysPhone;
  final String deliveryBoysAddress;
  final num weight;
  final num price;
  final num km;
  final String parcelDescription;
  final num parcelID;
  final String parcelImage;
  final String? uid;
  final String userUID;
  final bool status;
  final num comission;

  CourierModel(
      {required this.parcelName,
      required this.parcelDescription,
      required this.deliveryBoyID,
      required this.comission,
      required this.status,
      required this.parcelImage,
      required this.userUID,
      this.uid,
      required this.parcelID,
      required this.sendersName,
      required this.sendersPhone,
      required this.sendersAddress,
      required this.recipientName,
      required this.recipientAddress,
      required this.deliveryDate,
      required this.deliveryBoysName,
      required this.deliveryBoysPhone,
      required this.deliveryBoysAddress,
      required this.weight,
      required this.recipientPhone,
      required this.price,
      required this.km});

  Map<String, dynamic> toMap() {
    return {
      'comission': comission,
      'deliveryBoyID': deliveryBoyID,
      'parcelDescription': parcelDescription,
      'parcelName': parcelName,
      'status': status,
      'parcelImage': parcelImage,
      'parcelID': parcelID,
      'sendersName': sendersName,
      'sendersPhone': sendersPhone,
      'sendersAddress': sendersAddress,
      'recipientName': recipientName,
      'recipientAddress': recipientAddress,
      'deliveryDate': deliveryDate,
      'deliveryBoysName': deliveryBoysName,
      'deliveryBoysPhone': deliveryBoysPhone,
      'deliveryBoysAddress': deliveryBoysAddress,
      'weight': weight,
      'recipientPhone': recipientPhone,
      'price': price,
      'km': km,
      'userUID': userUID
    };
  }

  CourierModel.fromMap(
    Map<String, dynamic> data,
    this.uid,
  )   : parcelName = data['parcelName'],
        deliveryBoyID = data['deliveryBoyID'],
        comission = data['comission'],
        recipientPhone = data['recipientPhone'],
        parcelDescription = data['parcelDescription'],
        userUID = data['userUID'],
        parcelImage = data['parcelImage'],
        status = data['status'],
        parcelID = data['parcelID'],
        sendersName = data['sendersName'],
        sendersPhone = data['sendersPhone'],
        sendersAddress = data['sendersAddress'],
        recipientName = data['recipientName'],
        recipientAddress = data['recipientAddress'],
        deliveryDate = data['deliveryDate'],
        deliveryBoysName = data['deliveryBoysName'],
        deliveryBoysPhone = data['deliveryBoysPhone'],
        deliveryBoysAddress = data['deliveryBoysAddress'],
        weight = data['weight'],
        price = data['price'],
        km = data['km'];
}

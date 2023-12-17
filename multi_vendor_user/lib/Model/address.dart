class AddressModel {
  final String address;
  final String houseNumber;
  final String closestbusStop;
  final String id;
  final String? uid;

  AddressModel({
    required this.address,
    required this.houseNumber,
    required this.id,
    required this.closestbusStop,
    this.uid,
  });

  AddressModel.fromMap(Map<String, dynamic> data, this.uid)
      : address = data['Addresses'],
        houseNumber = data['houseNumber'],
        closestbusStop = data['closestbusStop'],
        id = data['id'];

  Map<String, dynamic> toMap() {
    return {
      'Addresses': address,
      'houseNumber': houseNumber,
      'closestbusStop': closestbusStop,
      'id': id
    };
  }
}

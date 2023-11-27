class AddressUpdate {
  final String address;

  final String uid;

  AddressUpdate({required this.address, required this.uid});

  AddressUpdate.fromMap(Map<String, dynamic> data, this.uid)
      : address = data['address'];

  Map<String, dynamic> toMap() {
    return {
      'address1': address,
    };
  }
}

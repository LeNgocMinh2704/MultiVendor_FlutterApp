class MarketModel {
  final String phonenumber;
  final String? uid;
  final String category;
  final String marketName;
  final String address;
  final String description;
  final num deliveryFee;
  final String openingTime;
  final String closingTime;
  final bool openStatus;
  final bool approval;
  final String vendorId;
  final String image1;
  final String image2;
  final String image3;
  final String timeCreated;
  final String doorDeliveryDetails;
  final String pickupDeliveryDetails;
  // final String marketID;
  final num? totalRating;
  final num? totalNumberOfUserRating;
  final num? lat;
  final num? long;

  MarketModel({
    // required this.marketID,
    required this.category,
    this.lat,
    this.long,
    this.totalRating,
    this.totalNumberOfUserRating,
    required this.doorDeliveryDetails,
    required this.pickupDeliveryDetails,
    required this.marketName,
    this.uid,
    required this.phonenumber,
    required this.address,
    required this.description,
    required this.deliveryFee,
    required this.openingTime,
    required this.closingTime,
    required this.openStatus,
    required this.approval,
    required this.vendorId,
    required this.image1,
    required this.image2,
    required this.image3,
    required this.timeCreated,
  });

  Map<String, dynamic> toMap() {
    return {
      'lat': lat,
      'long': long,
      'totalRating': totalRating,
      'totalNumberOfUserRating': totalNumberOfUserRating,
      'doorDeliveryDetails': doorDeliveryDetails,
      'pickupDeliveryDetails': pickupDeliveryDetails,
      'Market Name': marketName,
      // 'Market ID': marketID,
      'Category': category,
      'Phonenumber': phonenumber,
      'Address': address,
      'Description': description,
      'Delivery Fee': deliveryFee,
      'Opening Time': openingTime,
      'Closing Time': closingTime,
      'Open Status': openStatus,
      'Approval': approval,
      'Vendor ID': vendorId,
      'Image 1': image1,
      'Image 2': image2,
      'Image 3': image3,
      'Time Created': timeCreated
    };
  }

  MarketModel.fromMap(Map<String, dynamic> data, this.uid)
      : marketName = data['Market Name'],
        totalNumberOfUserRating = data['totalNumberOfUserRating'],
        totalRating = data['totalRating'],
        category = data['Category'],
        phonenumber = data['Phonenumber'],
        // marketID = data['Market ID'],
        doorDeliveryDetails = data['doorDeliveryDetails'],
        pickupDeliveryDetails = data['pickupDeliveryDetails'],
        address = data['Address'],
        description = data['Description'],
        deliveryFee = data['Delivery Fee'],
        openingTime = data['Opening Time'],
        closingTime = data['Closing Time'],
        openStatus = data['Open Status'],
        approval = data['Approval'],
        vendorId = data['Vendor ID'],
        image1 = data['Image 1'],
        image2 = data['Image 2'],
        image3 = data['Image 3'],
        lat = data['lat'],
        long = data['long'],
        timeCreated = data['Time Created'];
}

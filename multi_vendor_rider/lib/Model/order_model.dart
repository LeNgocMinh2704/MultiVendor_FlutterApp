class OrderModel {
  final String marketID;
  final String vendorID;
  final String userID;
  final String deliveryAddress;
  final String houseNumber;
  final String closesBusStop;
  final String deliveryBoyID;
  final String status;
  final bool accept;
  final int orderID;
  final dynamic timeCreated;
  final num total;
  final num deliveryFee;
  final bool acceptDelivery;
  final String paymentType;
  final List<Map<dynamic, dynamic>> orders;
  final String uid;

  OrderModel(
      {required this.marketID,
      required this.orderID,
      required this.orders,
      required this.uid,
      required this.acceptDelivery,
      required this.deliveryFee,
      required this.total,
      required this.vendorID,
      required this.paymentType,
      required this.userID,
      required this.timeCreated,
      required this.deliveryAddress,
      required this.houseNumber,
      required this.closesBusStop,
      required this.deliveryBoyID,
      required this.status,
      required this.accept});

  Map<String, dynamic> toMap() {
    return {
      'paymentType': paymentType,
      'marketID': marketID,
      'orderID': orderID,
      'orders': orders,
      'acceptDelivery': acceptDelivery,
      'deliveryFee': deliveryFee,
      'total': total,
      'vendorID': vendorID,
      'userID': userID,
      'timeCreated': timeCreated,
      'deliveryAddress': deliveryAddress,
      'houseNumber': houseNumber,
      'closesBusStop': closesBusStop,
      'deliveryBoyID': deliveryBoyID,
      'status': status,
      'accept': accept,
      'uid': uid
    };
  }
}

class OrderModel2 {
  final String marketID;
  final String vendorID;
  final String userID;
  final String deliveryAddress;
  final String houseNumber;
  final String closesBusStop;
  final String deliveryBoyID;
  final String status;
  final bool accept;
  final int orderID;
  final dynamic timeCreated;
  final num total;
  final String uid;
  final num deliveryFee;
  final bool acceptDelivery;
  final List<OrdersList> orders;
  final String paymentType;

  OrderModel2(
      {required this.marketID,
      required this.uid,
      required this.orderID,
      required this.orders,
      required this.acceptDelivery,
      required this.deliveryFee,
      required this.total,
      required this.vendorID,
      required this.paymentType,
      required this.userID,
      required this.timeCreated,
      required this.deliveryAddress,
      required this.houseNumber,
      required this.closesBusStop,
      required this.deliveryBoyID,
      required this.status,
      required this.accept});

  OrderModel2.fromMap(
    Map<String, dynamic> data,
    String uid,
  )   : marketID = data['marketID'],
        orderID = data['orderID'],
        orders = data['orders'],
        acceptDelivery = data['acceptDelivery'],
        deliveryFee = data['deliveryFee'],
        total = data['total'],
        vendorID = data['vendorID'],
        paymentType = data['paymentType'],
        userID = data['userID'],
        timeCreated = data['timeCreated'],
        deliveryAddress = data['deliveryAddress'],
        houseNumber = data['houseNumber'],
        closesBusStop = data['closesBusStop'],
        deliveryBoyID = data['deliveryBoyID'],
        status = data['status'],
        accept = data['accept'],
        uid = data['uid'];
}

class OrdersList {
  final String productName;
  final String selected;
  final num quantity;
  final String image;
  // final int price;
  final String category;
  final dynamic id;
  final num selectedPrice;
  final num totalRating;
  final num totalNumberOfUserRating;

  OrdersList(
      {required this.productName,
      required this.id,
      required this.selected,
      required this.image,
      // required this.price,
      required this.totalRating,
      required this.totalNumberOfUserRating,
      required this.selectedPrice,
      required this.category,
      required this.quantity});
  OrdersList.fromMap(Map<dynamic, dynamic> data)
      : productName = data['name'],
        selected = data['selected'],
        image = data['image1'],
        totalNumberOfUserRating = data['totalNumberOfUserRating'],
        totalRating = data['totalRating'],
        // price = data['newPrice'],
        quantity = data['quantity'],
        category = data['category'],
        selectedPrice = data['selectedPrice'],
        id = data['id'];
}

class ProductsModel {
  final String uid;
  final String name;
  final String category;
  final String subCategory;
  final String subSubCategory;
  final String image1;
  final String image2;
  final String image3;
  final String unitname1;
  final String unitname2;
  final String unitname3;
  final String unitname4;
  final String unitname5;
  final String unitname6;
  final String unitname7;
  final num unitPrice1;
  final num unitPrice2;
  final num unitPrice3;
  final num unitPrice4;
  final num unitPrice5;
  final num unitPrice6;
  final num unitPrice7;
  final num unitOldPrice1;
  final num unitOldPrice2;
  final num unitOldPrice3;
  final num unitOldPrice4;
  final num unitOldPrice5;
  final num unitOldPrice6;
  final num unitOldPrice7;
  final num percantageDiscount;
  final String vendorId;
  final String brandName;
  final String marketID;
  final String marketName;
  final String description;
  final String? selected;
  final num? quantity;
  final num? price;
  final num? selectedPrice;
  final String productID;
  final num totalRating;
  final num totalNumberOfUserRating;
  final String? endFlash;

  ProductsModel({
    this.endFlash,
    required this.totalRating,
    required this.totalNumberOfUserRating,
    required this.description,
    required this.marketID,
    required this.productID,
    required this.marketName,
    required this.uid,
    this.selectedPrice,
    this.selected,
    this.quantity,
    this.price,
    required this.name,
    required this.category,
    required this.subCategory,
    required this.subSubCategory,
    required this.image1,
    required this.image2,
    required this.image3,
    required this.unitname1,
    required this.unitname2,
    required this.unitname3,
    required this.unitname4,
    required this.unitname5,
    required this.unitname6,
    required this.unitname7,
    required this.unitPrice1,
    required this.unitPrice2,
    required this.unitPrice3,
    required this.unitPrice4,
    required this.unitPrice5,
    required this.unitPrice6,
    required this.unitPrice7,
    required this.unitOldPrice1,
    required this.unitOldPrice2,
    required this.unitOldPrice3,
    required this.unitOldPrice4,
    required this.unitOldPrice5,
    required this.unitOldPrice6,
    required this.unitOldPrice7,
    required this.percantageDiscount,
    required this.vendorId,
    required this.brandName,
  });
  Map<String, dynamic> toMap() {
    return {
      'endFlash': endFlash,
      'totalRating': totalRating,
      'totalNumberOfUserRating': totalNumberOfUserRating,
      'productID': productID,
      'price': price,
      'quantity': quantity,
      'selected': selected,
      'marketName': marketName,
      'marketID': marketID,
      'name': name,
      'description': description,
      'category': category,
      'subCategory': subCategory,
      'subSubCategory': subSubCategory,
      'image1': image1,
      'image2': image2,
      'selectedPrice': selectedPrice,
      'image3': image3,
      'unitname1': unitname1,
      'unitname2': unitname2,
      'unitname3': unitname3,
      'unitname4': unitname4,
      'unitname5': unitname5,
      'unitname6': unitname6,
      'unitname7': unitname7,
      'unitPrice1': unitPrice1,
      'unitPrice2': unitPrice2,
      'unitPrice3': unitPrice3,
      'unitPrice4': unitPrice4,
      'unitPrice5': unitPrice5,
      'unitPrice6': unitPrice6,
      'unitPrice7': unitPrice7,
      'unitOldPrice1': unitOldPrice1,
      'unitOldPrice2': unitOldPrice2,
      'unitOldPrice3': unitOldPrice3,
      'unitOldPrice4': unitOldPrice4,
      'unitOldPrice5': unitOldPrice5,
      'unitOldPrice6': unitOldPrice6,
      'unitOldPrice7': unitOldPrice7,
      'percantageDiscount': percantageDiscount,
      'vendorId': vendorId,
      'brandName': brandName,
    };
  }

  ProductsModel.fromMap(Map<String, dynamic> data, this.uid)
      : name = data['name'],
        endFlash = data['endFlash'],
        totalNumberOfUserRating = data['totalNumberOfUserRating'],
        totalRating = data['totalRating'],
        productID = data['productID'],
        quantity = data['quantity'],
        selectedPrice = data['selectedPrice'],
        selected = data['selected'],
        description = data['description'],
        marketName = data['marketName'],
        price = data['price'],
        marketID = data['marketID'],
        category = data['category'],
        subCategory = data['subCategory'],
        subSubCategory = data['subSubCategory'],
        image1 = data['image1'],
        image2 = data['image2'],
        image3 = data['image3'],
        unitname1 = data['unitname1'],
        unitname2 = data['unitname2'],
        unitname3 = data['unitname3'],
        unitname4 = data['unitname4'],
        unitname5 = data['unitname5'],
        unitname6 = data['unitname6'],
        unitname7 = data['unitname7'],
        unitPrice1 = data['unitPrice1'],
        unitPrice2 = data['unitPrice2'],
        unitPrice3 = data['unitPrice3'],
        unitPrice4 = data['unitPrice4'],
        unitPrice5 = data['unitPrice5'],
        unitPrice6 = data['unitPrice6'],
        unitPrice7 = data['unitPrice7'],
        unitOldPrice1 = data['unitOldPrice1'],
        unitOldPrice2 = data['unitOldPrice2'],
        unitOldPrice3 = data['unitOldPrice3'],
        unitOldPrice4 = data['unitOldPrice4'],
        unitOldPrice5 = data['unitOldPrice5'],
        unitOldPrice6 = data['unitOldPrice6'],
        unitOldPrice7 = data['unitOldPrice7'],
        percantageDiscount = data['percantageDiscount'],
        vendorId = data['vendorId'],
        brandName = data['brandName'];
}

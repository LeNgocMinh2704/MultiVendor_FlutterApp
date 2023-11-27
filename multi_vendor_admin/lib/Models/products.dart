class Products2 {
  final String? vendorsCategory;
  final String? stockString;
  final int? stock1;
  final int? stock2;
  final int? stock3;
  final int? stock4;
  final int? stock5;
  final int? stock6;
  final int? stock7;
  final String? id;
  final String? uid;
  final String? productName;
  final String? productDescription;
  final String? image1;
  final String? image2;
  final String? image3;
  final String? category;
  final String? unit1;
  final String? unit2;
  final String? unit3;
  final String? unit4;
  final String? unit5;
  final String? unit6;
  final String? unit7;
  final int? percentOff1;
  final int? percentOff2;
  final int? percentOff3;
  final int? percentOff4;
  final int? percentOff5;
  final int? percentOff6;
  final int? percentOff7;
  final int? price1;
  final int? price2;
  final int? price3;
  final int? price4;
  final int? price5;
  final int? price6;
  final int? price7;
  final int? productMRP1;
  final int? productMRP2;
  final int? productMRP3;
  final int? productMRP4;
  final int? productMRP5;
  final int? productMRP6;
  final int? productMRP7;
  final int? quantity;
  final String? selected;
  final int? selectedPrice;
  final int? subTotal;
  final String? cartID;
  final bool? deliverable;
  final String? vendorsname;
  final int? deliveryFee;
  final String? vendorsID;

  Products2({
    this.vendorsCategory,
    this.deliveryFee,
    this.vendorsID,
    this.deliverable,
    this.vendorsname,
    this.stockString,
    this.cartID,
    this.selectedPrice,
    this.subTotal,
    this.selected,
    this.quantity,
    this.stock2,
    this.stock3,
    this.stock4,
    this.stock5,
    this.stock6,
    this.stock7,
    this.stock1,
    this.unit1,
    this.unit2,
    this.unit3,
    this.unit4,
    this.unit5,
    this.unit6,
    this.unit7,
    this.percentOff1,
    this.percentOff2,
    this.percentOff3,
    this.percentOff4,
    this.percentOff5,
    this.percentOff6,
    this.percentOff7,
    this.price1,
    this.price2,
    this.price3,
    this.price4,
    this.price5,
    this.price6,
    this.price7,
    this.productMRP1,
    this.productMRP2,
    this.productMRP3,
    this.productMRP4,
    this.productMRP5,
    this.productMRP6,
    this.productMRP7,
    this.id,
    this.category,
    this.productName,
    this.productDescription,
    this.image1,
    this.image2,
    this.image3,
    this.uid,
  });
  Map<String, dynamic> toMap() {
    return {
      'vendorsCategory': vendorsCategory,
      'vendorsID': vendorsID,
      'Delivery Fee': deliveryFee,
      'vendorsname': vendorsname,
      'deliverable': deliverable,
      'stockString?': stockString,
      'cartID': cartID,
      'subTotal': subTotal,
      'selectedPrice': selectedPrice,
      'selected': selected,
      'quantity': quantity,
      'stock1': stock1,
      'stock2': stock2,
      'stock3': stock3,
      'stock4': stock4,
      'stock5': stock5,
      'stock6': stock6,
      'stock7': stock7,
      'price1': price1,
      'price2': price2,
      'price3': price3,
      'price4': price4,
      'price5': price5,
      'price6': price6,
      'price7': price7,
      'unit1': unit1,
      'unit2': unit2,
      'unit3': unit3,
      'unit4': unit4,
      'unit5': unit5,
      'unit6': unit6,
      'unit7': unit7,
      'percentOff1': percentOff1,
      'percentOff2': percentOff2,
      'percentOff3': percentOff3,
      'percentOff4': percentOff4,
      'percentOff5': percentOff5,
      'percentOff6': percentOff6,
      'percentOff7': percentOff7,
      'productMRP1': productMRP1,
      'productMRP2': productMRP2,
      'productMRP3': productMRP3,
      'productMRP4': productMRP4,
      'productMRP5': productMRP5,
      'productMRP6': productMRP6,
      'productMRP7': productMRP7,
      'image1': image1,
      'image2': image2,
      'image3': image3,
      'description': productDescription,
      'productName': productName,
      'id': id,
      'category': category,
    };
  }

  Products2.fromMap(Map<String?, dynamic> data, this.uid)
      : stock1 = data['stock1'],
        vendorsCategory = data['vendorsCategory'],
        deliverable = data['deliverable'],
        deliveryFee = data['Delivery Fee'],
        vendorsID = data['vendorsID'],
        stock2 = data['stock2'],
        cartID = data['cartID'],
        stockString = data['stockString'],
        subTotal = data['subTotal'],
        selectedPrice = data['selectedPrice'],
        stock3 = data['stock3'],
        stock4 = data['stock4'],
        selected = data['selected'],
        vendorsname = data['vendorsname'],
        stock5 = data['stock5'],
        stock6 = data['stock6'],
        stock7 = data['stock7'],
        category = data['category'],
        id = data['id'],
        quantity = data['quantity'],
        image1 = data['image1'],
        image2 = data['image2'],
        image3 = data['image3'],
        productDescription = data['description'],
        productName = data['productName'],
        percentOff1 = data['percentOff1'],
        percentOff2 = data['percentOff2'],
        percentOff3 = data['percentOff3'],
        percentOff4 = data['percentOff4'],
        percentOff5 = data['percentOff5'],
        percentOff6 = data['percentOff6'],
        percentOff7 = data['percentOff7'],
        unit1 = data['unit1'],
        unit2 = data['unit2'],
        unit3 = data['unit3'],
        unit4 = data['unit4'],
        unit5 = data['unit5'],
        unit6 = data['unit6'],
        unit7 = data['unit7'],
        price1 = data['price1'],
        price2 = data['price2'],
        price3 = data['price3'],
        price4 = data['price4'],
        price5 = data['price5'],
        price6 = data['price6'],
        price7 = data['price7'],
        productMRP1 = data['productMRP1'],
        productMRP2 = data['productMRP2'],
        productMRP3 = data['productMRP3'],
        productMRP4 = data['productMRP4'],
        productMRP5 = data['productMRP5'],
        productMRP6 = data['productMRP6'],
        productMRP7 = data['productMRP7'];
}

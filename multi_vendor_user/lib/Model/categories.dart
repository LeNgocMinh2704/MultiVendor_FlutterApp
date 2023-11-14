class CategoriesModel {
  final String? uid;

  final String category;
  final String image;
  final String houseNumber;
  final String closestbusStop;
  final String id;
  final String? uid;
  
  CategoriesModel({
    required this.category,
    this.uid,
    required this.image,
  });
  Map<String, dynamic> toMap() {
    return {
      'category': category,
      'image': image,
    };
  }

  CategoriesModel.fromMap(data, this.uid)
      : category = data['category'],
        image = data['image'];
}

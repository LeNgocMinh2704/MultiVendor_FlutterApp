class SubCategoriesCollectionsModel {
  final String? uid;
  final String? id;
  final String category;
  final String name;
  final String subCategory;
  final String image;
  SubCategoriesCollectionsModel(
      {required this.category,
      this.uid,
      required this.subCategory,
      required this.image,
      this.id,
      required this.name});
  Map<String, dynamic> toMap() {
    return {
      'category': category,
      'image': image,
      'id': id,
      'name': name,
      'sub-category': subCategory
    };
  }

  SubCategoriesCollectionsModel.fromMap(data, this.uid)
      : category = data['category'],
        image = data['image'],
        name = data['name'],
        id = data['id'],
        subCategory = data['sub-category'];
}

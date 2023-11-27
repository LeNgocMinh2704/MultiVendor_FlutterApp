class FeedsModel {
  final String? uid;
  final String category;
  final String subCategoryCollections;
  final String subCategory;
  final String image;
  final String title;
  final String detail;
  final bool? slider;
  FeedsModel(
      {required this.category,
      this.uid,
      this.slider,
      required this.title,
      required this.detail,
      required this.subCategory,
      required this.image,
      required this.subCategoryCollections});
  Map<String, dynamic> toMap() {
    return {
      'category': category,
      'image': image,
      'sub-category-collections': subCategoryCollections,
      'sub-category': subCategory,
      'slider': slider,
      'title': title,
      'detail': detail
    };
  }

  FeedsModel.fromMap(data, this.uid)
      : category = data['category'],
        image = data['image'],
        subCategoryCollections = data['sub-category-collections'],
        subCategory = data['sub-category'],
        slider = data['slider'],
        title = data['title'],
        detail = data['detail'];
}

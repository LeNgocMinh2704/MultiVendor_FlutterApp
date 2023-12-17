class SliderImage {
  final String? title;
  final String? image;
  final String? uid;

  SliderImage({this.image, this.title, this.uid});
  Map<String, dynamic> toMap() {
    return {'tittle': title, 'image': image, 'id': uid};
  }

  SliderImage.fromMap(data, this.uid)
      : title = data['title'],
        image = data['image'];
}

class CitiesModel {
  final String? uid;
  final String cityName;
  final String image;

  CitiesModel({this.uid, required this.cityName, required this.image});
  Map<String, dynamic> toMap() {
    return {
      'cityName': cityName,
      'image': image,
    };
  }

  CitiesModel.fromMap(data, this.uid)
      : cityName = data['cityName'],
        image = data['image'];
}

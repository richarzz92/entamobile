class OfficeModel {
  double? latitude, longitude;
  String? name;

  OfficeModel({this.name, this.latitude, this.longitude});

  OfficeModel.fromList(List<dynamic> map) {
    name = map[0];
    latitude = double.parse(map[1].toString());
    longitude = double.parse(map[2].toString());
  }
}

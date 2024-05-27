class HistoryModel {
  String? date, time, type, status, latitude, longitude, imageUrl, note;

  HistoryModel(this.date, this.time, this.type, this.status, this.latitude,
      this.longitude, this.imageUrl, this.note);

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{};
    map['date'] = date;
    map['time'] = time;
    map['type'] = type;
    map['status'] = status;
    map['latitude'] = latitude;
    map['longitude'] = longitude;
    map['imageUrl'] = imageUrl;
    map['note'] = note;

    return map;
  }

  HistoryModel.fromMap(Map<String, dynamic> map) {
    date = map['date'];
    time = map['time'];
    type = map['type'];
    status = map['status'];
    latitude = map['latitude'];
    longitude = map['longitude'];
    imageUrl = map['imageUrl'];
    note = map['note'];
  }
}

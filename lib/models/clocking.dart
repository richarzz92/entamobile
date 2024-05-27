import 'package:flutter/material.dart';

class ClockingHistoryModel {
  late DateTime date;
  String? time, type, status, imageUrl, note, group;
  double? latitude, longitude;
  String queryString = '';
  Color? statusColor;

  ClockingHistoryModel.fromList(List<dynamic> map) {
    date = DateTime.parse(map[0]);
    time = map[1];
    type = map[2];
    status = map[3].toUpperCase();
    if (status == 'APPROVED') {
      statusColor = Colors.green;
    } else if (status == 'REJECTED') {
      statusColor = Colors.red;
    } else {
      statusColor = Colors.blue;
    }
    if (map[4] == 'null' || map[4] == null) {
      latitude = null;
      longitude = null;
    } else {
      latitude = double.parse(map[4].toString());
      longitude = double.parse(map[5].toString());
    }
    List<String> arrImage = map[6].split('?');
    imageUrl = arrImage[0];
    if (arrImage.asMap().containsKey(1)) {
      queryString = "?${arrImage[1]}";
    }
    // imageUrl = map[6];
    note = map[7] ?? '-';
    if (map.asMap().containsKey(8)) {
      group = map[8];
    } else {
      group = '??';
    }
  }
}

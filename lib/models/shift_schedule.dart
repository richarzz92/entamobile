import 'package:flutter/material.dart';

class ShiftScheduleModel {
  int? id, employeeId;
  DateTime? date;
  String? code;
  TimeOfDay? timeIn, timeOut;
  DateTime? dateTimeIn, dateTimeOut;
  late int maxOT;

  ShiftScheduleModel.fromList(List<dynamic> map, int otMaxMinutes) {
    date = DateTime.parse(map[0]);
    employeeId = int.parse(map[1].toString());
    id = int.parse(map[2].toString());
    code = map[3];
    if (map[3] != 'OFF') {
      maxOT = otMaxMinutes;
    } else {
      maxOT = 999999;
    }
    dateTimeIn = DateTime.parse("${map[0]} ${map[4]}");
    dateTimeOut = DateTime.parse("${map[0]} ${map[5]}");
    timeIn = TimeOfDay(hour: dateTimeIn!.hour, minute: dateTimeIn!.minute);
    timeOut = TimeOfDay(hour: dateTimeOut!.hour, minute: dateTimeOut!.minute);
  }
}

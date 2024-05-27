import 'package:flutter/material.dart';

class OvertimeHistoryModel {
  String? code, employeeName, status;
  int? employeeId;
  Color? statusColor;
  DateTime? startDate, endDate;
  List<OvertimeApproverModel> approver = [];
  List<OvertimeDetailModel> detail = [];
  OvertimeHistoryModel.fromList(List<dynamic> map) {
    code = map[0];
    employeeId = map[1];
    employeeName = map[2];
    startDate = DateTime.parse(map[3]);
    endDate = DateTime.parse(map[4]);
    status = map[5].toUpperCase();
    if (status == 'APPROVED') {
      statusColor = Colors.green;
    } else if (status == 'REJECTED') {
      statusColor = Colors.red;
    } else {
      statusColor = Colors.blue;
    }
    approver.clear();
    detail.clear();
    for (var data in map[6]) {
      approver.add(OvertimeApproverModel.fromList(data));
    }
    for (var data in map[7]) {
      detail.add(OvertimeDetailModel.fromList(data));
    }
  }
}

class OvertimeApproverModel {
  String? employeeName, level, remark, status;
  Color? statusColor;
  OvertimeApproverModel.fromList(List<dynamic> map) {
    employeeName = map[0];
    level = map[1].toString();
    remark = map[2] ?? '-';
    status = map[3].toUpperCase();
    if (status == 'APPROVED') {
      statusColor = Colors.green;
    } else if (status == 'REJECTED') {
      statusColor = Colors.red;
    } else {
      statusColor = Colors.blue;
    }
  }
}

class OvertimeDetailModel {
  DateTime? shiftDate;
  int? shiftTypeId;
  late String totalOT;
  String? shiftName, shiftTimeIn, shiftTimeOut;
  DateTime? beforeInDate, beforeOutDate, afterInDate, afterOutDate;

  OvertimeDetailModel.fromList(List<dynamic> map) {
    shiftDate = DateTime.parse(map[0]);
    shiftTypeId = int.parse(map[1].toString());
    shiftName = map[2];
    shiftTimeIn = map[3];
    shiftTimeOut = map[4];
    totalOT = map[5].toString();
    if (map[6] != null || map[7] != null) {
      beforeInDate = DateTime.parse("${map[6]} ${map[7]}");
    }
    if (map[8] != null || map[9] != null) {
      beforeOutDate = DateTime.parse("${map[8]} ${map[9]}");
    }
    if (map[10] != null || map[11] != null) {
      afterInDate = DateTime.parse("${map[10]} ${map[11]}");
    }
    if (map[12] != null || map[13] != null) {
      afterOutDate = DateTime.parse("${map[12]} ${map[13]}");
    }
  }
}

import 'package:flutter/material.dart';

class LeaveHistoryModel {
  String? code, status, leaveType, remark, submittedBy;
  Color? statusColor;
  DateTime? startDate, endDate, submittedAt;
  List<DateTime> leaveDate = [];
  double? totalLeave;
  List<OvertimeApproverModel> approver = [];

  LeaveHistoryModel.fromList(List<dynamic> map) {
    code = map[0];
    startDate = DateTime.parse(map[1]);
    endDate = DateTime.parse(map[2]);
    leaveType = map[3];
    leaveDate.clear();
    for (var data in map[4]) {
      leaveDate.add(DateTime.parse(data.replaceAll(' ', '')));
    }
    totalLeave = double.parse(map[5].toString());
    remark = map[6];
    status = map[7].toUpperCase();
    if (status == 'APPROVED') {
      statusColor = Colors.green;
    } else if (status == 'REJECTED') {
      statusColor = Colors.red;
    } else {
      statusColor = Colors.blue;
    }
    submittedBy = map[8];
    submittedAt = DateTime.parse(map[9]);
    approver.clear();
    for (var data in map[10]) {
      approver.add(OvertimeApproverModel.fromList(data));
    }
  }
}

class OvertimeApproverModel {
  String? employeeName, level, remark, status;
  Color? statusColor;
  OvertimeApproverModel.fromList(List<dynamic> map) {
    employeeName = map[0];
    level = map[1].toString();
    remark = map[2] ?? "-";
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

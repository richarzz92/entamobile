import 'package:enta_mobile/models/employee.dart';
import 'package:enta_mobile/models/general.dart';
import 'package:flutter/material.dart';

class OvertimeRequestModel {
  GeneralModel? type;
  DateTime? startDate, endDate;
  List<OvertimeEmployeeRequestModel?>? employeeList = [];

  OvertimeRequestModel(
      {this.type, this.startDate, this.endDate, this.employeeList});

  OvertimeRequestModel.fromMap(Map<String, dynamic> map) {
    type = map['type'];
    startDate = map['start_date'];
    endDate = map['end_date'];
  }
}

class OvertimeEmployeeRequestModel {
  int id;
  EmployeeModel? employee;
  List<OvertimeDateRequestModel?>? date = [];
  OvertimeEmployeeRequestModel({required this.id, this.employee, this.date});
}

class OvertimeDateRequestModel {
  DateTime? date;
  DateTime? beforeIn, beforeOut, afterIn, afterOut;
  // TimeOfDay beforeIn, beforeOut, afterIn, afterOut;
  OvertimeDateRequestModel(
      {this.date, this.beforeIn, this.beforeOut, this.afterIn, this.afterOut});
}

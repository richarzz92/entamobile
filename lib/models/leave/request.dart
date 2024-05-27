import 'package:enta_mobile/models/employee.dart';
import 'package:enta_mobile/models/general.dart';
import 'package:flutter/material.dart';

class LeaveRequestModel {
  GeneralModel? type;
  GeneralModel? durationType;
  GeneralModel? leaveTypeGroup;
  GeneralModel? leaveType;
  DateTime? startDate, endDate;
  List<LeaveEmployeeRequestModel?>? employeeList = [];

  LeaveRequestModel(
      {this.type,
      this.durationType,
      this.leaveTypeGroup,
      this.leaveType,
      this.startDate,
      this.endDate,
      this.employeeList});
}

class LeaveEmployeeRequestModel {
  int id;
  EmployeeModel? employee;
  List<LeaveDateRequestModel?>? date = [];
  LeaveEmployeeRequestModel({required this.id, this.employee, this.date});
}

class LeaveDateRequestModel {
  DateTime? date;
  LeaveDateRequestModel({this.date});
}

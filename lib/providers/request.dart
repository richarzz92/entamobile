import 'dart:developer';

import 'package:enta_mobile/models/general.dart';
import 'package:enta_mobile/utils/data.dart';
import 'package:flutter/material.dart';

import '../models/overtime/request.dart';
import '../models/leave/request.dart';
import '../utils/functions.dart';

class RequestState with ChangeNotifier {
  RequestState();
  OvertimeRequestModel overTimeRequest = OvertimeRequestModel(
      type: GeneralModel(id: 1, label: 'Self'),
      employeeList: [],
      startDate: null,
      endDate: null);
  List<OvertimeRequestModel> overTimeRequestList = [];

  LeaveRequestModel leaveRequest = LeaveRequestModel(
      type: GeneralModel(id: 1, label: 'Self'),
      durationType: UIData.durationLeaveType[0],
      leaveTypeGroup: null,
      leaveType: null,
      employeeList: [],
      startDate: null,
      endDate: null);
  List<LeaveRequestModel> leaveRequestList = [];
  double totalLeave = 0;
  bool isSelectedAll = false;

  // OVERTIME
  void resetOvertimeRequest() {
    overTimeRequest = OvertimeRequestModel(
        type: GeneralModel(id: 1, label: 'Self'),
        employeeList: [],
        startDate: null,
        endDate: null);
    notifyListeners();
  }

  void updateOvertimeRequestFor({required GeneralModel type}) {
    if (type.id == 1) {
      overTimeRequest.employeeList!.clear();
    }
    overTimeRequest.type = type;

    notifyListeners();
  }

  void updateOvertimeRequestEmployeeDate(
      {OvertimeDateRequestModel? dateRequest,
      OvertimeEmployeeRequestModel? employee}) {
    var x = overTimeRequest.employeeList!.indexWhere((e) => e!.id == employee!.id);
    if (x >= 0) {
      var y = overTimeRequest.employeeList![x]!.date!
          .indexWhere((e) => e!.date == dateRequest!.date);
      if (y >= 0) {
        overTimeRequest.employeeList![x]!.date![y] = dateRequest;
      } else {
        overTimeRequest.employeeList![x]!.date!.add(dateRequest);
      }
    }
    notifyListeners();
  }

  void updateOvertimeRequestEmployee(
      {required List<OvertimeEmployeeRequestModel> employee}) {
    overTimeRequest.employeeList!.clear();
    overTimeRequest.employeeList!.addAll(employee);
    notifyListeners();
  }

  void updateOvertimeRequestAddEmployee(
      {OvertimeEmployeeRequestModel? employee}) {
    if (overTimeRequest.employeeList!.isEmpty) {
      overTimeRequest.employeeList!.add(employee);
    }
    notifyListeners();
  }

  void updateOvertimeRequestSchedule({required DateTimeRange schedule}) {
    overTimeRequest.startDate = schedule.start;
    overTimeRequest.endDate = schedule.end;
    notifyListeners();
  }

  void removeOvertimeRequestEmployee({int? id}) {
    overTimeRequest.employeeList!.removeWhere((element) => element!.id == id);

    notifyListeners();
  }

  void addOvertimeRequestEmployeeDate(
      {OvertimeEmployeeRequestModel? data, DateTime? date}) {
    var x = overTimeRequest.employeeList!.indexWhere((e) => e!.id == data!.id);
    if (x >= 0) {
      var y = overTimeRequest.employeeList![x]!.date!
          .indexWhere((e) => e!.date == date);
      if (y < 0) {
        overTimeRequest.employeeList![x]!.date!.add(OvertimeDateRequestModel(
            date: date,
            beforeIn: null,
            beforeOut: null,
            afterIn: null,
            afterOut: null));
      } else {
        overTimeRequest.employeeList![x]!.date!.removeWhere((e) => e!.date == date);
      }
    }
    notifyListeners();
  }

  bool checkOvertimeRequestEmployeeDate(
      {OvertimeEmployeeRequestModel? data, DateTime? date}) {
    var x = overTimeRequest.employeeList!.indexWhere((e) => e!.id == data!.id);
    if (x >= 0) {
      var y = overTimeRequest.employeeList![x]!.date!
          .indexWhere((e) => e!.date == date);
      if (y < 0) {
        return false;
      } else {
        return true;
      }
    } else {
      return false;
    }
  }

  OvertimeDateRequestModel? detailOvertimeRequestEmployeeDate(
      {OvertimeEmployeeRequestModel? data, DateTime? date}) {
    OvertimeDateRequestModel? searchItem;
    var x = overTimeRequest.employeeList!.indexWhere((e) => e!.id == data!.id);
    if (x >= 0) {
      searchItem = overTimeRequest.employeeList![x]!.date!
          .firstWhere((e) => e!.date == date, orElse: () => null);
    }
    return searchItem;
  }

  // LEAVE
  void resetLeaveRequest() {
    leaveRequest = LeaveRequestModel(
        type: GeneralModel(id: 1, label: 'Self'),
        durationType: UIData.durationLeaveType[0],
        leaveTypeGroup: null,
        leaveType: null,
        employeeList: [],
        startDate: null,
        endDate: null);
    notifyListeners();
  }

  void updateLeaveRequestFor({required GeneralModel type}) {
    if (type.id == 1) {
      leaveRequest.employeeList!.clear();
    }
    leaveRequest.type = type;

    notifyListeners();
  }

  void updateLeaveRequestDuration({required GeneralModel durationType}) {
    leaveRequest.durationType = durationType;
    log("Update Leave Duration ${durationType.id}");
    notifyListeners();
  }

  void updateLeaveRequestEmployeeDate(
      {LeaveDateRequestModel? dateRequest, LeaveEmployeeRequestModel? employee}) {
    var x = leaveRequest.employeeList!.indexWhere((e) => e!.id == employee!.id);
    if (x >= 0) {
      var y = leaveRequest.employeeList![x]!.date!
          .indexWhere((e) => e!.date == dateRequest!.date);
      if (y >= 0) {
        leaveRequest.employeeList![x]!.date![y] = dateRequest;
      } else {
        leaveRequest.employeeList![x]!.date!.add(dateRequest);
      }
    }
    notifyListeners();
  }

  void updateLeaveRequestEmployee({required List<LeaveEmployeeRequestModel> employee}) {
    leaveRequest.employeeList!.clear();
    leaveRequest.employeeList!.addAll(employee);
    notifyListeners();
  }

  void updateLeaveRequestAddEmployee({LeaveEmployeeRequestModel? employee}) {
    if (leaveRequest.employeeList!.isEmpty) {
      leaveRequest.employeeList!.add(employee);
    }
    notifyListeners();
  }

  void updateLeaveRequestSchedule({required DateTimeRange schedule}) {
    leaveRequest.startDate = schedule.start;
    leaveRequest.endDate = schedule.end;
    log("Update Start Date End Date to ${schedule.start} - ${schedule.end}");
    totalLeaveRequestEmployee();
    notifyListeners();
  }

  void totalLeaveRequestEmployee() {
    log(leaveRequest.durationType!.id.toString());
    if (leaveRequest.durationType!.id != 0) {
      totalLeave = 0.5;
    } else {
      totalLeave = 0;
      List<DateTime> dateList = UIFunction.getDaysInBetween(
        startDate: leaveRequest.startDate!,
        endDate: leaveRequest.endDate!,
      );
      for (var e in dateList) {
        log(e.toString());
        log("tanggal");
        var check = leaveRequest.employeeList![0]!.date!
            .firstWhere((element) => element!.date == e, orElse: () => null);
        if (check != null) {
          totalLeave = totalLeave + 1;
        }
      }
    }

    notifyListeners();
  }

  void removeLeaveRequestEmployee({int? id}) {
    leaveRequest.employeeList!.removeWhere((element) => element!.id == id);

    notifyListeners();
  }

  void addLeaveRequestEmployeeDate2(
      {LeaveEmployeeRequestModel? data, DateTime? date}) {
    var x = leaveRequest.employeeList!.indexWhere((e) => e!.id == data!.id);
    if (x >= 0) {
      var y =
          leaveRequest.employeeList![0]!.date!.indexWhere((e) => e!.date == date);
      if (y < 0) {
        leaveRequest.employeeList![0]!.date!.add(LeaveDateRequestModel(
          date: date,
        ));
      }
    }
    totalLeaveRequestEmployee();
    notifyListeners();
  }

  void getIsSelectedAll() {
    bool check = true;
    if (leaveRequest.startDate != null) {
      List<DateTime> dateList = UIFunction.getDaysInBetween(
        startDate: leaveRequest.startDate!,
        endDate: leaveRequest.endDate!,
      );
      for (var a in leaveRequest.employeeList!) {
        for (var e in dateList) {
          var search = a!.date!
              .firstWhere((element) => element!.date == e, orElse: () => null);
          if (search != null) {
          } else {
            check = false;
          }
        }
      }
      isSelectedAll = check;
    } else {
      isSelectedAll = check;
    }
    notifyListeners();
  }

  void resetSelectedLeaveDate() {
    leaveRequest.employeeList![0]!.date!.clear();
    totalLeave = 0;
    notifyListeners();
  }

  void toggleSelectAllLeaveDate() {
    if (isSelectedAll) {
      leaveRequest.employeeList![0]!.date!.clear();
    } else {
      List<DateTime> dateList = UIFunction.getDaysInBetween(
        startDate: leaveRequest.startDate!,
        endDate: leaveRequest.endDate!,
      );
      for (var a in leaveRequest.employeeList!) {
        for (var e in dateList) {
          var search = a!.date!
              .firstWhere((element) => element!.date == e, orElse: () => null);
          if (search != null) {
          } else {
            leaveRequest.employeeList![0]!.date!.add(LeaveDateRequestModel(
              date: e,
            ));
          }
        }
      }
    }
    getIsSelectedAll();
    totalLeaveRequestEmployee();
    notifyListeners();
  }

  void addLeaveRequestEmployeeDate(
      {LeaveEmployeeRequestModel? data, DateTime? date}) {
    var x = leaveRequest.employeeList!.indexWhere((e) => e!.id == data!.id);
    if (x >= 0) {
      var y =
          leaveRequest.employeeList![0]!.date!.indexWhere((e) => e!.date == date);
      if (y < 0) {
        leaveRequest.employeeList![0]!.date!.add(LeaveDateRequestModel(
          date: date,
        ));
      } else {
        log("remove");
        leaveRequest.employeeList![0]!.date!.removeWhere((e) => e!.date == date);
      }
    }
    getIsSelectedAll();
    totalLeaveRequestEmployee();
    notifyListeners();
  }

  bool checkLeaveRequestEmployeeDate(
      {LeaveEmployeeRequestModel? data, DateTime? date}) {
    var x = leaveRequest.employeeList!.indexWhere((e) => e!.id == data!.id);
    if (x >= 0) {
      var y =
          leaveRequest.employeeList![x]!.date!.indexWhere((e) => e!.date == date);
      if (y < 0) {
        return false;
      } else {
        return true;
      }
    } else {
      return false;
    }
  }

  LeaveDateRequestModel? detailLeaveRequestEmployeeDate(
      {LeaveEmployeeRequestModel? data, DateTime? date}) {
    LeaveDateRequestModel? searchItem;
    var x = leaveRequest.employeeList!.indexWhere((e) => e!.id == data!.id);
    if (x >= 0) {
      searchItem = leaveRequest.employeeList![x]!.date!
          .firstWhere((e) => e!.date == date, orElse: () => null);
    }
    return searchItem;
  }
}

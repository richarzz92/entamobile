import 'dart:developer';

import 'package:collection/collection.dart' show IterableExtension;
import 'package:enta_mobile/models/auth.dart';
import 'package:enta_mobile/models/general.dart';
import 'package:enta_mobile/models/office.dart';
import 'package:enta_mobile/models/shift_schedule.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';

import '../models/clocking.dart';
import '../models/leave/history.dart';
import '../models/overtime/history.dart';
import '../models/response_api.dart';
import '../utils/functions.dart';
import '../utils/url.dart';

class DeviceState with ChangeNotifier {
  DeviceState();
  PermissionStatus? permissionCamera, permissionStorage, permissionLocation;
  String? server, deviceId;
  int? validationCode = 0;
  int? leaveGroupCode = 0;
  int? shiftScheduleCode = 0;
  int? leaveBalanceCode = 0;
  int? codeOvertimeHistory = 0;
  int? codeLeaveHistory = 0;
  int? codeClockingHistory = 0;
  int? employeeId;
  double? leaveBalance;

  String? authToken, employeeName = '-';
  AuthModel? myAuth;
  List<OfficeModel>? officeList = [];
  List<GeneralModel> leaveTypeGroup = [];
  List<ShiftScheduleModel> shiftSchedule = [];
  List<OvertimeHistoryModel> overtimeHistoryList = [];
  List<LeaveHistoryModel> leaveHistoryList = [];
  List<ClockingHistoryModel> clockingHistoryList = [];
  List<GeneralModel> leaveTypeList = [];
  List<GeneralModel> workFromStatusList = [];
  List<String> workFromStatusLabels = [];
  List<String> extFile = [];
  int maxSizeFile = 0;
  double maxRadius = 0;
  String companyName = "", companyLogoUrl = "";
  double logoHeight = 0.4;
  bool clockingAccess = false;
  bool otAccess = false;
  bool lvAccess = false;
  bool loadingValidation = true;
  bool loadingLeaveGroup = true;
  bool loadingShiftSchedule = true;
  bool loadingLeaveBalance = false;
  bool loadingOvertimeHistory = true;
  bool loadingLeaveHistory = true;
  bool loadingClockingHistory = true;
  String msgValidation = '';
  String msgOvertimeHistory = '';
  String msgLeaveHistory = '';
  String msgClockingHistory = '';
  double? myLat, myLong;
  int otMaxMinutes = 999999; // by default

  Future<void> requestPermission({required Permission hardware}) async {
    PermissionStatus resultPermission = await hardware.request();
    if (hardware == Permission.camera) {
      permissionCamera = resultPermission;
    } else if (hardware == Permission.storage) {
      permissionStorage = resultPermission;
    } else if (hardware == Permission.locationWhenInUse) {
      permissionLocation = resultPermission;
    }
    notifyListeners();
  }

  void setDevicedId({String? id}) {
    deviceId = id;
    notifyListeners();
  }

  void setMyAuth({AuthModel? data}) {
    myAuth = data;
    notifyListeners();
  }

  void setMyOffice({List<OfficeModel>? data}) {
    officeList = data;
    notifyListeners();
  }

  void setMyLocation({double? latitude, double? longitude}) {
    myLat = latitude;
    myLong = longitude;
    notifyListeners();
  }

  String? getInfoSchedule({int? employeeId, DateTime? date}) {
    var x = shiftSchedule.firstWhereOrNull(
        (e) => e.date == date && e.employeeId == employeeId);
    if (x != null) {
      return "${x.code} (${DateFormat('HH:mm', 'id').format(x.dateTimeIn!)} - ${DateFormat('HH:mm', 'id').format(x.dateTimeOut!)})";
    } else {
      return null;
    }
  }

  ShiftScheduleModel? getDetailSchedule({int? employeeId, DateTime? date}) {
    var x = shiftSchedule.firstWhereOrNull(
        (e) => e.date == date && e.employeeId == employeeId);
    if (x != null) {
      return x;
    } else {
      return null;
    }
  }

  Future<ResponseAPI> actionCallAPI({
    bool isRefresh = false,
    String? method,
    required Uri uri,
    required String prefix,
    dynamic formData,
  }) async {
    if (uri.path == prefix + UIUrl.checkToken) {
      loadingValidation = true;
    } else if (uri.path == prefix + UIUrl.leaveTypeGroup) {
      loadingLeaveGroup = true;
    } else if (uri.path == prefix + UIUrl.shiftSchedule) {
      loadingShiftSchedule = true;
    } else if (uri.path == prefix + UIUrl.leaveBalance) {
      loadingLeaveBalance = true;
    } else if (uri.path == prefix + UIUrl.overtimeHistory) {
      log("Reset Overtime History");
      loadingOvertimeHistory = true;
      overtimeHistoryList.clear();
    } else if (uri.path == prefix + UIUrl.leaveHistory) {
      log("Reset Leave History");
      loadingLeaveHistory = true;
      leaveHistoryList.clear();
    } else if (uri.path == prefix + UIUrl.clockingHistory) {
      log("Reset Clocking History");
      loadingClockingHistory = true;
      clockingHistoryList.clear();
    }
    notifyListeners();
    ResponseAPI result;

    result = await UIFunction.callAPIDIO(
        method: method,
        url: uri.toString(),
        formData: formData,
        isToken: uri.path == prefix + UIUrl.checkToken ? true : false);

    if (uri.path == prefix + UIUrl.checkToken) {
      loadingValidation = false;
      validationCode = result.code;

      if (result.success) {
        employeeId = int.parse(result.data[0].toString());
        employeeName = result.data[1].toString();
        officeList!.clear();
        extFile.clear();
        workFromStatusList.clear();
        workFromStatusLabels.clear();
        if (result.data[2] != null) {
          for (var company in result.data[2]) {
            officeList!.add(OfficeModel.fromList(company));
          }
        }
        maxSizeFile = int.parse(result.data[3].toString()) * 1024;
        if (result.data[4] != null) {
          for (var ext in result.data[4]) {
            extFile.add('.$ext');
          }
        }
        maxRadius = double.parse(result.data[5].toString());
        companyName = result.data[6].toString();
        companyLogoUrl = result.data[7].toString();
        for (var access in result.data[8]) {
          if (access[0] == "AttAccess") {
            if (access[1] == 1) {
              clockingAccess = true;
            } else {
              clockingAccess = false;
            }
          } else if (access[0] == "OtAccess") {
            if (access[1] == 1) {
              otAccess = true;
            } else {
              otAccess = false;
            }
          } else if (access[0] == "LvAccess") {
            if (access[1] == 1) {
              lvAccess = true;
            } else {
              lvAccess = false;
            }
          }
        }
        if (result.data.asMap().containsKey(9)) {
          logoHeight = double.parse(result.data[9].toString());
        }
        if (result.data.asMap().containsKey(10)) {
          otMaxMinutes = int.parse(result.data[10].toString());
        }
        if (result.data.asMap().containsKey(11)) {
          for (var wfs in result.data[11]) {
            workFromStatusList.add(GeneralModel(
              code: wfs[0].toString(),
              label: wfs[1].toString()
            ));
            workFromStatusLabels.add(wfs[1].toString());
          }
        }
      } else {
        msgValidation = result.message;
      }
    } else if (uri.path == prefix + UIUrl.leaveTypeGroup) {
      loadingLeaveGroup = false;
      leaveGroupCode = result.code;
      leaveTypeGroup.clear();
      leaveTypeList.clear();
      leaveTypeList.add(GeneralModel(id: 0, label: 'All'));
      if (result.success) {
        if (result.data[0] == 'S') {
          if (result.data[1] != null) {
            for (var group in result.data[1]) {
              List<GeneralModel> children = [];
              if (group[2] != null) {
                for (var type in group[2]) {
                  if (type.asMap().containsKey(2)) {
                    children.add(GeneralModel(
                      id: int.parse(type[0].toString()),
                      label: type[1],
                      checkLeaveBalance: type[2],
                    ));

                    leaveTypeList.add(GeneralModel(
                      id: int.parse(type[0].toString()),
                      label: type[1],
                      checkLeaveBalance: type[2],
                    ));
                  } else {
                    children.add(GeneralModel(
                        id: int.parse(type[0].toString()),
                        label: type[1],
                        checkLeaveBalance: false));

                    leaveTypeList.add(GeneralModel(
                        id: int.parse(type[0].toString()),
                        label: type[1],
                        checkLeaveBalance: false));
                  }
                }
              } else {
                // nothing todo
              }
              if (int.parse(group[0].toString()) != 0) {
                leaveTypeGroup.add(
                  GeneralModel(
                      id: int.parse(group[0].toString()),
                      label: group[1],
                      children: children),
                );
              }
            }
          }
        }
      }
    } else if (uri.path == prefix + UIUrl.shiftSchedule) {
      loadingShiftSchedule = false;
      shiftScheduleCode = result.code;
      shiftSchedule.clear();
      if (result.success) {
        if (result.data[0] == 'S') {
          log(result.data[1].toString());
          for (var schedule in result.data[1]) {
            shiftSchedule.add(ShiftScheduleModel.fromList(schedule, otMaxMinutes));
          }
        }
      }
    } else if (uri.path == prefix + UIUrl.leaveBalance) {
      loadingLeaveBalance = false;
      leaveBalanceCode = result.code;
      if (result.success) {
        if (result.data[0] == 'S') {
          if (result.data[1] != null) {
            if (result.data[1].toString() == "-") {
              leaveBalance = null;
            } else {
              if (result.data[1].toString() != null) {
                leaveBalance = double.parse(result.data[1].toString());
              }
            }
          } else {
            leaveBalance = null;
          }
        }
      }
    } else if (uri.path == prefix + UIUrl.overtimeHistory) {
      loadingOvertimeHistory = false;
      codeOvertimeHistory = result.code;
      if (result.success) {
        if (result.data[0] == 'S') {
          var list = result.data[1];
          for (var data in list) {
            overtimeHistoryList.add(OvertimeHistoryModel.fromList(data));
          }
        } else {
          msgOvertimeHistory = result.message;
        }
      } else {
        msgOvertimeHistory = result.message;
      }
    } else if (uri.path == prefix + UIUrl.leaveHistory) {
      loadingLeaveHistory = false;
      codeLeaveHistory = result.code;
      if (result.success) {
        if (result.data[0] == 'S') {
          var list = result.data[1];
          for (var data in list) {
            leaveHistoryList.add(LeaveHistoryModel.fromList(data));
          }
        } else {
          msgLeaveHistory = result.message;
        }
      } else {
        msgLeaveHistory = result.message;
      }
    } else if (uri.path == prefix + UIUrl.clockingHistory) {
      loadingClockingHistory = false;
      codeClockingHistory = result.code;
      if (result.success) {
        if (result.data[0] == 'S') {
          var list = result.data[1];
          for (var data in list) {
            clockingHistoryList.add(ClockingHistoryModel.fromList(data));
          }
        } else {
          msgClockingHistory = result.message;
        }
      } else {
        msgClockingHistory = result.message;
      }
    }
    notifyListeners();
    return result;
  }
}

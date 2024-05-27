import 'package:enta_mobile/models/employee.dart';
import 'package:enta_mobile/models/office.dart';
import 'package:enta_mobile/pages/approval/index.dart';
import 'package:enta_mobile/pages/history/clocking.dart';
import 'package:enta_mobile/pages/history/index.dart';
import 'package:enta_mobile/pages/history/leave.dart';
import 'package:enta_mobile/pages/history/overtime.dart';
import 'package:enta_mobile/pages/request_form/leave.dart';
import 'package:flutter/material.dart';

import '../models/general.dart';
import '../pages/request_form/overtime.dart';

class UIData {
  static int codeVersion = 16;
  static String appVersion = 'v1.1.1';
  static List<GeneralModel> menuFeature = [
    GeneralModel(
      code: 'clocking',
      label: 'Tap In/Out',
      icon: Icons.touch_app_rounded,
      route: ApprovalPage.routeName,
      args: null,
    ),
    GeneralModel(
      code: 'overtime',
      label: 'Overtime Request',
      icon: Icons.more_time_rounded,
      route: OvertimeRequestPage.routeName,
    ),
    GeneralModel(
      code: 'leave',
      label: 'Leave Request',
      icon: Icons.dynamic_form_rounded,
      route: LeaveRequestPage.routeName,
    ),
    GeneralModel(
      code: 'history',
      label: 'History',
      icon: Icons.history_rounded,
      route: HistoryPage.routeName,
    ),
  ];

  static List<GeneralModel> menuApproval = [
    GeneralModel(
      code: 'travel_request',
      label: 'Travel Request',
      icon: Icons.pending_actions_rounded,
      route: '',
    ),
    GeneralModel(
      code: 'leave_request',
      label: 'Leave Request',
      icon: Icons.dynamic_form_rounded,
      route: '',
    ),
    GeneralModel(
      code: 'leave_encashment',
      label: 'Leave Encashment',
      icon: Icons.dynamic_form_rounded,
      route: '',
    ),
    GeneralModel(
      code: 'work_off_permission',
      label: 'Work Off Permission',
      icon: Icons.dynamic_form_rounded,
      route: '',
    ),
    GeneralModel(
      code: 'overtime_work_order',
      label: 'Overtime Work Order',
      icon: Icons.dynamic_form_rounded,
      route: '',
    ),
    GeneralModel(
      code: 'subordinate_schedule_changes',
      label: 'Subordinate Schedule Changes',
      icon: Icons.dynamic_form_rounded,
      route: '',
    ),
    GeneralModel(
      code: 'medical_adjustment',
      label: 'Medical Adjustment',
      icon: Icons.dynamic_form_rounded,
      route: '',
    ),
  ];

  static List<GeneralModel> menuRequestForm = [
    GeneralModel(
      code: 'overtime',
      label: 'Overtime',
      icon: Icons.pending_actions_rounded,
      route: '',
    ),
    GeneralModel(
      code: 'switch_with_other',
      label: 'Switch with Other',
      icon: Icons.dynamic_form_rounded,
      route: '',
    ),
    GeneralModel(
      code: 'leave_encashment',
      label: 'Leave Encashment',
      icon: Icons.dynamic_form_rounded,
      route: '',
    ),
    GeneralModel(
      code: 'work_off_permission',
      label: 'Work Off Permission',
      icon: Icons.dynamic_form_rounded,
      route: '',
    ),
    GeneralModel(
      code: 'work_off',
      label: 'Work Off',
      icon: Icons.dynamic_form_rounded,
      route: '',
    ),
    GeneralModel(
      code: 'day_changes',
      label: 'Day Changes',
      icon: Icons.dynamic_form_rounded,
      route: '',
    ),
    GeneralModel(
      code: 'leave',
      label: 'Leave',
      icon: Icons.dynamic_form_rounded,
      route: '',
    ),
    GeneralModel(
      code: 'payslip',
      label: 'Payslip',
      icon: Icons.dynamic_form_rounded,
      route: '',
    ),
  ];

  static List<GeneralModel> menuHistory = [
    GeneralModel(
      code: 'clocking',
      label: 'Tap In & Out',
      icon: Icons.pending_actions_rounded,
      route: ClockingHistoryPage.routeName,
    ),
    GeneralModel(
      code: 'overtime',
      label: 'Overtime Request',
      icon: Icons.dynamic_form_rounded,
      route: OvertimeHistoryPage.routeName,
    ),
    GeneralModel(
      code: 'leave',
      label: 'Leave Request',
      icon: Icons.dynamic_form_rounded,
      route: LeaveHistoryPage.routeName,
    ),
  ];

  static List<GeneralModel> menuInfo = [
    GeneralModel(
      code: 'leave_balance',
      label: 'Leave Balance',
      icon: Icons.pending_actions_rounded,
      route: '',
    ),
    GeneralModel(
      code: 'employee_on_leave',
      label: 'Employee on Leave',
      icon: Icons.dynamic_form_rounded,
      route: '',
    ),
    GeneralModel(
      code: 'employee_late',
      label: 'Employee Late',
      icon: Icons.dynamic_form_rounded,
      route: '',
    ),
  ];

  static List<GeneralModel> clockingType = [
    GeneralModel(
      id: 1,
      code: 'WFO',
      label: 'WFO',
    ),
    GeneralModel(
      id: 3,
      code: 'BZT',
      label: 'Business Trip',
    ),
    GeneralModel(
      id: 2,
      code: 'WFH',
      label: 'WFH',
    ),
  ];

  static List<GeneralModel> requestType = [
    GeneralModel(
      id: 1,
      code: '1',
      label: 'Self',
    ),
    GeneralModel(
      id: 2,
      code: '2',
      label: 'Others',
    ),
  ];

  static List<GeneralModel> leaveTypeGroup = [
    GeneralModel(
      code: '1',
      label: 'AL',
    ),
    GeneralModel(
      code: '2',
      label: 'AL-Foreigner',
    ),
    GeneralModel(
      code: '3',
      label: 'Cuti Besar',
    ),
    GeneralModel(
      code: '4',
      label: 'Cuti Tahunan',
    ),
    GeneralModel(
      code: '5',
      label: 'Kelahiran Anak',
    ),
  ];

  static List<GeneralModel> leaveType = [
    GeneralModel(
      code: '1',
      label: 'Type 1',
    ),
    GeneralModel(
      code: '2',
      label: 'Type 2',
    ),
  ];

  static List<GeneralModel> durationLeaveType = [
    GeneralModel(
      id: 0,
      label: 'Full Day',
    ),
    GeneralModel(
      id: 1,
      label: '1st Half Day',
    ),
    GeneralModel(
      id: 2,
      label: '2nd Half Day',
    ),
  ];

  static List<OfficeModel> dummyOffice = [
    OfficeModel(
      name: 'Kintamani',
      latitude: -6.3530659,
      longitude: 106.3864552,
    ),
    OfficeModel(
      name: 'Stasiun Maja',
      latitude: -6.33230,
      longitude: 106.39658,
    ),
  ];

  static List<EmployeeModel> dummyEmployee = [
    EmployeeModel(
      employeeId: 123,
      name: 'Employee 001',
      photoUrl: 'https://i.imgur.com/9w1giMh.png',
      isSelected: false,
    ),
    EmployeeModel(
      employeeId: 124,
      name: 'Employee 002',
      photoUrl: 'https://i.imgur.com/9w1giMh.png',
      isSelected: false,
    ),
    EmployeeModel(
      employeeId: 125,
      name: 'Employee 003',
      photoUrl: 'https://i.imgur.com/9w1giMh.png',
      isSelected: false,
    ),
    EmployeeModel(
      employeeId: 126,
      name: 'Employee 004',
      photoUrl: 'https://i.imgur.com/9w1giMh.png',
      isSelected: false,
    ),
    EmployeeModel(
      employeeId: 127,
      name: 'Employee 005',
      photoUrl: 'https://i.imgur.com/9w1giMh.png',
      isSelected: false,
    ),
    EmployeeModel(
      employeeId: 128,
      name: 'Employee 006',
      photoUrl: 'https://i.imgur.com/9w1giMh.png',
      isSelected: false,
    ),
  ];

  static List<String> allowedAttachExt = [
    '.pdf',
    '.xlsx',
    '.xls',
    '.csv',
    '.docx',
    '.doc',
    '.png',
    '.jpg',
    '.jpeg',
    '.txt',
    '.zip'
  ];
}

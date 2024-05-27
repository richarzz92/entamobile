// ignore_for_file: use_build_context_synchronously, prefer_interpolation_to_compose_strings

import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:enta_mobile/components/modal/employee.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:enta_mobile/models/employee.dart';
import 'package:enta_mobile/models/general.dart';
import 'package:enta_mobile/providers/device.dart';
import 'package:enta_mobile/utils/images.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:group_button/group_button.dart';
// ignore: depend_on_referenced_packages
import 'package:path/path.dart' as p;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:enta_mobile/components/stepper.dart' as customstepper;
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:skeleton_text/skeleton_text.dart';

import '../../args/general.dart';
import '../../models/leave/request.dart';
import '../../models/response_api.dart';
import '../../providers/request.dart';
import '../../root.dart';
import '../../utils/data.dart';
import '../../utils/functions.dart';
import '../../utils/url.dart';
import '../login.dart';

class LeaveRequestPage extends StatefulWidget {
  static const routeName = '/request-form/leave';
  const LeaveRequestPage({Key? key}) : super(key: key);

  @override
  State<LeaveRequestPage> createState() => _LeaveRequestPageState();
}

class _LeaveRequestPageState extends State<LeaveRequestPage> {
  DateTimeRange? selectedSchedule;
  final TextEditingController leaveTypeGroupText = TextEditingController();
  final TextEditingController leaveTypeText = TextEditingController();
  final TextEditingController startDateText = TextEditingController();
  final TextEditingController endDateText = TextEditingController();
  final TextEditingController remarksText = TextEditingController();
  final TextEditingController emergencyContactText = TextEditingController();
  DateTime startDate = DateTime.now(), endDate = DateTime.now();
  final formScheduleKey = GlobalKey<FormState>();
  File? attachFile;
  String? attachFileName, attachFileSize = "0kb", attachFileExt;
  late String attachIcon;
  Color? attachColor;
  int currentStep = 0;
  double? height, width;
  late DeviceState deviceState;
  late RequestState requestState;
  int durationType = 0;
  late SharedPreferences prefs;
  bool resetSelected = false;

  final durationController = GroupButtonController();
  GeneralModel? selectedLeaveType, selectedLeaveTypeGroup;
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () async {
      prefs = await SharedPreferences.getInstance();
      durationController.selectIndex(0);
      requestState.resetLeaveRequest();
      // hardcode self request
      requestState.updateLeaveRequestAddEmployee(
        employee: LeaveEmployeeRequestModel(
          id: DateTime.now().millisecondsSinceEpoch,
          date: [],
          employee: EmployeeModel(
            employeeId: deviceState.employeeId,
            name: deviceState.employeeName,
            isSelected: true,
            photoUrl: deviceState.myAuth!.photoProfile,
          ),
        ),
      );
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> getBalance() async {
    Uri uriLeaveBalance;
    if (prefs.getBool("secure")!) {
      uriLeaveBalance = Uri.https(prefs.getString("host")!,
          prefs.getString("prefix")! + UIUrl.leaveBalance);
    } else {
      uriLeaveBalance = Uri.http(prefs.getString("host")!,
          prefs.getString("prefix")! + UIUrl.leaveBalance);
    }
    String planText = prefs.getString("username")! +
        deviceState.employeeId.toString() +
        'LEAVE_DETAILS' +
        selectedLeaveType!.id.toString() +
        deviceState.myAuth!.companyCode! +
        deviceState.deviceId! +
        deviceState.myAuth!.companyCode! +
        deviceState.deviceId!;
    String secretKey = UIFunction.encodeSha1(planText);
    String parameters = json.encode([
      prefs.getString("username"),
      deviceState.employeeId.toString(),
      'LEAVE_DETAILS',
      selectedLeaveType!.id.toString(),
      deviceState.myAuth!.companyCode,
      deviceState.deviceId,
      secretKey
    ]);
    log("Param Leave Balance : $parameters");
    await deviceState.actionCallAPI(
        method: 'POST',
        uri: uriLeaveBalance,
        prefix: prefs.getString("prefix")!,
        formData: parameters);
  }

  void tapped(int step) {
    // if (step == 2) {
    // } else {
    //   if (requestState.leaveRequest.startDate == null) {
    //     UIFunction.showToastMessage(
    //       context: context,
    //       isError: true,
    //       position: 'TOP',
    //       title: 'OOpps',
    //       message: 'Please select start date.',
    //     );
    //   } else {
    //     setState(() => currentStep = step);
    //   }
    // }
  }

  void next() {
    if (resetSelected) {
      requestState.resetSelectedLeaveDate();
    }
    if (currentStep < 2) {
      currentStep += 1;
    }
    requestState.getIsSelectedAll();
    setState(() {});
  }

  void previous() {
    if (currentStep > 0) {
      currentStep -= 1;
    }
    setState(() {});
  }

  Future<void> callAPI() async {
    FocusScope.of(context).requestFocus(FocusNode());
    List<DateTime> dateList = UIFunction.getDaysInBetween(
      startDate: requestState.leaveRequest.startDate!,
      endDate: requestState.leaveRequest.endDate!,
    );

    List dateLeaveList = [];
    for (var a in requestState.leaveRequest.employeeList!) {
      for (var e in dateList) {
        var search = a!.date!
            .firstWhere((element) => element!.date == e, orElse: () => null);
        if (search != null) {
          dateLeaveList.add(DateFormat('yyyy-MM-dd', 'id').format(search.date!));
        }
      }
    }
    List attachment = [];
    if (attachFile != null) {
      String imageBase64 = await (UIFunction.encodeImageBase64(attachFile!) as FutureOr<String>);
      attachment.add("$attachFileName$attachFileExt");
      attachment.add(imageBase64);
    }
    String fullDay = requestState.leaveRequest.durationType!.id == 0 ? '1' : '0';
    String halfDay = requestState.leaveRequest.durationType!.id == 1 ? '1' : '0';
    String halfDay2 =
        requestState.leaveRequest.durationType!.id == 2 ? '1' : '0';
    String planText = prefs.getString("username")! +
        selectedLeaveTypeGroup!.id.toString() +
        selectedLeaveType!.id.toString() +
        DateFormat('yyyy-MM-dd', 'id')
            .format(requestState.leaveRequest.startDate!) +
        DateFormat('yyyy-MM-dd', 'id').format(
            requestState.leaveRequest.durationType!.id != 0
                ? requestState.leaveRequest.startDate!
                : requestState.leaveRequest.endDate!) +
        'SELF' +
        json.encode(attachment) +
        remarksText.text +
        emergencyContactText.text +
        fullDay +
        halfDay +
        halfDay2 +
        dateLeaveList.join(',') +
        deviceState.myAuth!.companyCode! +
        deviceState.deviceId! +
        deviceState.myAuth!.companyCode! +
        deviceState.deviceId!;
    String secretKey = UIFunction.encodeSha1(planText);
    String parameters = json.encode([
      prefs.getString("username"),
      selectedLeaveTypeGroup!.id.toString(),
      selectedLeaveType!.id.toString(),
      DateFormat('yyyy-MM-dd', 'id')
          .format(requestState.leaveRequest.startDate!),
      DateFormat('yyyy-MM-dd', 'id').format(
          requestState.leaveRequest.durationType!.id != 0
              ? requestState.leaveRequest.startDate!
              : requestState.leaveRequest.endDate!),
      'SELF',
      attachment,
      remarksText.text,
      emergencyContactText.text,
      fullDay,
      halfDay,
      halfDay2,
      dateLeaveList.join(','),
      deviceState.myAuth!.companyCode,
      deviceState.deviceId,
      secretKey
    ]);
    Uri urlSubmit;
    if (prefs.getBool("secure")!) {
      urlSubmit = Uri.https(prefs.getString("host")!,
          prefs.getString("prefix")! + UIUrl.leaveSubmit);
    } else {
      urlSubmit = Uri.http(prefs.getString("host")!,
          prefs.getString("prefix")! + UIUrl.leaveSubmit);
    }
    log("Parameter Leave Request $parameters");
    UIFunction.showDialogLoadingBlank(context: context);
    ResponseAPI result = await UIFunction.callAPIDIO(
      method: 'POST',
      url: urlSubmit.toString(),
      formData: parameters,
    );
    Navigator.pop(context);
    if (result.success) {
      if (result.data[0] == 'S') {
        Navigator.pop(context, result.data[1]);
      } else {
        if (result.code == 401) {
          UIFunction.unsetPreferences();
          Navigator.popUntil(context, ModalRoute.withName(MainPage.routeName));
          Navigator.pushReplacementNamed(
            context,
            LoginPage.routeName,
            arguments: GeneralArgs(
              showAlert: true,
              alertText: 'Session is expired',
            ),
          );
        } else {
          UIFunction.showToastMessage(
              context: context,
              isError: true,
              position: 'TOP',
              title: 'Information',
              message: result.data[1]);
        }
      }
    } else {
      UIFunction.showToastMessage(
          context: context,
          isError: true,
          position: 'TOP',
          title: 'Information',
          message: result.message);
    }
  }

  Future<void> showListEmployee() async {
    FocusScope.of(context).requestFocus(FocusNode());
    var result = await showMaterialModalBottomSheet(
      context: context,
      expand: false,
      enableDrag: false,
      builder: (context) => ConstrainedBox(
        constraints: BoxConstraints(maxHeight: height! * 0.75),
        child: const EmployeeModal(
          type: 1,
        ),
      ),
    );
    if (result != null) {
      requestState.updateLeaveRequestEmployee(employee: result);
    }
  }

  Future<void> showListLeaveTypeGroup() async {
    FocusScope.of(context).requestFocus(FocusNode());
    await showMaterialModalBottomSheet(
      context: context,
      expand: false,
      enableDrag: false,
      builder: (context) => ConstrainedBox(
        constraints: BoxConstraints(maxHeight: height! * 0.65),
        child: Container(
          padding: const EdgeInsets.symmetric(
            vertical: 0,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Leave Type Group".toUpperCase(),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: Theme.of(context)
                            .primaryTextTheme
                            .subtitle1!
                            .fontSize,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: Icon(
                        Icons.close,
                        color: Theme.of(context).iconTheme.color,
                      ),
                    )
                  ],
                ),
              ),
              const Divider(
                height: 0,
              ),
              Expanded(
                child: ListView.separated(
                    padding: const EdgeInsets.all(0),
                    itemCount: deviceState.leaveTypeGroup.length,
                    separatorBuilder: (BuildContext context, int i) {
                      return const Divider(
                        height: 0,
                      );
                    },
                    itemBuilder: (BuildContext context, int i) {
                      return ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 0),
                        onTap: () {
                          if (selectedLeaveType != null) {
                            if (selectedLeaveTypeGroup!.id !=
                                deviceState.leaveTypeGroup[i].id) {
                              selectedLeaveType = null;
                              leaveTypeText.text = '';
                            }
                          }
                          selectedLeaveTypeGroup =
                              deviceState.leaveTypeGroup[i];
                          leaveTypeGroupText.text =
                              selectedLeaveTypeGroup!.label!;

                          setState(() {});
                          Navigator.pop(context);
                        },
                        title: Text(
                          deviceState.leaveTypeGroup[i].label!,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing: selectedLeaveTypeGroup == null ||
                                selectedLeaveTypeGroup!.id !=
                                    deviceState.leaveTypeGroup[i].id
                            ? const SizedBox(
                                height: 5,
                              )
                            : const Icon(
                                Icons.check,
                                color: Colors.green,
                              ),
                      );
                    }),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> showListLeaveType() async {
    FocusScope.of(context).requestFocus(FocusNode());
    await showMaterialModalBottomSheet(
      context: context,
      expand: false,
      enableDrag: false,
      builder: (context) => ConstrainedBox(
        constraints: BoxConstraints(maxHeight: height! * 0.65),
        child: Container(
          padding: const EdgeInsets.symmetric(
            vertical: 0,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Leave Type".toUpperCase(),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: Theme.of(context)
                            .primaryTextTheme
                            .subtitle1!
                            .fontSize,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: Icon(
                        Icons.close,
                        color: Theme.of(context).iconTheme.color,
                      ),
                    )
                  ],
                ),
              ),
              const Divider(
                height: 0,
              ),
              Expanded(
                child: ListView.separated(
                    padding: const EdgeInsets.all(0),
                    itemCount: selectedLeaveTypeGroup!.children!.length,
                    separatorBuilder: (BuildContext context, int i) {
                      return const Divider(
                        height: 0,
                      );
                    },
                    itemBuilder: (BuildContext context, int i) {
                      return ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 0),
                        onTap: () {
                          if (selectedLeaveType != null) {
                            if (selectedLeaveTypeGroup!.children![i].id !=
                                selectedLeaveType!.id) {
                              resetSelected = true;
                              log("Reset Selected");
                            }
                          }
                          setState(() {
                            selectedLeaveType =
                                selectedLeaveTypeGroup!.children![i];
                            leaveTypeText.text = selectedLeaveType!.label!;
                            getBalance();
                          });
                          Navigator.pop(context);
                        },
                        title: Text(
                          selectedLeaveTypeGroup!.children![i].label!,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing: selectedLeaveType == null ||
                                selectedLeaveType!.id !=
                                    selectedLeaveTypeGroup!.children![i].id
                            ? const SizedBox(
                                height: 5,
                              )
                            : const Icon(
                                Icons.check,
                                color: Colors.green,
                              ),
                      );
                    }),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<DateTime?> getDate({required DateTime selectedDate}) {
    return showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(DateTime.now().month - 12),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData(
            primaryColor: Theme.of(context).primaryColor,
            brightness: Brightness.light,
            colorScheme:
                ColorScheme.light(primary: Theme.of(context).primaryColor),
          ),
          child: child!,
        );
      },
    );
  }

  Future<void> onPickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null) {
      attachFile = File(result.files.single.path!);
      attachFileSize = UIFunction.fileSize(await attachFile!.length());
      attachFileName = p.basenameWithoutExtension(attachFile!.path);
      attachFileExt = p.extension(attachFile!.path);
      log(deviceState.extFile.toString());
      int x = await attachFile!.length();
      if (x > deviceState.maxSizeFile) {
        attachFile = null;
        UIFunction.showToastMessage(
          context: context,
          isError: true,
          position: 'TOP',
          title: 'OOpps',
          message: 'The attach file must be less than or equal 5 MB.',
        );
      } else if (!deviceState.extFile.contains(attachFileExt)) {
        attachFile = null;
        UIFunction.showToastMessage(
          context: context,
          isError: true,
          position: 'TOP',
          title: 'OOpps',
          message:
              'The attach file must be a file of type: ${deviceState.extFile}',
        );
      } else {
        if (attachFileExt == '.pdf') {
          attachIcon = UIImage.extPdf;
          attachColor = Colors.red;
        } else if (attachFileExt == '.xlsx' ||
            attachFileExt == '.xls' ||
            attachFileExt == '.csv') {
          attachIcon = UIImage.extXls;
          attachColor = Colors.green;
        } else if (attachFileExt == '.docx' || attachFileExt == '.doc') {
          attachIcon = UIImage.extWord;
          attachColor = Colors.blue;
        } else if (attachFileExt == '.png' ||
            attachFileExt == '.jpg' ||
            attachFileExt == '.jepg') {
          attachIcon = UIImage.extImage;
          attachColor = Colors.orange;
        } else if (attachFileExt == '.txt' || attachFileExt == '.zip') {
          attachIcon = UIImage.extText;
          attachColor = Colors.orange;
        } else {
          attachIcon = UIImage.extText;
          attachColor = Colors.grey;
        }
      }
    }
    setState(() {});
  }

  void onSelectedDate({required int i, LeaveEmployeeRequestModel? employee}) {
    bool checkRequestDate = requestState.checkLeaveRequestEmployeeDate(
      date: requestState.leaveRequest.startDate!.add(
        Duration(days: i),
      ),
      data: employee,
    );
    if (checkRequestDate) {
      requestState.addLeaveRequestEmployeeDate(
        data: employee,
        date: requestState.leaveRequest.startDate!.add(
          Duration(days: i),
        ),
      );
    } else {
      if (selectedLeaveType!.checkLeaveBalance!) {
        if (deviceState.leaveBalance! - requestState.totalLeave == 0) {
          UIFunction.showToastMessage(
            context: context,
            isError: true,
            position: 'TOP',
            message:
                'You can not select this data because your leave balance is not enough',
          );
        } else {
          requestState.addLeaveRequestEmployeeDate(
            data: employee,
            date: requestState.leaveRequest.startDate!.add(
              Duration(days: i),
            ),
          );
        }
      } else {
        requestState.addLeaveRequestEmployeeDate(
          data: employee,
          date: requestState.leaveRequest.startDate!.add(
            Duration(days: i),
          ),
        );
      }
    }
  }

  void onSelectAll() {
    if (selectedLeaveType!.checkLeaveBalance!) {
      int different = requestState.leaveRequest.endDate!
              .difference(requestState.leaveRequest.startDate!)
              .inDays +
          1;
      // if(requestState)
      if (deviceState.leaveBalance! - different < 0) {
        UIFunction.showToastMessage(
            context: context,
            isError: true,
            position: 'TOP',
            message:
                'You can not select all date because your leave balance is not enough');
      } else {
        requestState.toggleSelectAllLeaveDate();
      }
    } else {
      requestState.toggleSelectAllLeaveDate();
    }
  }

  @override
  Widget build(BuildContext context) {
    deviceState = Provider.of<DeviceState>(context);
    requestState = Provider.of<RequestState>(context);
    height = MediaQuery.of(context).size.height;
    width = MediaQuery.of(context).size.width;
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(FocusNode());
      },
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          title: const Text("Form Leave Request"),
        ),
        bottomNavigationBar: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12.5, vertical: 7.5),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                blurRadius: 5.0,
                color: Theme.of(context).dividerColor.withAlpha(30),
                offset: const Offset(-1, 0),
              )
            ],
          ),
          child: buildActionBottom(),
        ),
        body: customstepper.Stepper(
          elevation: 1,
          currentStep: currentStep,
          type: customstepper.StepperType.horizontal,
          physics: const ClampingScrollPhysics(),
          onStepTapped: (step) => tapped(step),
          controlsBuilder:
              (BuildContext context, customstepper.ControlsDetails details) {
            return const Center(
              heightFactor: 0,
            );
          },
          steps: <customstepper.Step>[
            customstepper.Step(
              state: customstepper.StepState.schedule,
              isActive: currentStep >= 0,
              title: const Text('Schedule'),
              content: buildSchedule(),
            ),
            customstepper.Step(
              state: customstepper.StepState.overtime,
              isActive: currentStep >= 1,
              title: const Text('Leave'),
              content: buildDetail(),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildActionBottom() {
    if (currentStep == 0) {
      return actionButton(
        code: "SCHEDULE",
        title: 'Next',
        color: Colors.blue,
      );
    } else {
      return Row(
        children: [
          Expanded(
            child: actionButton(
              code: "BACK",
              title: 'Back',
              color: Colors.red,
            ),
          ),
          const SizedBox(
            width: 10,
          ),
          Expanded(
            child: actionButton(
              code: "SUBMIT",
              title: 'Submit',
              color: Colors.blue,
            ),
          )
        ],
      );
    }
  }

  Widget buildAttachmentItem() {
    if (attachFile != null) {
      return ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 0),
        leading: SvgPicture.asset(
          attachIcon,
          height: 45.0,
        ),
        title: Text(
          attachFileName!,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(attachFileSize!),
        trailing: IconButton(
            icon: const Icon(Icons.delete),
            color: Colors.red,
            onPressed: () {
              attachFile = null;
              setState(() {});
            }),
      );
    } else {
      return const Center(
        heightFactor: 0,
      );
    }
  }

  Widget buildBtnAttachment() {
    return ElevatedButton.icon(
      onPressed: () async {
        if (deviceState.permissionStorage == PermissionStatus.granted) {
          await onPickFile();
        } else {
          await deviceState.requestPermission(hardware: Permission.storage);
          if (deviceState.permissionStorage == PermissionStatus.granted) {
            await onPickFile();
          } else if (deviceState.permissionStorage ==
              PermissionStatus.permanentlyDenied) {
            await openAppSettings();
          }
        }
      },
      icon: Icon(
        Icons.file_upload_rounded,
        color: Colors.white,
        size: Theme.of(context).primaryTextTheme.headline6!.fontSize! - 1,
      ),
      label: const Text(
        "Choose file",
        style: TextStyle(
          color: Colors.white,
        ),
      ),
    );
  }

  Widget actionButton({String? code, required String title, Color? color}) {
    return ElevatedButton(
      onPressed: () {
        if (code == "SCHEDULE") {
          if (formScheduleKey.currentState!.validate()) {
            next();
          } else {
            log("please fill the field blank");
          }
        } else if (code == "NEXT") {
          next();
        } else if (code == "BACK") {
          previous();
        } else {
          log("Submit");
          callAPI();
        }
      },
      style: ElevatedButton.styleFrom(primary: color),
      child: Text(title),
    );
  }

  Widget buildSchedule() {
    return SizedBox(
      height: height! * 0.73,
      child: Form(
        key: formScheduleKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: CustomScrollView(
          shrinkWrap: true,
          slivers: <Widget>[
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: GroupButton(
                            controller: durationController,
                            isRadio: true,
                            onSelected: (dynamic text, index, isSelected) {
                              durationType = index;
                              requestState.updateLeaveRequestDuration(
                                  durationType:
                                      UIData.durationLeaveType[index]);
                              if (index == 1 || index == 2) {
                                requestState.updateLeaveRequestSchedule(
                                    schedule: DateTimeRange(
                                        start: startDate, end: startDate));

                                requestState.addLeaveRequestEmployeeDate2(
                                  data:
                                      requestState.leaveRequest.employeeList![0],
                                  date: requestState.leaveRequest.startDate,
                                );
                              } else {
                                requestState.updateLeaveRequestSchedule(
                                    schedule: DateTimeRange(
                                        start: startDate, end: endDate));
                              }
                              resetSelected = true;
                              setState(() {});
                            },
                            buttons: const [
                              "Full Day",
                              "1st Half Day",
                              "2nd Half Day"
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    "Leave Type Group",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize:
                          Theme.of(context).primaryTextTheme.caption!.fontSize,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12.5),
                    child: InkWell(
                      onTap: () async {
                        showListLeaveTypeGroup();
                      },
                      splashColor: Colors.transparent,
                      focusColor: Colors.transparent,
                      hoverColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                      child: IgnorePointer(
                        ignoring: true,
                        child: TextFormField(
                          maxLines: 1,
                          controller: leaveTypeGroupText,
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Leave type group is required';
                            } else {
                              return null;
                            }
                          },
                          decoration: InputDecoration(
                            contentPadding: EdgeInsets.zero,
                            focusColor: Theme.of(context).primaryColor,
                            hintText: 'Leave type group',
                          ),
                        ),
                      ),
                    ),
                  ),
                  Text(
                    "Leave Type",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize:
                          Theme.of(context).primaryTextTheme.caption!.fontSize,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12.5),
                    child: InkWell(
                      onTap: () async {
                        if (selectedLeaveTypeGroup == null) {
                          UIFunction.showToastMessage(
                              context: context,
                              isError: true,
                              position: 'TOP',
                              message: 'Please select leave type group');
                        } else {
                          showListLeaveType();
                        }
                      },
                      splashColor: Colors.transparent,
                      focusColor: Colors.transparent,
                      hoverColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                      child: IgnorePointer(
                        ignoring: true,
                        child: TextFormField(
                          maxLines: 1,
                          controller: leaveTypeText,
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Leave type is required';
                            } else {
                              return null;
                            }
                          },
                          decoration: InputDecoration(
                            contentPadding: EdgeInsets.zero,
                            focusColor: Theme.of(context).primaryColor,
                            hintText: 'Leave type',
                          ),
                        ),
                      ),
                    ),
                  ),
                  Text(
                    "Start Date",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize:
                          Theme.of(context).primaryTextTheme.caption!.fontSize,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12.5),
                    child: InkWell(
                      onTap: () async {
                        DateTime? result =
                            await getDate(selectedDate: startDate);
                        if (result != null) {
                          if (startDate != null && startDate != result) {
                            resetSelected = true;
                          }
                          if (requestState.leaveRequest.durationType!.id != 0) {
                            startDate = result;
                            endDate = result;
                            startDateText.text = DateFormat('dd MMM yyyy', 'id')
                                .format(startDate);
                            endDateText.text = DateFormat('dd MMM yyyy', 'id')
                                .format(startDate);
                            requestState.updateLeaveRequestSchedule(
                              schedule: DateTimeRange(
                                start: startDate,
                                end: startDate,
                              ),
                            );
                          } else {
                            startDate = result;
                            startDateText.text = DateFormat('dd MMM yyyy', 'id')
                                .format(startDate);
                            if (startDateText.text.isNotEmpty &&
                                endDateText.text.isNotEmpty) {
                              if (endDate.isAfter(startDate) ||
                                  endDate.isAtSameMomentAs(startDate)) {
                                requestState.updateLeaveRequestSchedule(
                                  schedule: DateTimeRange(
                                    start: startDate,
                                    end: endDate,
                                  ),
                                );
                              }
                            }
                          }

                          setState(() {});
                        }
                      },
                      splashColor: Colors.transparent,
                      focusColor: Colors.transparent,
                      hoverColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                      child: IgnorePointer(
                        ignoring: true,
                        child: TextFormField(
                          maxLines: 1,
                          controller: startDateText,
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Start Date is required';
                            } else {
                              if (startDateText.text.isNotEmpty &&
                                  endDateText.text.isNotEmpty) {
                                if (endDate.isAfter(startDate) ||
                                    endDate.isAtSameMomentAs(startDate)) {
                                  return null;
                                } else {
                                  if (durationType == 0) {
                                    return 'Invalid Schedule';
                                  } else {
                                    return null;
                                  }
                                }
                              }
                              return null;
                            }
                          },
                          decoration: InputDecoration(
                            contentPadding: EdgeInsets.zero,
                            focusColor: Theme.of(context).primaryColor,
                            hintText: 'dd-mm-yyyy',
                          ),
                        ),
                      ),
                    ),
                  ),
                  Visibility(
                      visible: durationType == 0 ? true : false,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "End Date",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: Theme.of(context)
                                  .primaryTextTheme
                                  .caption!
                                  .fontSize,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 12.5),
                            child: InkWell(
                              onTap: () async {
                                DateTime? result =
                                    await getDate(selectedDate: endDate);
                                if (result != null) {
                                  if (endDate != null && endDate != result) {
                                    resetSelected = true;
                                  }
                                  endDate = result;
                                  endDateText.text =
                                      DateFormat('dd MMM yyyy', 'id')
                                          .format(endDate);
                                  if (startDateText.text.isNotEmpty &&
                                      endDateText.text.isNotEmpty) {
                                    if (endDate.isAfter(startDate) ||
                                        endDate.isAtSameMomentAs(startDate)) {
                                      requestState.updateLeaveRequestSchedule(
                                          schedule: DateTimeRange(
                                              start: startDate, end: endDate));
                                    }
                                  }
                                  setState(() {});
                                }
                              },
                              splashColor: Colors.transparent,
                              focusColor: Colors.transparent,
                              hoverColor: Colors.transparent,
                              highlightColor: Colors.transparent,
                              child: IgnorePointer(
                                ignoring: true,
                                child: TextFormField(
                                  maxLines: 1,
                                  controller: endDateText,
                                  validator: (value) {
                                    if (value!.isEmpty) {
                                      return 'End Date is required';
                                    } else {
                                      if (startDateText.text.isNotEmpty &&
                                          endDateText.text.isNotEmpty) {
                                        if (endDate.isAfter(startDate) ||
                                            endDate
                                                .isAtSameMomentAs(startDate)) {
                                          return null;
                                        } else {
                                          if (durationType == 0) {
                                            return 'Invalid Schedule';
                                          } else {
                                            return null;
                                          }
                                        }
                                      }
                                      return null;
                                    }
                                  },
                                  decoration: InputDecoration(
                                    contentPadding: EdgeInsets.zero,
                                    focusColor: Theme.of(context).primaryColor,
                                    hintText: 'dd-mm-yyyy',
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      )),
                  Visibility(
                    visible: selectedLeaveType == null ? false : true,
                    child: buildLeaveInfo(),
                  ),
                  Text(
                    "Emergency Contact",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize:
                          Theme.of(context).primaryTextTheme.caption!.fontSize,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 5),
                    child: TextFormField(
                      maxLines: 1,
                      controller: emergencyContactText,
                      validator: (value) {
                        return null;
                      },
                      maxLength: 200,
                      decoration: const InputDecoration(
                        hintText: "Emergency Contact (optional)",
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 0, vertical: 10),
                      ),
                    ),
                  ),
                  Text(
                    "Note",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize:
                          Theme.of(context).primaryTextTheme.caption!.fontSize,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 5),
                    child: TextFormField(
                      maxLines: 4,
                      minLines: 2,
                      controller: remarksText,
                      validator: (value) {
                        return null;
                      },
                      maxLength: 255,
                      decoration: const InputDecoration(
                        hintText: "Note (optional)",
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 0, vertical: 10),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 5),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Attachment",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize:
                            Theme.of(context).primaryTextTheme.caption!.fontSize,
                      ),
                    ),
                    buildAttachmentItem(),
                    buildBtnAttachment(),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget buildDetail() {
    if (requestState.leaveRequest.type == null) {
      return const Center(
        child: Text("Please setup the schedule"),
      );
    } else {
      if (requestState.leaveRequest.type!.id == 1 &&
          requestState.leaveRequest.startDate != null &&
          requestState.leaveRequest.employeeList!.isNotEmpty) {
        return SizedBox(
          height: height! * 0.73,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            shrinkWrap: true,
            slivers: [
              SliverToBoxAdapter(
                child: Visibility(
                    visible: requestState.leaveRequest.endDate!
                                .difference(requestState.leaveRequest.startDate!)
                                .inDays >
                            1
                        ? true
                        : false,
                    child: Column(
                      children: [
                        ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 0, vertical: 0),
                          onTap: () {
                            onSelectAll();
                          },
                          leading: Checkbox(
                              value: requestState.isSelectedAll,
                              activeColor: requestState.isSelectedAll
                                  ? Colors.red
                                  : Colors.blue,
                              onChanged: (bool? value) {
                                onSelectAll();
                              }),
                          title: Text(requestState.isSelectedAll
                              ? "Unselect All"
                              : "Select All"),
                        ),
                        const Divider(
                          height: 0,
                        ),
                      ],
                    )),
              ),
              SliverToBoxAdapter(
                child: Column(
                  children: [
                    buildListSchedule(
                      employee: requestState.leaveRequest.employeeList![0],
                    ),
                  ],
                ),
              ),
              SliverToBoxAdapter(
                child: buildLeaveInfo(),
              ),
            ],
          ),
        );
      } else {
        return const Center(
          child: Text("Please setup the schedule"),
        );
      }
    }
  }

  Widget buildListSchedule({LeaveEmployeeRequestModel? employee}) {
    return ListView.separated(
      shrinkWrap: true,
      padding: EdgeInsets.zero,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: requestState.leaveRequest.endDate!
              .difference(requestState.leaveRequest.startDate!)
              .inDays +
          1,
      separatorBuilder: (context, i) {
        return const Divider(
          height: 0,
        );
      },
      itemBuilder: (context, i) {
        bool checkRequestDate = requestState.checkLeaveRequestEmployeeDate(
          date: requestState.leaveRequest.startDate!.add(
            Duration(days: i),
          ),
          data: employee,
        );

        return ListTile(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
          onTap: () {
            onSelectedDate(i: i, employee: employee);
          },
          leading: Checkbox(
              value: checkRequestDate,
              onChanged: (bool? value) {
                onSelectedDate(i: i, employee: employee);
              }),
          title: Text(
            DateFormat('dd MMM yyyy', 'id').format(
                requestState.leaveRequest.startDate!.add(Duration(days: i))),
          ),
        );
      },
    );
  }

  Widget buildLeaveInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Visibility(
          visible: durationType != 0 && startDateText.text.isNotEmpty
              ? true
              : startDateText.text.isNotEmpty && endDateText.text.isNotEmpty
                  ? true
                  : false,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Container(
              color: Colors.yellow,
              padding: const EdgeInsets.all(5),
              child: Text("Total Leave ${requestState.totalLeave} days"),
            ),
          ),
        ),
        deviceState.loadingLeaveBalance
            ? Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: SkeletonAnimation(
                  child: Container(
                    height:
                        Theme.of(context).primaryTextTheme.subtitle1!.fontSize,
                    decoration: BoxDecoration(
                      color: Theme.of(context).dividerColor,
                    ),
                  ),
                ),
              )
            : deviceState.leaveBalanceCode != 200
                ? Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: SkeletonAnimation(
                      child: Container(
                        height: Theme.of(context)
                            .primaryTextTheme
                            .subtitle1!
                            .fontSize,
                        decoration: BoxDecoration(
                          color: Theme.of(context).dividerColor,
                        ),
                      ),
                    ),
                  )
                : Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Container(
                      color: Colors.yellow,
                      padding: const EdgeInsets.all(5),
                      child: Text(
                          "Leave Balance : ${deviceState.leaveBalance ?? '-'} days"),
                    ),
                  ),
      ],
    );
  }
}

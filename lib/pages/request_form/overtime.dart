// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:enta_mobile/components/modal/employee.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:enta_mobile/components/modal/overtime.dart';
import 'package:enta_mobile/models/employee.dart';
import 'package:enta_mobile/models/overtime/request.dart';
import 'package:enta_mobile/models/shift_schedule.dart';
import 'package:enta_mobile/providers/device.dart';
import 'package:enta_mobile/utils/images.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_svg/flutter_svg.dart';
// ignore: depend_on_referenced_packages
import 'package:path/path.dart' as p;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:jiffy/jiffy.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:enta_mobile/components/stepper.dart' as customstepper;
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../args/general.dart';
import '../../components/avatar.dart';
import '../../models/response_api.dart';
import '../../providers/request.dart';
import '../../root.dart';
import '../../utils/functions.dart';
import '../../utils/url.dart';
import '../login.dart';

class OvertimeRequestPage extends StatefulWidget {
  static const routeName = '/request-form/overtime';
  const OvertimeRequestPage({Key? key}) : super(key: key);

  @override
  State<OvertimeRequestPage> createState() => _OvertimeRequestPageState();
}

class _OvertimeRequestPageState extends State<OvertimeRequestPage> {
  DateTimeRange? selectedSchedule;
  final TextEditingController requestTypeText = TextEditingController();
  final TextEditingController scheduleText = TextEditingController();
  final TextEditingController remarksText = TextEditingController();
  final formScheduleKey = GlobalKey<FormState>();
  File? attachFile;
  String? attachFileName, attachFileSize = "0kb", attachFileExt;
  late String attachIcon;
  Color? attachColor;
  int currentStep = 0;
  double? height, width;
  late DeviceState deviceState;
  late RequestState requestState;
  late SharedPreferences prefs;
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () async {
      prefs = await SharedPreferences.getInstance();
      requestState.resetOvertimeRequest();
      // hardcode self request
      requestState.updateOvertimeRequestAddEmployee(
        employee: OvertimeEmployeeRequestModel(
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

  void tapped(int step) {
    // if (step == 2) {

    // } else {
    //   if (requestState.overTimeRequest.startDate == null) {
    //     UIFunction.showToastMessage(
    //       context: context,
    //       isError: true,
    //       position: 'TOP',
    //       title: 'OOpps',
    //       message: 'Please select start end date.',
    //     );
    //   } else {
    //     setState(() => currentStep = step);
    //   }
    // }
  }

  void next() {
    if (currentStep < 2) {
      currentStep += 1;
    }

    setState(() {});
  }

  void previous() {
    if (currentStep > 0) {
      currentStep -= 1;
    }
    setState(() {});
  }

  Future<void> getShiftSchedule({required DateTime start, required DateTime end}) async {
    Uri uriShiftSchedule;
    if (prefs.getBool("secure")!) {
      uriShiftSchedule = Uri.https(prefs.getString("host")!,
          prefs.getString("prefix")! + UIUrl.shiftSchedule);
    } else {
      uriShiftSchedule = Uri.http(prefs.getString("host")!,
          prefs.getString("prefix")! + UIUrl.shiftSchedule);
    }
    String planText = "";
    planText = prefs.getString("username")! +
        DateFormat('yyyy-MM-dd', 'id').format(start) +
        DateFormat('yyyy-MM-dd', 'id').format(end) +
        json.encode([deviceState.employeeId]) +
        deviceState.myAuth!.companyCode! +
        deviceState.deviceId! +
        deviceState.myAuth!.companyCode! +
        deviceState.deviceId!;
    String secretKey = UIFunction.encodeSha1(planText);
    var parameters = json.encode([
      prefs.getString("username"),
      DateFormat('yyyy-MM-dd', 'id').format(start),
      DateFormat('yyyy-MM-dd', 'id').format(end),
      [deviceState.employeeId],
      deviceState.myAuth!.companyCode,
      deviceState.deviceId,
      secretKey
    ]);
    log(parameters);
    UIFunction.showDialogLoading(context: context);
    ResponseAPI result = await deviceState.actionCallAPI(
      method: 'POST',
      uri: uriShiftSchedule,
      prefix: prefs.getString("prefix")!,
      formData: parameters,
    );
    Navigator.pop(context);
    if (!result.success) {
      UIFunction.showToastMessage(
          context: context,
          isError: true,
          message: result.message,
          position: 'TOP');
    } else {
      scheduleText.text =
          "${DateFormat('dd MMM yyyy', 'id').format(start)} - ${DateFormat('dd MMM yyyy', 'id').format(end)}";
      requestState.updateOvertimeRequestSchedule(
          schedule: DateTimeRange(start: start, end: end));
    }
  }

  Future<void> callAPI() async {
    FocusScope.of(context).requestFocus(FocusNode());
    List<DateTime> dateList = UIFunction.getDaysInBetween(
      startDate: requestState.overTimeRequest.startDate!,
      endDate: requestState.overTimeRequest.endDate!,
    );

    List employeeList = [];
    for (var a in requestState.overTimeRequest.employeeList!) {
      List data = [];
      List otList = [];
      for (var e in dateList) {
        var search = a!.date!
            .firstWhere((element) => element!.date == e, orElse: () => null);
        if (search != null) {
          if (search.afterIn == null &&
              search.afterOut == null &&
              search.beforeIn == null &&
              search.beforeOut == null) {
            // NOTHING TO DO
          } else {
            List detail = [];
            ShiftScheduleModel detailShiftSchedule = deviceState
                .getDetailSchedule(date: e, employeeId: a.employee!.employeeId)!;
            detail.add(DateFormat('yyyy-MM-dd', 'id').format(search.date!));
            detail.add(detailShiftSchedule.id.toString());
            // BEFORE
            if (search.beforeIn != null && search.beforeOut != null) {
              detail
                  .add(DateFormat('yyyy-MM-dd', 'id').format(search.beforeIn!));
              detail.add(DateFormat('HH:mm', 'id').format(search.beforeIn!));
              detail
                  .add(DateFormat('yyyy-MM-dd', 'id').format(search.beforeOut!));
              detail.add(DateFormat('HH:mm', 'id').format(search.beforeOut!));
            } else {
              detail.add("");
              detail.add("");
              detail.add("");
              detail.add("");
            }

            // AFTER
            if (search.afterIn != null && search.afterOut != null) {
              detail.add(DateFormat('yyyy-MM-dd', 'id').format(search.afterIn!));
              detail.add(DateFormat('HH:mm', 'id').format(search.afterIn!));
              detail
                  .add(DateFormat('yyyy-MM-dd', 'id').format(search.afterOut!));
              detail.add(DateFormat('HH:mm', 'id').format(search.afterOut!));
            } else {
              detail.add("");
              detail.add("");
              detail.add("");
              detail.add("");
            }
            otList.add(detail);
          }
        }
      }
      data.add(a!.employee!.employeeId);
      data.add(otList);
      employeeList.add(data);
    }

    // ignore: prefer_interpolation_to_compose_strings
    String planText = prefs.getString("username")! +
        DateFormat('yyyy-MM-dd', 'id')
            .format(requestState.overTimeRequest.startDate!) +
        DateFormat('yyyy-MM-dd', 'id')
            .format(requestState.overTimeRequest.endDate!) +
        'SELF' +
        remarksText.text +
        json.encode(employeeList[0]) +
        deviceState.myAuth!.companyCode! +
        deviceState.deviceId! +
        deviceState.myAuth!.companyCode! +
        deviceState.deviceId!;

    String secretKey = UIFunction.encodeSha1(planText);

    String parameters = json.encode([
      prefs.getString("username"),
      DateFormat('yyyy-MM-dd', 'id')
          .format(requestState.overTimeRequest.startDate!),
      DateFormat('yyyy-MM-dd', 'id')
          .format(requestState.overTimeRequest.endDate!),
      'SELF',
      remarksText.text,
      employeeList[0],
      deviceState.myAuth!.companyCode,
      deviceState.deviceId,
      secretKey
    ]);
    log("Parameter Overtime Request $parameters");
    Uri urlSubmit;
    if (prefs.getBool("secure")!) {
      urlSubmit = Uri.https(prefs.getString("host")!,
          prefs.getString("prefix")! + UIUrl.overtimeSubmit);
    } else {
      urlSubmit = Uri.http(prefs.getString("host")!,
          prefs.getString("prefix")! + UIUrl.overtimeSubmit);
    }
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
        child: const EmployeeModal(type: 0),
      ),
    );
    if (result != null) {
      requestState.updateOvertimeRequestEmployee(employee: result);
    }
  }

  Future<void> showModalOverTime({
    DateTime? date,
    required OvertimeEmployeeRequestModel employee,
  }) async {
    FocusScope.of(context).requestFocus(FocusNode());
    OvertimeDateRequestModel? searchItem;
    var x = requestState.overTimeRequest.employeeList!
        .indexWhere((e) => e!.id == employee.id);
    if (x >= 0) {
      searchItem = requestState.overTimeRequest.employeeList![x]!.date!
          .firstWhere((e) => e!.date == date, orElse: () => null);
    }
    ShiftScheduleModel? detailShiftSchedule = deviceState.getDetailSchedule(
        date: date, employeeId: employee.employee!.employeeId);
    OvertimeDateRequestModel? result = await showMaterialModalBottomSheet(
      context: context,
      expand: false,
      enableDrag: false,
      builder: (context) => ConstrainedBox(
        constraints: BoxConstraints(maxHeight: height! * 0.75),
        child: OvertimeModal(
          date: date,
          employee: employee,
          schedule: detailShiftSchedule,
          data: searchItem,
        ),
      ),
    );
    if (result != null) {
      requestState.updateOvertimeRequestEmployeeDate(
        employee: employee,
        dateRequest: result,
      );
    }
  }

  Future<void> dateTimeRangePicker() async {
    DateTimeRange? picked = await showDateRangePicker(
      context: context,
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData(
            brightness: Brightness.light,
            colorScheme:
                ColorScheme.light(primary: Theme.of(context).primaryColor),
          ),
          child: child!,
        );
      },
      firstDate: DateTime(DateTime.now().month - 2),
      lastDate: DateTime(DateTime.now().year + 1),
      initialDateRange: DateTimeRange(
        end: requestState.overTimeRequest.endDate ??
            DateTime(DateTime.now().year, DateTime.now().month,
                DateTime.now().day + 3),
        start: requestState.overTimeRequest.startDate ?? DateTime.now(),
      ),
    );
    if (picked == null) {
      scheduleText.text = "";
    } else {
      if (requestState.overTimeRequest.startDate != picked.start ||
          requestState.overTimeRequest.endDate != picked.end) {
        getShiftSchedule(start: picked.start, end: picked.end);
      }
    }
    setState(() {});
  }

  Future<TimeOfDay?> timePicker({required TimeOfDay initialTime}) {
    return showTimePicker(
      context: context,
      initialTime: initialTime,
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData(
            primaryColor: Theme.of(context).primaryColor,
            brightness: Brightness.light,
            colorScheme:
                ColorScheme.light(primary: Theme.of(context).primaryColor),
          ),
          child: MediaQuery(
            data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: false),
            child: child!,
          ),
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
      int x = await attachFile!.length();
      // 5242880
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
          title: const Text("Form Overtime Request"),
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
              title: const Text('Overtime'),
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
          // confirmSubmit(state: 0);
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
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Text(
                      "Start - End Date",
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
                          dateTimeRangePicker();
                        },
                        splashColor: Colors.transparent,
                        focusColor: Colors.transparent,
                        hoverColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                        child: IgnorePointer(
                          ignoring: true,
                          child: TextFormField(
                            maxLines: 1,
                            controller: scheduleText,
                            validator: (value) {
                              if (value!.isEmpty) {
                                return 'Schedule is required';
                              } else {
                                return null;
                              }
                            },
                            decoration: InputDecoration(
                              contentPadding: EdgeInsets.zero,
                              focusColor: Theme.of(context).primaryColor,
                              hintText: 'dd-mm-yyyy ~ dd-mm-yyyy',
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Visibility(
                    visible: requestState.overTimeRequest.type == null
                        ? false
                        : requestState.overTimeRequest.type!.id == 2
                            ? true
                            : false,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        showListEmployee();
                      },
                      icon: const Icon(Icons.add),
                      label: const Text("Add Employee"),
                    ),
                  ),
                  for (var i in requestState.overTimeRequest.employeeList!)
                    Visibility(
                      visible: requestState.overTimeRequest.type == null
                          ? false
                          : requestState.overTimeRequest.type!.id == 2
                              ? true
                              : false,
                      child: ListTile(
                        dense: true,
                        horizontalTitleGap: 2,
                        contentPadding: const EdgeInsets.all(0),
                        leading: AvatarWidget(
                          url: i!.employee!.photoUrl,
                          width: 30,
                          height: 30,
                        ),
                        title: Text(
                          i.employee!.employeeId.toString(),
                          style: TextStyle(
                            fontSize: Theme.of(context)
                                .primaryTextTheme
                                .subtitle1!
                                .fontSize,
                          ),
                        ),
                        subtitle: Text(
                          i.employee!.name!,
                          style: TextStyle(
                            fontSize: Theme.of(context)
                                .primaryTextTheme
                                .subtitle2!
                                .fontSize,
                          ),
                        ),
                        trailing: IconButton(
                            onPressed: () {
                              requestState.removeOvertimeRequestEmployee(
                                  id: i.id);
                            },
                            icon: const Icon(
                              Icons.remove_circle,
                              color: Colors.red,
                            )),
                      ),
                    )
                ],
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
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
            ),
            // SliverToBoxAdapter(
            //   child: Padding(
            //     padding:
            //         const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
            //     child: Column(
            //       crossAxisAlignment: CrossAxisAlignment.start,
            //       children: [
            //         Text(
            //           "Attachment",
            //           style: TextStyle(
            //             fontWeight: FontWeight.bold,
            //             fontSize:
            //                 Theme.of(context).primaryTextTheme.caption.fontSize,
            //           ),
            //         ),
            //         buildAttachmentItem(),
            //         buildBtnAttachment(),
            //       ],
            //     ),
            //   ),
            // )
          ],
        ),
      ),
    );
  }

  Widget buildDetail() {
    if (requestState.overTimeRequest.type == null) {
      return const Center(
        child: Text("Please setup the schedule"),
      );
    } else {
      if (requestState.overTimeRequest.type!.id == 1 &&
          requestState.overTimeRequest.startDate != null &&
          requestState.overTimeRequest.employeeList!.isNotEmpty) {
        return SizedBox(
          height: height! * 0.73,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            shrinkWrap: true,
            slivers: [
              SliverToBoxAdapter(
                child: Column(
                  children: [
                    buildListSchedule(
                      employee: requestState.overTimeRequest.employeeList![0],
                    ),
                  ],
                ),
              )
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

  Widget buildListSchedule({OvertimeEmployeeRequestModel? employee}) {
    return ListView.separated(
      shrinkWrap: true,
      padding: EdgeInsets.zero,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: requestState.overTimeRequest.endDate!
              .difference(requestState.overTimeRequest.startDate!)
              .inDays +
          1,
      separatorBuilder: (context, i) {
        return const Divider(
          height: 0,
        );
      },
      itemBuilder: (context, i) {
        String? shiftInfo = deviceState.getInfoSchedule(
            date: requestState.overTimeRequest.startDate!.add(Duration(days: i)),
            employeeId: employee!.employee!.employeeId);
        OvertimeDateRequestModel? detailRequest;
        int? totalOTBefore, totalOTAfter;
        bool checkRequestDate = requestState.checkOvertimeRequestEmployeeDate(
          date: requestState.overTimeRequest.startDate!.add(
            Duration(days: i),
          ),
          data: employee,
        );

        if (checkRequestDate) {
          detailRequest = requestState.detailOvertimeRequestEmployeeDate(
              date: requestState.overTimeRequest.startDate!.add(
                Duration(days: i),
              ),
              data: employee);
          if (detailRequest != null) {
            if (detailRequest.beforeIn != null) {
              totalOTBefore = Jiffy(detailRequest.beforeOut)
                  .diff(Jiffy(detailRequest.beforeIn), Units.MINUTE) as int?;
            }

            if (detailRequest.afterIn != null) {
              totalOTAfter = Jiffy(detailRequest.afterOut)
                  .diff(Jiffy(detailRequest.afterIn), Units.MINUTE) as int?;
            }
          }
        }
        return ListTile(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
          isThreeLine:
              totalOTBefore != null && totalOTAfter != null ? true : false,
          onTap: () {
            if (shiftInfo != null) {
              showModalOverTime(
                employee: employee,
                date: requestState.overTimeRequest.startDate!.add(
                  Duration(days: i),
                ),
              );
            } else {
              UIFunction.showToastMessage(
                  context: context,
                  isError: true,
                  position: 'TOP',
                  title: 'Ooops',
                  message:
                      'Shift Schedule on ${DateFormat('dd MMM yyyy', 'id').format(requestState.overTimeRequest.startDate!.add(Duration(days: i)))} not found');
            }
          },
          horizontalTitleGap: 1,
          leading: Checkbox(
              value: checkRequestDate,
              onChanged: (bool? value) {
                if (shiftInfo != null) {
                  if (totalOTBefore != null || totalOTAfter != null) {
                    requestState.addOvertimeRequestEmployeeDate(
                      data: employee,
                      date: requestState.overTimeRequest.startDate!.add(
                        Duration(days: i),
                      ),
                    );
                  }
                }
              }),
          title: Row(
            children: [
              Text(
                DateFormat('dd MMM yyyy', 'id').format(requestState
                    .overTimeRequest.startDate!
                    .add(Duration(days: i))),
              ),
              Padding(
                  padding: const EdgeInsets.only(left: 5),
                  child: Container(
                    color: shiftInfo != null ? Colors.yellow : Colors.red,
                    child: Text(
                      shiftInfo ?? "Shift not found",
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: Theme.of(context)
                            .primaryTextTheme
                            .subtitle1!
                            .fontSize,
                        color: shiftInfo != null
                            ? Theme.of(context).primaryColor
                            : Colors.white,
                      ),
                    ),
                  )),
            ],
          ),
          subtitle: totalOTBefore == null && totalOTAfter == null
              ? null
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Visibility(
                      visible: totalOTBefore != null ? true : false,
                      child: Text("Total OT Before : $totalOTBefore mins"),
                    ),
                    Visibility(
                      visible: totalOTAfter != null ? true : false,
                      child: Text("Total OT After : $totalOTAfter mins"),
                    )
                  ],
                ),
          trailing: Icon(
            Icons.check_circle_rounded,
            color: totalOTBefore == null && totalOTAfter == null
                ? Colors.grey
                : Colors.green,
          ),
        );
      },
    );
  }

  Widget buildTotalBefore() {
    return const Text("Info");
  }
}

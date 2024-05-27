import 'dart:convert';
import 'dart:developer';

import 'package:enta_mobile/models/general.dart';
import 'package:enta_mobile/providers/device.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../components/errors/get_data.dart';
import '../../components/errors/no_data.dart';
import '../../components/loading.dart';
import '../../components/modal/filter_leave.dart';
import '../../models/leave/history.dart';
import '../../utils/functions.dart';
import '../../utils/url.dart';

class LeaveHistoryPage extends StatefulWidget {
  static const routeName = '/history/leave';
  const LeaveHistoryPage({Key? key}) : super(key: key);

  @override
  State<LeaveHistoryPage> createState() => _LeaveHistoryPageState();
}

class _LeaveHistoryPageState extends State<LeaveHistoryPage> {
  late DeviceState deviceState;
  DateTime? startDate = DateTime.now().subtract(const Duration(days: 30));
  DateTime? endDate = DateTime.now();
  List<String?> status = [];
  late SharedPreferences prefs;
  List<GeneralModel>? filterStatus = [
    GeneralModel(
      code: 'NEW',
      label: 'New',
      selected: true,
    ),
    GeneralModel(
      code: 'APPROVED',
      label: 'Approved',
      selected: true,
    ),
    GeneralModel(
      code: 'REJECTED',
      label: 'Rejected',
      selected: true,
    ),
  ];
  late double height;
  GeneralModel? leaveType = GeneralModel(id: 0, label: 'All');
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () async {
      prefs = await SharedPreferences.getInstance();
      initPage();
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> initPage() async {
    Uri uriHistory;
    if (prefs.getBool("secure")!) {
      uriHistory = Uri.https(prefs.getString("host")!,
          prefs.getString("prefix")! + UIUrl.leaveHistory);
    } else {
      uriHistory = Uri.http(prefs.getString("host")!,
          prefs.getString("prefix")! + UIUrl.leaveHistory);
    }
    String leaveTypeId = '';
    if (leaveType!.id == 0) {
      leaveTypeId = '0';
    } else {
      leaveTypeId = leaveType!.id.toString();
    }
    // ignore: prefer_interpolation_to_compose_strings
    String planText = prefs.getString("username")! +
        leaveTypeId +
        DateFormat('yyyy-MM-dd', 'id').format(startDate!) +
        DateFormat('yyyy-MM-dd', 'id').format(endDate!) +
        status.join(',') +
        deviceState.myAuth!.companyCode! +
        deviceState.deviceId! +
        deviceState.myAuth!.companyCode! +
        deviceState.deviceId!;
    String secretKey = UIFunction.encodeSha1(planText);
    String parameters = json.encode([
      prefs.getString("username"),
      leaveTypeId,
      DateFormat('yyyy-MM-dd', 'id').format(startDate!),
      DateFormat('yyyy-MM-dd', 'id').format(endDate!),
      status.join(','),
      deviceState.myAuth!.companyCode,
      deviceState.deviceId,
      secretKey
    ]);
    log("Parameter Leave History $parameters");
    await deviceState.actionCallAPI(
      method: 'POST',
      uri: uriHistory,
      prefix: prefs.getString("prefix")!,
      formData: parameters,
    );
  }

  Future<void> showFilter() async {
    FocusScope.of(context).requestFocus(FocusNode());
    var result = await showCupertinoModalBottomSheet(
      context: context,
      expand: false,
      enableDrag: false,
      backgroundColor: Colors.transparent,
      builder: (context) => ConstrainedBox(
        constraints: BoxConstraints(maxHeight: height * 0.6),
        child: FilterLeaveModal(
          startDate: startDate,
          endDate: endDate,
          filterStatus: filterStatus,
          leaveType: leaveType,
        ),
      ),
    );
    if (result != null) {
      filterStatus = result['status'];
      startDate = result['start_date'];
      endDate = result['end_date'];
      leaveType = result['leave_type'];
      var x = filterStatus!.where((element) => element.selected == true);
      status.clear();
      for (var element in x) {
        status.add(element.code);
      }
      setState(() {});
      initPage();
    }
  }

  Future<void> showDetail({LeaveHistoryModel? data}) async {
    FocusScope.of(context).requestFocus(FocusNode());
    await showMaterialModalBottomSheet(
      context: context,
      expand: false,
      enableDrag: false,
      builder: (context) => ConstrainedBox(
        constraints: BoxConstraints(maxHeight: height * 0.7),
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
                      "Detail Leave".toUpperCase(),
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
                child: CustomScrollView(
                  slivers: [
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: Card(
                          child: Column(
                            children: [
                              ListTile(
                                dense: true,
                                contentPadding:
                                    const EdgeInsets.symmetric(horizontal: 10),
                                title: Text(
                                  "Request No",
                                  style: TextStyle(
                                    fontSize: Theme.of(context)
                                        .primaryTextTheme
                                        .caption!
                                        .fontSize,
                                  ),
                                ),
                                subtitle: Text(
                                  data!.code!,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: Theme.of(context)
                                        .primaryTextTheme
                                        .subtitle1!
                                        .fontSize,
                                  ),
                                ),
                              ),
                              const Divider(
                                height: 0,
                              ),
                              ListTile(
                                dense: true,
                                contentPadding:
                                    const EdgeInsets.symmetric(horizontal: 10),
                                title: Text(
                                  "Start End Date",
                                  style: TextStyle(
                                    fontSize: Theme.of(context)
                                        .primaryTextTheme
                                        .caption!
                                        .fontSize,
                                  ),
                                ),
                                subtitle: Text(
                                  "${DateFormat('dd MMM yyyy', 'id').format(data.startDate!)} - ${DateFormat('dd MMM yyyy', 'id').format(data.endDate!)}",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: Theme.of(context)
                                        .primaryTextTheme
                                        .subtitle1!
                                        .fontSize,
                                  ),
                                ),
                              ),
                              const Divider(
                                height: 0,
                              ),
                              ListTile(
                                dense: true,
                                contentPadding:
                                    const EdgeInsets.symmetric(horizontal: 10),
                                title: Text(
                                  "Leave Type",
                                  style: TextStyle(
                                    fontSize: Theme.of(context)
                                        .primaryTextTheme
                                        .caption!
                                        .fontSize,
                                  ),
                                ),
                                subtitle: Text(
                                  data.leaveType!,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: Theme.of(context)
                                        .primaryTextTheme
                                        .subtitle1!
                                        .fontSize,
                                  ),
                                ),
                              ),
                              const Divider(
                                height: 0,
                              ),
                              ListTile(
                                dense: true,
                                contentPadding:
                                    const EdgeInsets.symmetric(horizontal: 10),
                                title: Text(
                                  "Submitted By",
                                  style: TextStyle(
                                    fontSize: Theme.of(context)
                                        .primaryTextTheme
                                        .caption!
                                        .fontSize,
                                  ),
                                ),
                                subtitle: Text(
                                  data.submittedBy!,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: Theme.of(context)
                                        .primaryTextTheme
                                        .subtitle1!
                                        .fontSize,
                                  ),
                                ),
                              ),
                              const Divider(
                                height: 0,
                              ),
                              ListTile(
                                dense: true,
                                contentPadding:
                                    const EdgeInsets.symmetric(horizontal: 10),
                                title: Text(
                                  "Submitted At",
                                  style: TextStyle(
                                    fontSize: Theme.of(context)
                                        .primaryTextTheme
                                        .caption!
                                        .fontSize,
                                  ),
                                ),
                                subtitle: Text(
                                  DateFormat('dd MMM yyyy', 'id').format(
                                    data.submittedAt!,
                                  ),
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: Theme.of(context)
                                        .primaryTextTheme
                                        .subtitle1!
                                        .fontSize,
                                  ),
                                ),
                              ),
                              const Divider(
                                height: 0,
                              ),
                              ListTile(
                                dense: true,
                                contentPadding:
                                    const EdgeInsets.symmetric(horizontal: 10),
                                title: Text(
                                  "Status",
                                  style: TextStyle(
                                    fontSize: Theme.of(context)
                                        .primaryTextTheme
                                        .caption!
                                        .fontSize,
                                  ),
                                ),
                                subtitle: Text(
                                  data.status!,
                                  style: TextStyle(
                                    color: data.statusColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: Theme.of(context)
                                        .primaryTextTheme
                                        .subtitle1!
                                        .fontSize,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: Card(
                          child: Column(
                            children: [
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12.5),
                                child: Text(
                                  "Approver".toUpperCase(),
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: Theme.of(context)
                                        .primaryTextTheme
                                        .subtitle1!
                                        .fontSize,
                                  ),
                                ),
                              ),
                              const Divider(
                                height: 0,
                              ),
                              ListView.separated(
                                  padding: EdgeInsets.zero,
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemBuilder: (context, i) {
                                    return ListTile(
                                      dense: true,
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                              horizontal: 10),
                                      title: Text(
                                        data.approver[i].employeeName!,
                                        style: TextStyle(
                                          fontSize: Theme.of(context)
                                              .primaryTextTheme
                                              .subtitle1!
                                              .fontSize,
                                        ),
                                      ),
                                      subtitle: Text(
                                        data.approver[i].remark == ''
                                            ? '-'
                                            : data.approver[i].remark!,
                                        style: TextStyle(
                                          fontSize: Theme.of(context)
                                              .primaryTextTheme
                                              .caption!
                                              .fontSize,
                                        ),
                                      ),
                                      trailing: Text(
                                        data.approver[i].status!,
                                        style: TextStyle(
                                          color: data.approver[i].statusColor,
                                          fontStyle: FontStyle.italic,
                                          fontWeight: FontWeight.bold,
                                          fontSize: Theme.of(context)
                                              .primaryTextTheme
                                              .caption!
                                              .fontSize,
                                        ),
                                      ),
                                    );
                                  },
                                  separatorBuilder: (context, i) {
                                    return const Divider(
                                      height: 0,
                                    );
                                  },
                                  itemCount: data.approver.length)
                            ],
                          ),
                        ),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: Card(
                          child: Column(
                            children: [
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12.5),
                                child: Text(
                                  "Leave Date".toUpperCase(),
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: Theme.of(context)
                                        .primaryTextTheme
                                        .subtitle1!
                                        .fontSize,
                                  ),
                                ),
                              ),
                              const Divider(
                                height: 0,
                              ),
                              ListView.separated(
                                  padding: EdgeInsets.zero,
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemBuilder: (context, i) {
                                    return ListTile(
                                      title: Text(
                                          DateFormat('dd MMM yyyy', 'id')
                                              .format(data.leaveDate[i])),
                                    );
                                  },
                                  separatorBuilder: (context, i) {
                                    return const Divider(
                                      height: 0,
                                    );
                                  },
                                  itemCount: data.leaveDate.length)
                            ],
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    height = MediaQuery.of(context).size.height;
    deviceState = Provider.of<DeviceState>(context);
    return Scaffold(
      appBar: AppBar(
        elevation: 0.5,
        title: const Text("Leave Request"),
        actions: [
          IconButton(
            onPressed: () {
              showFilter();
            },
            icon: const Icon(Icons.filter_alt),
          )
        ],
      ),
      body: RefreshIndicator(
        onRefresh: initPage,
        child: buildBody(),
      ),
    );
  }

  Widget buildBody() {
    if (deviceState.loadingLeaveHistory) {
      return const Center(
        child: LoadingWidget(),
      );
    } else if (deviceState.codeLeaveHistory != 200) {
      return ErrorGetData(
        callBack: initPage,
        title: deviceState.msgLeaveHistory,
      );
    } else if (deviceState.leaveHistoryList.isEmpty) {
      return ErrorNoData(
        callBack: initPage,
      );
    } else {
      return ListView.separated(
          itemBuilder: (BuildContext context, int i) {
            return Ink(
              color: Colors.white,
              child: ListTile(
                onTap: () {
                  showDetail(data: deviceState.leaveHistoryList[i]);
                },
                leading: CircleAvatar(
                  radius: 20,
                  backgroundColor: deviceState.leaveHistoryList[i].statusColor,
                  child: const Center(
                    child: Icon(
                      Icons.dynamic_form_rounded,
                      color: Colors.white,
                    ),
                  ),
                ),
                trailing: const Icon(
                  Icons.chevron_right_rounded,
                  size: 15,
                ),
                horizontalTitleGap: 5,
                title: Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Text(
                    deviceState.leaveHistoryList[i].code!,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.only(bottom: 10, top: 5),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(deviceState.leaveHistoryList[i].leaveType!),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text(
                            "${DateFormat('dd MMM yyyy', 'id').format(deviceState.leaveHistoryList[i].startDate!)} - ${DateFormat('dd MMM yyyy', 'id').format(deviceState.leaveHistoryList[i].endDate!)}",
                            style: TextStyle(
                                fontSize: Theme.of(context)
                                    .primaryTextTheme
                                    .subtitle2!
                                    .fontSize),
                          ),
                          Text(
                            deviceState.leaveHistoryList[i].status!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                color:
                                    deviceState.leaveHistoryList[i].statusColor,
                                fontStyle: FontStyle.italic,
                                fontSize: Theme.of(context)
                                    .primaryTextTheme
                                    .caption!
                                    .fontSize),
                          )
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
          separatorBuilder: (BuildContext context, int i) {
            return const Divider(
              height: 0,
            );
          },
          itemCount: deviceState.leaveHistoryList.length);
    }
  }
}

import 'dart:convert';
import 'dart:developer';

import 'package:enta_mobile/components/modal/filter_overtime.dart';
import 'package:enta_mobile/models/general.dart';
import 'package:enta_mobile/models/overtime/history.dart';
import 'package:enta_mobile/providers/device.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../components/errors/get_data.dart';
import '../../components/errors/no_data.dart';
import '../../components/loading.dart';
import '../../utils/functions.dart';
import '../../utils/url.dart';

class OvertimeHistoryPage extends StatefulWidget {
  static const routeName = '/history/overtime';
  const OvertimeHistoryPage({Key? key}) : super(key: key);

  @override
  State<OvertimeHistoryPage> createState() => _OvertimeHistoryPageState();
}

class _OvertimeHistoryPageState extends State<OvertimeHistoryPage> {
  late DeviceState deviceState;
  DateTime? startDate = DateTime.now().subtract(const Duration(days: 30));
  DateTime? endDate = DateTime.now();
  List<String?> status = [];
  late SharedPreferences prefs;
  List<GeneralModel>? filterStatus = [
    GeneralModel(
      code: 'OPEN',
      label: 'Open',
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
          prefs.getString("prefix")! + UIUrl.overtimeHistory);
    } else {
      uriHistory = Uri.http(prefs.getString("host")!,
          prefs.getString("prefix")! + UIUrl.overtimeHistory);
    }
    // ignore: prefer_interpolation_to_compose_strings
    String statusText = '';
    if (status.isEmpty) {
      statusText = '';
    } else {
      statusText = status.join(',');
    }
    String planText = prefs.getString("username")! +
        DateFormat('yyyy-MM-dd', 'id').format(startDate!) +
        DateFormat('yyyy-MM-dd', 'id').format(endDate!) +
        statusText +
        deviceState.myAuth!.companyCode! +
        deviceState.deviceId! +
        deviceState.myAuth!.companyCode! +
        deviceState.deviceId!;
    String secretKey = UIFunction.encodeSha1(planText);
    String parameters = json.encode([
      prefs.getString("username"),
      DateFormat('yyyy-MM-dd', 'id').format(startDate!),
      DateFormat('yyyy-MM-dd', 'id').format(endDate!),
      statusText,
      deviceState.myAuth!.companyCode,
      deviceState.deviceId,
      secretKey
    ]);
    log("Parameter OT History $parameters");
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
      enableDrag: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ConstrainedBox(
        constraints: BoxConstraints(maxHeight: height * 0.5),
        child: FilterOvertimeModal(
          startDate: startDate,
          endDate: endDate,
          filterStatus: filterStatus,
        ),
      ),
    );
    if (result != null) {
      filterStatus = result['status'];
      startDate = result['start_date'];
      endDate = result['end_date'];
      var x = filterStatus!.where((element) => element.selected == true);
      status.clear();
      for (var element in x) {
        status.add(element.code);
      }
      setState(() {});
      initPage();
    }
  }

  Future<void> showDetail({OvertimeHistoryModel? data}) async {
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
                      "Detail Overtime".toUpperCase(),
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
                                  "OT Detail".toUpperCase(),
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
                                    return Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.stretch,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 10, vertical: 5),
                                          decoration: const BoxDecoration(
                                            color: Colors.yellow,
                                          ),
                                          child: Text(
                                            "${data.detail[i].shiftName} (${data.detail[i].shiftTimeIn}-${data.detail[i].shiftTimeOut})",
                                            style: TextStyle(
                                              fontSize: Theme.of(context)
                                                  .primaryTextTheme
                                                  .subtitle1!
                                                  .fontSize,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        data.detail[i].beforeInDate == null
                                            ? const SizedBox(
                                                height: 0,
                                              )
                                            : ListTile(
                                                dense: true,
                                                contentPadding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 10),
                                                title: Text(
                                                  "Before In",
                                                  style: TextStyle(
                                                    fontSize: Theme.of(context)
                                                        .primaryTextTheme
                                                        .caption!
                                                        .fontSize,
                                                  ),
                                                ),
                                                subtitle: Text(
                                                  "${DateFormat('dd MMM yyyy HH:mm', 'id').format(data.detail[i].beforeInDate!)} ",
                                                  style: TextStyle(
                                                    fontSize: Theme.of(context)
                                                        .primaryTextTheme
                                                        .subtitle1!
                                                        .fontSize,
                                                  ),
                                                ),
                                              ),
                                        data.detail[i].beforeOutDate == null
                                            ? const SizedBox(
                                                height: 0,
                                              )
                                            : ListTile(
                                                dense: true,
                                                contentPadding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 10),
                                                title: Text(
                                                  "Before Out",
                                                  style: TextStyle(
                                                    fontSize: Theme.of(context)
                                                        .primaryTextTheme
                                                        .caption!
                                                        .fontSize,
                                                  ),
                                                ),
                                                subtitle: Text(
                                                  "${DateFormat('dd MMM yyyy HH:mm', 'id').format(data.detail[i].beforeOutDate!)} ",
                                                  style: TextStyle(
                                                    fontSize: Theme.of(context)
                                                        .primaryTextTheme
                                                        .subtitle1!
                                                        .fontSize,
                                                  ),
                                                ),
                                              ),
                                        data.detail[i].afterInDate == null
                                            ? const SizedBox(
                                                height: 0,
                                              )
                                            : ListTile(
                                                dense: true,
                                                contentPadding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 10),
                                                title: Text(
                                                  "After In",
                                                  style: TextStyle(
                                                    fontSize: Theme.of(context)
                                                        .primaryTextTheme
                                                        .caption!
                                                        .fontSize,
                                                  ),
                                                ),
                                                subtitle: Text(
                                                  "${DateFormat('dd MMM yyyy HH:mm', 'id').format(data.detail[i].afterInDate!)} ",
                                                  style: TextStyle(
                                                    fontSize: Theme.of(context)
                                                        .primaryTextTheme
                                                        .subtitle1!
                                                        .fontSize,
                                                  ),
                                                ),
                                              ),
                                        data.detail[i].afterOutDate == null
                                            ? const SizedBox(
                                                height: 0,
                                              )
                                            : ListTile(
                                                dense: true,
                                                contentPadding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 10),
                                                title: Text(
                                                  "After Out",
                                                  style: TextStyle(
                                                    fontSize: Theme.of(context)
                                                        .primaryTextTheme
                                                        .caption!
                                                        .fontSize,
                                                  ),
                                                ),
                                                subtitle: Text(
                                                  "${DateFormat('dd MMM yyyy HH:mm', 'id').format(data.detail[i].afterOutDate!)} ",
                                                  style: TextStyle(
                                                    fontSize: Theme.of(context)
                                                        .primaryTextTheme
                                                        .subtitle1!
                                                        .fontSize,
                                                  ),
                                                ),
                                              ),
                                        ListTile(
                                          dense: true,
                                          contentPadding:
                                              const EdgeInsets.symmetric(
                                                  horizontal: 10),
                                          title: Text(
                                            "Total Overtime",
                                            style: TextStyle(
                                              fontSize: Theme.of(context)
                                                  .primaryTextTheme
                                                  .caption!
                                                  .fontSize,
                                            ),
                                          ),
                                          subtitle: Text(
                                            data.detail[i].totalOT,
                                            style: TextStyle(
                                              fontSize: Theme.of(context)
                                                  .primaryTextTheme
                                                  .subtitle1!
                                                  .fontSize,
                                            ),
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                  separatorBuilder: (context, i) {
                                    return const Divider(
                                      height: 0,
                                    );
                                  },
                                  itemCount: data.detail.length)
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
        title: const Text("Overtime Request"),
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
    if (deviceState.loadingOvertimeHistory) {
      return const Center(
        child: LoadingWidget(),
      );
    } else if (deviceState.codeOvertimeHistory != 200) {
      return ErrorGetData(
        callBack: initPage,
        title: deviceState.msgOvertimeHistory,
      );
    } else if (deviceState.overtimeHistoryList.isEmpty) {
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
                  showDetail(data: deviceState.overtimeHistoryList[i]);
                },
                leading: CircleAvatar(
                  radius: 20,
                  backgroundColor:
                      deviceState.overtimeHistoryList[i].statusColor,
                  child: const Center(
                    child: Icon(
                      Icons.more_time,
                      color: Colors.white,
                    ),
                  ),
                ),
                trailing: const Icon(
                  Icons.chevron_right_rounded,
                  size: 15,
                ),
                title: Text(
                  deviceState.overtimeHistoryList[i].code!,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(
                      "${DateFormat('dd MMM yyyy', 'id').format(deviceState.overtimeHistoryList[i].startDate!)} - ${DateFormat('dd MMM yyyy', 'id').format(deviceState.overtimeHistoryList[i].endDate!)}",
                      style: TextStyle(
                          fontSize: Theme.of(context)
                              .primaryTextTheme
                              .subtitle2!
                              .fontSize),
                    ),
                    Text(
                      deviceState.overtimeHistoryList[i].status!,
                      style: TextStyle(
                          color: deviceState.overtimeHistoryList[i].statusColor,
                          fontStyle: FontStyle.italic,
                          fontSize: Theme.of(context)
                              .primaryTextTheme
                              .caption!
                              .fontSize),
                    )
                  ],
                ),
              ),
            );
          },
          separatorBuilder: (BuildContext context, int i) {
            return const Divider(
              height: 0,
            );
          },
          itemCount: deviceState.overtimeHistoryList.length);
    }
  }
}

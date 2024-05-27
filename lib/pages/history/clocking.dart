import 'dart:convert';
import 'dart:developer';

import 'package:enta_mobile/args/general.dart';
import 'package:enta_mobile/components/modal/filter_overtime.dart';
import 'package:enta_mobile/models/general.dart';
import 'package:enta_mobile/pages/history/clocking_detail.dart';
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

class ClockingHistoryPage extends StatefulWidget {
  static const routeName = '/history/clocking';
  const ClockingHistoryPage({Key? key}) : super(key: key);

  @override
  State<ClockingHistoryPage> createState() => _ClockingHistoryPageState();
}

class _ClockingHistoryPageState extends State<ClockingHistoryPage> {
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
          prefs.getString("prefix")! + UIUrl.clockingHistory);
    } else {
      uriHistory = Uri.http(prefs.getString("host")!,
          prefs.getString("prefix")! + UIUrl.clockingHistory);
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
    log("Parameter Tap History $parameters");
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

  @override
  Widget build(BuildContext context) {
    height = MediaQuery.of(context).size.height;
    deviceState = Provider.of<DeviceState>(context);
    return Scaffold(
      appBar: AppBar(
        elevation: 0.5,
        title: const Text("Tap In/Out Request"),
        // actions: [
        //   IconButton(
        //     onPressed: () {
        //       showFilter();
        //     },
        //     icon: const Icon(Icons.filter_alt),
        //   )
        // ],
      ),
      body: RefreshIndicator(
        onRefresh: initPage,
        child: buildBody(),
      ),
    );
  }

  Widget buildBody() {
    if (deviceState.loadingClockingHistory) {
      return const Center(
        child: LoadingWidget(),
      );
    } else if (deviceState.codeClockingHistory != 200) {
      return ErrorGetData(
        callBack: initPage,
        title: deviceState.msgClockingHistory,
      );
    } else if (deviceState.clockingHistoryList.isEmpty) {
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
                  Navigator.pushNamed(
                    context,
                    ClockingHistoryDetailPage.routeName,
                    arguments: GeneralArgs(
                        clocking: deviceState.clockingHistoryList[i]),
                  );
                },
                leading: CircleAvatar(
                  radius: 20,
                  backgroundColor:
                      deviceState.clockingHistoryList[i].statusColor,
                  child: Center(
                    child: Icon(
                      deviceState.clockingHistoryList[i].type!.toUpperCase() ==
                              'IN'
                          ? Icons.arrow_upward
                          : deviceState.clockingHistoryList[i].type!
                                      .toUpperCase() ==
                                  'OUT'
                              ? Icons.arrow_downward
                              : Icons.error,
                      color: Colors.white,
                    ),
                  ),
                ),
                trailing: const Icon(
                  Icons.chevron_right_rounded,
                  size: 15,
                ),
                title: Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Text(
                    DateFormat('dd MMM yyyy', 'id')
                        .format(deviceState.clockingHistoryList[i].date),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.only(bottom: 10, top: 5),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text(
                        deviceState.clockingHistoryList[i].time!,
                        style: TextStyle(
                            fontSize: Theme.of(context)
                                .primaryTextTheme
                                .subtitle2!
                                .fontSize),
                      ),
                      Text(
                        deviceState.clockingHistoryList[i].status!,
                        style: TextStyle(
                            color:
                                deviceState.clockingHistoryList[i].statusColor,
                            fontStyle: FontStyle.italic,
                            fontSize: Theme.of(context)
                                .primaryTextTheme
                                .caption!
                                .fontSize),
                      )
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
          itemCount: deviceState.clockingHistoryList.length);
    }
  }
}

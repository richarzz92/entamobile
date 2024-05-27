import 'dart:developer';

import 'package:enta_mobile/models/general.dart';
import 'package:enta_mobile/providers/device.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:provider/provider.dart';

import '../../utils/functions.dart';

class FilterLeaveModal extends StatefulWidget {
  final DateTime? startDate, endDate;
  final List<GeneralModel>? filterStatus;
  final GeneralModel? leaveType;
  const FilterLeaveModal(
      {Key? key,
      this.startDate,
      this.endDate,
      this.filterStatus,
      this.leaveType})
      : super(key: key);

  @override
  State<FilterLeaveModal> createState() => _FilterLeaveModalState();
}

class _FilterLeaveModalState extends State<FilterLeaveModal> {
  DateTime? startDate = DateTime.now();
  DateTime? endDate = DateTime.now();
  List<GeneralModel>? filterStatus = [];
  GeneralModel? leaveType;
  late double height;
  late DeviceState deviceState;
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      startDate = widget.startDate;
      endDate = widget.endDate;
      filterStatus = widget.filterStatus;
      leaveType = widget.leaveType;
      setState(() {});
    });
  }

  @override
  void dispose() {
    super.dispose();
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
      firstDate: DateTime(DateTime.now().year - 2),
      lastDate: DateTime(DateTime.now().year + 2),
      initialDateRange: DateTimeRange(
        end: endDate!,
        start: startDate!,
      ),
    );
    if (picked == null) {
    } else {
      int different = picked.end.difference(picked.start).inDays;
      if (different > 31) {
        UIFunction.showToastMessage(
          context: context,
          isError: true,
          message:
              'History period that can be selected is a maximum of 31 days',
        );
      } else {
        startDate = picked.start;
        endDate = picked.end;
        setState(() {});
      }
    }
    setState(() {});
  }

  Future<void> showListLeaveType() async {
    FocusScope.of(context).requestFocus(FocusNode());
    await showMaterialModalBottomSheet(
      context: context,
      expand: false,
      enableDrag: false,
      builder: (context) => ConstrainedBox(
        constraints: BoxConstraints(maxHeight: height * 0.65),
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
                    itemCount: deviceState.leaveTypeList.length,
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
                          leaveType = deviceState.leaveTypeList[i];

                          setState(() {});
                          Navigator.pop(context);
                        },
                        title: Text(
                          deviceState.leaveTypeList[i].label!,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing: leaveType == null ||
                                leaveType!.id != deviceState.leaveTypeList[i].id
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

  @override
  Widget build(BuildContext context) {
    deviceState = Provider.of<DeviceState>(context);
    height = MediaQuery.of(context).size.height;
    return Material(
        child: CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        leading: InkWell(
          onTap: () {
            Navigator.pop(context);
          },
          child: Icon(
            Icons.close,
            size: Theme.of(context).primaryTextTheme.headline6!.fontSize! + 1,
          ),
        ),
        middle: Text(
          "Filter",
          style: TextStyle(
            fontWeight: FontWeight.normal,
            fontSize: Theme.of(context).primaryTextTheme.subtitle1!.fontSize,
          ),
        ),
        trailing: InkWell(
          onTap: () {
            for (var element in filterStatus!) {
              element.selected = true;
            }
            startDate = DateTime.now().subtract(const Duration(days: 30));
            endDate = DateTime.now();
            leaveType = GeneralModel(id: 0, label: 'All');
            setState(() {});
          },
          child: Text(
            "Reset",
            style: TextStyle(
              color: Theme.of(context).primaryColor,
              fontSize: Theme.of(context).primaryTextTheme.subtitle2!.fontSize,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: ListView(
                padding:
                    const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                children: [
                  ListTile(
                    dense: true,
                    onTap: () {
                      dateTimeRangePicker();
                    },
                    contentPadding: const EdgeInsets.symmetric(horizontal: 0),
                    title: Text(
                      "Start End Date",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: Theme.of(context)
                            .primaryTextTheme
                            .subtitle1!
                            .fontSize,
                      ),
                    ),
                    subtitle: Text(
                      "${DateFormat('dd MMMM yyyy', 'id').format(startDate!)} - ${DateFormat('dd MMMM yyyy', 'id').format(endDate!)}",
                      style: TextStyle(
                        fontSize: Theme.of(context)
                            .primaryTextTheme
                            .subtitle2!
                            .fontSize,
                      ),
                    ),
                    trailing: const Icon(Icons.chevron_right),
                  ),
                  const Divider(
                    height: 0,
                  ),
                  ListTile(
                    onTap: () {
                      showListLeaveType();
                    },
                    contentPadding: const EdgeInsets.symmetric(horizontal: 0),
                    title: Text(
                      "Leave Type",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: Theme.of(context)
                            .primaryTextTheme
                            .subtitle1!
                            .fontSize,
                      ),
                    ),
                    subtitle: Text(
                      leaveType == null ? '-' : leaveType!.label!,
                      style: TextStyle(
                        fontSize: Theme.of(context)
                            .primaryTextTheme
                            .subtitle2!
                            .fontSize,
                      ),
                    ),
                    trailing: const Icon(Icons.chevron_right),
                  ),
                  const Divider(
                    height: 0,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 10, bottom: 10),
                    child: Text(
                      "Status",
                      style: TextStyle(
                        fontSize: Theme.of(context)
                            .primaryTextTheme
                            .subtitle1!
                            .fontSize,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: filterStatus!.length,
                    itemBuilder: (BuildContext context, int i) {
                      return InkWell(
                        onTap: () {
                          filterStatus![i].selected = !filterStatus![i].selected!;
                          setState(() {});
                        },
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                filterStatus![i].label!,
                                style: TextStyle(
                                  fontSize: Theme.of(context)
                                      .primaryTextTheme
                                      .subtitle1!
                                      .fontSize,
                                ),
                              ),
                            ),
                            Checkbox(
                              value: filterStatus![i].selected,
                              onChanged: (bool? value) {
                                filterStatus![i].selected = value;

                                setState(() {});
                              },
                            )
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
              child: ElevatedButton(
                onPressed: () {
                  Map<String, dynamic> result = <String, dynamic>{};
                  result["start_date"] = startDate;
                  result["end_date"] = endDate;
                  result["status"] = filterStatus;
                  result["leave_type"] = leaveType;
                  log(leaveType!.id.toString());
                  Navigator.pop(context, result);
                },
                child: const Text("Submit"),
              ),
            )
          ],
        ),
      ),
    ));
  }
}

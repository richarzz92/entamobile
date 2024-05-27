import 'package:enta_mobile/models/general.dart';
import 'package:enta_mobile/utils/functions.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class FilterOvertimeModal extends StatefulWidget {
  final DateTime? startDate, endDate;
  final List<GeneralModel>? filterStatus;
  const FilterOvertimeModal(
      {Key? key, this.startDate, this.endDate, this.filterStatus})
      : super(key: key);

  @override
  State<FilterOvertimeModal> createState() => _FilterOvertimeModalState();
}

class _FilterOvertimeModalState extends State<FilterOvertimeModal> {
  DateTime? startDate = DateTime.now();
  DateTime? endDate = DateTime.now();
  List<GeneralModel>? filterStatus = [];
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      startDate = widget.startDate;
      endDate = widget.endDate;
      filterStatus = widget.filterStatus;
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
  }

  @override
  Widget build(BuildContext context) {
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

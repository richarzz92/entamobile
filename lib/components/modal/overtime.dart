import 'package:enta_mobile/models/overtime/request.dart';
import 'package:enta_mobile/models/shift_schedule.dart';
import 'package:enta_mobile/providers/device.dart';
import 'package:enta_mobile/utils/functions.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:jiffy/jiffy.dart';
import 'package:provider/provider.dart';

class OvertimeModal extends StatefulWidget {
  final DateTime? date;
  final OvertimeEmployeeRequestModel? employee;
  final OvertimeDateRequestModel? data;
  final ShiftScheduleModel? schedule;
  const OvertimeModal(
      {Key? key, this.date, this.employee, required this.schedule, this.data})
      : super(key: key);

  @override
  State<OvertimeModal> createState() => _OvertimeModalState();
}

class _OvertimeModalState extends State<OvertimeModal> {
  final TextEditingController beforeInText = TextEditingController();
  final TextEditingController beforeOutText = TextEditingController();
  final TextEditingController afterInText = TextEditingController();
  final TextEditingController afterOutText = TextEditingController();
  final TextEditingController totalOTBeforeText = TextEditingController();
  final TextEditingController totalOTAfterText = TextEditingController();
  int? totalOTBefore, totalOTAfter;
  DateTime? selectedBeforeIn = DateTime.now();
  DateTime? selectedBeforeOut = DateTime.now();
  DateTime? selectedAfterIn = DateTime.now();
  DateTime? selectedAfterOut = DateTime.now();
  // TimeOfDay selectedBeforeIn = TimeOfDay.fromDateTime(DateTime.now());
  // TimeOfDay selectedBeforeOut = TimeOfDay.fromDateTime(DateTime.now());
  // TimeOfDay selectedAfterIn = TimeOfDay.fromDateTime(DateTime.now());
  // TimeOfDay selectedAfterOut = TimeOfDay.fromDateTime(DateTime.now());
  final formKey = GlobalKey<FormState>();
  late DeviceState deviceState;
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      if (widget.data != null) {
        selectedBeforeIn = widget.data!.beforeIn ?? widget.date;
        selectedBeforeOut = widget.data!.beforeOut ?? widget.date;
        if (widget.data!.beforeIn != null) {
          beforeInText.text =
              DateFormat('dd MMMM yyyy HH:mm', 'id').format(selectedBeforeIn!);

          beforeOutText.text =
              DateFormat('dd MMMM yyyy HH:mm', 'id').format(selectedBeforeOut!);
          var totalOT = Jiffy(selectedBeforeOut)
              .diff(Jiffy(selectedBeforeIn), Units.MINUTE);
          totalOTBeforeText.text = "$totalOT mins";
          totalOTBefore = totalOT as int?;
        }

        selectedAfterIn = widget.data!.afterIn ?? widget.date;
        selectedAfterOut = widget.data!.afterOut ?? widget.date;
        if (widget.data!.afterIn != null) {
          afterInText.text =
              DateFormat('dd MMMM yyyy HH:mm', 'id').format(selectedAfterIn!);

          afterOutText.text =
              DateFormat('dd MMMM yyyy HH:mm', 'id').format(selectedAfterOut!);
          var totalOT = Jiffy(selectedAfterOut)
              .diff(Jiffy(selectedAfterIn), Units.MINUTE);
          totalOTAfterText.text = "$totalOT mins";
          totalOTAfter = totalOT as int?;
        }
      } else {
        selectedBeforeIn = widget.date;
        selectedBeforeOut = widget.date;
        selectedAfterIn = widget.date;
        selectedAfterOut = widget.date;
      }
      setState(() {});
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<DateTime?> getDate({required DateTime selectedDate}) {
    return showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: widget.date!,
      lastDate: selectedDate.add(const Duration(days: 1)),
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
              data:
                  MediaQuery.of(context).copyWith(alwaysUse24HourFormat: false),
              child: child!),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    deviceState = Provider.of<DeviceState>(context);
    return Form(
      key: formKey,
      autovalidateMode: AutovalidateMode.always,
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
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    DateFormat('dd MMM yyyy', 'id').format(widget.date!),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize:
                          Theme.of(context).primaryTextTheme.subtitle1!.fontSize,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  Container(
                    color: Colors.yellow,
                    child: Text(
                      deviceState.getInfoSchedule(
                          date: widget.date,
                          employeeId: widget.employee!.employee!.employeeId)!,
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
              child: Column(
                children: [
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          "Before In",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: Theme.of(context)
                                .primaryTextTheme
                                .caption!
                                .fontSize,
                          ),
                        ),
                        InkWell(
                          splashColor: Colors.transparent,
                          focusColor: Colors.transparent,
                          hoverColor: Colors.transparent,
                          highlightColor: Colors.transparent,
                          onTap: () async {
                            DateTime? resultDate =
                                await getDate(selectedDate: selectedBeforeIn!);
                            if (resultDate != null) {
                              TimeOfDay? resultTime = await timePicker(
                                  initialTime: TimeOfDay(
                                      hour: selectedBeforeIn!.hour,
                                      minute: selectedBeforeIn!.minute));
                              if (resultTime != null) {
                                selectedBeforeIn = DateTime(
                                    resultDate.year,
                                    resultDate.month,
                                    resultDate.day,
                                    resultTime.hour,
                                    resultTime.minute);
                                beforeInText.text =
                                    DateFormat('dd MMMM yyyy HH:mm', 'id')
                                        .format(selectedBeforeIn!);
                                if (beforeInText.text.isNotEmpty &&
                                    beforeOutText.text.isNotEmpty) {
                                  var totalOT = Jiffy(selectedBeforeOut).diff(
                                      Jiffy(selectedBeforeIn), Units.MINUTE);
                                  totalOTBeforeText.text = "$totalOT mins";
                                  totalOTBefore = totalOT as int?;
                                }

                                setState(() {});
                              }
                            }
                          },
                          child: IgnorePointer(
                            ignoring: true,
                            child: TextFormField(
                              maxLines: 1,
                              controller: beforeInText,
                              validator: (value) {
                                if (value!.isEmpty) {
                                  if (beforeOutText.text.isEmpty) {
                                    return null;
                                  } else {
                                    return 'Before In is required';
                                  }
                                } else {
                                  if (beforeInText.text.isNotEmpty &&
                                      beforeOutText.text.isNotEmpty) {
                                    if (selectedBeforeOut!
                                        .isAfter(selectedBeforeIn!)) {
                                      if (totalOTBefore! >
                                          widget.schedule!.maxOT) {
                                        int hour = widget.schedule!.maxOT ~/ 60;
                                        return 'Maximum OT is $hour Hours';
                                      } else {
                                        return null;
                                      }
                                    } else {
                                      return 'Invalid total OT Before';
                                    }
                                  } else {
                                    return null;
                                  }
                                }
                              },
                              decoration: const InputDecoration(
                                hintText: "dd-mm-yyyy HH:mm",
                                contentPadding: EdgeInsets.symmetric(
                                    horizontal: 0, vertical: 0),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Text(
                          "Before Out",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: Theme.of(context)
                                .primaryTextTheme
                                .caption!
                                .fontSize,
                          ),
                        ),
                        InkWell(
                          splashColor: Colors.transparent,
                          focusColor: Colors.transparent,
                          hoverColor: Colors.transparent,
                          highlightColor: Colors.transparent,
                          onTap: () async {
                            DateTime? resultDate =
                                await getDate(selectedDate: selectedBeforeOut!);
                            if (resultDate != null) {
                              TimeOfDay? resultTime = await timePicker(
                                  initialTime: TimeOfDay(
                                      hour: selectedBeforeOut!.hour,
                                      minute: selectedBeforeOut!.minute));
                              if (resultTime != null) {
                                selectedBeforeOut = DateTime(
                                    resultDate.year,
                                    resultDate.month,
                                    resultDate.day,
                                    resultTime.hour,
                                    resultTime.minute);
                                beforeOutText.text =
                                    DateFormat('dd MMMM yyyy HH:mm', 'id')
                                        .format(selectedBeforeOut!);
                                if (beforeInText.text.isNotEmpty &&
                                    beforeOutText.text.isNotEmpty) {
                                  var totalOT = Jiffy(selectedBeforeOut).diff(
                                      Jiffy(selectedBeforeIn), Units.MINUTE);
                                  totalOTBeforeText.text = "$totalOT mins";
                                  totalOTBefore = totalOT as int?;
                                }
                                setState(() {});
                              }
                            }
                          },
                          child: IgnorePointer(
                            ignoring: true,
                            child: TextFormField(
                              maxLines: 1,
                              controller: beforeOutText,
                              validator: (value) {
                                if (value!.isEmpty) {
                                  if (beforeInText.text.isEmpty) {
                                    return null;
                                  } else {
                                    return 'Before Out is required';
                                  }
                                } else {
                                  if (beforeInText.text.isNotEmpty &&
                                      beforeOutText.text.isNotEmpty) {
                                    if (selectedBeforeOut!
                                        .isAfter(selectedBeforeIn!)) {
                                      if (totalOTBefore! >
                                          widget.schedule!.maxOT) {
                                        int hour = widget.schedule!.maxOT ~/ 60;
                                        return 'Maximum OT is $hour Hours';
                                      } else {
                                        return null;
                                      }
                                    } else {
                                      return 'Invalid total OT Before';
                                    }
                                  } else {
                                    return null;
                                  }
                                }
                              },
                              decoration: const InputDecoration(
                                hintText: "dd-mm-yyyy HH:mm",
                                contentPadding: EdgeInsets.symmetric(
                                    horizontal: 0, vertical: 10),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Visibility(
                          visible: beforeInText.text.isNotEmpty &&
                                  beforeOutText.text.isNotEmpty &&
                                  totalOTBefore != null
                              ? true
                              : false,
                          child: Container(
                            color: Colors.yellow,
                            padding: const EdgeInsets.all(5),
                            child: Text("Total OT Before $totalOTBefore mins"),
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Text(
                          "After In",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: Theme.of(context)
                                .primaryTextTheme
                                .caption!
                                .fontSize,
                          ),
                        ),
                        InkWell(
                          splashColor: Colors.transparent,
                          focusColor: Colors.transparent,
                          hoverColor: Colors.transparent,
                          highlightColor: Colors.transparent,
                          onTap: () async {
                            DateTime? resultDate =
                                await getDate(selectedDate: selectedAfterIn!);
                            if (resultDate != null) {
                              TimeOfDay? resultTime = await timePicker(
                                  initialTime: TimeOfDay(
                                      hour: selectedAfterIn!.hour,
                                      minute: selectedAfterIn!.minute));
                              if (resultTime != null) {
                                selectedAfterIn = DateTime(
                                    resultDate.year,
                                    resultDate.month,
                                    resultDate.day,
                                    resultTime.hour,
                                    resultTime.minute);
                                afterInText.text =
                                    DateFormat('dd MMMM yyyy HH:mm', 'id')
                                        .format(selectedAfterIn!);
                                if (afterInText.text.isNotEmpty &&
                                    afterOutText.text.isNotEmpty) {
                                  var totalOT = Jiffy(selectedAfterOut).diff(
                                      Jiffy(selectedAfterIn), Units.MINUTE);
                                  totalOTBeforeText.text = "$totalOT mins";
                                  totalOTBefore = totalOT as int?;
                                }

                                setState(() {});
                              }
                            }
                          },
                          child: IgnorePointer(
                            ignoring: true,
                            child: TextFormField(
                              maxLines: 1,
                              controller: afterInText,
                              validator: (value) {
                                if (value!.isEmpty) {
                                  if (afterOutText.text.isEmpty) {
                                    return null;
                                  } else {
                                    return 'After In is required';
                                  }
                                } else {
                                  if (afterInText.text.isNotEmpty &&
                                      afterOutText.text.isNotEmpty) {
                                    if (selectedAfterOut!
                                        .isAfter(selectedAfterIn!)) {
                                      if (totalOTAfter! >
                                          widget.schedule!.maxOT) {
                                        int hour = widget.schedule!.maxOT ~/ 60;
                                        return 'Maximum OT is $hour Hours';
                                      } else {
                                        return null;
                                      }
                                    } else {
                                      return 'Invalid total OT After';
                                    }
                                  } else {
                                    return null;
                                  }
                                }
                              },
                              decoration: const InputDecoration(
                                hintText: "dd-mm-yyyy HH:mm",
                                contentPadding: EdgeInsets.symmetric(
                                    horizontal: 0, vertical: 10),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Text(
                          "After Out",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: Theme.of(context)
                                .primaryTextTheme
                                .caption!
                                .fontSize,
                          ),
                        ),
                        InkWell(
                          splashColor: Colors.transparent,
                          focusColor: Colors.transparent,
                          hoverColor: Colors.transparent,
                          highlightColor: Colors.transparent,
                          onTap: () async {
                            DateTime? resultDate =
                                await getDate(selectedDate: selectedAfterOut!);
                            if (resultDate != null) {
                              TimeOfDay? resultTime = await timePicker(
                                  initialTime: TimeOfDay(
                                      hour: selectedAfterOut!.hour,
                                      minute: selectedAfterOut!.minute));
                              if (resultTime != null) {
                                selectedAfterOut = DateTime(
                                    resultDate.year,
                                    resultDate.month,
                                    resultDate.day,
                                    resultTime.hour,
                                    resultTime.minute);
                                afterOutText.text =
                                    DateFormat('dd MMMM yyyy HH:mm', 'id')
                                        .format(selectedAfterOut!);
                                if (afterInText.text.isNotEmpty &&
                                    afterOutText.text.isNotEmpty) {
                                  var totalOT = Jiffy(selectedAfterOut).diff(
                                      Jiffy(selectedAfterIn), Units.MINUTE);
                                  totalOTAfterText.text = "$totalOT mins";
                                  totalOTAfter = totalOT as int?;
                                }

                                setState(() {});
                              }
                            }
                          },
                          child: IgnorePointer(
                            ignoring: true,
                            child: TextFormField(
                              maxLines: 1,
                              controller: afterOutText,
                              validator: (value) {
                                if (value!.isEmpty) {
                                  if (afterInText.text.isEmpty) {
                                    return null;
                                  } else {
                                    return 'After Out is required';
                                  }
                                } else {
                                  if (afterInText.text.isNotEmpty &&
                                      afterOutText.text.isNotEmpty) {
                                    if (selectedAfterOut!
                                        .isAfter(selectedAfterIn!)) {
                                      if (totalOTAfter! >
                                          widget.schedule!.maxOT) {
                                        int hour = widget.schedule!.maxOT ~/ 60;
                                        return 'Maximum OT is $hour Hours';
                                      } else {
                                        return null;
                                      }
                                    } else {
                                      return 'Invalid total OT After';
                                    }
                                  } else {
                                    return null;
                                  }
                                }
                              },
                              decoration: const InputDecoration(
                                hintText: "dd-mm-yyyy HH:mm",
                                contentPadding: EdgeInsets.symmetric(
                                    horizontal: 0, vertical: 10),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Visibility(
                          visible: afterInText.text.isNotEmpty &&
                                  afterOutText.text.isNotEmpty &&
                                  totalOTAfter != null
                              ? true
                              : false,
                          child: Container(
                            color: Colors.yellow,
                            padding: const EdgeInsets.all(5),
                            child: Text("Total OT After $totalOTAfter mins"),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Divider(
              height: 0,
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        if (formKey.currentState!.validate()) {
                          if (afterInText.text.isEmpty &&
                              afterOutText.text.isEmpty &&
                              beforeInText.text.isEmpty &&
                              beforeOutText.text.isEmpty) {
                            UIFunction.showToastMessage(
                              context: context,
                              isError: true,
                              position: 'TOP',
                              title: 'Ooops',
                              message: 'Please fill in the blank space',
                            );
                          } else {
                            OvertimeDateRequestModel result =
                                OvertimeDateRequestModel(
                              date: widget.date,
                              beforeIn: beforeInText.text.isNotEmpty
                                  ? selectedBeforeIn
                                  : null,
                              beforeOut: beforeOutText.text.isNotEmpty
                                  ? selectedBeforeOut
                                  : null,
                              afterIn: afterInText.text.isNotEmpty
                                  ? selectedAfterIn
                                  : null,
                              afterOut: afterOutText.text.isNotEmpty
                                  ? selectedAfterOut
                                  : null,
                            );
                            Navigator.pop(context, result);
                          }
                        }
                      },
                      child: const Text("Oke"),
                    ),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        selectedBeforeIn = widget.date;
                        selectedBeforeOut = widget.date;
                        selectedAfterIn = widget.date;
                        selectedAfterOut = widget.date;
                        beforeInText.text = '';
                        afterInText.text = '';
                        beforeOutText.text = '';
                        afterOutText.text = '';
                        totalOTAfter = null;
                        totalOTBefore = null;
                        setState(() {});
                      },
                      style: ElevatedButton.styleFrom(
                        primary: Colors.grey,
                      ),
                      child: const Text("Reset"),
                    ),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

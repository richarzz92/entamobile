import 'package:enta_mobile/models/clocking.dart';
import 'package:enta_mobile/models/history.dart';
import 'package:flutter/material.dart';

class GeneralArgs {
  Key? key;
  String? alertText, url, title, type;
  bool? showAlert;
  ClockingHistoryModel? clocking;

  GeneralArgs({
    this.key,
    this.showAlert,
    this.alertText,
    this.url,
    this.title,
    this.clocking,
    this.type, HistoryModel? history,
  });
}

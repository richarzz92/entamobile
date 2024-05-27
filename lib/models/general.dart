import 'package:flutter/material.dart';

class GeneralModel {
  int? id;
  String? label, message, image, code, title, subtitle;
  String? route, url, path;
  IconData? icon;
  bool? visible, success, selected;
  bool? checkLeaveBalance;
  dynamic args;
  List<GeneralModel>? children;

  GeneralModel(
      {this.id,
      this.label,
      this.route,
      this.url,
      this.message,
      this.children,
      this.args,
      this.title,
      this.subtitle,
      this.image,
      this.icon,
      this.path,
      this.selected,
      this.success,
      this.code,
      this.visible,
      this.checkLeaveBalance});
}

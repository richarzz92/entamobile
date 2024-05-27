import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;
import 'dart:developer';

import 'package:another_flushbar/flushbar.dart';
import 'package:crypto/crypto.dart';
import 'package:dio/adapter.dart';
import 'package:dio/dio.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../components/loading.dart';
import '../models/response_api.dart';

class UIFunction {
  static Future<void> unsetPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    prefs.setString("token", "");
    prefs.setString("employee_name", "");
    prefs.setString("photo_profile", "");
    prefs.setString("username", "");
  }

  static void showToastMessage(
      {required BuildContext context,
      required bool isError,
      String? title,
      String? message,
      String? position}) async {
    Flushbar(
            margin: const EdgeInsets.all(8),
            borderRadius: BorderRadius.circular(8),
            backgroundColor: isError ? Colors.red : Colors.green,
            flushbarPosition: position == 'TOP'
                ? FlushbarPosition.TOP
                : FlushbarPosition.BOTTOM,
            duration: const Duration(seconds: 4),
            icon: const Icon(
              Icons.info_outline_rounded,
              color: Colors.white,
            ),
            title: title == null || title == '' ? null : title,
            message: message)
        .show(context);
  }

  static Future<ResponseAPI> callAPIDIO(
      {required String url,
      String? method,
      dynamic formData,
      Map? header,
      isToken = false}) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    Map<String, String?> headers = <String, String?>{};
    String? deviceId = prefs.getString('device_id');
    String token = prefs.getString('token') ?? "";
    String companyCode = prefs.getString('company_code') ?? "";
    String username = '';
    if (prefs.getString("token") != "") {
      username = prefs.getString('username') ?? "";
    } else {
      username = "";
    }

    String employeeName = prefs.getString('employee_name') ?? "";
    String platfrom = prefs.getString('device_platform') ?? "";
    int codeVersion = prefs.getInt('code_version') ?? 0;
    headers["Authorization"] = "EntaAuth $token";
    headers["X-Enta-CompanyCode"] = companyCode;
    headers["X-Enta-DeviceId"] = deviceId;
    headers["Accept"] = "application/json";
    if (platfrom != "") {
      headers["X-Enta-Platform"] = platfrom;
    }
    if (codeVersion != 0) {
      headers["X-Enta-CodeVersion"] = codeVersion.toString();
    }
    Map<String, dynamic> result = <String, dynamic>{};
    var dio = Dio();
    if (!kIsWeb) {
      (dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate =
          (HttpClient client) {
        client.badCertificateCallback =
            (X509Certificate cert, String host, int port) => true;
        return client;
      };
    }
    try {
      bool success = false;
      Response response;
      log(url);
      if (method == 'POST') {
        var dio = Dio();

        response = await dio.post(
          url,
          data: formData,
          onSendProgress: (int sent, int total) {},
          options: Options(
            sendTimeout: 60000,
            receiveTimeout: 60000,
            headers: headers,
            method: method,
            responseType: ResponseType.json,
          ),
        );
      } else {
        response = await dio.put(
          url,
          data: formData,
          onSendProgress: (int sent, int total) {},
          options: Options(
              sendTimeout: 60000,
              receiveTimeout: 60000,
              headers: headers,
              method: method,
              responseType: ResponseType.json),
        );
      }

      log(response.statusCode.toString());
      if (response.statusCode == 200) {
        result['statusCode'] = response.statusCode;
        success = true;
        if (response.data[0] != 'S' && !isToken) {
          FirebaseCrashlytics.instance.setCustomKey('url', url);
          FirebaseCrashlytics.instance.setCustomKey('username', username);
          FirebaseCrashlytics.instance
              .setCustomKey('message', response.data.toString());
          await FirebaseCrashlytics.instance.recordError(
            'Error Call API',
            null,
            reason: 'Call API $url',
            information: [
              DiagnosticsNode.message("Header        : ${headers.toString()}"),
              DiagnosticsNode.message("Company Code  : $companyCode"),
              DiagnosticsNode.message("Username      : $username"),
              DiagnosticsNode.message("Employee Name : $employeeName"),
            ],
            fatal: false,
          );
        }
        // log(response.toString());
      }

      return ResponseAPI(
        success,
        response.statusCode,
        'Ok',
        response.data,
      );
    } on DioError catch (e, stacktrace) {
      FirebaseCrashlytics.instance.setCustomKey('url', url);
      FirebaseCrashlytics.instance.setCustomKey('header', headers.toString());
      FirebaseCrashlytics.instance.setCustomKey('username', username);
      if (e.response != null) {
        FirebaseCrashlytics.instance
            .setCustomKey('status code', e.response!.statusCode!);

        FirebaseCrashlytics.instance
            .setCustomKey('response message', e.response!.statusMessage!);
      } else {
        FirebaseCrashlytics.instance.setCustomKey('status code', 0);
        FirebaseCrashlytics.instance.setCustomKey('response message', '-');
      }

      String? message = '';
      int? statusCode = 0;
      if (e.response != null) {
        statusCode = e.response!.statusCode;
        result['statusCode'] = e.response!.statusCode;
        if (statusCode == 404) {
          message = e.response!.statusMessage;
        } else {
          // log(e.response.data.toString());
          if (e.response!.data.isNotEmpty) {
            // if (e.response.data.containsKey('ExceptionMessage')) {
            // message = e.response.data['ExceptionMessage'];
            // } else {
            message = e.response!.data.toString();
            // }
          } else {
            message = e.response!.statusMessage;
          }
        }
      } else {
        statusCode = 0;
        message = e.message;
      }
      FirebaseCrashlytics.instance.setCustomKey('message', message!);
      await FirebaseCrashlytics.instance.recordError(
        e,
        stacktrace,
        reason: 'Call API $url',
        information: [
          DiagnosticsNode.message("Header        : ${headers.toString()}"),
          DiagnosticsNode.message("Company Code  : $companyCode"),
          DiagnosticsNode.message("Username      : $username"),
        ],
        fatal: false,
      );
      log("$url [$statusCode] : $message");
      return ResponseAPI(false, statusCode, message, null);
    }
  }

  static Future<Future<Object?>> showDialogLoadingBlank({required BuildContext context}) async {
    return showGeneralDialog(
      context: context,
      pageBuilder: (BuildContext buildContext, Animation<double> animation,
          Animation<double> secondaryAnimation) {
        return SafeArea(
          child: Builder(builder: (BuildContext context) {
            return WillPopScope(
              onWillPop: () async => false,
              child: const Center(
                child: LoadingWidget(
                  color: Colors.white,
                ),
              ),
            );
          }),
        );
      },
      barrierDismissible: false,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 150),
    );
  }

  static Future<void> showDialogLoading({required BuildContext context}) async =>
      showGeneralDialog(
        context: context,
        pageBuilder: (BuildContext buildContext, Animation<double> animation,
            Animation<double> secondaryAnimation) {
          return SafeArea(
            child: WillPopScope(
              onWillPop: () async => false,
              child: AlertDialog(
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
                content: Row(
                  children: const <Widget>[
                    LoadingWidget(),
                    SizedBox(
                      width: 20,
                    ),
                    Text("Please wait..."),
                  ],
                ),
              ),
            ),
          );
        },
        barrierDismissible: false,
        barrierLabel:
            MaterialLocalizations.of(context).modalBarrierDismissLabel,
        barrierColor: Colors.black54,
        transitionDuration: const Duration(milliseconds: 150),
      );

  //ENCODE STRING TO BASE64
  static String encodeStringBase64(String plainText) {
    var bytes = utf8.encode(plainText);
    var digest = base64Encode(bytes);
    return digest;
  }

  //ENCODE STRING TO BASE64 URL
  static String encodeStringBase64URL(String plainText) {
    var bytes = utf8.encode(plainText);
    var digest = base64UrlEncode(bytes);
    return digest;
  }

  // ENCODE IMAGE TO BASE65
  static Future encodeImageBase64(File filePath) async {
    List<int> imageBytes = filePath.readAsBytesSync();
    String base64Image = base64Encode(imageBytes);
    return base64Image;
  }

  //ENCODE STRING TO SHA1
  static String encodeSha1(String plainText) {
    var bytes = utf8.encode(plainText);
    // print(bytes);
    var digest = sha1.convert(bytes).toString();
    // print(digest);
    return digest;
  }

  static double calculateDistance(
      {required double lat1, required double lon1, required double lat2, required double lon2}) {
    var p = 0.017453292519943295;
    var a = 0.5 -
        math.cos((lat2 - lat1) * p) / 2 +
        math.cos(lat1 * p) *
            math.cos(lat2 * p) *
            (1 - math.cos((lon2 - lon1) * p)) /
            2;
    return 12742 * math.asin(math.sqrt(a));
  }

  static String fileSize(dynamic size, [int round = 2]) {
    int divider = 1024;
    // ignore: no_leading_underscores_for_local_identifiers
    int _size;
    try {
      _size = int.parse(size.toString());
    } catch (e) {
      throw ArgumentError("Can not parse the size parameter: $e");
    }

    if (_size < divider) {
      return "$_size B";
    }

    if (_size < divider * divider && _size % divider == 0) {
      return "${(_size / divider).toStringAsFixed(0)} KB";
    }

    if (_size < divider * divider) {
      return "${(_size / divider).toStringAsFixed(round)} KB";
    }

    if (_size < divider * divider * divider && _size % divider == 0) {
      return "${(_size / (divider * divider)).toStringAsFixed(0)} MB";
    }

    if (_size < divider * divider * divider) {
      return "${(_size / divider / divider).toStringAsFixed(round)} MB";
    }

    if (_size < divider * divider * divider * divider && _size % divider == 0) {
      return "${(_size / (divider * divider * divider)).toStringAsFixed(0)} GB";
    }

    if (_size < divider * divider * divider * divider) {
      return "${(_size / divider / divider / divider).toStringAsFixed(round)} GB";
    }

    if (_size < divider * divider * divider * divider * divider &&
        _size % divider == 0) {
      num r = _size / divider / divider / divider / divider;
      return "${r.toStringAsFixed(0)} TB";
    }

    if (_size < divider * divider * divider * divider * divider) {
      num r = _size / divider / divider / divider / divider;
      return "${r.toStringAsFixed(round)} TB";
    }

    if (_size < divider * divider * divider * divider * divider * divider &&
        _size % divider == 0) {
      num r = _size / divider / divider / divider / divider / divider;
      return "${r.toStringAsFixed(0)} PB";
    } else {
      num r = _size / divider / divider / divider / divider / divider;
      return "${r.toStringAsFixed(round)} PB";
    }
  }

  static List<DateTime> getDaysInBetween(
      {required DateTime startDate, required DateTime endDate}) {
    List<DateTime> days = [];
    for (int i = 0; i <= endDate.difference(startDate).inDays; i++) {
      days.add(startDate.add(Duration(days: i)));
    }
    return days;
  }
}

// ignore_for_file: use_build_context_synchronously

import 'dart:developer';
import 'dart:io';

import 'package:device_info/device_info.dart';
import 'package:enta_mobile/args/general.dart';
import 'package:enta_mobile/components/loading.dart';
import 'package:enta_mobile/pages/login.dart';
import 'package:enta_mobile/providers/device.dart';
import 'package:enta_mobile/utils/colors.dart';
import 'package:enta_mobile/utils/data.dart';
import 'package:enta_mobile/utils/images.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/auth.dart';
import '../root.dart';

class SplashPage extends StatefulWidget {
  static const routeName = '/splash';
  final bool? showAlert;
  final String? alertText;
  const SplashPage({Key? key, this.showAlert, this.alertText}) : super(key: key);

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  late DeviceState deviceState;
  late SharedPreferences prefs;
  String? authToken, username;
  double? height, width;
  DateTime now = DateTime.now();
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      initPage();
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> initPage() async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    prefs = await SharedPreferences.getInstance();
    prefs.setInt("code_version", UIData.codeVersion);
    if (Platform.isAndroid) {
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      prefs.setString("device_manufacturer", androidInfo.manufacturer);
      prefs.setString("device_model", androidInfo.model);
      prefs.setString("device_id", androidInfo.androidId);
      prefs.setString("device_platform", "ANDROID");
      deviceState.setDevicedId(id: androidInfo.androidId);
      log("device_manufacturer : ${androidInfo.manufacturer}");
      log("device_model : ${androidInfo.model}");
      log("device_id : ${androidInfo.androidId}");
    } else if (Platform.isIOS) {
      IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
      prefs.setString("device_manufacturer", iosInfo.utsname.machine);
      prefs.setString("device_model", iosInfo.utsname.machine);
      prefs.setString("device_id", iosInfo.identifierForVendor);
      prefs.setString("device_platform", "IOS");
      deviceState.setDevicedId(id: iosInfo.identifierForVendor);
      log("device_manufacturer : ${iosInfo.utsname.machine}");
      log("device_model : ${iosInfo.utsname.machine}");
      log("device_id : ${iosInfo.identifierForVendor}");
    }
    authToken = prefs.getString('token');
    username = prefs.getString('username');
    if (authToken == null ||
        authToken == "" ||
        username == null ||
        username == "") {
      Navigator.pushReplacementNamed(context, LoginPage.routeName,
          arguments: GeneralArgs(showAlert: false, alertText: ''));
    } else {
      AuthModel auth = AuthModel(
        token: prefs.getString("token"),
        username: prefs.getString("employee_name"),
        employeeName: prefs.getString("employee_name"),
        photoProfile: prefs.getString("photo_profile"),
        companyCode: prefs.getString("company_code"),
        host: prefs.getString("host"),
      );
      log("My Token is : ${auth.token}");
      deviceState.setMyAuth(data: auth);
      deviceState.setMyOffice(data: UIData.dummyOffice);
      Navigator.pushReplacementNamed(
        context,
        MainPage.routeName,
        arguments: GeneralArgs(showAlert: false, alertText: ''),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    deviceState = Provider.of<DeviceState>(context);
    height = MediaQuery.of(context).size.height;
    width = MediaQuery.of(context).size.width;
    return Scaffold(
      body: Stack(
        children: <Widget>[
          Container(
            width: width,
            height: height,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: UIColor.gradientPrimary,
                tileMode: TileMode.mirror,
              ),
            ),
          ),
          SizedBox(
              width: width,
              height: height,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Container(
                    width: width! * 0.20,
                    height: width! * 0.20,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.rectangle,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: const <BoxShadow>[
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 10,
                          offset: Offset(0, 0),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(width! * 0.05),
                      child: SvgPicture.asset(UIImage.logo),
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  const SafeArea(
                    child: LoadingWidget(color: Colors.white),
                  )
                ],
              ))
        ],
      ),
    );
  }
}

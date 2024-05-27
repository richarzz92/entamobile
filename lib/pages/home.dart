import 'dart:convert';
import 'dart:developer';
import 'dart:typed_data';

import 'package:another_flushbar/flushbar.dart';
import 'package:enta_mobile/args/general.dart';
import 'package:enta_mobile/pages/history.dart';
import 'package:enta_mobile/pages/login.dart';
import 'package:enta_mobile/pages/tap_in_out.dart';
import 'package:enta_mobile/providers/device.dart';
import 'package:enta_mobile/utils/images.dart';
import 'package:enta_mobile/utils/strings.dart';
import 'package:enta_mobile/utils/url.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../utils/colors.dart';

class HomePage extends StatefulWidget {
  static const routeName = '/home';
  final bool? showAlert;
  final String? alertText;
  final Map? userInfo;
  const HomePage({Key? key, this.showAlert, this.alertText, this.userInfo})
      : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // String _initialName = "";
  late DeviceState deviceState;
  double? width, height;
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
    if (widget.showAlert!) {
      Flushbar(
        margin: const EdgeInsets.all(8),
        borderRadius: BorderRadius.circular(8),
        backgroundColor: Colors.green,
        flushbarPosition: FlushbarPosition.TOP,
        duration: const Duration(seconds: 3),
        icon: const Icon(
          Icons.check,
          color: Colors.white,
        ),
        title: 'Information',
        message: widget.alertText,
      ).show(context);
    }
    // String str1 = widget.userInfo["employeeName"];
    // String str1 = deviceState.myAuth.employeeName;
    // if (str1.isNotEmpty) {
    //   var arrStr1 = str1.split(' ');
    //   if (arrStr1.isNotEmpty && arrStr1.length < 2) {
    //     if (arrStr1[0].isNotEmpty) {
    //       _initialName = arrStr1[0].toUpperCase().substring(0, 1);
    //     } else {
    //       _initialName = '??';
    //     }
    //   } else if (arrStr1.length >= 2 && arrStr1.length < 3) {
    //     if (arrStr1[0].isEmpty && arrStr1[1].isEmpty) {
    //       _initialName = "??";
    //     } else {
    //       if (arrStr1[0].isNotEmpty) {
    //         _initialName += arrStr1[0].toUpperCase().substring(0, 1);
    //       }
    //       if (arrStr1[1].isNotEmpty) {
    //         _initialName += arrStr1[1].toUpperCase().substring(0, 1);
    //       }
    //     }
    //   } else if (arrStr1.length >= 3) {
    //     if (arrStr1[0].isEmpty && arrStr1[1].isEmpty) {
    //       _initialName = "??";
    //     } else {
    //       if (arrStr1[0].isNotEmpty) {
    //         _initialName += arrStr1[0].toUpperCase().substring(0, 1);
    //       }
    //       if (arrStr1[1].isNotEmpty) {
    //         _initialName += arrStr1[1].toUpperCase().substring(0, 1);
    //       } else {
    //         if (arrStr1[2].isNotEmpty) {
    //           _initialName += arrStr1[2].toUpperCase().substring(0, 1);
    //         }
    //       }
    //     }
    //   }
    // } else {
    //   _initialName = '??';
    // }
    // setState(() {});
  }

  Future<void> confirmLogout() async {
    var result = await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Confirm Logout"),
            content: const Text(UIString.confirmLogout),
            actions: <Widget>[
              TextButton(
                child: const Text(
                  UIString.btnLogout,
                  style: TextStyle(color: Colors.red),
                ),
                onPressed: () async {
                  Navigator.pop(context, true);
                },
              ),
              TextButton(
                child: const Text(
                  "Cancel",
                  style: TextStyle(color: Colors.green),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        });
    if (result == null || result == '') {
      log("Tidak Ada Result");
    } else {
      Map<String, dynamic> result = <String, dynamic>{};
      SharedPreferences _prefs = await SharedPreferences.getInstance();
      _prefs.setString("token", "");
      _prefs.setString("employee_name", "");
      _prefs.setString("photo_profile", "");
      _prefs.setString("username", "");
      result['success'] = true;
      Navigator.pushReplacementNamed(
        context,
        LoginPage.routeName,
        arguments: GeneralArgs(showAlert: true, alertText: 'Success Logout'),
      );
    }
  }

  Future<void> checkPermission({int? type}) async {
    if (deviceState.permissionCamera == PermissionStatus.granted) {
      if (deviceState.permissionLocation == PermissionStatus.granted) {
        log("oke 1");
        openPage(type: type);
      } else {
        await deviceState.requestPermission(
            hardware: Permission.locationWhenInUse);
        if (deviceState.permissionLocation == PermissionStatus.granted) {
          log("oke 2");
          openPage(type: type);
        } else if (deviceState.permissionLocation ==
            PermissionStatus.permanentlyDenied) {
          await openAppSettings();
        }
      }
    } else {
      await deviceState.requestPermission(hardware: Permission.camera);
      if (deviceState.permissionCamera == PermissionStatus.granted) {
        if (deviceState.permissionLocation == PermissionStatus.granted) {
          log("oke 3");
          openPage(type: type);
        } else {
          await deviceState.requestPermission(
              hardware: Permission.locationWhenInUse);
          if (deviceState.permissionLocation == PermissionStatus.granted) {
            log("oke 4");
            openPage(type: type);
          } else if (deviceState.permissionLocation ==
              PermissionStatus.permanentlyDenied) {
            await openAppSettings();
          }
        }
      } else if (deviceState.permissionCamera ==
          PermissionStatus.permanentlyDenied) {
        await openAppSettings();
      }
    }
  }

  Future<void> openPage({int? type}) async {
    // ignore: prefer_typing_uninitialized_variables
    var result;
    if (type == 0) {
      log("open tap in");
      result = await Navigator.pushNamed(
        context,
        TapInOutPage.routeName,
        arguments: GeneralArgs(
          title: 'Tap In',
          url: UIUrl.tapIn,
          key: const Key("tap in"),
        ),
      );
    } else {
      result = await Navigator.pushNamed(
        context,
        TapInOutPage.routeName,
        arguments: GeneralArgs(
          title: 'Tap Out',
          url: UIUrl.tapOut,
          key: const Key("tap out"),
        ),
      );
    }
    if (result != null && result != "") {
      log(result.toString());
      if (result['code'] == 401) {
        SharedPreferences _prefs = await SharedPreferences.getInstance();
        _prefs.setString("token", "");
        _prefs.setString("employee_name", "");
        _prefs.setString("photo_profile", "");
        _prefs.setString("username", "");
        Navigator.pushReplacementNamed(
          context,
          LoginPage.routeName,
          arguments:
              GeneralArgs(showAlert: true, alertText: 'Session is expired'),
        );
      } else {
        Flushbar(
          margin: const EdgeInsets.all(8),
          borderRadius: BorderRadius.circular(8),
          backgroundColor: Colors.green,
          flushbarPosition: FlushbarPosition.TOP,
          duration: const Duration(seconds: 3),
          icon: const Icon(
            Icons.info_outline_rounded,
            color: Colors.white,
          ),
          title: 'Information',
          message: result['msg'],
        ).show(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    deviceState = Provider.of<DeviceState>(context);
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;
    return Scaffold(
        appBar: AppBar(
          title: const Text("ENTA MOBILE"),
          elevation: 0,
          actions: <Widget>[buildLogout()],
        ),
        body: Stack(
          children: <Widget>[
            Container(
              width: width,
              height: width! * 0.18,
              color: UIColor.primaryColor,
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                buildCardAccount(),
                buildCardMainFeature(),
              ],
            )
          ],
        ));
  }

  Widget buildCardAccount() {
    return Padding(
      padding: EdgeInsets.only(
          top: width! * 0.08, left: width! * 0.04, right: width! * 0.04),
      child: Card(
        child: Row(
          children: <Widget>[
            buildAvatar(),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Text(
                  "Hi,",
                  style: TextStyle(color: Colors.grey),
                ),
                const Padding(
                  padding: EdgeInsets.only(top: 2, bottom: 2),
                ),
                Text(
                  deviceState.myAuth!.employeeName!,
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget buildAvatar() {
    if (deviceState.myAuth!.photoProfile != null &&
        deviceState.myAuth!.photoProfile != "") {
      Uint8List bytes = base64Decode(deviceState.myAuth!.photoProfile!);
      return Padding(
        padding: const EdgeInsets.all(10),
        child: Container(
          width: width! * 0.15,
          height: width! * 0.15,
          decoration: const BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: <BoxShadow>[
                BoxShadow(color: Colors.black12, blurRadius: 5)
              ]),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(5),
              child: Container(
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(
                        fit: BoxFit.fill, image: MemoryImage(bytes))),
              ),
            ),
          ),
        ),
      );
    } else {
      return Padding(
        padding: const EdgeInsets.all(10),
        child: Image.asset(
          UIImage.user,
          height: 50,
        ),
      );
    }
  }

  Widget buildLogout() {
    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: InkWell(
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        onTap: () {
          confirmLogout();
        },
        child: Padding(
          padding: const EdgeInsets.only(top: 15, bottom: 10),
          child: Container(
            decoration: BoxDecoration(
                shape: BoxShape.rectangle,
                borderRadius: BorderRadius.circular(13),
                color: Colors.black12),
            child: Center(
              child: Padding(
                padding: const EdgeInsets.only(left: 10, right: 10),
                child: Row(
                  children: const <Widget>[
                    Icon(
                      FontAwesomeIcons.powerOff,
                      size: 13,
                    ),
                    Text(
                      " Logout",
                      style: TextStyle(fontSize: 12.5),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildCardMainFeature() {
    return Padding(
        padding: EdgeInsets.only(
            top: width! * 0.05, left: width! * 0.15, right: width! * 0.15),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Expanded(
              child: builBtnTapInOut(
                title: 'Tap In',
                index: 0,
                iconColor: Colors.green,
                icon: FontAwesomeIcons.arrowUp,
              ),
            ),
            const SizedBox(
              width: 20,
            ),
            Expanded(
              child: builBtnTapInOut(
                title: 'Tap Out',
                index: 1,
                iconColor: Colors.red,
                icon: FontAwesomeIcons.arrowDown,
              ),
            ),
            const SizedBox(
              width: 20,
            ),
            Expanded(
              child: builBtnTapInOut(
                title: 'History',
                index: 2,
                iconColor: Colors.blue,
                icon: FontAwesomeIcons.history,
              ),
            )
          ],
        ));
  }

  Widget builBtnTapInOut(
      {int? index, required String title, IconData? icon, Color? iconColor}) {
    return InkWell(
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        onTap: () async {
          if (index != 2) {
            if (deviceState.permissionCamera ==
                    PermissionStatus.permanentlyDenied ||
                deviceState.permissionLocation ==
                    PermissionStatus.permanentlyDenied) {
              Flushbar(
                margin: const EdgeInsets.all(8),
                borderRadius: BorderRadius.circular(8),
                backgroundColor: Colors.red,
                flushbarPosition: FlushbarPosition.TOP,
                duration: const Duration(seconds: 3),
                icon: const Icon(
                  Icons.info_outline_rounded,
                  color: Colors.white,
                ),
                title: 'Information',
                message: UIString.messagePermission,
              ).show(context);
            } else {
              checkPermission(type: index);
            }
          } else {
            Navigator.pushNamed(context, HistoryPage.routeName);
          }
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Container(
              height: width! * 0.18,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.black12),
                color: Colors.white,
              ),
              child: Center(
                child: Icon(
                  icon,
                  size: 25,
                  color: iconColor,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 5),
              child: Text(
                title.toUpperCase(),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            )
          ],
        ));
  }
}

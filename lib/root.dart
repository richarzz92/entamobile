// ignore_for_file: prefer_interpolation_to_compose_strings, use_build_context_synchronously

import 'dart:convert';
import 'dart:developer';
import 'dart:typed_data';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:enta_mobile/models/response_api.dart';
import 'package:enta_mobile/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:intl/intl.dart';
import 'package:location/location.dart' as loc;
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:skeleton_text/skeleton_text.dart';
import 'package:snapping_sheet/snapping_sheet.dart';

import 'args/general.dart';
import 'components/errors/get_data.dart';
import 'pages/login.dart';
import 'pages/request_form/tap_in_out.dart';
import 'providers/device.dart';
import 'utils/data.dart';
import 'utils/functions.dart';
import 'utils/images.dart';
import 'utils/strings.dart';
import 'utils/url.dart';

class MainPage extends StatefulWidget {
  static const routeName = '/home';
  final bool? showAlert;
  final String? alertText;
  final String? route;
  final dynamic args;
  const MainPage({
    Key? key,
    this.alertText,
    this.showAlert,
    this.route,
    this.args,
  }) : super(key: key);

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  double? width, height;
  late DeviceState deviceState;
  late Uint8List photoProfile;
  var snapController = SnappingSheetController();
  final ScrollController scrollController = ScrollController();
  late SharedPreferences prefs;
  String greeting = '';
  loc.Location location = loc.Location();

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () async {
      prefs = await SharedPreferences.getInstance();
      var hour = DateTime.now().hour;
      if (hour < 12) {
        greeting = 'Selamat Pagi';
      } else if (hour < 17) {
        greeting = 'Selamat Siang';
      } else {
        greeting = 'Selamat Malam';
      }
      checkPermission(type: null);
      initPage();
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> checkToken() async {
    Uri uriCheckToken, uriLeaveTypeGroup;
    if (prefs.getBool("secure")!) {
      uriCheckToken = Uri.https(prefs.getString("host")!,
          prefs.getString("prefix")! + UIUrl.checkToken);
      uriLeaveTypeGroup = Uri.https(prefs.getString("host")!,
          prefs.getString("prefix")! + UIUrl.leaveTypeGroup);
    } else {
      uriCheckToken = Uri.http(prefs.getString("host")!,
          prefs.getString("prefix")! + UIUrl.checkToken);
      uriLeaveTypeGroup = Uri.http(prefs.getString("host")!,
          prefs.getString("prefix")! + UIUrl.leaveTypeGroup);
    }
    String planText = prefs.getString("username")! +
        'LeaveGroup' +
        deviceState.myAuth!.companyCode! +
        deviceState.deviceId! +
        deviceState.myAuth!.companyCode! +
        deviceState.deviceId!;
    String secretKey = UIFunction.encodeSha1(planText);
    String parameters = json.encode([
      prefs.getString("username"),
      'LeaveGroup',
      deviceState.myAuth!.companyCode,
      deviceState.deviceId,
      secretKey
    ]);
    log("Param Leave Type Group : $parameters");
    ResponseAPI result = await deviceState.actionCallAPI(
      method: 'POST',
      uri: uriCheckToken,
      prefix: prefs.getString("prefix")!,
    );
    if (result.code == 401) {
      Map<String, dynamic> resultx = <String, dynamic>{};
      bool rememberMe = prefs.getBool("remember_me") ?? false;
      prefs.setString("token", "");
      prefs.setString("employee_name", "");
      prefs.setString("photo_profile", "");
      if (result.message == '[E, Invalid device.]') {
        prefs.setString("host", "");
        resultx['success'] = true;
        prefs.setString("username", "");
        prefs.setString("password", "");
        onSuccessLogout(
            msg:
                'Session is expired, because you are logged in another device');
      } else {
        if (!rememberMe) {
          prefs.setString("username", "");
          prefs.setString("password", "");
        }
        resultx['success'] = true;
        onSuccessLogout(msg: 'Session is expired');
      }
    } else if (result.code == 200) {
      deviceState.actionCallAPI(
        method: 'POST',
        uri: uriLeaveTypeGroup,
        prefix: prefs.getString("prefix")!,
        formData: parameters,
      );
    }
  }

  Future<void> initPage() async {
    await checkToken();
    if (widget.showAlert!) {
      UIFunction.showToastMessage(
        context: context,
        isError: false,
        position: 'TOP',
        message: widget.alertText,
      );
    }
    if (deviceState.myAuth!.photoProfile != null &&
        deviceState.myAuth!.photoProfile != "") {
      photoProfile = base64Decode(deviceState.myAuth!.photoProfile!);
    }
  }

  Future<void> getMyLocation() async {
    location.onLocationChanged.listen((loc.LocationData currentLocation) {
      log("Get Latitude = ${currentLocation.latitude} Longitude = ${currentLocation.longitude}");
      deviceState.setMyLocation(
          latitude: currentLocation.latitude,
          longitude: currentLocation.longitude);
    });
  }

  Future<void> showClocking() async {
    await showMaterialModalBottomSheet(
      context: context,
      expand: false,
      enableDrag: false,
      backgroundColor: Colors.white,
      builder: (context) => ConstrainedBox(
        constraints: BoxConstraints(maxHeight: height! * 0.575),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          onClickClocking(type: 0);
                        },
                        style: ElevatedButton.styleFrom(
                          primary: Colors.green,
                        ),
                        child: const Text("Tap In"),
                      ),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          onClickClocking(type: 1);
                        },
                        style: ElevatedButton.styleFrom(
                          primary: Colors.red,
                        ),
                        child: const Text("Tap Out"),
                      ),
                    )
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> onClickClocking({int? type}) async {
    if (deviceState.permissionCamera == PermissionStatus.permanentlyDenied ||
        deviceState.permissionLocation == PermissionStatus.permanentlyDenied) {
      UIFunction.showToastMessage(
        context: context,
        isError: true,
        position: 'TOP',
        title: 'Information',
        message: UIString.messagePermission,
      );
    } else {
      checkPermission(type: type);
    }
  }

  Future<void> checkPermission({int? type}) async {
    if (deviceState.permissionCamera == PermissionStatus.granted) {
      if (deviceState.permissionLocation == PermissionStatus.granted) {
        if (type != null) {
          openPage(type: type);
        }
      } else {
        await deviceState.requestPermission(
            hardware: Permission.locationWhenInUse);
        if (deviceState.permissionLocation == PermissionStatus.granted) {
          if (type != null) {
            openPage(type: type);
          }
        } else if (deviceState.permissionLocation ==
            PermissionStatus.permanentlyDenied) {
          await openAppSettings();
        }
      }
    } else {
      await deviceState.requestPermission(hardware: Permission.camera);
      if (deviceState.permissionCamera == PermissionStatus.granted) {
        if (deviceState.permissionLocation == PermissionStatus.granted) {
          if (deviceState.permissionLocation == PermissionStatus.granted &&
              deviceState.myLat == null) {
            log("initial get my location");
            getMyLocation();
          }
          if (type != null) {
            openPage(type: type);
          }
        } else {
          await deviceState.requestPermission(
              hardware: Permission.locationWhenInUse);
          if (deviceState.permissionLocation == PermissionStatus.granted) {
            if (deviceState.permissionLocation == PermissionStatus.granted &&
                deviceState.myLat == null) {
              log("initial get my location");
              getMyLocation();
            }
            if (type != null) {
              openPage(type: type);
            }
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
    Navigator.pop(context);
    // ignore: prefer_typing_uninitialized_variables
    var result;
    loc.Location location = loc.Location();
    bool isOn = await location.serviceEnabled();
    if (!isOn) {
      bool isturnedon = await location.requestService();
      if (!isturnedon) {
        UIFunction.showToastMessage(
            context: context,
            isError: true,
            position: 'TOP',
            message: 'please activate your gps');
      }
    } else {
      if (type == 0) {
        result = await Navigator.pushNamed(
          context,
          TapInOutPage.routeName,
          arguments: GeneralArgs(
            title: 'Tap In',
            url: UIUrl.tapIn,
            key: const Key("tap in"),
            type: 'TYPE_IN',
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
            type: 'TYPE_OUT',
          ),
        );
      }
      if (result != null && result != "") {
        UIFunction.showToastMessage(
          context: context,
          isError: false,
          position: 'TOP',
          title: 'Information',
          message: result['msg'],
        );
      }
    }
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
      SharedPreferences prefs = await SharedPreferences.getInstance();
      bool rememberMe = prefs.getBool("remember_me") ?? false;
      prefs.setString("token", "");
      prefs.setString("employee_name", "");
      prefs.setString("photo_profile", "");
      if (!rememberMe) {
        prefs.setString("username", "");
        prefs.setString("password", "");
      }
      result['success'] = true;
      onSuccessLogout(msg: 'Success Logout');
    }
  }

  void onSuccessLogout({String? msg}) {
    Navigator.pushReplacementNamed(
      context,
      LoginPage.routeName,
      arguments: GeneralArgs(showAlert: true, alertText: msg),
    );
  }

  @override
  Widget build(BuildContext context) {
    deviceState = Provider.of<DeviceState>(context);
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;
    return Scaffold(
        backgroundColor: Colors.white,
        bottomNavigationBar: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              UIData.appVersion,
              style: TextStyle(
                fontSize: Theme.of(context).primaryTextTheme.caption!.fontSize,
              ),
            ),
          ],
        ),
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.transparent,
          title: const Text("Enta HR"),
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                tileMode: TileMode.mirror,
                end: Alignment.centerRight,
                begin: Alignment.centerLeft,
                colors: UIColor.gradientPrimary,
              ),
            ),
          ),
          actions: [
            IconButton(
              onPressed: () {
                confirmLogout();
              },
              icon: const Icon(
                Icons.logout_rounded,
              ),
            )
          ],
        ),
        body: Stack(
          children: [
            Container(
              height: height! * 0.4,
              padding: EdgeInsets.symmetric(
                horizontal: 10,
                vertical: height! * 0.05,
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  tileMode: TileMode.mirror,
                  end: Alignment.centerRight,
                  begin: Alignment.centerLeft,
                  colors: UIColor.gradientPrimary,
                ),
              ),
              child: buildEmployeeInfo(),
            ),
            RefreshIndicator(
              onRefresh: () async {
                await checkToken();
              },
              child: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.only(top: height! * 0.15),
                      child: Container(
                        height: height! * 0.7,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(10),
                            topRight: Radius.circular(10),
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: Stack(
                            children: [
                              deviceState.validationCode == 200
                                  ? Center(
                                      child: SizedBox(
                                        height: height! *
                                            0.7 *
                                            deviceState.logoHeight,
                                        child: Opacity(
                                          opacity: 0.15,
                                          child: CachedNetworkImage(
                                            placeholder: (context, url) =>
                                                SkeletonAnimation(
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  color: Theme.of(context)
                                                      .dividerColor,
                                                ),
                                                child: const Icon(
                                                  Icons.info,
                                                  color: Colors.transparent,
                                                  size: 60,
                                                ),
                                              ),
                                            ),
                                            imageUrl:
                                                deviceState.companyLogoUrl,
                                            fit: BoxFit.contain,
                                          ),
                                        ),
                                      ),
                                    )
                                  : const SizedBox(
                                      height: 0,
                                    ),
                              Column(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 7.5),
                                    child: Text(
                                      DateFormat('EEEE, dd MMM yyyy', 'id')
                                          .format(DateTime.now())
                                          .toString(),
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: Theme.of(context)
                                            .primaryTextTheme
                                            .subtitle1!
                                            .fontSize,
                                        fontWeight: FontWeight.bold,
                                        color: Theme.of(context).disabledColor,
                                      ),
                                    ),
                                  ),
                                  buildFeature(),
                                ],
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                  )
                ],
              ),
            )
          ],
        ));
  }

  Widget buildEmployeeInfo() {
    if (deviceState.loadingValidation) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SkeletonAnimation(
            child: Container(
              width: width! * 0.14,
              height: width! * 0.14,
              decoration: BoxDecoration(
                color: Theme.of(context).dividerColor,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.info,
                color: Colors.transparent,
                size: 60,
              ),
            ),
          ),
          const SizedBox(
            width: 10,
          ),
          Flexible(
              child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SkeletonAnimation(
                child: Container(
                  height: Theme.of(context).primaryTextTheme.subtitle1!.fontSize,
                  decoration: BoxDecoration(
                    color: Theme.of(context).dividerColor,
                  ),
                ),
              ),
              const SizedBox(
                height: 7.5,
              ),
              SkeletonAnimation(
                child: Container(
                  height: Theme.of(context).primaryTextTheme.subtitle1!.fontSize,
                  decoration: BoxDecoration(
                    color: Theme.of(context).dividerColor,
                  ),
                ),
              ),
            ],
          )),
        ],
      );
    } else if (deviceState.validationCode != 200) {
      return const Center(
        heightFactor: 0,
      );
    } else {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          buildAvatar(),
          const SizedBox(
            width: 10,
          ),
          Flexible(
              child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "$greeting,",
                style: TextStyle(
                  color: Colors.white,
                  fontSize:
                      Theme.of(context).primaryTextTheme.subtitle1!.fontSize,
                ),
              ),
              const SizedBox(
                height: 7.5,
              ),
              Text(
                deviceState.employeeName!,
                style: const TextStyle(
                  color: Colors.white,
                ),
              ),
            ],
          )),
        ],
      );
    }
  }

  Widget buildAvatar() {
    if (deviceState.myAuth!.photoProfile != null &&
        deviceState.myAuth!.photoProfile != "") {
      return Container(
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
                  fit: BoxFit.fill,
                  image: MemoryImage(photoProfile),
                ),
              ),
            ),
          ),
        ),
      );
    } else {
      return Image.asset(
        UIImage.user,
        height: 35,
        width: 35,
      );
    }
  }

  Widget buildFeature() {
    if (deviceState.loadingValidation) {
      return Padding(
        padding: const EdgeInsets.only(top: 17.5),
        child: MasonryGridView.count(
          physics: const ScrollPhysics(parent: NeverScrollableScrollPhysics()),
          shrinkWrap: true,
          crossAxisCount: 4,
          mainAxisSpacing: 0.0,
          crossAxisSpacing: 0.0,
          padding: const EdgeInsets.symmetric(horizontal: 0),
          itemCount: UIData.menuFeature.length,
          itemBuilder: (BuildContext context, int i) {
            return SkeletonAnimation(
              child: Column(
                children: [
                  Container(
                    width: width! * 0.14,
                    height: width! * 0.14,
                    decoration: BoxDecoration(
                      color: Theme.of(context).dividerColor,
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: const Icon(
                      Icons.info,
                      color: Colors.transparent,
                      size: 60,
                    ),
                  ),
                  const SizedBox(
                    height: 7.5,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Container(
                      height:
                          Theme.of(context).primaryTextTheme.subtitle2!.fontSize,
                      decoration: BoxDecoration(
                        color: Theme.of(context).dividerColor,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      );
    } else if (deviceState.validationCode != 200) {
      return ErrorGetData(
        callBack: initPage,
        title: deviceState.msgValidation,
      );
    } else {
      return Padding(
        padding: const EdgeInsets.only(top: 17.5),
        child: MasonryGridView.count(
          physics: const ScrollPhysics(parent: NeverScrollableScrollPhysics()),
          shrinkWrap: true,
          crossAxisCount: 4,
          mainAxisSpacing: 0.0,
          crossAxisSpacing: 0.0,
          padding: const EdgeInsets.symmetric(horizontal: 0),
          itemCount: UIData.menuFeature.length,
          itemBuilder: (BuildContext context, int i) {
            return Visibility(
              visible: UIData.menuFeature[i].code == 'clocking' &&
                      deviceState.clockingAccess
                  ? true
                  : UIData.menuFeature[i].code == 'overtime' &&
                          deviceState.otAccess
                      ? true
                      : UIData.menuFeature[i].code == 'leave' &&
                              deviceState.lvAccess
                          ? true
                          : UIData.menuFeature[i].code == 'history'
                              ? true
                              : false,
              child: GestureDetector(
                  onTap: () async {
                    if (UIData.menuFeature[i].code == 'clocking') {
                      showClocking();
                    } else {
                      var result = await Navigator.pushNamed(
                          context, UIData.menuFeature[i].route!);
                      if (result != null) {
                        UIFunction.showToastMessage(
                            context: context,
                            isError: false,
                            position: 'TOP',
                            message: result.toString());
                      }
                    }
                  },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Theme.of(context).dividerColor.withAlpha(15),
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          UIData.menuFeature[i].icon,
                          color: Theme.of(context).primaryColor,
                          size: 28,
                        ),
                      ),
                      const SizedBox(
                        height: 2,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 2.5),
                        child: Text(
                          UIData.menuFeature[i].label!,
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: Theme.of(context)
                                .primaryTextTheme
                                .caption!
                                .fontSize,
                          ),
                        ),
                      )
                    ],
                  )),
            );
          },
        ),
      );
    }
  }

  Widget buildClocking({int? i}) {
    if (deviceState.loadingValidation) {
      return SkeletonAnimation(
        child: Column(
          children: [
            Container(
              width: width! * 0.14,
              height: width! * 0.14,
              decoration: BoxDecoration(
                color: Theme.of(context).dividerColor,
                borderRadius: BorderRadius.circular(5),
              ),
              child: const Icon(
                Icons.info,
                color: Colors.transparent,
                size: 60,
              ),
            ),
            const SizedBox(
              height: 7.5,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Container(
                height: Theme.of(context).primaryTextTheme.subtitle2!.fontSize,
                decoration: BoxDecoration(
                  color: Theme.of(context).dividerColor,
                ),
              ),
            ),
          ],
        ),
      );
    } else if (deviceState.validationCode != 200) {
      return SkeletonAnimation(
        child: Column(
          children: [
            Container(
              width: width! * 0.14,
              height: width! * 0.14,
              decoration: BoxDecoration(
                color: Theme.of(context).dividerColor,
                borderRadius: BorderRadius.circular(5),
              ),
              child: const Icon(
                Icons.info,
                color: Colors.transparent,
                size: 60,
              ),
            ),
            const SizedBox(
              height: 7.5,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Container(
                height: Theme.of(context).primaryTextTheme.subtitle2!.fontSize,
                decoration: BoxDecoration(
                  color: Theme.of(context).dividerColor,
                ),
              ),
            ),
          ],
        ),
      );
    } else {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              border: Border.all(
                color: Theme.of(context).dividerColor.withAlpha(15),
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              UIData.menuFeature[i!].icon,
              color: Theme.of(context).primaryColor,
              size: 28,
            ),
          ),
          const SizedBox(
            height: 2,
          ),
          Padding(
            padding: const EdgeInsets.only(top: 2.5),
            child: Text(
              UIData.menuFeature[i].label!,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: Theme.of(context).primaryTextTheme.caption!.fontSize,
              ),
            ),
          )
        ],
      );
    }
  }

  Widget buildOvertime({required int i}) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            border: Border.all(
              color: Theme.of(context).dividerColor.withAlpha(15),
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            UIData.menuFeature[i].icon,
            color: Theme.of(context).primaryColor,
            size: 28,
          ),
        ),
        const SizedBox(
          height: 2,
        ),
        Padding(
          padding: const EdgeInsets.only(top: 2.5),
          child: Text(
            UIData.menuFeature[i].label!,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: Theme.of(context).primaryTextTheme.caption!.fontSize,
            ),
          ),
        )
      ],
    );
  }

  Widget buildLeave({required int i}) {
    // if (deviceState.loadingLeaveGroup) {
    //   return SkeletonAnimation(
    //     child: Column(
    //       children: [
    //         Container(
    //           width: width * 0.14,
    //           height: width * 0.14,
    //           decoration: BoxDecoration(
    //             color: Theme.of(context).dividerColor,
    //             borderRadius: BorderRadius.circular(5),
    //           ),
    //           child: const Icon(
    //             Icons.info,
    //             color: Colors.transparent,
    //             size: 60,
    //           ),
    //         ),
    //         const SizedBox(
    //           height: 7.5,
    //         ),
    //         Padding(
    //           padding: const EdgeInsets.symmetric(horizontal: 10),
    //           child: Container(
    //             height: Theme.of(context).primaryTextTheme.subtitle2.fontSize,
    //             decoration: BoxDecoration(
    //               color: Theme.of(context).dividerColor,
    //             ),
    //           ),
    //         ),
    //       ],
    //     ),
    //   );
    // } else if (deviceState.leaveGroupCode != 200) {
    //   return SkeletonAnimation(
    //     child: Column(
    //       children: [
    //         Container(
    //           width: width * 0.14,
    //           height: width * 0.14,
    //           decoration: BoxDecoration(
    //             color: Theme.of(context).dividerColor,
    //             borderRadius: BorderRadius.circular(5),
    //           ),
    //           child: const Icon(
    //             Icons.info,
    //             color: Colors.transparent,
    //             size: 60,
    //           ),
    //         ),
    //         const SizedBox(
    //           height: 7.5,
    //         ),
    //         Padding(
    //           padding: const EdgeInsets.symmetric(horizontal: 10),
    //           child: Container(
    //             height: Theme.of(context).primaryTextTheme.subtitle2.fontSize,
    //             decoration: BoxDecoration(
    //               color: Theme.of(context).dividerColor,
    //             ),
    //           ),
    //         ),
    //       ],
    //     ),
    //   );
    // } else {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            border: Border.all(
              color: Theme.of(context).dividerColor.withAlpha(15),
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            UIData.menuFeature[i].icon,
            color: Theme.of(context).primaryColor,
            size: 28,
          ),
        ),
        const SizedBox(
          height: 2,
        ),
        Padding(
          padding: const EdgeInsets.only(top: 2.5),
          child: Text(
            UIData.menuFeature[i].label!,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: Theme.of(context).primaryTextTheme.caption!.fontSize,
            ),
          ),
        )
      ],
    );
    // }
  }

  Widget buildHistory({required int i}) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            border: Border.all(
              color: Theme.of(context).dividerColor.withAlpha(15),
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            UIData.menuFeature[i].icon,
            color: Theme.of(context).primaryColor,
            size: 28,
          ),
        ),
        const SizedBox(
          height: 2,
        ),
        Padding(
          padding: const EdgeInsets.only(top: 2.5),
          child: Text(
            UIData.menuFeature[i].label!,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: Theme.of(context).primaryTextTheme.caption!.fontSize,
            ),
          ),
        )
      ],
    );
  }
}

// ignore_for_file: prefer_typing_uninitialized_variables

import 'dart:convert';
import 'dart:developer';
import 'package:another_flushbar/flushbar.dart';
import 'package:enta_mobile/models/response_api.dart';
import 'package:enta_mobile/providers/device.dart';
import 'package:enta_mobile/utils/data.dart';
import 'package:enta_mobile/utils/url.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../utils/functions.dart';
import '../utils/images.dart';
import '../utils/strings.dart';

class RegisterPage extends StatefulWidget {
  static const routeName = '/register';
  const RegisterPage({Key? key}) : super(key: key);

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  late DeviceState deviceState;
  final formRegisterKey = GlobalKey<FormState>();
  final FocusNode focusCompanyCode = FocusNode();
  final FocusNode focusHost = FocusNode();
  final TextEditingController _usernameText = TextEditingController();
  final TextEditingController _companyCodeText = TextEditingController();
  final TextEditingController _hostText = TextEditingController();
  late SharedPreferences prefs;
  bool isLoading = false;
  late String _host;
  double? height, width;
  var _deviceId, _planText, _secretKey, _parameters, responseAPI;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () async {
      prefs = await SharedPreferences.getInstance();
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> callAPI() async {
    String lastStringURL = _hostText.text.trim();
    String lastStringURLv2 = lastStringURL.substring(lastStringURL.length - 1);
    if (lastStringURLv2 == "/") {
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
        message: UIString.invalidUrl,
      ).show(context);
    } else {
      _host = lastStringURL;
      _deviceId = deviceState.deviceId;
      _planText = _usernameText.text +
          _companyCodeText.text +
          _deviceId +
          _companyCodeText.text +
          _deviceId;
      _secretKey = UIFunction.encodeSha1(_planText);

      _parameters = json.encode(
        [_usernameText.text, _companyCodeText.text, _deviceId, _secretKey],
      );
      log(_parameters);
      UIFunction.showDialogLoadingBlank(context: context);

      ResponseAPI result = await UIFunction.callAPIDIO(
        method: 'POST',
        url: _host + UIUrl.register,
        formData: _parameters,
      );
      onSuccessCalAPI(result: result);
    }
  }

  void onSuccessCalAPI({required ResponseAPI result}) {
    Navigator.pop(context);
    Uri uri = Uri.parse(_host);
    if (result.success) {
      if (result.data[0] == 'S') {
        bool secure = false;
        if (uri.isScheme('HTTPS')) {
          secure = true;
        } else {
          secure = false;
        }
        prefs.setBool("secure", secure);
        if (uri.port != null) {
          prefs.setString("host", "${uri.host}:${uri.port}");
        } else {
          prefs.setString("host", uri.host);
        }
        prefs.setString("prefix", uri.path);
        prefs.setString("company_code", _companyCodeText.text);
        Navigator.pop(context, 'Register was successfully');
      } else {
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
          message: result.data[1],
        ).show(context);
      }

      // Navigator.pop(context, result.data);
    } else {
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
        message: result.message,
      ).show(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    deviceState = Provider.of<DeviceState>(context);
    height = MediaQuery.of(context).size.height;
    width = MediaQuery.of(context).size.width;
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(FocusNode());
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: Stack(
          children: <Widget>[
            Image(
              image: const AssetImage(UIImage.background),
              fit: BoxFit.cover,
              width: width,
              height: height,
            ),
            CustomScrollView(
              slivers: <Widget>[
                SliverToBoxAdapter(
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.only(top: width! * 0.2),
                        child: SvgPicture.asset(
                          UIImage.logo,
                          width: width! * 0.2,
                          height: width! * 0.2,
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(
                            top: width! * 0.1, bottom: width! * 0.05),
                        child: const Text(
                          UIString.appName,
                          style: TextStyle(fontSize: 25),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 15.0, right: 15.0),
                        child: Form(
                            key: formRegisterKey,
                            autovalidateMode:
                                AutovalidateMode.onUserInteraction,
                            child: Column(
                              children: <Widget>[
                                TextFormField(
                                  autofocus: false,
                                  maxLines: 1,
                                  controller: _usernameText,
                                  validator: (value) {
                                    if (value!.isEmpty) {
                                      return UIString.usernameRequired;
                                    } else {
                                      return null;
                                    }
                                  },
                                  onFieldSubmitted: (val) =>
                                      FocusScope.of(context)
                                          .requestFocus(focusCompanyCode),
                                  decoration: InputDecoration(
                                    contentPadding: EdgeInsets.zero,
                                    focusColor: Theme.of(context).primaryColor,
                                    hintText: UIString.usernameLabel,
                                  ),
                                ),
                                TextFormField(
                                  autofocus: false,
                                  maxLines: 1,
                                  controller: _companyCodeText,
                                  focusNode: focusCompanyCode,
                                  validator: (value) {
                                    if (value!.isEmpty) {
                                      return UIString.companyCodeRequired;
                                    } else {
                                      return null;
                                    }
                                  },
                                  onFieldSubmitted: (val) =>
                                      FocusScope.of(context)
                                          .requestFocus(focusHost),
                                  decoration: InputDecoration(
                                    contentPadding: EdgeInsets.zero,
                                    focusColor: Theme.of(context).primaryColor,
                                    hintText: UIString.companyCodeLabel,
                                  ),
                                ),
                                TextFormField(
                                  autofocus: false,
                                  maxLines: 1,
                                  controller: _hostText,
                                  focusNode: focusHost,
                                  validator: (value) {
                                    if (value!.isEmpty) {
                                      return UIString.hostRequired;
                                    } else {
                                      return null;
                                    }
                                  },
                                  onFieldSubmitted: (val) =>
                                      FocusScope.of(context).requestFocus(
                                    FocusNode(),
                                  ),
                                  decoration: InputDecoration(
                                    contentPadding: EdgeInsets.zero,
                                    focusColor: Theme.of(context).primaryColor,
                                    hintText: UIString.hostLabel,
                                  ),
                                ),
                                const SizedBox(
                                  height: 20,
                                ),
                                buildBtnRegister()
                              ],
                            )),
                      )
                    ],
                  ),
                )
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget buildBtnRegister() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        ElevatedButton(
          onPressed: () async {
            if (formRegisterKey.currentState!.validate()) {
              FocusScope.of(context).requestFocus(FocusNode());
              await callAPI();
            }
          },
          child: const Text("Register"),
        ),
        const SizedBox(
          height: 10,
        ),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 5),
          child: InkWell(
            onTap: () async {
              Navigator.pop(context);
            },
            child: Align(
              alignment: Alignment.center,
              child: RichText(
                text: TextSpan(
                  text: 'Already register device ? ',
                  style: const TextStyle(
                    color: Colors.black,
                  ),
                  children: [
                    TextSpan(
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          Navigator.pop(context);
                        },
                      text: "Login",
                      style: TextStyle(
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(
          height: 10,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              UIData.appVersion,
              // style: TextStyle(
              //   fontSize: Theme.of(context).primaryTextTheme.caption.fontSize,
              // ),
            ),
          ],
        ),
      ],
    );
  }
}

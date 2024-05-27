// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'dart:developer';

import 'package:another_flushbar/flushbar.dart';
import 'package:enta_mobile/args/general.dart';
import 'package:enta_mobile/models/auth.dart';
import 'package:enta_mobile/models/response_api.dart';
import 'package:enta_mobile/pages/register.dart';
import 'package:enta_mobile/providers/device.dart';
import 'package:enta_mobile/utils/url.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../root.dart';
import '../utils/data.dart';
import '../utils/functions.dart';
import '../utils/images.dart';
import '../utils/strings.dart';

class LoginPage extends StatefulWidget {
  static const routeName = '/login';
  final bool? showAlert;
  final String? alertText;
  const LoginPage({Key? key, this.showAlert, this.alertText}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  late DeviceState deviceState;
  final formLoginKey = GlobalKey<FormState>();
  final FocusNode focusPassword = FocusNode();
  final TextEditingController _usernameText = TextEditingController();
  final TextEditingController _passwordText = TextEditingController();
  late SharedPreferences prefs;
  bool isLoading = false;
  bool? rememberMe = false;
  double? height, width;
  String? deviceInfo,
      heightScreen,
      widthScreen,
      _companyCode,
      _host,
      _prefix,
      _deviceId,
      _password,
      _planText,
      _secretKey,
      _parameters,
      responseAPI;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () async {
      prefs = await SharedPreferences.getInstance();
      rememberMe = prefs.getBool("remember_me") ?? false;
      if (rememberMe!) {
        _usernameText.text = prefs.getString("username") ?? "";
        _passwordText.text = prefs.getString("password") ?? "";
      }
      setState(() {});
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
          Icons.info_outline_rounded,
          color: Colors.white,
        ),
        title: 'Information',
        message: widget.alertText,
      ).show(context);
    }
  }

  Future<void> callAPI() async {
    _deviceId = deviceState.deviceId;
    _companyCode = prefs.getString("company_code") ?? "";
    bool secure = prefs.getBool("secure") ?? false;
    _host = prefs.getString("host");
    _prefix = prefs.getString("prefix");
    if (_host == null || _host == "") {
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
        message: UIString.errorNotYetRegister,
      ).show(context);
    } else {
      Uri uri;
      if (secure) {
        uri = Uri.https(_host!, _prefix! + UIUrl.login);
      } else {
        uri = Uri.http(_host!, _prefix! + UIUrl.login);
      }
      _password = UIFunction.encodeStringBase64URL(_passwordText.text);
      var passwordv2 = _password!.replaceAll("=", "");
      passwordv2 = passwordv2.replaceAll("+", "-");
      passwordv2 = passwordv2.replaceAll("/", "_");
      _planText = _usernameText.text +
          passwordv2 +
          _companyCode! +
          _deviceId! +
          _companyCode! +
          _deviceId!;
      _secretKey = UIFunction.encodeSha1(_planText!);
      _parameters = json.encode([
        _usernameText.text,
        passwordv2,
        _companyCode,
        _deviceId,
        _secretKey,
      ]);
      log(_parameters!);
      UIFunction.showDialogLoadingBlank(context: context);
      ResponseAPI result = await UIFunction.callAPIDIO(
        method: 'POST',
        url: uri.toString(),
        formData: _parameters,
      );
      Navigator.pop(context);
      if (result.success) {
        log("Login Success");
        if (result.data[0] == 'S') {
          var data = json.decode(result.data[1]);
          AuthModel auth = AuthModel(
            token: data[0].toString(),
            username: _usernameText.text,
            employeeName: data[1],
            photoProfile: data[3] ?? "",
            companyCode: _companyCode,
            host: _host,
          );
          prefs.setString("token", auth.token!);
          prefs.setString("username", auth.username!);
          prefs.setBool("remember_me", rememberMe!);
          if (rememberMe!) {
            prefs.setString("password", _passwordText.text);
          }
          prefs.setString("employee_name", auth.employeeName!);
          prefs.setString("photo_profile", auth.photoProfile ?? "");
          deviceState.setMyAuth(data: auth);
          deviceState.setMyOffice(data: UIData.dummyOffice);
          Navigator.pushReplacementNamed(context, MainPage.routeName,
              arguments: GeneralArgs(
                  showAlert: true, alertText: "Welcome ${auth.employeeName}"));
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
                    crossAxisAlignment: CrossAxisAlignment.stretch,
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
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 25),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 15.0, right: 15.0),
                        child: Form(
                            key: formLoginKey,
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
                                          .requestFocus(focusPassword),
                                  decoration: InputDecoration(
                                    contentPadding: EdgeInsets.zero,
                                    focusColor: Theme.of(context).primaryColor,
                                    hintText: UIString.usernameLabel,
                                  ),
                                ),
                                TextFormField(
                                  autofocus: false,
                                  obscureText: true,
                                  maxLines: 1,
                                  controller: _passwordText,
                                  focusNode: focusPassword,
                                  validator: (value) {
                                    if (value!.isEmpty) {
                                      return UIString.passwordRequired;
                                    } else {
                                      return null;
                                    }
                                  },
                                  onFieldSubmitted: (val) =>
                                      FocusScope.of(context)
                                          .requestFocus(FocusNode()),
                                  decoration: InputDecoration(
                                    contentPadding: EdgeInsets.zero,
                                    focusColor: Theme.of(context).primaryColor,
                                    hintText: UIString.passwordLabel,
                                  ),
                                ),
                                const SizedBox(
                                  height: 5,
                                ),
                                GestureDetector(
                                  onTap: () {
                                    rememberMe = !rememberMe!;
                                    setState(() {});
                                  },
                                  child: Transform(
                                    transform: Matrix4.translationValues(
                                        -10.0, 0.0, 0.0),
                                    child: Row(
                                      children: [
                                        Checkbox(
                                            value: rememberMe,
                                            onChanged: (bool? val) {
                                              rememberMe = val;
                                              setState(() {});
                                            }),
                                        const Text("Remember me ?")
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                buildBtnLogin()
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

  Widget buildBtnLogin() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        ElevatedButton(
          onPressed: () async {
            if (formLoginKey.currentState!.validate()) {
              FocusScope.of(context).requestFocus(FocusNode());
              await callAPI();
            }
          },
          child: const Text("Log In"),
        ),
        const SizedBox(
          height: 10,
        ),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 5),
          child: InkWell(
            onTap: () async {
              var result =
                  await Navigator.pushNamed(context, RegisterPage.routeName);
              if (result != null) {
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
                  message: result as String?,
                ).show(context);
              }
            },
            child: Align(
              alignment: Alignment.center,
              child: RichText(
                text: TextSpan(
                  text: 'Not yet register device ? ',
                  style: const TextStyle(
                    color: Colors.black,
                  ),
                  children: [
                    TextSpan(
                      recognizer: TapGestureRecognizer()
                        ..onTap = () async {
                          var result = await Navigator.pushNamed(
                              context, RegisterPage.routeName);
                          if (result != null) {
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
                              message: result as String?,
                            ).show(context);
                          }
                        },
                      text: "Register Now",
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
          height: 5,
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

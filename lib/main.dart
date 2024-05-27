import 'dart:async';

import 'package:enta_mobile/pages/approval/index.dart';
import 'package:enta_mobile/pages/history/clocking_detail.dart';
import 'package:enta_mobile/pages/history/leave.dart';
import 'package:enta_mobile/pages/history/overtime.dart';
import 'package:enta_mobile/pages/info/index.dart';
import 'package:enta_mobile/pages/login.dart';
import 'package:enta_mobile/pages/register.dart';
import 'package:enta_mobile/pages/request_form/leave.dart';
import 'package:enta_mobile/pages/request_form/overtime.dart';
import 'package:enta_mobile/pages/request_form/tap_in_out.dart';
import 'package:enta_mobile/providers/device.dart';
import 'package:enta_mobile/providers/request.dart';
import 'package:enta_mobile/root.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'args/general.dart';
import 'pages/error.dart';
import 'pages/history/clocking.dart';
import 'pages/history/index.dart';
import 'pages/request_form/index.dart';
import 'pages/splash.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() async {
  await runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();
    initializeDateFormatting();
    await Firebase.initializeApp();
    FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.black38,
      ),
    );
    runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<DeviceState>(
            create: (context) => DeviceState(),
          ),
          ChangeNotifierProvider<RequestState>(
            create: (context) => RequestState(),
          )
        ],
        child: const MyApp(),
      ),
    );
  }, (error, stackTrace) {
    FirebaseCrashlytics.instance.recordError(error, stackTrace);
  });
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        primaryColor: Colors.blue,
      ),
      title: 'Enta Mobile',
      onGenerateRoute: (settings) {
        if (settings.name == SplashPage.routeName) {
          final GeneralArgs? args = settings.arguments as GeneralArgs?;
          return MaterialPageRoute(
            settings: const RouteSettings(name: SplashPage.routeName),
            builder: (context) {
              return SplashPage(
                showAlert: args!.showAlert ?? false,
                alertText: args.alertText ?? "",
              );
            },
          );
        } else if (settings.name == LoginPage.routeName) {
          final GeneralArgs? args = settings.arguments as GeneralArgs?;
          return MaterialPageRoute(
            settings: const RouteSettings(name: LoginPage.routeName),
            builder: (context) {
              return LoginPage(
                showAlert: args!.showAlert ?? false,
                alertText: args.alertText,
              );
            },
          );
        } else if (settings.name == RegisterPage.routeName) {
          return MaterialPageRoute(
            settings: const RouteSettings(name: RegisterPage.routeName),
            builder: (context) {
              return const RegisterPage();
            },
          );
        } else if (settings.name == MainPage.routeName) {
          final GeneralArgs? args = settings.arguments as GeneralArgs?;
          return MaterialPageRoute(
            settings: const RouteSettings(name: MainPage.routeName),
            builder: (context) {
              return MainPage(
                showAlert: args!.showAlert ?? false,
                alertText: args.alertText ?? "",
              );
            },
          );
        } else if (settings.name == ApprovalPage.routeName) {
          return MaterialPageRoute(
            settings: const RouteSettings(name: ApprovalPage.routeName),
            builder: (context) {
              return const ApprovalPage();
            },
          );
        } else if (settings.name == RequestFormPage.routeName) {
          return MaterialPageRoute(
            settings: const RouteSettings(name: RequestFormPage.routeName),
            builder: (context) {
              return const RequestFormPage();
            },
          );
        } else if (settings.name == LeaveRequestPage.routeName) {
          return MaterialPageRoute(
            settings: const RouteSettings(name: LeaveRequestPage.routeName),
            builder: (context) {
              return const LeaveRequestPage();
            },
          );
        } else if (settings.name == OvertimeRequestPage.routeName) {
          return MaterialPageRoute(
            settings: const RouteSettings(name: OvertimeRequestPage.routeName),
            builder: (context) {
              return const OvertimeRequestPage();
            },
          );
        } else if (settings.name == TapInOutPage.routeName) {
          final GeneralArgs? args = settings.arguments as GeneralArgs?;
          return MaterialPageRoute(
            settings: const RouteSettings(name: TapInOutPage.routeName),
            builder: (context) {
              return TapInOutPage(
                key: args!.key,
                title: args.title,
                url: args.url,
                type: args.type,
              );
            },
          );
        } else if (settings.name == HistoryPage.routeName) {
          return MaterialPageRoute(
            settings: const RouteSettings(name: HistoryPage.routeName),
            builder: (context) {
              return const HistoryPage();
            },
          );
        } else if (settings.name == ClockingHistoryPage.routeName) {
          return MaterialPageRoute(
            settings: const RouteSettings(name: ClockingHistoryPage.routeName),
            builder: (context) {
              return const ClockingHistoryPage();
            },
          );
        } else if (settings.name == OvertimeHistoryPage.routeName) {
          return MaterialPageRoute(
            settings: const RouteSettings(name: OvertimeHistoryPage.routeName),
            builder: (context) {
              return const OvertimeHistoryPage();
            },
          );
        } else if (settings.name == LeaveHistoryPage.routeName) {
          return MaterialPageRoute(
            settings: const RouteSettings(name: LeaveHistoryPage.routeName),
            builder: (context) {
              return const LeaveHistoryPage();
            },
          );
        } else if (settings.name == InfoPage.routeName) {
          return MaterialPageRoute(
            settings: const RouteSettings(name: InfoPage.routeName),
            builder: (context) {
              return const InfoPage();
            },
          );
        } else if (settings.name == ClockingHistoryDetailPage.routeName) {
          final GeneralArgs? args = settings.arguments as GeneralArgs?;
          return MaterialPageRoute(
            settings:
                const RouteSettings(name: ClockingHistoryDetailPage.routeName),
            builder: (context) {
              return ClockingHistoryDetailPage(
                data: args!.clocking,
              );
            },
          );
        } else {
          return MaterialPageRoute(
            builder: (context) {
              return const ErrorPage();
            },
          );
        }
      },
      home: const SplashPage(),
    );
  }
}

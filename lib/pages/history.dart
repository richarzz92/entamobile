import 'dart:convert';
import 'package:enta_mobile/args/general.dart';
import 'package:enta_mobile/models/history.dart';
import 'package:enta_mobile/models/response_api.dart';
import 'package:enta_mobile/pages/history_detail.dart';
import 'package:enta_mobile/providers/device.dart';
import 'package:enta_mobile/utils/functions.dart';
import 'package:enta_mobile/utils/url.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

import '../components/errors/get_data.dart';
import '../components/errors/no_data.dart';
import '../components/loading.dart';

class HistoryPage extends StatefulWidget {
  static const routeName = '/history';
  const HistoryPage({Key? key}) : super(key: key);

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  int? code = 0;
  bool loading = true;
  String msg = "";
  List<HistoryModel> historyList = [];
  late DeviceState deviceState;
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
    loading = true;
    msg = "";
    historyList.clear();
    setState(() {});

    ResponseAPI result = await UIFunction.callAPIDIO(
        url: deviceState.myAuth!.host! + UIUrl.history,
        method: 'POST',
        formData: {});
    code = result.code;
    msg = result.message;
    loading = false;
    setState(() {});
    if (result.success) {
      if (result.data[0] == 'S') {
        List data = json.decode(result.data[1]);
        for (var item in data) {
          historyList.add(HistoryModel(
              item[0],
              item[1],
              item[2].toString().toLowerCase(),
              item[3],
              item[4].toString(),
              item[5].toString(),
              item[6],
              item[7]));
        }
        setState(() {});
      } else {
        code = 500;
        setState(() {});
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    deviceState = Provider.of<DeviceState>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('History'),
      ),
      body: RefreshIndicator(
        onRefresh: initPage,
        child: buildBody(),
      ),
    );
  }

  Widget buildBody() {
    if (loading) {
      return const Center(
        child: LoadingWidget(),
      );
    } else if (code != 200) {
      return ErrorGetData(
        callBack: initPage,
        title: msg,
      );
    } else if (historyList.isEmpty) {
      return ErrorNoData(
        callBack: initPage,
      );
    } else {
      return ListView.separated(
          itemBuilder: (BuildContext context, int i) {
            return Ink(
              color: Colors.white,
              child: ListTile(
                onTap: () {
                  Navigator.pushNamed(context, HistoryDetailPage.routeName,
                      arguments: GeneralArgs(history: historyList[i]));
                },
                leading: CircleAvatar(
                  radius: 20,
                  backgroundColor: historyList[i].type == 'in'
                      ? Theme.of(context).primaryColor
                      : historyList[i].type == 'out'
                          ? Colors.redAccent
                          : Colors.orangeAccent,
                  child: Center(
                    child: Icon(
                      historyList[i].type == 'in'
                          ? FontAwesomeIcons.arrowUp
                          : historyList[i].type == 'out'
                              ? FontAwesomeIcons.arrowDown
                              : FontAwesomeIcons.question,
                      color: Colors.white,
                      size: 17,
                    ),
                  ),
                ),
                trailing: const Icon(
                  FontAwesomeIcons.chevronRight,
                  size: 15,
                ),
                title: Text(
                  historyList[i].date!,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(
                      historyList[i].time!,
                      style: TextStyle(
                          fontSize: Theme.of(context)
                              .primaryTextTheme
                              .subtitle2!
                              .fontSize),
                    ),
                    Text(
                      historyList[i].status!,
                      style: TextStyle(
                          fontSize: Theme.of(context)
                              .primaryTextTheme
                              .subtitle2!
                              .fontSize),
                    )
                  ],
                ),
              ),
            );
          },
          separatorBuilder: (BuildContext context, int i) {
            return const Divider(
              height: 0,
            );
          },
          itemCount: historyList.length);
    }
  }
}

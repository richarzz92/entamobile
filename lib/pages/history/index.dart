import 'package:enta_mobile/providers/device.dart';
import 'package:enta_mobile/utils/data.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HistoryPage extends StatefulWidget {
  static const routeName = '/history';
  const HistoryPage({Key? key}) : super(key: key);

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  late DeviceState deviceState;
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    deviceState = Provider.of<DeviceState>(context);
    return Scaffold(
      appBar: AppBar(
        elevation: 1,
        title: const Text("History"),
      ),
      body: ListView.separated(
        itemBuilder: (context, i) {
          return Visibility(
            visible: UIData.menuHistory[i].code == 'clocking' &&
                    deviceState.clockingAccess
                ? true
                : UIData.menuHistory[i].code == 'overtime' &&
                        deviceState.otAccess
                    ? true
                    : UIData.menuHistory[i].code == 'leave' &&
                            deviceState.lvAccess
                        ? true
                        : false,
            child: ListTile(
              onTap: () {
                if (UIData.menuHistory[i].route != null) {
                  Navigator.pushNamed(context, UIData.menuHistory[i].route!);
                }
              },
              title: Text(UIData.menuHistory[i].label!),
              trailing: const Icon(Icons.chevron_right_rounded),
            ),
          );
        },
        separatorBuilder: (context, i) {
          return const Divider(
            height: 0,
          );
        },
        itemCount: UIData.menuHistory.length,
      ),
    );
  }
}

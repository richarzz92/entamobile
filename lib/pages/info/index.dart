import 'package:enta_mobile/utils/data.dart';
import 'package:flutter/material.dart';

class InfoPage extends StatefulWidget {
  static const routeName = '/info';
  const InfoPage({Key? key}) : super(key: key);

  @override
  State<InfoPage> createState() => _InfoPageState();
}

class _InfoPageState extends State<InfoPage> {
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
    return Scaffold(
      appBar: AppBar(
        elevation: 1,
        title: const Text("Info"),
      ),
      body: ListView.separated(
        itemBuilder: (context, i) {
          return ListTile(
            onTap: () {},
            title: Text(UIData.menuInfo[i].label!),
            trailing: const Icon(Icons.chevron_right_rounded),
          );
        },
        separatorBuilder: (context, i) {
          return const Divider(
            height: 0,
          );
        },
        itemCount: UIData.menuInfo.length,
      ),
    );
  }
}

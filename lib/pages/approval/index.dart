import 'package:enta_mobile/utils/data.dart';
import 'package:flutter/material.dart';

class ApprovalPage extends StatefulWidget {
  static const routeName = '/approval';
  const ApprovalPage({Key? key}) : super(key: key);

  @override
  State<ApprovalPage> createState() => _ApprovalPageState();
}

class _ApprovalPageState extends State<ApprovalPage> {
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
        title: const Text("Approval"),
      ),
      body: ListView.separated(
        itemBuilder: (context, i) {
          return ListTile(
            onTap: () {},
            title: Text(UIData.menuApproval[i].label!),
            trailing: const Icon(Icons.chevron_right_rounded),
          );
        },
        separatorBuilder: (context, i) {
          return const Divider(
            height: 0,
          );
        },
        itemCount: UIData.menuApproval.length,
      ),
    );
  }
}

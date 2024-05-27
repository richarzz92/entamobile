import 'package:enta_mobile/utils/data.dart';
import 'package:flutter/material.dart';

class RequestFormPage extends StatefulWidget {
  static const routeName = '/request-form';
  const RequestFormPage({Key? key}) : super(key: key);

  @override
  State<RequestFormPage> createState() => _RequestFormPageState();
}

class _RequestFormPageState extends State<RequestFormPage> {
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
        title: const Text("Request Form"),
      ),
      body: ListView.separated(
        itemBuilder: (context, i) {
          return ListTile(
            onTap: () {},
            title: Text(UIData.menuRequestForm[i].label!),
            trailing: const Icon(Icons.chevron_right_rounded),
          );
        },
        separatorBuilder: (context, i) {
          return const Divider(
            height: 0,
          );
        },
        itemCount: UIData.menuRequestForm.length,
      ),
    );
  }
}

import 'dart:developer';

import 'package:flutter/material.dart';

class ErrorNoData extends StatefulWidget {
  final void Function()? callBack;
  const ErrorNoData({
    Key? key,
    this.callBack,
  }) : super(key: key);

  @override
  State<ErrorNoData> createState() => _ErrorNoDataState();
}

class _ErrorNoDataState extends State<ErrorNoData> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            child: Text("No Data"),
          ),
          const SizedBox(
            height: 10,
          ),
          Center(
            child: ElevatedButton(
              onPressed: () {
                log("reload");
                widget.callBack!();
              },
              style: ElevatedButton.styleFrom(
                elevation: 0,
                primary: Theme.of(context).primaryColor.withAlpha(50),
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(
                    Radius.circular(20),
                  ),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
              ),
              child: Text(
                "Reload",
                style: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontSize:
                      Theme.of(context).primaryTextTheme.subtitle2!.fontSize,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';

class ErrorGetData extends StatefulWidget {
  final String title;
  final void Function() callBack;
  const ErrorGetData({
    Key? key,
    required this.title,
    required this.callBack,
  }) : super(key: key);

  @override
  State<ErrorGetData> createState() => _ErrorGetDataState();
}

class _ErrorGetDataState extends State<ErrorGetData> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            child: Text(
              widget.title,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          Center(
            child: ElevatedButton(
              onPressed: () {
                widget.callBack();
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

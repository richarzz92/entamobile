import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class LoadingWidget extends StatelessWidget {
  final double? size;
  final double? stroke;
  final Color? color;
  const LoadingWidget({Key? key, this.size, this.stroke, this.color})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      return SizedBox(
        height: size ?? 25,
        width: size ?? 25,
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(
              color ?? Theme.of(context).primaryColor),
          strokeWidth: stroke ?? 3,
        ),
      );
    } else {
      return SizedBox(
        height: size ?? 25,
        width: size ?? 25,
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(
              color ?? Theme.of(context).primaryColor),
          strokeWidth: stroke ?? 3,
        ),
      );
    }
  }
}

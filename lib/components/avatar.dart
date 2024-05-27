import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:skeleton_text/skeleton_text.dart';

import '../utils/images.dart';

class AvatarWidget extends StatefulWidget {
  final String? url;
  final double? width, height;
  const AvatarWidget({Key? key, this.url, this.width, this.height})
      : super(key: key);

  @override
  State<AvatarWidget> createState() => _AvatarWidgetState();
}

class _AvatarWidgetState extends State<AvatarWidget> {
  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
        imageUrl: widget.url!,
        imageBuilder: (context, imageProvider) => Container(
              height: widget.height,
              width: widget.width,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                image: DecorationImage(
                  image: imageProvider,
                  fit: BoxFit.cover,
                ),
              ),
            ),
        placeholder: (context, url) => SkeletonAnimation(
              child: Container(
                height: widget.height,
                width: widget.width,
                decoration: BoxDecoration(
                  color: Theme.of(context).dividerColor,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.info,
                  color: Colors.transparent,
                  size: 30,
                ),
              ),
            ),
        errorWidget: (context, url, error) {
          return Image.asset(
            UIImage.user,
            height: widget.height,
            width: widget.width,
          );
        });
  }
}

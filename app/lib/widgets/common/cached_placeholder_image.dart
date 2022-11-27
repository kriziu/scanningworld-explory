import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class CachedPlaceholderImage extends StatelessWidget {
  const CachedPlaceholderImage(
      {Key? key,
      required this.imageUrl,
      this.fit = BoxFit.cover,
      this.height,
      this.width,
      this.placeholder,
      this.errorWidget})
      : super(key: key);

  final String imageUrl;
  final double? height;
  final double? width;
  final BoxFit? fit;
  final Widget? placeholder;
  final Widget? errorWidget;

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: imageUrl,
      placeholder: (context, url) => placeholder != null
          ? placeholder!
          : Image.asset(
              'assets/logo_scanningworld.png',
            ),
      errorWidget: (context, url, error) => errorWidget != null ? errorWidget! : Image.asset(
        'assets/logo_scanningworld.png',
      ),
      height: height,
      width: width,
      fit: fit,
    );
  }
}

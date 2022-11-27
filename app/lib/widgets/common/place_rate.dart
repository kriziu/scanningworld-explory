import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

class PlaceRate extends StatelessWidget {
  final num rate;

  const PlaceRate({Key? key, required this.rate}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (rate == 0) {
      return const SizedBox.shrink();
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          "($rate",
        ),
        Icon(
          context.platformIcon(
              material: Icons.star, cupertino: CupertinoIcons.star_fill),
          color: Colors.amber,
          size: 16,
        ),
        const Text(")"),
      ],
    );
  }
}

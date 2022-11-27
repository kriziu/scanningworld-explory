import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:scanning_world/widgets/common/cached_placeholder_image.dart';

import '../../data/remote/models/user/review.dart';

class ReviewRow extends StatelessWidget {
  final Review review;

  const ReviewRow({Key? key, required this.review}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: const Color(0xffefefef),
                radius: 30,
                child: Image.asset(
                  'assets/avatars/${review.publisher.avatar}.png',
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(review.publisher.name),
                  const SizedBox(height: 4),
                  const Text("4 reviews"),
                ],
              ),
              const Spacer(),
              Text(
                '2 days ago',
                style: TextStyle(color: Colors.grey.shade600),
              ),
            ],
          ),
          const SizedBox(height: 12),
          RatingBar.builder(
            initialRating: review.rating.toDouble(),
            glow: false,
            ignoreGestures: true,
            minRating: 1,
            itemSize: 28,
            direction: Axis.horizontal,
            itemCount: 5,
            itemPadding: const EdgeInsets.symmetric(horizontal: 0.0),
            itemBuilder: (context, _) => const Icon(
              Icons.star,
              color: Colors.amber,
            ),
            onRatingUpdate: (d) => {},
          ),
          const SizedBox(height: 8),
          Text(
            review.comment ?? '',
            style: const TextStyle(fontSize: 15),
          ),
          const Divider(),
        ],
      ),
    );
  }
}



import 'package:scanning_world/data/remote/models/user/review_publisher.dart';

class Review{


  final ReviewPublisher publisher;
  final num rating;
  final String? comment;

  Review({
    required this.publisher,
    required this.rating,
    this.comment,
  });

  factory Review.fromJson(Map<String, dynamic> json) => Review(
    publisher: ReviewPublisher.fromJson(json["user"]),
    rating: json["rating"],
    comment: json["comment"],
  );

  Map<String, dynamic> toJson() => {
    "publisher": publisher.toJson(),
    "rating": rating,
    "comment": comment,
  };

}
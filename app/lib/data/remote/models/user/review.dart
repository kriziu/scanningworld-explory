import 'package:scanning_world/data/remote/models/user/review_publisher.dart';

class Review {
  final ReviewPublisher publisher;
  final num rating;
  final DateTime date;
  final String? comment;

  Review({
    required this.publisher,
    required this.rating,
    required this.date,
    this.comment,
  });

  factory Review.fromJson(Map<String, dynamic> json) => Review(
        publisher: ReviewPublisher.fromJson(json["user"]),
        rating: json["rating"],
        date: DateTime.parse(json["reviewDate"]),
        comment: json["comment"],
      );

  Map<String, dynamic> toJson() => {
        "publisher": publisher.toJson(),
        "rating": rating,
        "comment": comment,
        "reviewDate": date.toIso8601String(),
      };
}

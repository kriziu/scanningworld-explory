class ReviewPublisher {
  final String name;
  final String avatar;

  ReviewPublisher({
    required this.name,
    required this.avatar,
  });

  factory ReviewPublisher.fromJson(Map<String, dynamic> json) =>
      ReviewPublisher(
        name: json["name"],
        avatar: json["avatar"],
      );

  Map<String, dynamic> toJson() => {
        "name": name,
        "avatar": avatar,
      };
}

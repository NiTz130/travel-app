class Review {
  final String? userId;
  final String reviewId;
  final String name;
  final DateTime publishAt;
  final String reviewerPhotoUrl;
  final String text;

  Review({
    required this.userId,
    required this.reviewId,
    required this.name,
    required this.publishAt,
    required this.reviewerPhotoUrl,
    required this.text,
  });

  Map<String, dynamic> toJson() => {
    "userId": userId,
    "reviewId": reviewId,
    "name": name,
    "publishAt": publishAt, // Có thể cần chuyển sang Timestamp nếu push lên Firestore
    "reviewerPhotoUrl": reviewerPhotoUrl,
    "text": text,
  };

  factory Review.fromMap(dynamic map) {
    // Xử lý các trường hợp publishAt là Timestamp, DateTime, String
    DateTime parsePublishAt(dynamic val) {
      if (val == null) return DateTime.now();
      if (val is DateTime) return val;
      if (val is String) return DateTime.tryParse(val) ?? DateTime.now();
      // Nếu là Timestamp của cloud_firestore
      if (val.runtimeType.toString() == 'Timestamp') {
        return val.toDate();
      }
      return DateTime.now();
    }

    return Review(
      userId: map["userId"],
      reviewId: map["reviewId"] ?? "etetret",
      name: map["name"] ?? "",
      publishAt: parsePublishAt(map["publishAt"]),
      reviewerPhotoUrl: map["reviewerPhotoUrl"] ?? "",
      text: map["text"] ?? "",
    );
  }
}

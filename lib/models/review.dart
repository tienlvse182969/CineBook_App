class ReviewSummary {
  final double averageScore;
  final int reviewCount;

  const ReviewSummary({required this.averageScore, required this.reviewCount});

  factory ReviewSummary.fromJson(Map<String, dynamic> json) {
    return ReviewSummary(
      averageScore: (json['average_score'] as num?)?.toDouble() ?? 0.0,
      reviewCount: (json['review_count'] as num?)?.toInt() ?? 0,
    );
  }
}

class MovieReview {
  final int reviewId;
  final int movieId;
  final int? userId;
  final String reviewerName;
  final int score;
  final String? comment;
  final DateTime createdAt;

  const MovieReview({
    required this.reviewId,
    required this.movieId,
    this.userId,
    required this.reviewerName,
    required this.score,
    this.comment,
    required this.createdAt,
  });

  factory MovieReview.fromJson(Map<String, dynamic> json) {
    final userJson = json['User'] as Map<String, dynamic>?;
    final reviewerName =
        json['reviewer_name']?.toString() ??
        userJson?['full_name']?.toString() ??
        'Người dùng';

    final createdAtStr = json['created_at']?.toString();
    final createdAt =
        (createdAtStr != null ? DateTime.tryParse(createdAtStr) : null)
            ?.toLocal() ??
        DateTime.now();

    return MovieReview(
      reviewId: (json['review_id'] as num?)?.toInt() ?? 0,
      movieId: (json['movie_id'] as num?)?.toInt() ?? 0,
      userId: (json['user_id'] as num?)?.toInt(),
      reviewerName: reviewerName,
      score: (json['score'] as num?)?.toInt() ?? 1,
      comment: json['comment']?.toString(),
      createdAt: createdAt,
    );
  }

  String get initials {
    final parts = reviewerName
        .trim()
        .split(RegExp(r'\s+'))
        .where((p) => p.isNotEmpty)
        .toList();
    if (parts.isEmpty) return 'U';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  String get dateLabel {
    String pad(int n) => n.toString().padLeft(2, '0');
    return '${pad(createdAt.day)}/${pad(createdAt.month)}/${createdAt.year}';
  }
}

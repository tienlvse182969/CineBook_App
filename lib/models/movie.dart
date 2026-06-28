import 'package:flutter/material.dart';

class Movie {
  final int? id;
  final String? apiMovieId;
  final String title;
  final String genre;
  final String rating;
  final String duration;
  final String year;
  final List<Color> colors;
  final String description;
  final String director;
  final List<String> cast;
  final String ageRating;
  final String ageRatingDesc;
  final String language;
  final String firstShowing;
  final String? posterUrl;
  final String status;

  const Movie({
    this.id,
    this.apiMovieId,
    required this.title,
    required this.genre,
    required this.rating,
    required this.duration,
    required this.year,
    required this.colors,
    required this.description,
    required this.director,
    required this.cast,
    required this.ageRating,
    required this.ageRatingDesc,
    required this.language,
    required this.firstShowing,
    this.posterUrl,
    this.status = 'NOW_SHOWING',
  });

  factory Movie.fromJson(Map<String, dynamic> json) {
    final age = (json['age_restriction'] as num?)?.toInt() ?? 0;
    final duration = (json['duration_minutes'] as num?)?.toInt();
    final castJson = json['cast'];
    final cast = castJson is List
        ? castJson.map((e) => e.toString()).toList()
        : <String>[];

    return Movie(
      id: (json['movie_id'] as num?)?.toInt(),
      apiMovieId: json['api_movie_id']?.toString(),
      title: json['title']?.toString() ?? '',
      genre: json['genre']?.toString() ?? 'Đang cập nhật',
      rating: json['rating']?.toString() ?? 'N/A',
      duration: duration == null ? 'Đang cập nhật' : '$duration phút',
      year: _yearFromFirstShowing(json['first_showing']?.toString()),
      colors: [
        _colorFromHex(
          json['color_primary']?.toString(),
          const Color(0xFF1A237E),
        ),
        _colorFromHex(
          json['color_secondary']?.toString(),
          const Color(0xFF880E4F),
        ),
      ],
      firstShowing: json['first_showing']?.toString() ?? 'Đang cập nhật',
      posterUrl: _cleanUrl(json['poster_url']?.toString()),
      language: json['language']?.toString() ?? 'Đang cập nhật',
      ageRating: age == 0 ? 'P' : 'T$age',
      ageRatingDesc: age == 0
          ? 'Phim được phổ biến đến mọi đối tượng khán giả.'
          : 'Phim được phổ biến đến người xem từ đủ $age tuổi trở lên.',
      director: json['director']?.toString() ?? 'Đang cập nhật',
      cast: cast,
      description:
          json['description']?.toString() ??
          'Nội dung phim đang được cập nhật.',
      status: json['status']?.toString() ?? 'NOW_SHOWING',
    );
  }

  static String _yearFromFirstShowing(String? value) {
    if (value == null || value.isEmpty) return '';
    final match = RegExp(r'\d{4}').firstMatch(value);
    return match?.group(0) ?? value;
  }

  static Color _colorFromHex(String? value, Color fallback) {
    if (value == null || value.isEmpty) return fallback;
    final hex = value.replaceFirst('#', '');
    if (hex.length != 6) return fallback;
    return Color(int.parse('FF$hex', radix: 16));
  }

  static String? _cleanUrl(String? value) {
    if (value == null) return null;
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }
}

import 'package:flutter/material.dart';

class Movie {
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

  const Movie({
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
  });
}

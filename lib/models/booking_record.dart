import 'package:flutter/material.dart';

class BookingRecord {
  final int id;
  final String movieTitle;
  final String? posterUrl;
  final Color color;
  final String date;
  final String time;
  final String hall;
  final List<String> seats;
  final int total;
  final String bookingStatus;
  final bool isUpcoming;

  const BookingRecord({
    required this.id,
    required this.movieTitle,
    this.posterUrl,
    required this.color,
    required this.date,
    required this.time,
    required this.hall,
    required this.seats,
    required this.total,
    required this.bookingStatus,
    required this.isUpcoming,
  });

  String get bookingCode => 'CB-${id.toString().padLeft(6, '0')}';

  factory BookingRecord.fromJson(Map<String, dynamic> json) {
    final showtimeJson = json['Showtime'] as Map<String, dynamic>?;
    final movieJson = showtimeJson?['Movie'] as Map<String, dynamic>?;
    final roomJson = showtimeJson?['Room'] as Map<String, dynamic>?;

    DateTime? startTime;
    final startStr = showtimeJson?['start_time']?.toString();
    if (startStr != null) startTime = DateTime.tryParse(startStr)?.toLocal();

    final now = DateTime.now();
    final isUpcoming = startTime != null && startTime.isAfter(now);

    String pad(int n) => n.toString().padLeft(2, '0');
    final date = startTime == null
        ? '--/--/----'
        : '${pad(startTime.day)}/${pad(startTime.month)}/${startTime.year}';
    final time = startTime == null
        ? '--:--'
        : '${pad(startTime.hour)}:${pad(startTime.minute)}';

    final seatsJson = json['BookingSeats'] as List<dynamic>? ?? [];
    final seats = seatsJson.expand<String>((s) {
      final seat = (s as Map<String, dynamic>)['Seat'] as Map<String, dynamic>?;
      if (seat == null) return <String>[];
      return ['${seat['row_name']}${seat['seat_number']}'];
    }).toList();

    final hex = (movieJson?['color_primary']?.toString() ?? '#1A237E')
        .replaceFirst('#', '');
    final color = hex.length == 6
        ? Color(int.parse('FF$hex', radix: 16))
        : const Color(0xFF1A237E);

    final totalRaw = json['total_amount'];
    final total = totalRaw is num
        ? totalRaw.round()
        : double.tryParse(totalRaw?.toString() ?? '')?.round() ?? 0;

    return BookingRecord(
      id: (json['booking_id'] as num?)?.toInt() ?? 0,
      movieTitle: movieJson?['title']?.toString() ?? 'Phim đã đặt',
      posterUrl: movieJson?['poster_url']?.toString(),
      color: color,
      date: date,
      time: time,
      hall: roomJson?['name']?.toString() ?? 'Phòng chiếu',
      seats: seats,
      total: total,
      bookingStatus: json['booking_status']?.toString() ?? 'RESERVED',
      isUpcoming: isUpcoming,
    );
  }
}

class ShowtimeData {
  final int? id;
  final int? movieId;
  final int? roomId;
  final DateTime? startTime;
  final DateTime? endTime;
  final int price;
  final String time;
  final String hall;

  /// Seat labels (e.g. "A3", "F7") that are already booked for this slot.
  final List<String> bookedSeats;

  const ShowtimeData({
    this.id,
    this.movieId,
    this.roomId,
    this.startTime,
    this.endTime,
    this.price = 75000,
    required this.time,
    required this.hall,
    required this.bookedSeats,
  });

  factory ShowtimeData.fromJson(Map<String, dynamic> json, {List<String> bookedSeats = const []}) {
    final start = DateTime.tryParse(json['start_time']?.toString() ?? '');
    final room = json['Room'] is Map<String, dynamic> ? json['Room'] as Map<String, dynamic> : null;
    return ShowtimeData(
      id: (json['showtime_id'] as num?)?.toInt(),
      movieId: (json['movie_id'] as num?)?.toInt(),
      roomId: (json['room_id'] as num?)?.toInt(),
      startTime: start,
      endTime: DateTime.tryParse(json['end_time']?.toString() ?? ''),
      price: _priceToInt(json['price']),
      time: start == null ? '--:--' : '${start.hour.toString().padLeft(2, '0')}:${start.minute.toString().padLeft(2, '0')}',
      hall: room?['name']?.toString() ?? 'Phòng ${(json['room_id'] as num?)?.toInt() ?? ''}',
      bookedSeats: bookedSeats,
    );
  }

  ShowtimeData copyWithBookedSeats(List<String> seats) => ShowtimeData(
        id: id,
        movieId: movieId,
        roomId: roomId,
        startTime: startTime,
        endTime: endTime,
        price: price,
        time: time,
        hall: hall,
        bookedSeats: seats,
      );

  static const int totalSeats = 90; // 9 rows × 10 cols

  int get availableSeats => totalSeats - bookedSeats.length;
  double get bookedFraction => bookedSeats.length / totalSeats;

  /// Slot is considered sold out when more than 88 % of seats are taken.
  bool get isSoldOut => bookedSeats.length > (totalSeats * 0.88).toInt();

  static int _priceToInt(dynamic value) {
    if (value is num) return value.round();
    return double.tryParse(value?.toString() ?? '')?.round() ?? 75000;
  }
}

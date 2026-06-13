class ShowtimeData {
  final String time;
  final String hall;

  /// Seat labels (e.g. "A3", "F7") that are already booked for this slot.
  final List<String> bookedSeats;

  const ShowtimeData({required this.time, required this.hall, required this.bookedSeats});

  static const int totalSeats = 90; // 9 rows × 10 cols

  int get availableSeats => totalSeats - bookedSeats.length;
  double get bookedFraction => bookedSeats.length / totalSeats;

  /// Slot is considered sold out when more than 88 % of seats are taken.
  bool get isSoldOut => bookedSeats.length > (totalSeats * 0.88).toInt();
}

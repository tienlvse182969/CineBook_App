import 'package:ve_xem_phim/models/movie.dart';
import 'package:ve_xem_phim/models/showtime.dart';

class BookingInfo {
  final Movie movie;
  final DateTime date;
  final ShowtimeData showtime;
  final List<String> seatLabels;
  final List<int> seatIds;
  final int regularCount;
  final int vipCount;
  final int ticketTotal;

  const BookingInfo({
    required this.movie,
    required this.date,
    required this.showtime,
    required this.seatLabels,
    this.seatIds = const [],
    required this.regularCount,
    required this.vipCount,
    required this.ticketTotal,
  });
}

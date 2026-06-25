import 'package:ve_xem_phim/models/booking_info.dart';
import 'package:ve_xem_phim/models/snack.dart';

class PaymentInfo {
  final BookingInfo booking;
  final Map<int, int> snackQty;
  final List<SnackItem> snackItems;
  final int snackTotal;

  const PaymentInfo({
    required this.booking,
    required this.snackQty,
    this.snackItems = const [],
    required this.snackTotal,
  });

  int get grandTotal => booking.ticketTotal + snackTotal;
}

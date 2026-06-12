import 'package:ve_xem_phim/models/booking_info.dart';

class PaymentInfo {
  final BookingInfo booking;
  final Map<String, int> snackQty;
  final int snackTotal;

  const PaymentInfo({
    required this.booking,
    required this.snackQty,
    required this.snackTotal,
  });

  int get grandTotal => booking.ticketTotal + snackTotal;
}

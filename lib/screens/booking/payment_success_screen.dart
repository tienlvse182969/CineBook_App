import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:ve_xem_phim/models/payment_info.dart';
import 'package:ve_xem_phim/screens/booking/seat_selection_screen.dart';
import 'package:ve_xem_phim/screens/home/home_screen.dart';
import 'package:ve_xem_phim/screens/profile/my_tickets_screen.dart';

class PaymentSuccessScreen extends StatefulWidget {
  final PaymentInfo info;
  const PaymentSuccessScreen({super.key, required this.info});

  @override
  State<PaymentSuccessScreen> createState() => _PaymentSuccessScreenState();
}

class _PaymentSuccessScreenState extends State<PaymentSuccessScreen>
    with TickerProviderStateMixin {
  late final AnimationController _checkCtrl;
  late final AnimationController _cardCtrl;
  late final Animation<double> _checkScale;
  late final Animation<double> _checkOpacity;
  late final Animation<Offset> _cardSlide;
  late final Animation<double> _cardOpacity;

  @override
  void initState() {
    super.initState();

    _checkCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _cardCtrl  = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));

    _checkScale   = CurvedAnimation(parent: _checkCtrl, curve: Curves.elasticOut);
    _checkOpacity = CurvedAnimation(parent: _checkCtrl, curve: const Interval(0, 0.4));

    _cardSlide   = Tween<Offset>(begin: const Offset(0, 0.12), end: Offset.zero)
        .animate(CurvedAnimation(parent: _cardCtrl, curve: Curves.easeOut));
    _cardOpacity = CurvedAnimation(parent: _cardCtrl, curve: Curves.easeOut);

    // Sequence: check first, then card
    _checkCtrl.forward().then((_) => _cardCtrl.forward());
  }

  @override
  void dispose() {
    _checkCtrl.dispose();
    _cardCtrl.dispose();
    super.dispose();
  }

  String _fmt(int p) {
    if (p == 0) return '0 đ';
    final s = p.toString();
    final b = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) b.write('.');
      b.write(s[i]);
    }
    b.write(' đ');
    return b.toString();
  }

  Color get _ageColor {
    switch (widget.info.booking.movie.ageRating) {
      case 'P':   return const Color(0xFF4CAF50);
      case 'K':   return const Color(0xFF2196F3);
      case 'T13': return const Color(0xFFFFC107);
      case 'T16': return const Color(0xFFFF9800);
      case 'T18': return const Color(0xFFF44336);
      default:    return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF080C14),
      body: Stack(
        children: [
          _buildBg(),
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 40),
                _buildCheckmark(),
                const SizedBox(height: 20),
                _buildTitle(),
                const SizedBox(height: 32),
                Expanded(
                  child: FadeTransition(
                    opacity: _cardOpacity,
                    child: SlideTransition(
                      position: _cardSlide,
                      child: ListView(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        children: [
                          _buildTicketCard(),
                          const SizedBox(height: 14),
                          _buildQrCard(),
                          const SizedBox(height: 28),
                          _buildButtons(context),
                          SizedBox(height: MediaQuery.of(context).padding.bottom + 16),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Background ───────────────────────────────────────────────

  Widget _buildBg() {
    return Stack(children: [
      Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF041A0E), Color(0xFF080C14), Color(0xFF080C14)],
          ),
        ),
      ),
      Positioned(
        top: -80, left: 0, right: 0,
        child: Center(
          child: ImageFiltered(
            imageFilter: ImageFilter.blur(sigmaX: 60, sigmaY: 60),
            child: Container(
              width: 280, height: 280,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0x264CAF50),
              ),
            ),
          ),
        ),
      ),
    ]);
  }

  // ── Animated checkmark ───────────────────────────────────────

  Widget _buildCheckmark() {
    return ScaleTransition(
      scale: _checkScale,
      child: FadeTransition(
        opacity: _checkOpacity,
        child: Container(
          width: 90, height: 90,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFF4CAF50).withValues(alpha: 0.12),
            border: Border.all(color: const Color(0xFF4CAF50).withValues(alpha: 0.5), width: 2),
            boxShadow: [
              BoxShadow(color: const Color(0xFF4CAF50).withValues(alpha: 0.25), blurRadius: 30, spreadRadius: 4),
            ],
          ),
          child: const Icon(LucideIcons.circleCheck, color: Color(0xFF4CAF50), size: 44),
        ),
      ),
    );
  }

  Widget _buildTitle() {
    return FadeTransition(
      opacity: _checkOpacity,
      child: Column(
        children: [
          const Text(
            'Thanh toán thành công!',
            style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          Text(
            'Vé của bạn đã được xác nhận',
            style: TextStyle(color: Colors.white.withValues(alpha: 0.45), fontSize: 13),
          ),
        ],
      ),
    );
  }

  // ── Ticket card ──────────────────────────────────────────────

  Widget _buildTicketCard() {
    final b = widget.info.booking;
    final date = b.date;

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
          ),
          child: Column(
            children: [
              // Header strip
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      b.movie.colors.first.withValues(alpha: 0.5),
                      b.movie.colors.last.withValues(alpha: 0.3),
                    ],
                  ),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                      decoration: BoxDecoration(
                        color: _ageColor.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(7),
                        border: Border.all(color: _ageColor.withValues(alpha: 0.5)),
                      ),
                      child: Text(b.movie.ageRating, style: TextStyle(color: _ageColor, fontWeight: FontWeight.bold, fontSize: 12)),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        b.movie.title,
                        style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),

              // Dashed separator
              _DashedDivider(),

              // Info grid
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
                child: Column(
                  children: [
                    Row(
                      children: [
                        _InfoCell(icon: LucideIcons.calendar, label: 'Ngày',    value: '${date.day}/${date.month}/${date.year}'),
                        _InfoCell(icon: LucideIcons.clock,    label: 'Suất',    value: b.showtime.time),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        _InfoCell(icon: LucideIcons.monitor,  label: 'Phòng chiếu', value: b.showtime.hall),
                        _InfoCell(icon: LucideIcons.ticket,   label: 'Ghế',         value: b.seatLabels.join(', ')),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        _InfoCell(
                          icon: LucideIcons.banknote,
                          label: 'Tổng tiền',
                          value: _fmt(widget.info.grandTotal),
                          highlight: true,
                        ),
                        const Expanded(child: SizedBox()),
                      ],
                    ),
                  ],
                ),
              ),

              // Bottom booking code
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.04),
                  borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
                  border: Border(top: BorderSide(color: Colors.white.withValues(alpha: 0.08))),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(LucideIcons.hash, size: 12, color: Colors.white.withValues(alpha: 0.3)),
                    const SizedBox(width: 5),
                    Text('Mã đặt vé: CB-2026-${(date.millisecondsSinceEpoch % 900000 + 100000)}',
                      style: TextStyle(color: Colors.white.withValues(alpha: 0.35), fontSize: 12, letterSpacing: 0.5)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── QR placeholder card ──────────────────────────────────────

  Widget _buildQrCard() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
          ),
          child: Column(
            children: [
              // QR code
              Container(
                width: 120, height: 120,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: Image.asset('assets/qr/QRCode.jpg', fit: BoxFit.contain),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Xuất trình mã này tại quầy',
                style: TextStyle(color: Colors.white.withValues(alpha: 0.45), fontSize: 12),
              ),
              const SizedBox(height: 4),
              Text(
                'Vé có hiệu lực trong 24 giờ',
                style: TextStyle(color: Colors.white.withValues(alpha: 0.25), fontSize: 11),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Action buttons ───────────────────────────────────────────

  Widget _buildButtons(BuildContext context) {
    return Column(
      children: [
        // Primary: về trang chủ
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => const HomeScreen()),
              (_) => false,
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE50914),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              padding: const EdgeInsets.symmetric(vertical: 16),
              elevation: 0,
            ),
            child: const Text('Về trang chủ', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
          ),
        ),
        const SizedBox(height: 12),
        // Secondary: xem vé
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const MyTicketsScreen()),
            ),
            icon: const Icon(LucideIcons.ticket, size: 16),
            label: const Text('Xem vé của tôi'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.white70,
              side: BorderSide(color: Colors.white.withValues(alpha: 0.18)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        ),
        const SizedBox(height: 8),
        // Link: về trang chọn ghế của suất chiếu đã đặt
        TextButton.icon(
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => SeatSelectionScreen(movie: widget.info.booking.movie),
            ),
          ),
          icon: const Icon(LucideIcons.armchair, size: 16),
          label: const Text('Xem lại sơ đồ ghế đã đặt'),
          style: TextButton.styleFrom(
            foregroundColor: const Color(0xFFE50914),
            padding: const EdgeInsets.symmetric(vertical: 10),
          ),
        ),
      ],
    );
  }
}

// ── Sub-widgets ──────────────────────────────────────────────────

class _DashedDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 20,
      child: Row(
        children: [
          Container(
            width: 14, height: 14,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF080C14),
              border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
            ),
          ),
          Expanded(
            child: CustomPaint(
              painter: _DashPainter(),
            ),
          ),
          Container(
            width: 14, height: 14,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF080C14),
              border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
            ),
          ),
        ],
      ),
    );
  }
}

class _DashPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.12)
      ..strokeWidth = 1;
    const dashW = 6.0;
    const gap = 4.0;
    double x = 0;
    final y = size.height / 2;
    while (x < size.width) {
      canvas.drawLine(Offset(x, y), Offset(x + dashW, y), paint);
      x += dashW + gap;
    }
  }

  @override
  bool shouldRepaint(_) => false;
}

class _InfoCell extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool highlight;
  const _InfoCell({required this.icon, required this.label, required this.value, this.highlight = false});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32, height: 32,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.06),
            ),
            child: Icon(icon, size: 14, color: Colors.white.withValues(alpha: 0.4)),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(color: Colors.white.withValues(alpha: 0.35), fontSize: 10)),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    color: highlight ? const Color(0xFFE50914) : Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

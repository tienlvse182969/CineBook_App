import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:ve_xem_phim/models/booking_record.dart';

class TicketDetailScreen extends StatelessWidget {
  final BookingRecord ticket;
  const TicketDetailScreen({super.key, required this.ticket});

  String _fmt(int p) {
    final s = p.toString();
    final b = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) b.write('.');
      b.write(s[i]);
    }
    return '${b.toString()} đ';
  }

  String get _bookingCode => ticket.bookingCode;

  @override
  Widget build(BuildContext context) {
    final t = ticket;
    final statusColor = t.isUpcoming ? const Color(0xFF2196F3) : const Color(0xFF4CAF50);

    return Scaffold(
      backgroundColor: const Color(0xFF080C14),
      body: Stack(
        children: [
          _buildBg(),
          CustomScrollView(
            slivers: [
              SliverToBoxAdapter(child: _buildHeader(context)),
              SliverToBoxAdapter(child: _buildTicketCard(t, statusColor)),
              SliverToBoxAdapter(child: _buildQrSection()),
              SliverToBoxAdapter(
                child: SizedBox(height: MediaQuery.of(context).padding.bottom + 32),
              ),
            ],
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
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF0A0E1A), Color(0xFF160A28), Color(0xFF0C1530)],
          ),
        ),
      ),
      Positioned(
        top: -60, right: -60,
        child: ImageFiltered(
          imageFilter: ImageFilter.blur(sigmaX: 50, sigmaY: 50),
          child: Container(
            width: 220, height: 220,
            decoration: BoxDecoration(shape: BoxShape.circle, color: ticket.color.withValues(alpha: 0.18)),
          ),
        ),
      ),
    ]);
  }

  // ── Header ───────────────────────────────────────────────────

  Widget _buildHeader(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 12, 16, 20),
        child: Row(
          children: [
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                  child: Container(
                    width: 40, height: 40,
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.35),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
                    ),
                    child: const Icon(LucideIcons.arrowLeft, color: Colors.white, size: 20),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 14),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Chi tiết vé', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                SizedBox(height: 2),
                Text('Thông tin đặt vé', style: TextStyle(color: Colors.white54, fontSize: 11)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ── Ticket card ──────────────────────────────────────────────

  Widget _buildTicketCard(BookingRecord t, Color statusColor) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
      child: ClipRRect(
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
                // Gradient header
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [t.color.withValues(alpha: 0.6), t.color.withValues(alpha: 0.25)],
                    ),
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: statusColor.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: statusColor.withValues(alpha: 0.5)),
                            ),
                            child: Text(
                              t.isUpcoming ? 'Sắp tới' : 'Đã xem',
                              style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.w600),
                            ),
                          ),
                          const Spacer(),
                          Icon(LucideIcons.film, size: 14, color: Colors.white.withValues(alpha: 0.5)),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        t.movieTitle,
                        style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold, height: 1.2),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),

                // Dashed divider
                _DashedDivider(color: t.color),

                // Info grid
                Padding(
                  padding: const EdgeInsets.fromLTRB(18, 16, 18, 20),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          _InfoCell(icon: LucideIcons.calendar, label: 'Ngày chiếu', value: t.date),
                          _InfoCell(icon: LucideIcons.clock, label: 'Suất chiếu', value: t.time),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          _InfoCell(icon: LucideIcons.mapPin, label: 'Rạp chiếu', value: 'CGV Vincom Center'),
                          _InfoCell(icon: LucideIcons.monitor, label: 'Phòng chiếu', value: t.hall),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          _InfoCell(
                            icon: LucideIcons.ticket,
                            label: 'Số ghế',
                            value: t.seats.join(', '),
                          ),
                          _InfoCell(
                            icon: LucideIcons.banknote,
                            label: 'Tổng tiền',
                            value: _fmt(t.total),
                            highlight: true,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Booking code footer
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
                      Text(
                        'Mã đặt vé: $_bookingCode',
                        style: TextStyle(color: Colors.white.withValues(alpha: 0.35), fontSize: 12, letterSpacing: 0.5),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── QR section ───────────────────────────────────────────────

  Widget _buildQrSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 24),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
            ),
            child: Column(
              children: [
                Text(
                  'Mã QR vào cửa',
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 12),
                ),
                const SizedBox(height: 16),
                // QR code
                Container(
                  width: 160, height: 160,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.3), blurRadius: 20)],
                  ),
                  child: CustomPaint(painter: _QrPainter()),
                ),
                const SizedBox(height: 16),
                Text(
                  _bookingCode,
                  style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold, letterSpacing: 2),
                ),
                const SizedBox(height: 6),
                Text(
                  'Xuất trình mã này tại quầy soát vé',
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.35), fontSize: 12),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(LucideIcons.shieldCheck, size: 11, color: const Color(0xFF4CAF50).withValues(alpha: 0.7)),
                    const SizedBox(width: 4),
                    Text(
                      'Vé hợp lệ · Không thể chuyển nhượng',
                      style: TextStyle(color: Colors.white.withValues(alpha: 0.25), fontSize: 11),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Sub-widgets ──────────────────────────────────────────────────

class _DashedDivider extends StatelessWidget {
  final Color color;
  const _DashedDivider({required this.color});

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
          Expanded(child: CustomPaint(painter: _DashPainter())),
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
      ..color = Colors.white.withValues(alpha: 0.1)
      ..strokeWidth = 1;
    const dashW = 6.0, gap = 4.0;
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
                Text(label, style: TextStyle(color: Colors.white.withValues(alpha: 0.32), fontSize: 10)),
                const SizedBox(height: 3),
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

class _QrPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = const Color(0xFF111111);
    const grid = 11;
    final cell = size.width / grid;

    const pattern = [
      [1,1,1,1,1,1,1,0,1,0,1],
      [1,0,0,0,0,0,1,0,0,1,0],
      [1,0,1,1,1,0,1,0,1,0,1],
      [1,0,1,1,1,0,1,1,0,1,0],
      [1,0,1,1,1,0,1,0,1,1,1],
      [1,0,0,0,0,0,1,1,0,0,0],
      [1,1,1,1,1,1,1,0,1,0,1],
      [0,0,0,0,0,0,0,1,1,0,1],
      [1,0,1,1,0,1,1,0,1,1,0],
      [0,1,0,0,1,1,0,1,0,1,1],
      [1,1,0,1,0,0,1,0,1,0,1],
    ];

    for (int r = 0; r < grid; r++) {
      for (int c = 0; c < grid; c++) {
        if (pattern[r][c] == 1) {
          canvas.drawRRect(
            RRect.fromRectAndRadius(
              Rect.fromLTWH(c * cell + 1, r * cell + 1, cell - 2, cell - 2),
              const Radius.circular(2),
            ),
            paint,
          );
        }
      }
    }
  }

  @override
  bool shouldRepaint(_) => false;
}

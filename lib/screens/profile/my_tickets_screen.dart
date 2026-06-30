import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:ve_xem_phim/models/booking_record.dart';
import 'package:ve_xem_phim/screens/profile/ticket_detail_screen.dart';
import 'package:ve_xem_phim/services/api_service.dart';

class MyTicketsScreen extends StatefulWidget {
  const MyTicketsScreen({super.key});

  @override
  State<MyTicketsScreen> createState() => _MyTicketsScreenState();
}

class _MyTicketsScreenState extends State<MyTicketsScreen> {
  List<BookingRecord> _bookings = [];
  bool _loading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _loadBookings();
  }

  Future<void> _loadBookings() async {
    setState(() { _loading = true; _hasError = false; });
    try {
      final bookings = await ApiService.getMyBookings();
      if (!mounted) return;
      setState(() { _bookings = bookings; _loading = false; });
    } catch (_) {
      if (mounted) setState(() { _loading = false; _hasError = true; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final upcoming = _bookings.where((t) => t.isUpcoming).toList();
    final watched  = _bookings.where((t) => !t.isUpcoming).toList();

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: const Color(0xFF080C14),
        body: Stack(
          children: [
            _buildBg(),
            Column(
              children: [
                SafeArea(bottom: false, child: _buildHeader(context)),
                const SizedBox(height: 12),
                _buildTabBar(),
                const SizedBox(height: 4),
                Expanded(
                  child: _loading
                      ? const Center(
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Color(0xFFE50914),
                          ),
                        )
                      : _hasError
                          ? _buildError()
                          : TabBarView(
                              children: [
                                _TicketList(tickets: upcoming, emptyLabel: 'Không có vé sắp tới'),
                                _TicketList(tickets: watched,  emptyLabel: 'Chưa có vé nào đã xem'),
                              ],
                            ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(LucideIcons.wifiOff, size: 40, color: Colors.white.withValues(alpha: 0.2)),
          const SizedBox(height: 14),
          Text(
            'Không tải được vé',
            style: TextStyle(color: Colors.white.withValues(alpha: 0.45), fontSize: 14),
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: _loadBookings,
            child: const Text('Thử lại', style: TextStyle(color: Color(0xFFE50914))),
          ),
        ],
      ),
    );
  }

  Widget _buildBg() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0A0E1A), Color(0xFF160A28), Color(0xFF0C1530)],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 16, 0),
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
              Text('Vé của tôi', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              SizedBox(height: 2),
              Text('Tất cả vé đã đặt', style: TextStyle(color: Colors.white54, fontSize: 11)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.07),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.white.withValues(alpha: 0.13), width: 1.5),
            ),
            child: TabBar(
              indicatorSize: TabBarIndicatorSize.tab,
              indicator: BoxDecoration(
                borderRadius: BorderRadius.circular(11),
                color: const Color(0xFFE50914),
              ),
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white38,
              labelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
              unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal, fontSize: 14),
              dividerColor: Colors.transparent,
              padding: const EdgeInsets.all(4),
              tabs: const [
                Tab(text: 'Sắp tới'),
                Tab(text: 'Đã xem'),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Ticket list ──────────────────────────────────────────────────

class _TicketList extends StatelessWidget {
  final List<BookingRecord> tickets;
  final String emptyLabel;
  const _TicketList({required this.tickets, required this.emptyLabel});

  @override
  Widget build(BuildContext context) {
    if (tickets.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(LucideIcons.ticketX, size: 48, color: Colors.white.withValues(alpha: 0.15)),
            const SizedBox(height: 14),
            Text(emptyLabel, style: TextStyle(color: Colors.white.withValues(alpha: 0.3), fontSize: 14)),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: EdgeInsets.fromLTRB(16, 16, 16, MediaQuery.of(context).padding.bottom + 20),
      itemCount: tickets.length,
      separatorBuilder: (_, i) => const SizedBox(height: 12),
      itemBuilder: (context, i) => _TicketCard(
        ticket: tickets[i],
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => TicketDetailScreen(ticket: tickets[i])),
        ),
      ),
    );
  }
}

// ── Ticket card ──────────────────────────────────────────────────

class _TicketCard extends StatelessWidget {
  final BookingRecord ticket;
  final VoidCallback onTap;
  const _TicketCard({required this.ticket, required this.onTap});

  String _fmt(int p) {
    final s = p.toString();
    final b = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) b.write('.');
      b.write(s[i]);
    }
    return '${b.toString()} đ';
  }

  @override
  Widget build(BuildContext context) {
    final t = ticket;
    final statusColor = t.isUpcoming ? const Color(0xFF2196F3) : const Color(0xFF4CAF50);
    final statusLabel = t.isUpcoming ? 'Sắp tới' : 'Đã xem';

    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
            ),
            child: Column(
              children: [
                // Color header bar
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [t.color.withValues(alpha: 0.55), t.color.withValues(alpha: 0.25)],
                    ),
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  ),
                  child: Row(
                    children: [
                      const Icon(LucideIcons.film, size: 14, color: Colors.white70),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          t.movieTitle,
                          style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: statusColor.withValues(alpha: 0.18),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: statusColor.withValues(alpha: 0.45)),
                        ),
                        child: Text(statusLabel, style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.w600)),
                      ),
                    ],
                  ),
                ),

                // Info row
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
                  child: Row(
                    children: [
                      // Left: date + time + seats
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _Row(icon: LucideIcons.calendar, text: '${t.date}  ·  ${t.time}'),
                            const SizedBox(height: 7),
                            Row(
                              children: [
                                Icon(LucideIcons.ticket, size: 11, color: Colors.white.withValues(alpha: 0.35)),
                                const SizedBox(width: 5),
                                Wrap(
                                  spacing: 4,
                                  children: t.seats.map((s) => Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(alpha: 0.08),
                                      borderRadius: BorderRadius.circular(4),
                                      border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
                                    ),
                                    child: Text(s, style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 11, fontWeight: FontWeight.w600)),
                                  )).toList(),
                                ),
                              ],
                            ),
                            if (t.snacks.isNotEmpty) ...[
                              const SizedBox(height: 6),
                              _Row(
                                icon: LucideIcons.shoppingBag,
                                text: t.snacks.map((s) => '${s.name} x${s.qty}').join(' · '),
                              ),
                            ],
                          ],
                        ),
                      ),
                      // Right: price + chevron
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(_fmt(t.total), style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
                          const SizedBox(height: 4),
                          Icon(LucideIcons.chevronRight, size: 16, color: Colors.white.withValues(alpha: 0.25)),
                        ],
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
}

class _Row extends StatelessWidget {
  final IconData icon;
  final String text;
  const _Row({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 11, color: Colors.white.withValues(alpha: 0.35)),
        const SizedBox(width: 5),
        Text(text, style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 12)),
      ],
    );
  }
}

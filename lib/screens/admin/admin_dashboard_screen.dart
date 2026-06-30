import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:ve_xem_phim/services/api_service.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  Map<String, dynamic>? _stats;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    try {
      final data = await ApiService.getAdminStats();
      if (mounted) setState(() { _stats = data; _isLoading = false; });
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  static double _n(dynamic v) {
    if (v == null) return 0;
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString()) ?? 0;
  }

  String _fmt(dynamic n) {
    final double val = _n(n);
    if (val >= 1000000) return '${(val / 1000000).toStringAsFixed(1)}M đ';
    if (val >= 1000) return '${(val / 1000).toStringAsFixed(0)}K đ';
    return '${val.toStringAsFixed(0)} đ';
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      color: const Color(0xFFE50914),
      backgroundColor: const Color(0xFF161B22),
      onRefresh: _loadStats,
      child: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFE50914)))
          : SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildKpiGrid(),
                  const SizedBox(height: 20),
                  _buildSectionLabel('Vé bán theo phim'),
                  const SizedBox(height: 10),
                  _buildTicketsByMovie(),
                  const SizedBox(height: 20),
                  _buildSectionLabel('Booking gần nhất'),
                  const SizedBox(height: 10),
                  _buildRecentBookings(),
                ],
              ),
            ),
    );
  }

  Widget _buildSectionLabel(String title) => Text(
        title,
        style: const TextStyle(
          color: Color(0xFF8B949E),
          fontSize: 11,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.8,
        ),
      );

  Widget _buildKpiGrid() {
    final ov = _stats?['overview'] ?? {};
    final cards = [
      (icon: LucideIcons.dollarSign, label: 'Doanh thu hôm nay', value: _fmt(ov['todayRevenue']), color: const Color(0xFFE50914)),
      (icon: LucideIcons.trendingUp, label: 'Tổng doanh thu', value: _fmt(ov['totalRevenue']), color: const Color(0xFF22C55E)),
      (icon: LucideIcons.ticket, label: 'Vé hôm nay', value: '${ov['todayBookings'] ?? 0}', color: const Color(0xFF3B82F6)),
      (icon: LucideIcons.film, label: 'Phim đang chiếu', value: '${ov['activeMovies'] ?? 0}', color: const Color(0xFFA855F7)),
      (icon: LucideIcons.clock, label: 'Chờ thanh toán', value: '${ov['pendingBookings'] ?? 0}', color: const Color(0xFFF97316)),
      (icon: LucideIcons.users, label: 'Người dùng', value: '${ov['totalUsers'] ?? 0}', color: const Color(0xFF06B6D4)),
    ];

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.6,
      children: cards.map((c) => _KpiCard(icon: c.icon, label: c.label, value: c.value, color: c.color)).toList(),
    );
  }

  Widget _buildTicketsByMovie() {
    final list = (_stats?['ticketsByMovie'] as List?) ?? [];
    if (list.isEmpty) return _emptyState('Chưa có dữ liệu vé');
    final max = list.fold<double>(0, (m, e) { final t = _n(e['tickets']); return t > m ? t : m; });
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1C2128),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF30363D)),
      ),
      child: Column(
        children: list.map<Widget>((item) {
          final pct = max > 0 ? _n(item['tickets']) / max : 0.0;
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        item['title']?.toString() ?? '',
                        style: const TextStyle(color: Colors.white, fontSize: 12),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      '${item['tickets']} vé',
                      style: const TextStyle(color: Color(0xFF8B949E), fontSize: 11),
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: pct,
                    backgroundColor: const Color(0xFF30363D),
                    color: const Color(0xFFE50914),
                    minHeight: 6,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildRecentBookings() {
    final list = (_stats?['recentBookings'] as List?) ?? [];
    if (list.isEmpty) return _emptyState('Chưa có booking nào');
    return Column(
      children: list.map<Widget>((b) {
        final user = b['User'] as Map? ?? {};
        final showtime = b['Showtime'] as Map? ?? {};
        final movie = showtime['Movie'] as Map? ?? {};
        final status = b['booking_status']?.toString() ?? '';
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: _BookingRow(
            userName: user['full_name']?.toString() ?? '—',
            movieTitle: movie['title']?.toString() ?? '—',
            amount: _n(b['total_amount']),
            status: status,
          ),
        );
      }).toList(),
    );
  }

  Widget _emptyState(String msg) => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(msg, style: const TextStyle(color: Color(0xFF8B949E), fontSize: 13)),
        ),
      );
}

class _KpiCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _KpiCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF1C2128),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 16),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Text(
                label,
                style: const TextStyle(color: Color(0xFF8B949E), fontSize: 10),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _BookingRow extends StatelessWidget {
  final String userName;
  final String movieTitle;
  final double amount;
  final String status;

  const _BookingRow({
    required this.userName,
    required this.movieTitle,
    required this.amount,
    required this.status,
  });

  Color get _statusColor {
    switch (status) {
      case 'CONFIRMED': return const Color(0xFF22C55E);
      case 'CANCELLED': return const Color(0xFFEF4444);
      default:          return const Color(0xFFF97316);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1C2128),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF30363D)),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFFE50914).withValues(alpha: 0.12),
            ),
            child: const Icon(LucideIcons.user, color: Color(0xFFE50914), size: 16),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(userName, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
                Text(movieTitle, style: const TextStyle(color: Color(0xFF8B949E), fontSize: 11), overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${(amount / 1000).toStringAsFixed(0)}K đ',
                style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: _statusColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(status, style: TextStyle(color: _statusColor, fontSize: 9, fontWeight: FontWeight.w600)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:ve_xem_phim/services/api_service.dart';

double _n(dynamic v) {
  if (v == null) return 0;
  if (v is num) return v.toDouble();
  return double.tryParse(v.toString()) ?? 0;
}

String _fmtMoney(double v) {
  if (v >= 1000000) return '${(v / 1000000).toStringAsFixed(1)}M đ';
  if (v >= 1000) return '${(v / 1000).toStringAsFixed(0)}K đ';
  return '${v.toStringAsFixed(0)} đ';
}

class AdminBookingsScreen extends StatefulWidget {
  const AdminBookingsScreen({super.key});

  @override
  State<AdminBookingsScreen> createState() => _AdminBookingsScreenState();
}

class _AdminBookingsScreenState extends State<AdminBookingsScreen> {
  List<Map<String, dynamic>> _bookings = [];
  int _page = 1, _totalPages = 1, _total = 0;
  bool _isLoading = true;
  String? _filterStatus;
  String? _dateRange;

  static const _dateOptions = [
    (key: null,    label: 'Tất cả'),
    (key: 'today', label: 'Hôm nay'),
    (key: 'week',  label: 'Tuần này'),
    (key: 'month', label: 'Tháng này'),
  ];

  static const _statusOptions = [
    (key: null,        label: 'Tất cả', color: Color(0xFF94A3B8)),
    (key: 'CONFIRMED', label: 'Xác nhận', color: Color(0xFF22C55E)),
    (key: 'CANCELLED', label: 'Đã hủy', color: Color(0xFFE50914)),
  ];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load({int page = 1}) async {
    setState(() { _isLoading = true; _page = page; });
    try {
      final data = await ApiService.getAdminBookings(
        page: page,
        status: _filterStatus,
        dateRange: _dateRange,
      );
      if (mounted) {
        setState(() {
          _bookings = (data['bookings'] as List? ?? []).cast<Map<String, dynamic>>();
          _totalPages = (data['totalPages'] as num?)?.toInt() ?? 1;
          _total = (data['total'] as num?)?.toInt() ?? 0;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _cancelBooking(Map<String, dynamic> booking) async {
    final id = (booking['booking_id'] as num?)?.toInt();
    if (id == null) return;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF161B22),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Hủy booking', style: TextStyle(color: Colors.white)),
        content: Text('Hủy booking #$id?', style: TextStyle(color: Colors.white.withValues(alpha: 0.6))),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text('Không', style: TextStyle(color: Colors.white.withValues(alpha: 0.5)))),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Hủy booking', style: TextStyle(color: Color(0xFFE50914)))),
        ],
      ),
    );
    if (confirm != true || !mounted) return;
    try {
      await ApiService.cancelBooking(id);
      if (mounted) _load(page: _page);
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString().replaceFirst('Exception: ', '')), backgroundColor: const Color(0xFFE50914)));
    }
  }

  void _setDateRange(String? key) {
    setState(() { _dateRange = key; });
    _load(page: 1);
  }

  void _setStatus(String? key) {
    setState(() { _filterStatus = key; });
    _load(page: 1);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildDateChips(),
        _buildStatusChips(),
        if (!_isLoading && _bookings.isNotEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 6),
            child: Row(children: [
              Text('$_total booking', style: TextStyle(color: Colors.white.withValues(alpha: 0.35), fontSize: 11)),
            ]),
          ),
        Expanded(
          child: RefreshIndicator(
            color: const Color(0xFFE50914),
            backgroundColor: const Color(0xFF161B22),
            onRefresh: () => _load(page: 1),
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: Color(0xFFE50914)))
                : _bookings.isEmpty
                    ? _emptyState()
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                        itemCount: _bookings.length + (_totalPages > 1 ? 1 : 0),
                        separatorBuilder: (_, _) => const SizedBox(height: 8),
                        itemBuilder: (ctx, i) {
                          if (i == _bookings.length) return _buildPagination();
                          return _BookingCard(
                            booking: _bookings[i],
                            onCancel: () => _cancelBooking(_bookings[i]),
                          );
                        },
                      ),
          ),
        ),
      ],
    );
  }

  Widget _buildDateChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 6),
      child: Row(
        children: _dateOptions.map((opt) {
          final active = _dateRange == opt.key;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => _setDateRange(opt.key),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                decoration: BoxDecoration(
                  color: active ? const Color(0xFFE50914) : Colors.white.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: active ? const Color(0xFFE50914) : Colors.white.withValues(alpha: 0.12)),
                ),
                child: Text(opt.label, style: TextStyle(color: active ? Colors.white : Colors.white.withValues(alpha: 0.55), fontSize: 12, fontWeight: FontWeight.w500)),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildStatusChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
      child: Row(
        children: _statusOptions.map((opt) {
          final active = _filterStatus == opt.key;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => _setStatus(opt.key),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                decoration: BoxDecoration(
                  color: active ? opt.color.withValues(alpha: 0.2) : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: active ? opt.color.withValues(alpha: 0.6) : Colors.white.withValues(alpha: 0.12)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (active) ...[
                      Container(width: 6, height: 6, decoration: BoxDecoration(color: opt.color, shape: BoxShape.circle)),
                      const SizedBox(width: 5),
                    ],
                    Text(opt.label, style: TextStyle(color: active ? opt.color : Colors.white.withValues(alpha: 0.45), fontSize: 11, fontWeight: FontWeight.w500)),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildPagination() {
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _PagBtn(icon: LucideIcons.chevronLeft, enabled: _page > 1, onTap: () => _load(page: _page - 1)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text('$_page / $_totalPages', style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 13)),
          ),
          _PagBtn(icon: LucideIcons.chevronRight, enabled: _page < _totalPages, onTap: () => _load(page: _page + 1)),
        ],
      ),
    );
  }

  Widget _emptyState() => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(LucideIcons.ticket, color: Colors.white.withValues(alpha: 0.12), size: 48),
            const SizedBox(height: 12),
            Text('Không có booking nào', style: TextStyle(color: Colors.white.withValues(alpha: 0.3), fontSize: 14)),
          ],
        ),
      );
}

// ── Booking card ──────────────────────────────────────────────────────────────

class _BookingCard extends StatelessWidget {
  final Map<String, dynamic> booking;
  final VoidCallback onCancel;
  const _BookingCard({required this.booking, required this.onCancel});

  Color get _statusColor {
    switch (booking['booking_status']) {
      case 'CONFIRMED': return const Color(0xFF22C55E);
      case 'CANCELLED': return const Color(0xFFE50914);
      default:          return const Color(0xFFF97316);
    }
  }

  String get _statusLabel {
    switch (booking['booking_status']) {
      case 'CONFIRMED': return 'Xác nhận';
      case 'CANCELLED': return 'Đã hủy';
      default:          return 'Chờ xử lý';
    }
  }

  @override
  Widget build(BuildContext context) {
    final user      = booking['User']     as Map? ?? {};
    final showtime  = booking['Showtime'] as Map? ?? {};
    final movie     = showtime['Movie']   as Map? ?? {};
    final room      = showtime['Room']    as Map? ?? {};
    final amount    = _n(booking['total_amount']);
    final seats     = (booking['BookingSeats'] as List? ?? []);
    final snacks    = (booking['BookingSnacks'] as List? ?? []);
    final canCancel = booking['booking_status'] == 'CONFIRMED';

    final seatLabel = seats.map((s) {
      final seat = (s['Seat'] as Map?) ?? s;
      return '${seat['row_name'] ?? ''}${seat['seat_number'] ?? ''}';
    }).join(', ');

    final rawTime = showtime['start_time']?.toString() ?? '';
    final timeStr = rawTime.length >= 16 ? rawTime.substring(0, 16).replaceFirst('T', '  ') : rawTime;

    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.04),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: _statusColor.withValues(alpha: 0.12)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row
              Row(children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(color: _statusColor.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(8)),
                  child: Text(_statusLabel, style: TextStyle(color: _statusColor, fontSize: 11, fontWeight: FontWeight.w600)),
                ),
                const SizedBox(width: 8),
                Text('#${booking['booking_id']}', style: TextStyle(color: Colors.white.withValues(alpha: 0.35), fontSize: 11)),
                const Spacer(),
                Text(_fmtMoney(amount), style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              ]),
              const SizedBox(height: 10),
              const Divider(color: Colors.white12, height: 1),
              const SizedBox(height: 10),
              // Movie + time
              _InfoRow(LucideIcons.film, movie['title']?.toString() ?? '—', bold: true),
              if (timeStr.isNotEmpty) ...[const SizedBox(height: 5), _InfoRow(LucideIcons.clock, timeStr)],
              if (room['name'] != null) ...[const SizedBox(height: 5), _InfoRow(LucideIcons.monitor, room['name'].toString())],
              const SizedBox(height: 8),
              // Customer
              _InfoRow(LucideIcons.user, user['full_name']?.toString() ?? '—'),
              const SizedBox(height: 4),
              _InfoRow(LucideIcons.mail, user['email']?.toString() ?? '—'),
              // Seats
              if (seatLabel.isNotEmpty) ...[const SizedBox(height: 4), _InfoRow(LucideIcons.armchair, 'Ghế: $seatLabel')],
              // Snacks
              if (snacks.isNotEmpty) ...[
                const SizedBox(height: 4),
                _InfoRow(
                  LucideIcons.shoppingBag,
                  snacks.map((s) {
                    final snack = (s['Snack'] as Map?) ?? s;
                    final qty = (s['quantity'] as num?)?.toInt() ?? 1;
                    return '${snack['name'] ?? '—'} ×$qty';
                  }).join(' · '),
                ),
              ],
              // Cancel button
              if (canCancel) ...[
                const SizedBox(height: 10),
                GestureDetector(
                  onTap: onCancel,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE50914).withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFE50914).withValues(alpha: 0.25)),
                    ),
                    child: const Text('Hủy booking', textAlign: TextAlign.center, style: TextStyle(color: Color(0xFFE50914), fontSize: 12, fontWeight: FontWeight.w600)),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;
  final bool bold;
  const _InfoRow(this.icon, this.text, {this.bold = false});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 12, color: Colors.white.withValues(alpha: 0.3)),
        const SizedBox(width: 6),
        Expanded(child: Text(text, style: TextStyle(color: Colors.white.withValues(alpha: bold ? 0.9 : 0.55), fontSize: bold ? 13 : 12, fontWeight: bold ? FontWeight.w600 : FontWeight.normal), overflow: TextOverflow.ellipsis)),
      ],
    );
  }
}

class _PagBtn extends StatelessWidget {
  final IconData icon;
  final bool enabled;
  final VoidCallback onTap;
  const _PagBtn({required this.icon, required this.enabled, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        width: 36, height: 36,
        decoration: BoxDecoration(
          color: enabled ? Colors.white.withValues(alpha: 0.08) : Colors.white.withValues(alpha: 0.03),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
        ),
        child: Icon(icon, size: 16, color: enabled ? Colors.white.withValues(alpha: 0.6) : Colors.white.withValues(alpha: 0.2)),
      ),
    );
  }
}

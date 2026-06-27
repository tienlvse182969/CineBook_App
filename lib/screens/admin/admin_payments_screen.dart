import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:ve_xem_phim/services/api_service.dart';

double _n(dynamic v) {
  if (v == null) return 0;
  if (v is num) return v.toDouble();
  return double.tryParse(v.toString()) ?? 0;
}

String _fmtMoney(double v) {
  if (v >= 1000000) return '${(v / 1000000).toStringAsFixed(1)}M';
  if (v >= 1000) return '${(v / 1000).toStringAsFixed(0)}K';
  return v.toStringAsFixed(0);
}

String _fmtFull(double v) {
  final s = v.toStringAsFixed(0);
  final buf = StringBuffer();
  for (int i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) buf.write('.');
    buf.write(s[i]);
  }
  return '$buf đ';
}

const _monthNames = ['', 'T1', 'T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'T8', 'T9', 'T10', 'T11', 'T12'];

class AdminPaymentsScreen extends StatefulWidget {
  const AdminPaymentsScreen({super.key});

  @override
  State<AdminPaymentsScreen> createState() => _AdminPaymentsScreenState();
}

class _AdminPaymentsScreenState extends State<AdminPaymentsScreen> {
  Map<String, dynamic>? _data;
  bool _isLoading = false;

  String _period = 'month';
  int _year    = DateTime.now().year;
  int _month   = DateTime.now().month;
  int _quarter = ((DateTime.now().month - 1) ~/ 3) + 1;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _isLoading = true);
    try {
      final data = await ApiService.getRevenueReport(
        period: _period,
        year: _year,
        month: _period == 'month' ? _month : null,
        quarter: _period == 'quarter' ? _quarter : null,
      );
      if (mounted) setState(() { _data = data; _isLoading = false; });
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _prev() {
    setState(() {
      if (_period == 'month') {
        if (_month == 1) { _month = 12; _year--; } else { _month--; }
      } else if (_period == 'quarter') {
        if (_quarter == 1) { _quarter = 4; _year--; } else { _quarter--; }
      } else {
        _year--;
      }
    });
    _load();
  }

  void _next() {
    setState(() {
      if (_period == 'month') {
        if (_month == 12) { _month = 1; _year++; } else { _month++; }
      } else if (_period == 'quarter') {
        if (_quarter == 4) { _quarter = 1; _year++; } else { _quarter++; }
      } else {
        _year++;
      }
    });
    _load();
  }

  bool get _canGoNext {
    final now = DateTime.now();
    if (_period == 'year') return _year < now.year;
    if (_period == 'quarter') return !(_year == now.year && _quarter >= ((now.month - 1) ~/ 3) + 1);
    return !(_year == now.year && _month >= now.month);
  }

  String get _periodLabel {
    if (_period == 'quarter') return 'Q$_quarter/$_year';
    if (_period == 'year') return '$_year';
    return 'Tháng $_month/$_year';
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      color: const Color(0xFFE50914),
      backgroundColor: const Color(0xFF161B22),
      onRefresh: _load,
      child: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFE50914)))
          : SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildPeriodSelector(),
                  const SizedBox(height: 16),
                  _buildRevenueCard(),
                  const SizedBox(height: 20),
                  _buildBreakdown(),
                  const SizedBox(height: 20),
                  _buildChart(),
                  const SizedBox(height: 20),
                  _buildTopMovies(),
                ],
              ),
            ),
    );
  }

  // ── Period selector ───────────────────────────────────────────────────────

  Widget _buildPeriodSelector() {
    return Column(
      children: [
        // Type chips
        Row(
          children: [
            _buildPeriodChip('month',   'Tháng'),
            const SizedBox(width: 8),
            _buildPeriodChip('quarter', 'Quý'),
            const SizedBox(width: 8),
            _buildPeriodChip('year',    'Năm'),
          ],
        ),
        const SizedBox(height: 10),
        // Navigator < label >
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFF1C2128),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF30363D)),
          ),
          child: Row(children: [
            _NavBtn(icon: LucideIcons.chevronLeft, enabled: true, onTap: _prev),
            Expanded(
              child: Text(_periodLabel, textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
            ),
            _NavBtn(icon: LucideIcons.chevronRight, enabled: _canGoNext, onTap: _next),
          ]),
        ),
      ],
    );
  }

  Widget _buildPeriodChip(String key, String label) {
    final active = _period == key;
    return GestureDetector(
      onTap: () {
        setState(() => _period = key);
        _load();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        decoration: BoxDecoration(
          color: active ? const Color(0xFFE50914) : Colors.white.withValues(alpha: 0.07),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: active ? const Color(0xFFE50914) : Colors.white.withValues(alpha: 0.12)),
        ),
        child: Text(label, style: TextStyle(color: active ? Colors.white : Colors.white.withValues(alpha: 0.5), fontSize: 13, fontWeight: FontWeight.w600)),
      ),
    );
  }

  // ── Revenue card ──────────────────────────────────────────────────────────

  Widget _buildRevenueCard() {
    final total = _n(_data?['totalRevenue']);
    final prev  = _n(_data?['prevRevenue']);
    final pct   = _n(_data?['changePercent']);
    final count = (_data?['bookingCount'] as num?)?.toInt() ?? 0;
    final isUp  = pct >= 0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFFE50914).withValues(alpha: 0.18),
            const Color(0xFF1C2128),
          ],
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE50914).withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Icon(LucideIcons.trendingUp, color: const Color(0xFFE50914), size: 16),
            const SizedBox(width: 6),
            Text('Tổng doanh thu · $_periodLabel', style: const TextStyle(color: Color(0xFF8B949E), fontSize: 12)),
          ]),
          const SizedBox(height: 12),
          Text(_fmtFull(total), style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold, letterSpacing: -0.5)),
          const SizedBox(height: 8),
          Row(children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: isUp ? const Color(0xFF22C55E).withValues(alpha: 0.15) : const Color(0xFFEF4444).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(isUp ? LucideIcons.trendingUp : LucideIcons.trendingDown,
                    size: 11, color: isUp ? const Color(0xFF22C55E) : const Color(0xFFEF4444)),
                const SizedBox(width: 4),
                Text('${isUp ? '+' : ''}${pct.toStringAsFixed(1)}%',
                    style: TextStyle(color: isUp ? const Color(0xFF22C55E) : const Color(0xFFEF4444), fontSize: 11, fontWeight: FontWeight.bold)),
              ]),
            ),
            const SizedBox(width: 8),
            Text('vs kỳ trước (${_fmtMoney(prev)}đ)', style: const TextStyle(color: Color(0xFF8B949E), fontSize: 11)),
            const Spacer(),
            Row(children: [
              const Icon(LucideIcons.ticket, size: 11, color: Color(0xFF8B949E)),
              const SizedBox(width: 4),
              Text('$count booking', style: const TextStyle(color: Color(0xFF8B949E), fontSize: 11)),
            ]),
          ]),
        ],
      ),
    );
  }

  // ── Breakdown: Vé vs Đồ ăn ───────────────────────────────────────────────

  Widget _buildBreakdown() {
    final ticketRev = _n(_data?['ticketRevenue']);
    final snackRev  = _n(_data?['snackRevenue']);
    final total     = ticketRev + snackRev;

    return Row(
      children: [
        Expanded(child: _BreakdownCard(
          icon: LucideIcons.ticket,
          label: 'Vé',
          amount: ticketRev,
          color: const Color(0xFF3B82F6),
          pct: total > 0 ? ticketRev / total : 0,
        )),
        const SizedBox(width: 10),
        Expanded(child: _BreakdownCard(
          icon: LucideIcons.shoppingBag,
          label: 'Đồ ăn',
          amount: snackRev,
          color: const Color(0xFFF97316),
          pct: total > 0 ? snackRev / total : 0,
        )),
      ],
    );
  }

  // ── Bar chart ─────────────────────────────────────────────────────────────

  Widget _buildChart() {
    final raw = (_data?['byMonth'] as List? ?? []);
    if (raw.isEmpty) return const SizedBox.shrink();

    // Build 6-month slots ending at current month
    final now = DateTime.now();
    final slots = List.generate(6, (i) {
      final dt = DateTime(now.year, now.month - 5 + i);
      return (year: dt.year, month: dt.month);
    });

    final Map<String, double> revMap = {};
    for (final row in raw) {
      final y = _n(row['year']).toInt();
      final m = _n(row['month']).toInt();
      revMap['$y-$m'] = _n(row['revenue']);
    }

    final values = slots.map((s) => revMap['${s.year}-${s.month}'] ?? 0.0).toList();
    final maxVal = values.fold<double>(0, (a, b) => b > a ? b : a);

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1C2128),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF30363D)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('6 tháng gần nhất', style: TextStyle(color: Color(0xFF8B949E), fontSize: 12, fontWeight: FontWeight.w600)),
              const SizedBox(height: 16),
              SizedBox(
                height: 110,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: List.generate(slots.length, (i) {
                    final slot = slots[i];
                    final val = values[i];
                    final pct = maxVal > 0 ? val / maxVal : 0.0;
                    final isCurrentPeriod = slot.year == now.year && slot.month == now.month;
                    final barColor = isCurrentPeriod ? const Color(0xFFE50914) : const Color(0xFF3B82F6);

                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 3),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            if (val > 0)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 4),
                                child: Text(
                                  _fmtMoney(val),
                                  style: TextStyle(color: barColor, fontSize: 9, fontWeight: FontWeight.bold),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 500),
                              curve: Curves.easeOut,
                              height: (pct * 70).clamp(2.0, 70.0),
                              decoration: BoxDecoration(
                                color: barColor.withValues(alpha: isCurrentPeriod ? 0.9 : 0.5),
                                borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              _monthNames[slot.month],
                              style: TextStyle(
                                color: isCurrentPeriod ? Colors.white.withValues(alpha: 0.8) : Colors.white.withValues(alpha: 0.35),
                                fontSize: 10,
                                fontWeight: isCurrentPeriod ? FontWeight.bold : FontWeight.normal,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ],
          ),
    );
  }

  // ── Top movies ────────────────────────────────────────────────────────────

  Widget _buildTopMovies() {
    final list = (_data?['topMovies'] as List? ?? []);
    if (list.isEmpty) return const SizedBox.shrink();

    final maxRev = list.fold<double>(0, (m, e) {
      final r = _n(e['revenue']);
      return r > m ? r : m;
    });

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1C2128),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF30363D)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Top phim theo doanh thu', style: TextStyle(color: Color(0xFF8B949E), fontSize: 12, fontWeight: FontWeight.w600)),
          const SizedBox(height: 14),
          ...list.asMap().entries.map((entry) {
            final i    = entry.key;
            final item = entry.value as Map;
            final rev  = _n(item['revenue']);
            final cnt  = (_n(item['bookings'])).toInt();
            final pct  = maxRev > 0 ? rev / maxRev : 0.0;
            final colors = [
              const Color(0xFFE50914), const Color(0xFF3B82F6), const Color(0xFF22C55E),
              const Color(0xFFA855F7), const Color(0xFFF97316),
            ];
            final c = colors[i % colors.length];

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  Container(
                    width: 22, height: 22,
                    decoration: BoxDecoration(color: c.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(6)),
                    child: Center(child: Text('${i + 1}', style: TextStyle(color: c, fontSize: 10, fontWeight: FontWeight.bold))),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(children: [
                          Expanded(child: Text(item['title']?.toString() ?? '', style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500), overflow: TextOverflow.ellipsis)),
                          const SizedBox(width: 8),
                          Text('${_fmtMoney(rev)}đ', style: TextStyle(color: c, fontSize: 12, fontWeight: FontWeight.bold)),
                        ]),
                        const SizedBox(height: 5),
                        Row(children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(3),
                              child: LinearProgressIndicator(value: pct, backgroundColor: const Color(0xFF30363D), color: c, minHeight: 4),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text('$cnt vé', style: const TextStyle(color: Color(0xFF8B949E), fontSize: 10)),
                        ]),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

// ── Sub-widgets ───────────────────────────────────────────────────────────────

class _BreakdownCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final double amount;
  final Color color;
  final double pct;
  const _BreakdownCard({required this.icon, required this.label, required this.amount, required this.color, required this.pct});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF1C2128),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Icon(icon, color: color, size: 14),
            const SizedBox(width: 6),
            Text(label, style: const TextStyle(color: Color(0xFF8B949E), fontSize: 12)),
            const Spacer(),
            Text('${(pct * 100).toStringAsFixed(0)}%', style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600)),
          ]),
          const SizedBox(height: 8),
          Text('${_fmtMoney(amount)}đ', style: TextStyle(color: color, fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: LinearProgressIndicator(value: pct, backgroundColor: const Color(0xFF30363D), color: color, minHeight: 4),
          ),
        ],
      ),
    );
  }
}

class _NavBtn extends StatelessWidget {
  final IconData icon;
  final bool enabled;
  final VoidCallback onTap;
  const _NavBtn({required this.icon, required this.enabled, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        width: 36, height: 36,
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(10)),
        child: Icon(icon, size: 18, color: enabled ? Colors.white.withValues(alpha: 0.7) : Colors.white.withValues(alpha: 0.2)),
      ),
    );
  }
}

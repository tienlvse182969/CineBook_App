import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:ve_xem_phim/data/mock_snacks.dart';
import 'package:ve_xem_phim/models/booking_info.dart';
import 'package:ve_xem_phim/models/payment_info.dart';
import 'package:ve_xem_phim/models/snack.dart';
import 'package:ve_xem_phim/screens/booking/payment_screen.dart';
import 'package:ve_xem_phim/widgets/auth_widgets.dart';

class SnackScreen extends StatefulWidget {
  final BookingInfo booking;
  const SnackScreen({super.key, required this.booking});

  @override
  State<SnackScreen> createState() => _SnackScreenState();
}

class _SnackScreenState extends State<SnackScreen> {
  final Map<String, int> _qty = {};

  // ── Quantity helpers ────────────────────────────────────────

  int _quantityOf(SnackItem item) => _qty[item.id] ?? 0;

  void _increment(SnackItem item) =>
      setState(() => _qty[item.id] = (_qty[item.id] ?? 0) + 1);

  void _decrement(SnackItem item) {
    final current = _qty[item.id] ?? 0;
    if (current <= 0) return;
    setState(() {
      if (current == 1) {
        _qty.remove(item.id);
      } else {
        _qty[item.id] = current - 1;
      }
    });
  }

  // ── Price helpers ───────────────────────────────────────────

  int get _snackTotal => snackCategories
      .expand((c) => c.items)
      .fold(0, (sum, item) => sum + (_qty[item.id] ?? 0) * item.price);

  int get _grandTotal => widget.booking.ticketTotal + _snackTotal;

  String _fmt(int price) {
    if (price == 0) return '0 đ';
    final s = price.toString();
    final buf = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write('.');
      buf.write(s[i]);
    }
    buf.write(' đ');
    return buf.toString();
  }

  // ── Age color (for badge) ───────────────────────────────────

  Color get _ageColor {
    switch (widget.booking.movie.ageRating) {
      case 'P':   return const Color(0xFF4CAF50);
      case 'K':   return const Color(0xFF2196F3);
      case 'T13': return const Color(0xFFFFC107);
      case 'T16': return const Color(0xFFFF9800);
      case 'T18': return const Color(0xFFF44336);
      default:    return Colors.grey;
    }
  }

  // ── Category icon ───────────────────────────────────────────

  static IconData _categoryIcon(String name) {
    switch (name) {
      case 'Bắp rang':        return LucideIcons.flame;
      case 'Combo tiết kiệm': return LucideIcons.package;
      case 'Nước uống':       return LucideIcons.droplets;
      case 'Đồ ăn vặt':      return LucideIcons.utensils;
      default:                return LucideIcons.shoppingBag;
    }
  }

  // ── Build ────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF080C14),
      body: Stack(
        children: [
          _buildBg(),
          Column(
            children: [
              SafeArea(bottom: false, child: _buildHeader(context)),
              const SizedBox(height: 12),
              _buildInfoCard(),
              const SizedBox(height: 8),
              Expanded(
                child: ListView.builder(
                  padding: EdgeInsets.fromLTRB(
                    16, 8, 16,
                    MediaQuery.of(context).padding.bottom + 240,
                  ),
                  itemCount: snackCategories.length,
                  itemBuilder: (_, i) => _buildCategory(snackCategories[i]),
                ),
              ),
            ],
          ),
          Positioned(
            bottom: 0, left: 0, right: 0,
            child: _buildBottomPanel(context),
          ),
        ],
      ),
    );
  }

  // ── Background ──────────────────────────────────────────────

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
            width: 240, height: 240,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: widget.booking.movie.colors.first.withValues(alpha: 0.12),
            ),
          ),
        ),
      ),
      Positioned(
        bottom: 180, left: -80,
        child: ImageFiltered(
          imageFilter: ImageFilter.blur(sigmaX: 50, sigmaY: 50),
          child: Container(
            width: 200, height: 200,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: widget.booking.movie.colors.last.withValues(alpha: 0.08),
            ),
          ),
        ),
      ),
    ]);
  }

  // ── Header ──────────────────────────────────────────────────

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
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Bắp & Đồ uống',
                  style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 2),
                Text(
                  'Thêm bắp, nước uống vào đơn hàng',
                  style: TextStyle(color: Colors.white54, fontSize: 11),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Info card ────────────────────────────────────────────────

  Widget _buildInfoCard() {
    final b = widget.booking;
    final date = b.date;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.07),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
            ),
            child: Row(
              children: [
                // Age badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: _ageColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: _ageColor.withValues(alpha: 0.5)),
                  ),
                  child: Text(
                    b.movie.ageRating,
                    style: TextStyle(color: _ageColor, fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        b.movie.title,
                        style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(children: [
                        Icon(LucideIcons.calendar, size: 11, color: Colors.white.withValues(alpha: 0.4)),
                        const SizedBox(width: 4),
                        Text(
                          '${date.day}/${date.month}/${date.year}',
                          style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 12),
                        ),
                        const SizedBox(width: 10),
                        Icon(LucideIcons.clock, size: 11, color: Colors.white.withValues(alpha: 0.4)),
                        const SizedBox(width: 4),
                        Text(
                          b.showtime.time,
                          style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 12),
                        ),
                      ]),
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

  // ── Snack category ───────────────────────────────────────────

  Widget _buildCategory(SnackCategory category) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 20, bottom: 10),
          child: Row(children: [
            Icon(_categoryIcon(category.name), size: 14, color: const Color(0xFFE50914)),
            const SizedBox(width: 7),
            Text(
              category.name,
              style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600),
            ),
          ]),
        ),
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
              ),
              child: Column(
                children: category.items.asMap().entries.map((entry) {
                  final isLast = entry.key == category.items.length - 1;
                  return _buildSnackItem(entry.value, showDivider: !isLast);
                }).toList(),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSnackItem(SnackItem item, {required bool showDivider}) {
    final qty = _quantityOf(item);
    final hasQty = qty > 0;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name,
                      style: TextStyle(
                        color: hasQty ? Colors.white : Colors.white.withValues(alpha: 0.85),
                        fontSize: 14,
                        fontWeight: hasQty ? FontWeight.w600 : FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      item.description,
                      style: TextStyle(color: Colors.white.withValues(alpha: 0.38), fontSize: 11),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      _fmt(item.price),
                      style: TextStyle(
                        color: hasQty ? const Color(0xFFE50914) : Colors.white.withValues(alpha: 0.55),
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              _QuantityControl(
                qty: qty,
                onDecrement: () => _decrement(item),
                onIncrement: () => _increment(item),
              ),
            ],
          ),
        ),
        if (showDivider)
          Divider(height: 1, color: Colors.white.withValues(alpha: 0.07), indent: 14, endIndent: 14),
      ],
    );
  }

  // ── Bottom panel ────────────────────────────────────────────

  Widget _buildBottomPanel(BuildContext context) {
    final b = widget.booking;
    final hasSnacks = _snackTotal > 0;

    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
        child: Container(
          padding: EdgeInsets.fromLTRB(20, 16, 20, MediaQuery.of(context).padding.bottom + 16),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.6),
            border: Border(top: BorderSide(color: Colors.white.withValues(alpha: 0.08))),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Seat summary row
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(LucideIcons.ticket, size: 12, color: Colors.white.withValues(alpha: 0.35)),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Wrap(
                      spacing: 5, runSpacing: 5,
                      children: b.seatLabels.map((label) {
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(5),
                            border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
                          ),
                          child: Text(label, style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 11, fontWeight: FontWeight.w600)),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Price breakdown
              _PriceRow(
                label: 'Vé (${b.seatLabels.length} ghế)',
                value: _fmt(b.ticketTotal),
                small: true,
              ),
              if (hasSnacks) ...[
                const SizedBox(height: 4),
                _PriceRow(
                  label: 'Bắp & Đồ uống',
                  value: _fmt(_snackTotal),
                  small: true,
                ),
              ],
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Divider(color: Colors.white.withValues(alpha: 0.08), height: 1),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('Tổng cộng', style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 13)),
                  Text(
                    _fmt(_grandTotal),
                    style: const TextStyle(color: Color(0xFFE50914), fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              GlassPrimaryButton(
                label: 'Thanh toán  ·  ${_fmt(_grandTotal)}',
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => PaymentScreen(
                      info: PaymentInfo(
                        booking: widget.booking,
                        snackQty: Map.from(_qty),
                        snackTotal: _snackTotal,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Sub-widgets ─────────────────────────────────────────────────

class _QuantityControl extends StatelessWidget {
  final int qty;
  final VoidCallback onDecrement;
  final VoidCallback onIncrement;

  const _QuantityControl({required this.qty, required this.onDecrement, required this.onIncrement});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _CircleBtn(
          icon: LucideIcons.minus,
          onTap: qty > 0 ? onDecrement : null,
          active: qty > 0,
        ),
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 32,
          alignment: Alignment.center,
          child: Text(
            '$qty',
            style: TextStyle(
              color: qty > 0 ? Colors.white : Colors.white.withValues(alpha: 0.3),
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        _CircleBtn(
          icon: LucideIcons.plus,
          onTap: onIncrement,
          active: true,
          accent: true,
        ),
      ],
    );
  }
}

class _CircleBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final bool active;
  final bool accent;

  const _CircleBtn({required this.icon, required this.onTap, required this.active, this.accent = false});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: 30, height: 30,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: accent
              ? const Color(0xFFE50914).withValues(alpha: active ? 0.15 : 0.05)
              : Colors.white.withValues(alpha: active ? 0.12 : 0.04),
          border: Border.all(
            color: accent
                ? const Color(0xFFE50914).withValues(alpha: active ? 0.6 : 0.15)
                : Colors.white.withValues(alpha: active ? 0.22 : 0.08),
          ),
        ),
        child: Icon(
          icon,
          size: 14,
          color: accent
              ? const Color(0xFFE50914).withValues(alpha: active ? 1.0 : 0.3)
              : Colors.white.withValues(alpha: active ? 0.8 : 0.2),
        ),
      ),
    );
  }
}

class _PriceRow extends StatelessWidget {
  final String label;
  final String value;
  final bool small;

  const _PriceRow({required this.label, required this.value, this.small = false});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: Colors.white.withValues(alpha: 0.4), fontSize: small ? 12 : 13)),
        Text(value, style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: small ? 12 : 13, fontWeight: FontWeight.w500)),
      ],
    );
  }
}

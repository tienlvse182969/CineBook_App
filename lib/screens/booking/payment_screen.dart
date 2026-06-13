import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:ve_xem_phim/data/mock_snacks.dart';
import 'package:ve_xem_phim/models/payment_info.dart';
import 'package:ve_xem_phim/models/snack.dart';
import 'package:ve_xem_phim/screens/booking/payment_success_screen.dart';
import 'package:ve_xem_phim/widgets/auth_widgets.dart';

// ── Payment method data ──────────────────────────────────────────

class _PayMethod {
  final String id;
  final String name;
  final String subtitle;
  final IconData? icon;
  final Color color;
  final String? logoAsset; // SVG asset path, takes priority over icon
  const _PayMethod({
    required this.id,
    required this.name,
    required this.subtitle,
    required this.color,
    this.icon,
    this.logoAsset,
  });
}

final _payMethods = <_PayMethod>[
  const _PayMethod(id: 'momo',    name: 'MoMo',              subtitle: 'Ví điện tử MoMo',         color: Color(0xFFAE2A82), logoAsset: 'assets/logos/momo.png'),
  const _PayMethod(id: 'zalopay', name: 'ZaloPay',           subtitle: 'Ví điện tử ZaloPay',      color: Color(0xFF006AF5), logoAsset: 'assets/logos/zalopay.png'),
  const _PayMethod(id: 'vnpay',   name: 'VNPay',             subtitle: 'Ví VNPay & ngân hàng',    color: Color(0xFFE41D2C), logoAsset: 'assets/logos/vnpay.jpg'),
  const _PayMethod(id: 'card',    name: 'Thẻ ngân hàng',     subtitle: 'Visa / Mastercard / JCB', color: Color(0xFF9C9C9C), icon: LucideIcons.creditCard),
  const _PayMethod(id: 'cash',    name: 'Tiền mặt tại quầy', subtitle: 'Thanh toán khi nhận vé',  color: Color(0xFF4CAF50), icon: LucideIcons.banknote),
];

// ── Screen ───────────────────────────────────────────────────────

class PaymentScreen extends StatefulWidget {
  final PaymentInfo info;
  const PaymentScreen({super.key, required this.info});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  String? _selectedMethod;
  bool _termsAccepted = false;
  String _discountCode = '';
  bool _discountApplied = false;

  bool get _canPay => _selectedMethod != null && _termsAccepted;

  List<(SnackItem, int)> get _orderedSnacks => snackCategories
      .expand((c) => c.items)
      .where((item) => (widget.info.snackQty[item.id] ?? 0) > 0)
      .map((item) => (item, widget.info.snackQty[item.id]!))
      .toList();

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
              Expanded(
                child: ListView(
                  padding: EdgeInsets.fromLTRB(
                    16, 16, 16,
                    MediaQuery.of(context).padding.bottom + 96,
                  ),
                  children: [
                    _buildOrderSummary(),
                    const SizedBox(height: 14),
                    _buildPriceSection(),
                    const SizedBox(height: 14),
                    _buildDiscountSection(),
                    const SizedBox(height: 14),
                    _buildPaymentMethods(),
                    const SizedBox(height: 14),
                    _buildTermsCheckbox(),
                  ],
                ),
              ),
            ],
          ),
          Positioned(
            bottom: 0, left: 0, right: 0,
            child: _buildPayButton(context),
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
              color: widget.info.booking.movie.colors.first.withValues(alpha: 0.12),
            ),
          ),
        ),
      ),
      Positioned(
        bottom: 200, left: -80,
        child: ImageFiltered(
          imageFilter: ImageFilter.blur(sigmaX: 50, sigmaY: 50),
          child: Container(
            width: 200, height: 200,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: widget.info.booking.movie.colors.last.withValues(alpha: 0.08),
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
                Text('Thanh toán', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                SizedBox(height: 2),
                Text('Xác nhận và hoàn tất đặt vé', style: TextStyle(color: Colors.white54, fontSize: 11)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Order summary ───────────────────────────────────────────

  Widget _buildOrderSummary() {
    final b = widget.info.booking;
    final date = b.date;
    final snacks = _orderedSnacks;

    return _GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Movie info row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: _ageColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: _ageColor.withValues(alpha: 0.5)),
                ),
                child: Text(b.movie.ageRating, style: TextStyle(color: _ageColor, fontWeight: FontWeight.bold, fontSize: 13)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  b.movie.title,
                  style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Date + showtime + hall chips
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: [
              _InfoChip(icon: LucideIcons.calendar, label: '${date.day}/${date.month}/${date.year}'),
              _InfoChip(icon: LucideIcons.clock, label: b.showtime.time),
              _InfoChip(icon: LucideIcons.monitor, label: b.showtime.hall),
            ],
          ),
          const SizedBox(height: 14),
          Divider(color: Colors.white.withValues(alpha: 0.08), height: 1),
          const SizedBox(height: 14),

          // Seats
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Icon(LucideIcons.ticket, size: 13, color: Colors.white.withValues(alpha: 0.35)),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Ghế', style: TextStyle(color: Colors.white.withValues(alpha: 0.35), fontSize: 11)),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 5, runSpacing: 5,
                      children: b.seatLabels.map((label) => Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
                        ),
                        child: Text(label, style: TextStyle(color: Colors.white.withValues(alpha: 0.75), fontSize: 12, fontWeight: FontWeight.w600)),
                      )).toList(),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Snacks
          if (snacks.isNotEmpty) ...[
            const SizedBox(height: 14),
            Divider(color: Colors.white.withValues(alpha: 0.08), height: 1),
            const SizedBox(height: 14),
            Row(children: [
              Icon(LucideIcons.shoppingBag, size: 13, color: Colors.white.withValues(alpha: 0.35)),
              const SizedBox(width: 8),
              Text('Bắp & Đồ uống', style: TextStyle(color: Colors.white.withValues(alpha: 0.35), fontSize: 11)),
            ]),
            const SizedBox(height: 8),
            ...snacks.map((e) {
              final (item, qty) = e;
              return Padding(
                padding: const EdgeInsets.only(bottom: 5),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE50914).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Text('×$qty', style: const TextStyle(color: Color(0xFFE50914), fontSize: 11, fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(item.name, style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 13)),
                    ),
                    Text(_fmt(item.price * qty), style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 13)),
                  ],
                ),
              );
            }),
          ],
        ],
      ),
    );
  }

  // ── Price breakdown ─────────────────────────────────────────

  Widget _buildPriceSection() {
    final b = widget.info.booking;
    final snacks = _orderedSnacks;

    return _GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Icon(LucideIcons.receipt, size: 13, color: const Color(0xFFE50914)),
            const SizedBox(width: 7),
            const Text('Chi tiết giá', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
          ]),
          const SizedBox(height: 14),
          _SummaryRow(label: 'Vé (${b.seatLabels.length} ghế)', value: _fmt(b.ticketTotal)),
          ...snacks.map((e) {
            final (item, qty) = e;
            return Column(children: [
              const SizedBox(height: 7),
              _SummaryRow(label: '${item.name}  ×$qty', value: _fmt(item.price * qty)),
            ]);
          }),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Divider(color: Colors.white.withValues(alpha: 0.08), height: 1),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('Tổng cộng', style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 13)),
              Text(
                _fmt(widget.info.grandTotal),
                style: const TextStyle(color: Color(0xFFE50914), fontSize: 22, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Discount code ───────────────────────────────────────────

  Widget _buildDiscountSection() {
    return _GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Icon(LucideIcons.tag, size: 13, color: const Color(0xFFE50914)),
            const SizedBox(width: 7),
            const Text('Mã giảm giá', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
          ]),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  onChanged: (v) => setState(() {
                    _discountCode = v.trim();
                    _discountApplied = false;
                  }),
                  style: const TextStyle(color: Colors.white, fontSize: 14, letterSpacing: 1.5),
                  textCapitalization: TextCapitalization.characters,
                  decoration: InputDecoration(
                    hintText: 'Nhập mã giảm giá',
                    hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.25), fontSize: 13, letterSpacing: 0),
                    filled: true,
                    fillColor: Colors.white.withValues(alpha: 0.05),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.12)),
                    ),
                    focusedBorder: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                      borderSide: BorderSide(color: Color(0xFFE50914), width: 1.5),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              ElevatedButton(
                onPressed: _discountCode.isNotEmpty && !_discountApplied
                    ? () => setState(() {
                          _discountApplied = true;
                          FocusManager.instance.primaryFocus?.unfocus();
                        })
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE50914),
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: Colors.white.withValues(alpha: 0.07),
                  disabledForegroundColor: Colors.white38,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                  elevation: 0,
                ),
                child: const Text('Áp dụng', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              ),
            ],
          ),
          if (_discountApplied) ...[
            const SizedBox(height: 10),
            Row(children: [
              const Icon(LucideIcons.circleCheck, size: 14, color: Color(0xFF4CAF50)),
              const SizedBox(width: 6),
              const Text('Mã giảm giá hợp lệ!', style: TextStyle(color: Color(0xFF4CAF50), fontSize: 12)),
            ]),
          ],
        ],
      ),
    );
  }

  // ── Payment methods ─────────────────────────────────────────

  Widget _buildPaymentMethods() {
    return _GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Icon(LucideIcons.wallet, size: 13, color: const Color(0xFFE50914)),
            const SizedBox(width: 7),
            const Text('Phương thức thanh toán', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
          ]),
          const SizedBox(height: 12),
          ..._payMethods.asMap().entries.map((entry) {
            final isLast = entry.key == _payMethods.length - 1;
            final method = entry.value;
            final isSelected = _selectedMethod == method.id;
            return Column(
              children: [
                GestureDetector(
                  onTap: () => setState(() => _selectedMethod = method.id),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFFE50914).withValues(alpha: 0.08) : Colors.transparent,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isSelected ? const Color(0xFFE50914).withValues(alpha: 0.35) : Colors.transparent,
                      ),
                    ),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: method.logoAsset != null
                              ? Image.asset(method.logoAsset!, width: 38, height: 38, fit: BoxFit.cover)
                              : Container(
                                  width: 38, height: 38,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    color: method.color.withValues(alpha: 0.12),
                                    border: Border.all(color: method.color.withValues(alpha: 0.35)),
                                  ),
                                  child: Icon(method.icon, size: 17, color: method.color),
                                ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                method.name,
                                style: TextStyle(
                                  color: isSelected ? Colors.white : Colors.white.withValues(alpha: 0.8),
                                  fontSize: 14, fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 1),
                              Text(method.subtitle, style: TextStyle(color: Colors.white.withValues(alpha: 0.35), fontSize: 11)),
                            ],
                          ),
                        ),
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          width: 20, height: 20,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isSelected ? const Color(0xFFE50914) : Colors.transparent,
                            border: Border.all(
                              color: isSelected ? const Color(0xFFE50914) : Colors.white.withValues(alpha: 0.25),
                              width: 1.5,
                            ),
                          ),
                          child: isSelected
                              ? const Icon(LucideIcons.check, size: 12, color: Colors.white)
                              : null,
                        ),
                      ],
                    ),
                  ),
                ),
                if (!isLast)
                  Divider(height: 6, color: Colors.white.withValues(alpha: 0.06), indent: 12, endIndent: 12),
              ],
            );
          }),
        ],
      ),
    );
  }

  // ── Terms checkbox ──────────────────────────────────────────

  Widget _buildTermsCheckbox() {
    return GestureDetector(
      onTap: () => setState(() => _termsAccepted = !_termsAccepted),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: _termsAccepted
                    ? const Color(0xFFE50914).withValues(alpha: 0.4)
                    : Colors.white.withValues(alpha: 0.1),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  width: 22, height: 22,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(6),
                    color: _termsAccepted ? const Color(0xFFE50914) : Colors.white.withValues(alpha: 0.08),
                    border: Border.all(
                      color: _termsAccepted ? const Color(0xFFE50914) : Colors.white.withValues(alpha: 0.25),
                    ),
                  ),
                  child: _termsAccepted
                      ? const Icon(LucideIcons.check, size: 14, color: Colors.white)
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: RichText(
                    text: TextSpan(
                      style: TextStyle(color: Colors.white.withValues(alpha: 0.55), fontSize: 12, height: 1.65),
                      children: const [
                        TextSpan(text: 'Tôi đồng ý với '),
                        TextSpan(
                          text: 'Điều khoản sử dụng',
                          style: TextStyle(color: Color(0xFFE50914), decoration: TextDecoration.underline, decorationColor: Color(0xFFE50914)),
                        ),
                        TextSpan(text: ' và đang mua vé cho người có độ tuổi phù hợp với từng loại vé.'),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Pay button ──────────────────────────────────────────────

  Widget _buildPayButton(BuildContext context) {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
        child: Container(
          padding: EdgeInsets.fromLTRB(20, 16, 20, MediaQuery.of(context).padding.bottom + 16),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.6),
            border: Border(top: BorderSide(color: Colors.white.withValues(alpha: 0.08))),
          ),
          child: GlassPrimaryButton(
            label: 'Thanh toán  ·  ${_fmt(widget.info.grandTotal)}',
            onPressed: _canPay
                ? () => Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) => PaymentSuccessScreen(info: widget.info),
                      ),
                    )
                : null,
          ),
        ),
      ),
    );
  }
}

// ── Shared sub-widgets ───────────────────────────────────────────

class _GlassCard extends StatelessWidget {
  final Widget child;
  const _GlassCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
          ),
          child: child,
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _InfoChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 11, color: Colors.white.withValues(alpha: 0.35)),
        const SizedBox(width: 4),
        Text(label, style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 12)),
      ],
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  const _SummaryRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(label, style: TextStyle(color: Colors.white.withValues(alpha: 0.4), fontSize: 12), overflow: TextOverflow.ellipsis),
        ),
        const SizedBox(width: 12),
        Text(value, style: TextStyle(color: Colors.white.withValues(alpha: 0.65), fontSize: 12, fontWeight: FontWeight.w500)),
      ],
    );
  }
}

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:ve_xem_phim/models/booking_record.dart';
import 'package:ve_xem_phim/screens/auth/login_screen.dart';
import 'package:ve_xem_phim/screens/profile/edit_profile_screen.dart';
import 'package:ve_xem_phim/screens/profile/my_tickets_screen.dart';
import 'package:ve_xem_phim/services/api_service.dart';

// ── Screen ───────────────────────────────────────────────────────

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  List<BookingRecord> _bookings = [];
  bool _loadingBookings = false;

  static const int _points = 1250;
  static const int _tierPoints = 2000;
  static const String _currentTier = 'Thành viên Bạc';
  static const String _nextTier = 'Thành viên Vàng';

  @override
  void initState() {
    super.initState();
    _loadBookings();
  }

  Future<void> _loadBookings() async {
    if (!mounted) return;
    setState(() => _loadingBookings = true);
    try {
      final bookings = await ApiService.getMyBookings();
      if (!mounted) return;
      setState(() { _bookings = bookings; _loadingBookings = false; });
    } catch (_) {
      if (mounted) setState(() => _loadingBookings = false);
    }
  }

  String _fmt(int p) {
    final s = p.toString();
    final b = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) b.write('.');
      b.write(s[i]);
    }
    b.write(' đ');
    return b.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF080C14),
      body: Stack(
        children: [
          _buildBg(),
          CustomScrollView(
            slivers: [
              SliverToBoxAdapter(child: _buildHeader(context)),
              SliverToBoxAdapter(child: _buildTicketsSection(context)),
              SliverToBoxAdapter(child: _buildSettingsSection()),
              SliverToBoxAdapter(child: _buildLogoutRow(context)),
              SliverToBoxAdapter(
                child: SizedBox(height: MediaQuery.of(context).padding.bottom + 32),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Background ──────────────────────────────────────────────

  Widget _buildBg() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0A0E1A), Color(0xFF12042A), Color(0xFF0C1530)],
        ),
      ),
    );
  }

  // ── Header ──────────────────────────────────────────────────

  Widget _buildHeader(BuildContext context) {
    final user = ApiService.currentUser;
    final name = user?.fullName ?? 'Người dùng';
    final email = user?.email ?? '';
    final initials = user?.initials ?? 'U';
    final memberSince = user?.memberSinceLabel ?? 'Tháng 01, 2025';

    return Stack(
      children: [
        // Decorative orb
        Positioned(
          top: -50, right: -50,
          child: ImageFiltered(
            imageFilter: ImageFilter.blur(sigmaX: 60, sigmaY: 60),
            child: Container(
              width: 200, height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFE50914).withValues(alpha: 0.18),
              ),
            ),
          ),
        ),
        SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
            child: Column(
              children: [
                // Top row: back + edit
                Row(
                  children: [
                    _iconBtn(LucideIcons.arrowLeft, onTap: () => Navigator.pop(context)),
                    const Spacer(),
                    _iconBtn(LucideIcons.pencil, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const EditProfileScreen()))),
                  ],
                ),
                const SizedBox(height: 28),

                // Avatar
                Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    Container(
                      width: 88, height: 88,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Color(0xFFE50914), Color(0xFF8B0000)],
                        ),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.18), width: 2.5),
                        boxShadow: [BoxShadow(color: const Color(0xFFE50914).withValues(alpha: 0.3), blurRadius: 20, offset: const Offset(0, 6))],
                      ),
                      child: Center(
                        child: Text(initials, style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold, letterSpacing: 1)),
                      ),
                    ),
                    Container(
                      width: 26, height: 26,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFF4CAF50),
                        border: Border.all(color: const Color(0xFF080C14), width: 2.5),
                      ),
                      child: const Icon(LucideIcons.check, size: 13, color: Colors.white),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Name & email
                Text(name, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(email, style: TextStyle(color: Colors.white.withValues(alpha: 0.4), fontSize: 13)),
                const SizedBox(height: 12),
                const SizedBox(height: 5),
                Text('Thành viên từ $memberSince', style: TextStyle(color: Colors.white.withValues(alpha: 0.28), fontSize: 11)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ── Tickets section ─────────────────────────────────────────

  Widget _buildTicketsSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionHeader(
            icon: LucideIcons.ticket,
            title: 'Vé của tôi',
            action: 'Xem tất cả',
            onAction: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const MyTicketsScreen()),
            ),
          ),
          const SizedBox(height: 10),
          if (_loadingBookings)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Center(
                child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFFE50914)),
              ),
            )
          else if (_bookings.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Center(
                child: Text(
                  'Chưa có vé nào',
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.35), fontSize: 13),
                ),
              ),
            )
          else
            ..._bookings.take(3).map((t) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _TicketCard(ticket: t, fmt: _fmt),
            )),
        ],
      ),
    );
  }

  // ── Settings section ────────────────────────────────────────

  Widget _buildSettingsSection() {
    final items = <(IconData, String, String)>[
      (LucideIcons.bell,         'Thông báo',         'Quản lý thông báo đẩy'),
      (LucideIcons.globe,        'Ngôn ngữ',           'Tiếng Việt'),
      (LucideIcons.shieldCheck,  'Quyền riêng tư',    'Dữ liệu & bảo mật'),
      (LucideIcons.fileText,     'Điều khoản sử dụng', ''),
      (LucideIcons.info,         'Về ứng dụng',        'Phiên bản 1.0.0'),
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionHeader(icon: LucideIcons.settings2, title: 'Cài đặt'),
          const SizedBox(height: 10),
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
                  children: items.asMap().entries.map((e) {
                    final isLast = e.key == items.length - 1;
                    final (icon, label, sub) = e.value;
                    return Column(
                      children: [
                        Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () {},
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
                              child: Row(
                                children: [
                                  Container(
                                    width: 34, height: 34,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.white.withValues(alpha: 0.06),
                                    ),
                                    child: Icon(icon, size: 16, color: Colors.white.withValues(alpha: 0.55)),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(label, style: const TextStyle(color: Colors.white, fontSize: 14)),
                                        if (sub.isNotEmpty) ...[
                                          const SizedBox(height: 2),
                                          Text(sub, style: TextStyle(color: Colors.white.withValues(alpha: 0.32), fontSize: 11)),
                                        ],
                                      ],
                                    ),
                                  ),
                                  Icon(LucideIcons.chevronRight, size: 16, color: Colors.white.withValues(alpha: 0.22)),
                                ],
                              ),
                            ),
                          ),
                        ),
                        if (!isLast)
                          Divider(height: 1, color: Colors.white.withValues(alpha: 0.07), indent: 16, endIndent: 16),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Logout row ──────────────────────────────────────────────

  Widget _buildLogoutRow(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => _showLogoutDialog(context),
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: const Color(0xFFE50914).withValues(alpha: 0.07),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE50914).withValues(alpha: 0.2)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 34, height: 34,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFFE50914).withValues(alpha: 0.12),
                      ),
                      child: const Icon(LucideIcons.logOut, size: 16, color: Color(0xFFE50914)),
                    ),
                    const SizedBox(width: 12),
                    const Text('Đăng xuất', style: TextStyle(color: Color(0xFFE50914), fontSize: 14, fontWeight: FontWeight.w600)),
                    const Spacer(),
                    Icon(LucideIcons.chevronRight, size: 16, color: const Color(0xFFE50914).withValues(alpha: 0.4)),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.65),
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFF141428).withValues(alpha: 0.95),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 56, height: 56,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFFE50914).withValues(alpha: 0.1),
                      border: Border.all(color: const Color(0xFFE50914).withValues(alpha: 0.35), width: 1.5),
                    ),
                    child: const Icon(LucideIcons.logOut, color: Color(0xFFE50914), size: 24),
                  ),
                  const SizedBox(height: 16),
                  const Text('Đăng xuất', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  Text(
                    'Bạn có chắc chắn muốn đăng xuất khỏi CineBook không?',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white.withValues(alpha: 0.55), fontSize: 13, height: 1.6),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(ctx),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.white70,
                            side: BorderSide(color: Colors.white.withValues(alpha: 0.2)),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          child: const Text('Hủy'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            ApiService.token = null;
                            ApiService.currentUser = null;
                            Navigator.pop(ctx);
                            Navigator.of(context).pushAndRemoveUntil(
                              MaterialPageRoute(builder: (_) => const LoginScreen()),
                              (_) => false,
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFE50914),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            elevation: 0,
                          ),
                          child: const Text('Đăng xuất', style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Helpers ──────────────────────────────────────────────────────

Widget _iconBtn(IconData icon, {VoidCallback? onTap}) {
  return GestureDetector(
    onTap: onTap,
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
          child: Icon(icon, color: Colors.white70, size: 18),
        ),
      ),
    ),
  );
}

class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? action;
  final VoidCallback? onAction;
  const _SectionHeader({required this.icon, required this.title, this.action, this.onAction});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 14, color: const Color(0xFFE50914)),
        const SizedBox(width: 7),
        Text(title, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600)),
        if (action != null) ...[
          const Spacer(),
          GestureDetector(
            onTap: onAction,
            child: Row(
              children: [
                Text(action!, style: TextStyle(color: Colors.white.withValues(alpha: 0.35), fontSize: 12)),
                Icon(LucideIcons.chevronRight, size: 13, color: Colors.white.withValues(alpha: 0.25)),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _TicketCard extends StatelessWidget {
  final BookingRecord ticket;
  final String Function(int) fmt;
  const _TicketCard({required this.ticket, required this.fmt});

  @override
  Widget build(BuildContext context) {
    final t = ticket;
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
          ),
          child: Row(
            children: [
              // Color accent bar
              Container(
                width: 5,
                height: 80,
                decoration: BoxDecoration(
                  color: t.color,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(14),
                    bottomLeft: Radius.circular(14),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              // Info
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        t.movieTitle,
                        style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 5),
                      Row(children: [
                        Icon(LucideIcons.calendar, size: 11, color: Colors.white.withValues(alpha: 0.35)),
                        const SizedBox(width: 4),
                        Text('${t.date}  ·  ${t.time}', style: TextStyle(color: Colors.white.withValues(alpha: 0.45), fontSize: 12)),
                      ]),
                      const SizedBox(height: 5),
                      Wrap(
                        spacing: 4,
                        children: t.seats.map((s) => Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.07),
                            borderRadius: BorderRadius.circular(5),
                            border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
                          ),
                          child: Text(s, style: TextStyle(color: Colors.white.withValues(alpha: 0.65), fontSize: 11, fontWeight: FontWeight.w600)),
                        )).toList(),
                      ),
                    ],
                  ),
                ),
              ),
              // Right side: price + status
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 12, 14, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(fmt(t.total), style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 13, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: (t.isUpcoming ? const Color(0xFF2196F3) : const Color(0xFF4CAF50)).withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: (t.isUpcoming ? const Color(0xFF2196F3) : const Color(0xFF4CAF50)).withValues(alpha: 0.35),
                        ),
                      ),
                      child: Text(
                        t.isUpcoming ? 'Sắp tới' : 'Đã xem',
                        style: TextStyle(
                          color: t.isUpcoming ? const Color(0xFF2196F3) : const Color(0xFF4CAF50),
                          fontSize: 10, fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

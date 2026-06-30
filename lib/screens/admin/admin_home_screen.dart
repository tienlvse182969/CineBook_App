import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:ve_xem_phim/screens/admin/admin_dashboard_screen.dart';
import 'package:ve_xem_phim/screens/admin/admin_movies_screen.dart';
import 'package:ve_xem_phim/screens/admin/admin_payments_screen.dart';
import 'package:ve_xem_phim/screens/admin/admin_users_screen.dart';
import 'package:ve_xem_phim/services/api_service.dart';

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({super.key});

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  int _idx = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (ApiService.token == null) Navigator.of(context).pushReplacementNamed('/');
    });
  }

  static const _nav = [
    (icon: LucideIcons.layoutDashboard, label: 'Dashboard'),
    (icon: LucideIcons.film,            label: 'Phim & Lịch chiếu'),
    (icon: LucideIcons.trendingUp,      label: 'Doanh thu'),
    (icon: LucideIcons.users,           label: 'Users'),
  ];

  static const List<Widget> _screens = [
    AdminDashboardScreen(),
    AdminMoviesScreen(),
    AdminPaymentsScreen(),
    AdminUsersScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F1117),
      body: LayoutBuilder(
        builder: (ctx, constraints) {
          final wide = constraints.maxWidth >= 680;
          if (wide) {
            return Row(
              children: [
                _buildSidebar(true),
                Expanded(
                  child: Column(
                    children: [
                      _buildTopBar(),
                      Expanded(child: _screens[_idx]),
                    ],
                  ),
                ),
              ],
            );
          }
          // Mobile layout: top header + bottom nav
          return Column(
            children: [
              _buildMobileHeader(),
              Expanded(child: _screens[_idx]),
              _buildBottomNav(),
            ],
          );
        },
      ),
    );
  }

  Widget _buildMobileHeader() {
    final top = MediaQuery.of(context).padding.top;
    return Container(
      padding: EdgeInsets.fromLTRB(16, top + 10, 16, 12),
      decoration: const BoxDecoration(
        color: Color(0xFF161B22),
        border: Border(bottom: BorderSide(color: Color(0xFF21262D))),
      ),
      child: Row(
        children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFFE50914).withValues(alpha: 0.12),
              border: Border.all(color: const Color(0xFFE50914).withValues(alpha: 0.35)),
            ),
            child: const Icon(LucideIcons.clapperboard, color: Color(0xFFE50914), size: 18),
          ),
          const SizedBox(width: 12),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('CineBook Admin', style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w700)),
              Text('Quản trị hệ thống', style: TextStyle(color: Color(0xFF8B949E), fontSize: 11)),
            ],
          ),
          const Spacer(),
          GestureDetector(
            onTap: _confirmLogout,
            child: const Icon(LucideIcons.logOut, color: Color(0xFF8B949E), size: 20),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF161B22),
        border: Border(top: BorderSide(color: Color(0xFF21262D))),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: List.generate(_nav.length, (i) {
            final active = _idx == i;
            return Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _idx = i),
                child: Container(
                  color: Colors.transparent,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(_nav[i].icon, size: 20,
                          color: active ? const Color(0xFFE50914) : const Color(0xFF8B949E)),
                      const SizedBox(height: 4),
                      Text(
                        _nav[i].label.split(' ').first,
                        style: TextStyle(
                          fontSize: 10,
                          color: active ? const Color(0xFFE50914) : const Color(0xFF8B949E),
                          fontWeight: active ? FontWeight.w600 : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildSidebar(bool wide) {
    return Container(
      width: wide ? 220.0 : 64.0,
      decoration: const BoxDecoration(
        color: Color(0xFF161B22),
        border: Border(right: BorderSide(color: Color(0xFF21262D))),
      ),
      child: Column(
        children: [
          _buildLogo(wide),
          const Divider(color: Color(0xFF21262D), height: 1),
          const SizedBox(height: 8),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              children: List.generate(_nav.length, (i) => _buildNavItem(i, wide)),
            ),
          ),
          const Divider(color: Color(0xFF21262D), height: 1),
          _buildLogoutBtn(wide),
        ],
      ),
    );
  }

  Widget _buildLogo(bool wide) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        mainAxisAlignment: wide ? MainAxisAlignment.start : MainAxisAlignment.center,
        children: [
          Container(
            width: 32, height: 32,
            decoration: BoxDecoration(
              color: const Color(0xFFE50914).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFE50914).withValues(alpha: 0.35)),
            ),
            child: const Icon(LucideIcons.clapperboard, color: Color(0xFFE50914), size: 15),
          ),
          if (wide) ...[
            const SizedBox(width: 10),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('CineBook', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700)),
                Text('Admin', style: TextStyle(color: Color(0xFF8B949E), fontSize: 10, letterSpacing: 0.5)),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildNavItem(int i, bool wide) {
    final item = _nav[i];
    final active = _idx == i;
    return GestureDetector(
      onTap: () => setState(() => _idx = i),
      child: Container(
        margin: const EdgeInsets.only(bottom: 2),
        padding: EdgeInsets.symmetric(
          horizontal: wide ? (active ? 9 : 12) : 0,
          vertical: 10,
        ),
        decoration: BoxDecoration(
          color: active ? const Color(0xFFE50914).withValues(alpha: 0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: active
              ? const Border(left: BorderSide(color: Color(0xFFE50914), width: 3))
              : null,
        ),
        child: Row(
          mainAxisAlignment: wide ? MainAxisAlignment.start : MainAxisAlignment.center,
          children: [
            Icon(item.icon, size: 16,
                color: active ? const Color(0xFFE50914) : const Color(0xFF8B949E)),
            if (wide) ...[
              const SizedBox(width: 10),
              Text(
                item.label,
                style: TextStyle(
                  color: active ? Colors.white : const Color(0xFF8B949E),
                  fontSize: 13,
                  fontWeight: active ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Container(
      height: 52,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: const BoxDecoration(
        color: Color(0xFF161B22),
        border: Border(bottom: BorderSide(color: Color(0xFF21262D))),
      ),
      child: Row(
        children: [
          Text(
            _nav[_idx].label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogoutBtn(bool wide) {
    return GestureDetector(
      onTap: _confirmLogout,
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: wide ? 20 : 0,
          vertical: 16,
        ),
        child: Row(
          mainAxisAlignment: wide ? MainAxisAlignment.start : MainAxisAlignment.center,
          children: [
            const Icon(LucideIcons.logOut, size: 15, color: Color(0xFF8B949E)),
            if (wide) ...[
              const SizedBox(width: 10),
              const Text('Đăng xuất', style: TextStyle(color: Color(0xFF8B949E), fontSize: 13)),
            ],
          ],
        ),
      ),
    );
  }

  void _confirmLogout() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF161B22),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text('Đăng xuất', style: TextStyle(color: Colors.white, fontSize: 15)),
        content: const Text(
          'Thoát khỏi trang quản trị?',
          style: TextStyle(color: Color(0xFF8B949E), fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Hủy', style: TextStyle(color: Color(0xFF8B949E))),
          ),
          TextButton(
            onPressed: () {
              ApiService.logout();
              Navigator.pop(ctx);
              Navigator.of(context).pushReplacementNamed('/');
            },
            child: const Text('Đăng xuất', style: TextStyle(color: Color(0xFFE50914))),
          ),
        ],
      ),
    );
  }
}

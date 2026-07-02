import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:ve_xem_phim/services/api_service.dart';
import 'package:ve_xem_phim/widgets/auth_widgets.dart';

class PrivacyScreen extends StatefulWidget {
  const PrivacyScreen({super.key});

  @override
  State<PrivacyScreen> createState() => _PrivacyScreenState();
}

class _PrivacyScreenState extends State<PrivacyScreen> {
  bool _googleLinked    = true;
  bool _otpLinked       = false;

  void _showPasswordDialog() {
    final oldCtrl  = TextEditingController();
    final newCtrl  = TextEditingController();
    final confCtrl = TextEditingController();
    final key      = GlobalKey<FormState>();
    bool isSubmitting = false;

    showDialog<void>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.65),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 20),
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
              child: Form(
                key: key,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 40, height: 40,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color(0xFFE50914).withValues(alpha: 0.1),
                          ),
                          child: const Icon(LucideIcons.lock, color: Color(0xFFE50914), size: 18),
                        ),
                        const SizedBox(width: 12),
                        const Text('Đổi mật khẩu',
                            style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 20),
                    GlassInput(
                      label: 'Mật khẩu hiện tại',
                      hint: '••••••••',
                      prefixIcon: LucideIcons.lockKeyhole,
                      obscureText: true,
                      controller: oldCtrl,
                      validator: (v) => v?.isEmpty == true ? 'Nhập mật khẩu hiện tại' : null,
                    ),
                    const SizedBox(height: 12),
                    GlassInput(
                      label: 'Mật khẩu mới',
                      hint: '••••••••',
                      prefixIcon: LucideIcons.lock,
                      obscureText: true,
                      controller: newCtrl,
                      validator: (v) {
                        if (v?.isEmpty == true) return 'Nhập mật khẩu mới';
                        if (v!.length < 6) return 'Ít nhất 6 ký tự';
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    GlassInput(
                      label: 'Xác nhận mật khẩu mới',
                      hint: '••••••••',
                      prefixIcon: LucideIcons.lock,
                      obscureText: true,
                      controller: confCtrl,
                      validator: (v) {
                        if (v?.isEmpty == true) return 'Xác nhận mật khẩu';
                        if (v != newCtrl.text) return 'Mật khẩu không khớp';
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(ctx),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.white70,
                              side: BorderSide(color: Colors.white.withValues(alpha: 0.2)),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              padding: const EdgeInsets.symmetric(vertical: 13),
                            ),
                            child: const Text('Hủy'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: isSubmitting
                                ? null
                                : () async {
                                    if (!(key.currentState?.validate() ?? false)) return;
                                    setDialogState(() => isSubmitting = true);
                                    try {
                                      await ApiService.changePassword(
                                        oldCtrl.text,
                                        newCtrl.text,
                                      );
                                      if (!mounted) return;
                                      Navigator.of(context).pop();
                                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                        content: const Text('Đã đổi mật khẩu thành công'),
                                        backgroundColor: const Color(0xFF4CAF50),
                                        behavior: SnackBarBehavior.floating,
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                        margin: const EdgeInsets.all(16),
                                      ));
                                    } catch (e) {
                                      setDialogState(() => isSubmitting = false);
                                      if (!mounted) return;
                                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                        content: Text('$e'),
                                        backgroundColor: const Color(0xFFE50914),
                                        behavior: SnackBarBehavior.floating,
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                        margin: const EdgeInsets.all(16),
                                      ));
                                    }
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFE50914),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              padding: const EdgeInsets.symmetric(vertical: 13),
                              elevation: 0,
                              disabledBackgroundColor: const Color(0xFFE50914).withValues(alpha: 0.35),
                            ),
                            child: isSubmitting
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                  )
                                : const Text('Lưu', style: TextStyle(fontWeight: FontWeight.bold)),
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
      ),
      ),
    );
  }

  // ── Build ─────────────────────────────────────────────────────

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
              SliverToBoxAdapter(child: _buildSecuritySection()),
              SliverToBoxAdapter(child: _buildLoginMethodsSection()),
              SliverToBoxAdapter(
                child: SizedBox(height: MediaQuery.of(context).padding.bottom + 32),
              ),
            ],
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
          colors: [Color(0xFF0A0E1A), Color(0xFF12042A), Color(0xFF0C1530)],
        ),
      ),
    );
  }

  // ── Header ────────────────────────────────────────────────────

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
                Text('Quyền riêng tư',
                    style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                SizedBox(height: 2),
                Text('Dữ liệu & bảo mật',
                    style: TextStyle(color: Colors.white54, fontSize: 11)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ── Security ──────────────────────────────────────────────────

  Widget _buildSecuritySection() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader(LucideIcons.shieldCheck, 'Bảo mật'),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: _showPasswordDialog,
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 36, height: 36,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color(0xFFE50914).withValues(alpha: 0.1),
                          ),
                          child: const Icon(LucideIcons.keyRound, size: 17, color: Color(0xFFE50914)),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Đổi mật khẩu', style: TextStyle(color: Colors.white, fontSize: 14)),
                              SizedBox(height: 2),
                              Text('Cập nhật mật khẩu đăng nhập',
                                  style: TextStyle(color: Colors.white38, fontSize: 11)),
                            ],
                          ),
                        ),
                        Icon(LucideIcons.chevronRight, size: 16,
                            color: Colors.white.withValues(alpha: 0.25)),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Login methods ─────────────────────────────────────────────

  Widget _buildLoginMethodsSection() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader(LucideIcons.link, 'Phương thức đăng nhập'),
          const SizedBox(height: 12),
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
                  children: [
                    _MethodRow(
                      icon: LucideIcons.globe,
                      label: 'Google',
                      subtitle: 'Đăng nhập bằng tài khoản Google',
                      linked: _googleLinked,
                      onToggle: (v) => setState(() => _googleLinked = v),
                    ),
                    _divider(),
                    _MethodRow(
                      icon: LucideIcons.mail,
                      label: 'OTP Email',
                      subtitle: 'Xác thực qua mã gửi về email',
                      linked: _otpLinked,
                      onToggle: (v) => setState(() => _otpLinked = v),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _divider() =>
      Divider(height: 1, color: Colors.white.withValues(alpha: 0.07), indent: 16, endIndent: 16);

  // ── Helpers ───────────────────────────────────────────────────

  Widget _sectionHeader(IconData icon, String title) {
    return Row(
      children: [
        Icon(icon, size: 14, color: const Color(0xFFE50914)),
        const SizedBox(width: 7),
        Text(title,
            style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600)),
      ],
    );
  }
}

// ── Method toggle row ────────────────────────────────────────────

class _MethodRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final bool linked;
  final ValueChanged<bool> onToggle;

  const _MethodRow({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.linked,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: linked
                  ? const Color(0xFFE50914).withValues(alpha: 0.1)
                  : Colors.white.withValues(alpha: 0.06),
            ),
            child: Icon(icon, size: 17,
                color: linked ? const Color(0xFFE50914) : Colors.white.withValues(alpha: 0.4)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(color: Colors.white, fontSize: 14)),
                const SizedBox(height: 2),
                Text(subtitle,
                    style: TextStyle(color: Colors.white.withValues(alpha: 0.32), fontSize: 11)),
              ],
            ),
          ),
          Switch(
            value: linked,
            onChanged: onToggle,
            activeThumbColor: const Color(0xFFE50914),
            activeTrackColor: const Color(0xFFE50914).withValues(alpha: 0.3),
            inactiveThumbColor: Colors.white38,
            inactiveTrackColor: Colors.white.withValues(alpha: 0.1),
          ),
        ],
      ),
    );
  }
}

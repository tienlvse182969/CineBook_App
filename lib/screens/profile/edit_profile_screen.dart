import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:ve_xem_phim/services/api_service.dart';
import 'package:ve_xem_phim/widgets/auth_widgets.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _emailCtrl;
  late final TextEditingController _phoneCtrl;

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameCtrl  = TextEditingController(text: ApiService.currentUser?.fullName ?? '');
    _emailCtrl = TextEditingController(text: ApiService.currentUser?.email ?? '');
    _phoneCtrl = TextEditingController(text: ApiService.currentUser?.phone ?? '');
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  void _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _isSaving = true);
    try {
      await ApiService.updateProfile(
        fullName: _nameCtrl.text.trim(),
        phone: _phoneCtrl.text.trim().isEmpty ? null : _phoneCtrl.text.trim(),
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: const Text('Đã lưu thay đổi'),
        backgroundColor: const Color(0xFF4CAF50),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('$e'),
        backgroundColor: const Color(0xFFE50914),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ));
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
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
              SliverToBoxAdapter(child: _buildAvatar()),
              SliverToBoxAdapter(child: _buildPersonalSection()),
              SliverToBoxAdapter(child: _buildSaveButton()),
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
                Text('Chỉnh sửa hồ sơ',
                    style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                SizedBox(height: 2),
                Text('Cập nhật thông tin cá nhân',
                    style: TextStyle(color: Colors.white54, fontSize: 11)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ── Avatar ────────────────────────────────────────────────────

  Widget _buildAvatar() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Center(
        child: Stack(
          alignment: Alignment.bottomRight,
          children: [
            Container(
              width: 86, height: 86,
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
                child: Text(
                  ApiService.currentUser?.initials ?? 'U',
                  style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            Container(
              width: 30, height: 30,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF1565C0),
                border: Border.all(color: const Color(0xFF080C14), width: 2),
              ),
              child: const Icon(LucideIcons.camera, size: 14, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  // ── Personal info ─────────────────────────────────────────────

  Widget _buildPersonalSection() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader(LucideIcons.user, 'Thông tin cá nhân'),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      GlassInput(
                        label: 'Tên đăng nhập',
                        hint: 'username',
                        prefixIcon: LucideIcons.user,
                        controller: _nameCtrl,
                        validator: (v) => v?.trim().isEmpty == true ? 'Vui lòng nhập tên' : null,
                      ),
                      const SizedBox(height: 12),
                      GlassInput(
                        label: 'Email',
                        hint: 'example@email.com',
                        prefixIcon: LucideIcons.mail,
                        controller: _emailCtrl,
                        keyboardType: TextInputType.emailAddress,
                        readOnly: true,
                      ),
                      const SizedBox(height: 12),
                      GlassInput(
                        label: 'Số điện thoại',
                        hint: '0xxxxxxxxx',
                        prefixIcon: LucideIcons.phone,
                        controller: _phoneCtrl,
                        keyboardType: TextInputType.phone,
                        validator: (v) => v?.trim().isEmpty == true ? 'Vui lòng nhập SĐT' : null,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Save button ───────────────────────────────────────────────

  Widget _buildSaveButton() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
      child: SizedBox(
        width: double.infinity,
        height: 50,
        child: ElevatedButton(
          onPressed: _isSaving ? null : _save,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFE50914),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            elevation: 0,
            disabledBackgroundColor: const Color(0xFFE50914).withValues(alpha: 0.5),
          ),
          child: _isSaving
              ? const SizedBox(width: 20, height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
              : const Text('Lưu thay đổi',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }

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


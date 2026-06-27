import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:ve_xem_phim/services/api_service.dart';

class AdminUsersScreen extends StatefulWidget {
  const AdminUsersScreen({super.key});

  @override
  State<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends State<AdminUsersScreen> {
  List<Map<String, dynamic>> _users = [];
  int _page = 1;
  int _totalPages = 1;
  bool _isLoading = true;
  final _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _load({int page = 1}) async {
    setState(() { _isLoading = true; _page = page; });
    try {
      final data = await ApiService.getAdminUsers(
        page: page,
        search: _searchCtrl.text.trim().isEmpty ? null : _searchCtrl.text.trim(),
      );
      if (mounted) {
        setState(() {
          _users = (data['users'] as List? ?? []).cast<Map<String, dynamic>>();
          _totalPages = (data['totalPages'] as num?)?.toInt() ?? 1;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _toggleStatus(Map<String, dynamic> user) async {
    final id = (user['user_id'] as num?)?.toInt();
    if (id == null) return;
    final isActive = (user['is_active'] as int? ?? 1) == 1;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF161B22),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(isActive ? 'Khóa tài khoản' : 'Mở khóa tài khoản', style: const TextStyle(color: Colors.white)),
        content: Text(
          isActive
              ? 'Khóa tài khoản của "${user['full_name'] ?? user['email']}"?'
              : 'Mở khóa tài khoản của "${user['full_name'] ?? user['email']}"?',
          style: TextStyle(color: Colors.white.withValues(alpha: 0.6)),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text('Hủy', style: TextStyle(color: Colors.white.withValues(alpha: 0.5)))),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(isActive ? 'Khóa' : 'Mở khóa', style: TextStyle(color: isActive ? const Color(0xFFE50914) : const Color(0xFF22C55E))),
          ),
        ],
      ),
    );
    if (confirm != true || !mounted) return;
    try {
      await ApiService.toggleUserStatus(id);
      if (mounted) _load(page: _page);
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString().replaceFirst('Exception: ', '')), backgroundColor: const Color(0xFFE50914)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildSearchBar(),
        Expanded(
          child: RefreshIndicator(
            color: const Color(0xFFE50914),
            backgroundColor: const Color(0xFF161B22),
            onRefresh: () => _load(page: 1),
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: Color(0xFFE50914)))
                : _users.isEmpty
                    ? _emptyState()
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                        itemCount: _users.length + (_totalPages > 1 ? 1 : 0),
                        separatorBuilder: (_, _) => const SizedBox(height: 8),
                        itemBuilder: (context, i) {
                          if (i == _users.length) return _buildPagination();
                          return _UserCard(
                            user: _users[i],
                            onToggle: () => _toggleStatus(_users[i]),
                          );
                        },
                      ),
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
      child: TextField(
        controller: _searchCtrl,
        style: const TextStyle(color: Colors.white, fontSize: 13),
        onSubmitted: (_) => _load(page: 1),
        decoration: InputDecoration(
          hintText: 'Tìm tên, email, SĐT...',
          hintStyle: const TextStyle(color: Color(0xFF8B949E), fontSize: 13),
          prefixIcon: const Icon(LucideIcons.search, size: 16, color: Color(0xFF8B949E)),
          suffixIcon: _searchCtrl.text.isNotEmpty
              ? GestureDetector(
                  onTap: () { _searchCtrl.clear(); _load(page: 1); },
                  child: const Icon(LucideIcons.x, size: 16, color: Color(0xFF8B949E)),
                )
              : null,
          filled: true,
          fillColor: const Color(0xFF1C2128),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF30363D))),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF30363D))),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE50914))),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
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
            Icon(LucideIcons.users, color: Colors.white.withValues(alpha: 0.15), size: 48),
            const SizedBox(height: 12),
            Text('Không tìm thấy người dùng', style: TextStyle(color: Colors.white.withValues(alpha: 0.3), fontSize: 14)),
          ],
        ),
      );
}

class _UserCard extends StatelessWidget {
  final Map<String, dynamic> user;
  final VoidCallback onToggle;
  const _UserCard({required this.user, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    final isActive = (user['is_active'] as int? ?? 1) == 1;
    final name = user['full_name']?.toString() ?? '—';
    final email = user['email']?.toString() ?? '—';
    final phone = user['phone']?.toString();
    final initials = name.isNotEmpty ? name[0].toUpperCase() : '?';

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF1C2128),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isActive ? const Color(0xFF30363D) : const Color(0xFFEF4444).withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isActive
                  ? const Color(0xFFE50914).withValues(alpha: 0.12)
                  : const Color(0xFFEF4444).withValues(alpha: 0.08),
              border: Border.all(
                color: isActive
                    ? const Color(0xFFE50914).withValues(alpha: 0.3)
                    : const Color(0xFFEF4444).withValues(alpha: 0.2),
                width: 1.5,
              ),
            ),
            child: Center(
              child: Text(
                initials,
                style: TextStyle(
                  color: isActive ? const Color(0xFFE50914) : const Color(0xFF8B949E),
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        name,
                        style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (!isActive)
                      Container(
                        margin: const EdgeInsets.only(left: 6),
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEF4444).withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text('Đã khóa', style: TextStyle(color: Color(0xFFEF4444), fontSize: 9, fontWeight: FontWeight.w600)),
                      ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(email, style: const TextStyle(color: Color(0xFF8B949E), fontSize: 11), overflow: TextOverflow.ellipsis),
                if (phone != null && phone.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(phone, style: const TextStyle(color: Color(0xFF8B949E), fontSize: 11)),
                ],
              ],
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: onToggle,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isActive
                    ? const Color(0xFFEF4444).withValues(alpha: 0.1)
                    : const Color(0xFF22C55E).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isActive
                      ? const Color(0xFFEF4444).withValues(alpha: 0.25)
                      : const Color(0xFF22C55E).withValues(alpha: 0.25),
                ),
              ),
              child: Icon(
                isActive ? LucideIcons.userX : LucideIcons.userCheck,
                size: 16,
                color: isActive ? const Color(0xFFEF4444) : const Color(0xFF22C55E),
              ),
            ),
          ),
        ],
      ),
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
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: enabled ? const Color(0xFF1C2128) : const Color(0xFF161B22),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFF30363D)),
        ),
        child: Icon(icon, size: 16, color: enabled ? Colors.white.withValues(alpha: 0.7) : const Color(0xFF8B949E)),
      ),
    );
  }
}

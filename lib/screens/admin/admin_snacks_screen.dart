import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:ve_xem_phim/services/api_service.dart';

double _n(dynamic v) {
  if (v == null) return 0;
  if (v is num) return v.toDouble();
  return double.tryParse(v.toString()) ?? 0;
}

class AdminSnacksScreen extends StatefulWidget {
  const AdminSnacksScreen({super.key});

  @override
  State<AdminSnacksScreen> createState() => _AdminSnacksScreenState();
}

class _AdminSnacksScreenState extends State<AdminSnacksScreen> {
  List<Map<String, dynamic>> _snacks = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _isLoading = true);
    try {
      final list = await ApiService.getAllSnacks();
      if (mounted) setState(() { _snacks = list; _isLoading = false; });
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _toggleStatus(Map<String, dynamic> snack) async {
    final id = (snack['snack_id'] as num?)?.toInt();
    if (id == null) return;
    final newStatus = snack['status'] == 'AVAILABLE' ? 'UNAVAILABLE' : 'AVAILABLE';
    try {
      await ApiService.updateSnack(id, {'status': newStatus});
      _load();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(e.toString().replaceFirst('Exception: ', '')),
          backgroundColor: const Color(0xFFE50914),
        ));
      }
    }
  }

  Future<void> _deleteSnack(Map<String, dynamic> snack) async {
    final id = (snack['snack_id'] as num?)?.toInt();
    if (id == null) return;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF161B22),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Xóa đồ ăn', style: TextStyle(color: Colors.white)),
        content: Text('Xóa "${snack['name']}"?', style: TextStyle(color: Colors.white.withValues(alpha: 0.6))),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text('Hủy', style: TextStyle(color: Colors.white.withValues(alpha: 0.5)))),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Xóa', style: TextStyle(color: Color(0xFFE50914)))),
        ],
      ),
    );
    if (confirm != true) return;
    try {
      await ApiService.deleteSnack(id);
      _load();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(e.toString().replaceFirst('Exception: ', '')),
          backgroundColor: const Color(0xFFE50914),
        ));
      }
    }
  }

  void _showForm(BuildContext ctx, Map<String, dynamic>? snack) {
    final nameCtrl = TextEditingController(text: snack?['name']?.toString() ?? '');
    final priceCtrl = TextEditingController(text: snack == null ? '' : _n(snack['price']).toStringAsFixed(0));
    final descCtrl = TextEditingController(text: snack?['description']?.toString() ?? '');
    String type = snack?['type']?.toString() ?? 'POPCORN';
    String status = snack?['status']?.toString() ?? 'AVAILABLE';
    bool saving = false;

    showModalBottomSheet(
      context: ctx,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheet) => StatefulBuilder(
        builder: (sheet, setModal) => Container(
          decoration: const BoxDecoration(
            color: Color(0xFF161B22),
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: EdgeInsets.only(
            left: 20, right: 20, top: 20,
            bottom: MediaQuery.of(sheet).viewInsets.bottom + 24,
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2))),
                ),
                const SizedBox(height: 16),
                Text(snack == null ? 'Thêm đồ ăn / đồ uống' : 'Sửa đồ ăn', style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                _Field(label: 'Tên *', controller: nameCtrl),
                const SizedBox(height: 10),
                _Field(label: 'Giá (đồng) *', controller: priceCtrl, keyboardType: TextInputType.number),
                const SizedBox(height: 10),
                _Field(label: 'Mô tả', controller: descCtrl, maxLines: 2),
                const SizedBox(height: 10),
                Text('Loại', style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 12)),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 6, runSpacing: 6,
                  children: const [
                    ('POPCORN', 'Bắp rang'),
                    ('DRINK', 'Nước uống'),
                    ('COMBO', 'Combo'),
                    ('FOOD', 'Đồ ăn'),
                  ].map((t) {
                    final active = type == t.$1;
                    return GestureDetector(
                      onTap: () => setModal(() => type = t.$1),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: active ? const Color(0xFFE50914).withValues(alpha: 0.2) : Colors.white.withValues(alpha: 0.06),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: active ? const Color(0xFFE50914).withValues(alpha: 0.5) : Colors.transparent),
                        ),
                        child: Text(t.$2, style: TextStyle(color: active ? const Color(0xFFE50914) : Colors.white54, fontSize: 12, fontWeight: FontWeight.w600)),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 10),
                Text('Trạng thái', style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 12)),
                const SizedBox(height: 6),
                Row(
                  children: const [('AVAILABLE', 'Có bán'), ('UNAVAILABLE', 'Ngừng bán')].map((s) {
                    final active = status == s.$1;
                    final c = active ? const Color(0xFF22C55E) : Colors.white38;
                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: GestureDetector(
                          onTap: () => setModal(() => status = s.$1),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 9),
                            decoration: BoxDecoration(
                              color: active ? const Color(0xFF22C55E).withValues(alpha: 0.12) : Colors.white.withValues(alpha: 0.05),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: active ? const Color(0xFF22C55E).withValues(alpha: 0.35) : Colors.transparent),
                            ),
                            child: Text(s.$2, textAlign: TextAlign.center, style: TextStyle(color: c, fontSize: 12, fontWeight: FontWeight.w600)),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity, height: 48,
                  child: ElevatedButton(
                    onPressed: saving ? null : () async {
                      if (nameCtrl.text.trim().isEmpty) return;
                      final price = double.tryParse(priceCtrl.text.trim());
                      if (price == null || price <= 0) return;
                      setModal(() => saving = true);
                      try {
                        final body = {
                          'name': nameCtrl.text.trim(),
                          'price': price,
                          'description': descCtrl.text.trim(),
                          'type': type,
                          'status': status,
                        };
                        if (snack == null) {
                          await ApiService.createSnack(body);
                        } else {
                          await ApiService.updateSnack((snack['snack_id'] as num).toInt(), body);
                        }
                        if (sheet.mounted) Navigator.pop(sheet);
                        await _load();
                      } catch (e) {
                        if (sheet.mounted) {
                          ScaffoldMessenger.of(sheet).showSnackBar(SnackBar(content: Text(e.toString().replaceFirst('Exception: ', '')), backgroundColor: const Color(0xFFE50914)));
                        }
                        setModal(() => saving = false);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE50914),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                    child: saving
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : const Text('Lưu', style: TextStyle(fontWeight: FontWeight.w600)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      color: const Color(0xFFE50914),
      backgroundColor: const Color(0xFF161B22),
      onRefresh: _load,
      child: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFE50914)))
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 14, 20, 8),
                  child: Row(
                    children: [
                      Text('${_snacks.length} mặt hàng', style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 13)),
                      const Spacer(),
                      _AddBtn(onTap: () => _showForm(context, null)),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                    itemCount: _snacks.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 8),
                    itemBuilder: (context, i) => _SnackRow(
                      snack: _snacks[i],
                      onEdit: () => _showForm(context, _snacks[i]),
                      onDelete: () => _deleteSnack(_snacks[i]),
                      onToggle: () => _toggleStatus(_snacks[i]),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}

// ── Row widget ────────────────────────────────────────────────────────────────

class _SnackRow extends StatelessWidget {
  final Map<String, dynamic> snack;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onToggle;
  const _SnackRow({required this.snack, required this.onEdit, required this.onDelete, required this.onToggle});

  Color get _typeColor {
    switch (snack['type']) {
      case 'POPCORN': return const Color(0xFFF97316);
      case 'DRINK':   return const Color(0xFF3B82F6);
      case 'COMBO':   return const Color(0xFF8B5CF6);
      default:        return const Color(0xFF22C55E);
    }
  }

  String get _typeLabel {
    switch (snack['type']) {
      case 'POPCORN': return 'Bắp rang';
      case 'DRINK':   return 'Nước';
      case 'COMBO':   return 'Combo';
      default:        return 'Đồ ăn';
    }
  }

  @override
  Widget build(BuildContext context) {
    final available = snack['status'] == 'AVAILABLE';
    final price = _n(snack['price']);

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
            width: 42, height: 42,
            decoration: BoxDecoration(
              color: _typeColor.withValues(alpha: 0.13),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(LucideIcons.shoppingBag, color: _typeColor, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  snack['name']?.toString() ?? '',
                  style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(color: _typeColor.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(5)),
                    child: Text(_typeLabel, style: TextStyle(color: _typeColor, fontSize: 10, fontWeight: FontWeight.w600)),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${(price / 1000).toStringAsFixed(0)}K đ',
                    style: const TextStyle(color: Color(0xFFE50914), fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ]),
              ],
            ),
          ),
          GestureDetector(
            onTap: onToggle,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
              decoration: BoxDecoration(
                color: available ? const Color(0xFF22C55E).withValues(alpha: 0.12) : Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: available ? const Color(0xFF22C55E).withValues(alpha: 0.3) : Colors.white.withValues(alpha: 0.12)),
              ),
              child: Text(
                available ? 'Có bán' : 'Ngừng',
                style: TextStyle(color: available ? const Color(0xFF22C55E) : Colors.white38, fontSize: 10, fontWeight: FontWeight.w600),
              ),
            ),
          ),
          IconButton(icon: Icon(LucideIcons.pencil, color: Colors.white.withValues(alpha: 0.5), size: 15), onPressed: onEdit, padding: const EdgeInsets.all(4)),
          IconButton(icon: Icon(LucideIcons.trash2, color: const Color(0xFFE50914).withValues(alpha: 0.7), size: 15), onPressed: onDelete, padding: const EdgeInsets.all(4)),
        ],
      ),
    );
  }
}

// ── Shared widgets ────────────────────────────────────────────────────────────

class _AddBtn extends StatelessWidget {
  final VoidCallback onTap;
  const _AddBtn({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(color: const Color(0xFFE50914), borderRadius: BorderRadius.circular(10)),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(LucideIcons.plus, color: Colors.white, size: 14),
            SizedBox(width: 6),
            Text('Thêm mới', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}

class _Field extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final int maxLines;
  final TextInputType keyboardType;
  const _Field({required this.label, required this.controller, this.maxLines = 1, this.keyboardType = TextInputType.text});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 12)),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          style: const TextStyle(color: Colors.white, fontSize: 13),
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white.withValues(alpha: 0.06),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.12))),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.12))),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFE50914))),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          ),
        ),
      ],
    );
  }
}

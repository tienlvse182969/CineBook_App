import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:ve_xem_phim/services/api_service.dart';

double _n(dynamic v) {
  if (v == null) return 0;
  if (v is num) return v.toDouble();
  return double.tryParse(v.toString()) ?? 0;
}

int _nInt(dynamic v) {
  if (v == null) return 0;
  if (v is num) return v.toInt();
  return int.tryParse(v.toString().split('.').first) ?? 0;
}

class AdminShowtimesScreen extends StatefulWidget {
  const AdminShowtimesScreen({super.key});

  @override
  State<AdminShowtimesScreen> createState() => _AdminShowtimesScreenState();
}

class _AdminShowtimesScreenState extends State<AdminShowtimesScreen> {
  List<Map<String, dynamic>> _showtimes = [];
  List<Map<String, dynamic>> _movies = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _isLoading = true);
    try {
      final results = await Future.wait([
        ApiService.getAllShowtimes(),
        ApiService.getMovies().then((list) => list.map((m) => {'movie_id': m.id, 'title': m.title}).toList()),
      ]);
      if (mounted) {
        setState(() {
          _showtimes = results[0] as List<Map<String, dynamic>>;
          _movies = results[1] as List<Map<String, dynamic>>;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
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
                      Text(
                        '${_showtimes.length} lịch chiếu',
                        style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 13),
                      ),
                      const Spacer(),
                      _AddButton(
                        label: 'Thêm lịch',
                        onTap: () => _showForm(context, null),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                    itemCount: _showtimes.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 8),
                    itemBuilder: (context, i) => _ShowtimeRow(
                      showtime: _showtimes[i],
                      onEdit: () => _showForm(context, _showtimes[i]),
                      onDelete: () => _confirmDelete(context, _showtimes[i]),
                      onCancel: () => _confirmCancel(context, _showtimes[i]),
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  void _showForm(BuildContext context, Map<String, dynamic>? st) {
    int? selectedMovieId = st != null ? _nInt(st['movie_id']) : null;
    final dateCtrl = TextEditingController(text: st?['start_time']?.toString().substring(0, 10) ?? '');
    final timeCtrl = TextEditingController(text: st?['start_time']?.toString().length != null && st!['start_time'].toString().length >= 16 ? st['start_time'].toString().substring(11, 16) : '');
    final priceCtrl = TextEditingController(text: st?['price']?.toString() ?? '');
    bool saving = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModal) => Container(
          decoration: const BoxDecoration(
            color: Color(0xFF161B22),
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: EdgeInsets.only(
            left: 20, right: 20, top: 20,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2))),
                ),
                const SizedBox(height: 16),
                Text(
                  st == null ? 'Thêm lịch chiếu' : 'Sửa lịch chiếu',
                  style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                Text('Phim *', style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 12)),
                const SizedBox(height: 6),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: DropdownButton<int>(
                    value: selectedMovieId,
                    isExpanded: true,
                    dropdownColor: const Color(0xFF1E2530),
                    underline: const SizedBox(),
                    hint: Text('Chọn phim', style: TextStyle(color: Colors.white.withValues(alpha: 0.4), fontSize: 13)),
                    style: const TextStyle(color: Colors.white, fontSize: 13),
                    items: _movies.map((m) => DropdownMenuItem<int>(
                      value: _nInt(m['movie_id']),
                      child: Text(m['title']?.toString() ?? '', overflow: TextOverflow.ellipsis),
                    )).toList(),
                    onChanged: (v) => setModal(() => selectedMovieId = v),
                  ),
                ),
                const SizedBox(height: 10),
                _FormField(label: 'Ngày chiếu (YYYY-MM-DD) *', controller: dateCtrl, hint: '2025-01-01'),
                const SizedBox(height: 10),
                _FormField(label: 'Giờ chiếu (HH:mm) *', controller: timeCtrl, hint: '19:30'),
                const SizedBox(height: 10),
                _FormField(label: 'Giá vé (VNĐ)', controller: priceCtrl, hint: '100000'),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: saving ? null : () async {
                      if (selectedMovieId == null || dateCtrl.text.isEmpty || timeCtrl.text.isEmpty) return;
                      setModal(() => saving = true);
                      try {
                        final startTime = '${dateCtrl.text.trim()}T${timeCtrl.text.trim()}:00';
                        final body = {
                          'movie_id': selectedMovieId,
                          'start_time': startTime,
                          if (priceCtrl.text.isNotEmpty) 'price': double.tryParse(priceCtrl.text.trim()) ?? 0,
                        };
                        if (st == null) {
                          await ApiService.createShowtime(body);
                        } else {
                          await ApiService.updateShowtime(_nInt(st['showtime_id']), body);
                        }
                        if (ctx.mounted) Navigator.pop(ctx);
                        await _load();
                      } catch (e) {
                        if (ctx.mounted) ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text(e.toString().replaceFirst('Exception: ', '')), backgroundColor: const Color(0xFFE50914)));
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

  void _confirmCancel(BuildContext context, Map<String, dynamic> st) {
    final movie = st['Movie'] as Map? ?? {};
    final title = movie['title']?.toString() ?? 'suất #${st['showtime_id']}';
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF161B22),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Hủy suất chiếu', style: TextStyle(color: Colors.white)),
        content: Text(
          'Hủy "$title"?\n\nTất cả booking của suất này sẽ bị hủy và hoàn tiền cho khách.',
          style: TextStyle(color: Colors.white.withValues(alpha: 0.6)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Không', style: TextStyle(color: Colors.white.withValues(alpha: 0.5))),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                final res = await ApiService.cancelShowtime(_nInt(st['showtime_id']));
                final affected = res['affected'] ?? 0;
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text('Đã hủy suất chiếu · $affected booking bị ảnh hưởng'),
                    backgroundColor: const Color(0xFFF97316),
                  ));
                }
                await _load();
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text(e.toString().replaceFirst('Exception: ', '')),
                    backgroundColor: const Color(0xFFE50914),
                  ));
                }
              }
            },
            child: const Text('Hủy suất', style: TextStyle(color: Color(0xFFF97316))),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, Map<String, dynamic> st) {
    final movie = st['Movie'] as Map? ?? {};
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF161B22),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Xóa lịch chiếu', style: TextStyle(color: Colors.white)),
        content: Text(
          'Xóa lịch chiếu "${movie['title'] ?? st['showtime_id']}"?',
          style: TextStyle(color: Colors.white.withValues(alpha: 0.6)),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text('Hủy', style: TextStyle(color: Colors.white.withValues(alpha: 0.5)))),
          TextButton(
            onPressed: () async {
              try {
                await ApiService.deleteShowtime(_nInt(st['showtime_id']));
                if (ctx.mounted) Navigator.pop(ctx);
                await _load();
              } catch (e) {
                if (ctx.mounted) Navigator.pop(ctx);
                if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString().replaceFirst('Exception: ', '')), backgroundColor: const Color(0xFFE50914)));
              }
            },
            child: const Text('Xóa', style: TextStyle(color: Color(0xFFE50914))),
          ),
        ],
      ),
    );
  }
}

class _ShowtimeRow extends StatelessWidget {
  final Map<String, dynamic> showtime;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onCancel;

  const _ShowtimeRow({required this.showtime, required this.onEdit, required this.onDelete, required this.onCancel});

  String get _formattedTime {
    final raw = showtime['start_time']?.toString() ?? '';
    if (raw.length >= 16) return raw.substring(0, 16).replaceAll('T', ' ');
    return raw;
  }

  @override
  Widget build(BuildContext context) {
    final movie = showtime['Movie'] as Map? ?? {};
    final room = showtime['Room'] as Map? ?? {};
    final price = _n(showtime['price']);

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
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFF3B82F6).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(LucideIcons.calendar, color: Color(0xFF3B82F6), size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  movie['title']?.toString() ?? 'ID ${showtime['showtime_id']}',
                  style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(LucideIcons.clock, size: 11, color: Color(0xFF8B949E)),
                    const SizedBox(width: 4),
                    Text(_formattedTime, style: const TextStyle(color: Color(0xFF8B949E), fontSize: 11)),
                    if (room['room_name'] != null) ...[
                      const SizedBox(width: 8),
                      const Icon(LucideIcons.tv, size: 11, color: Color(0xFF8B949E)),
                      const SizedBox(width: 4),
                      Text(room['room_name'].toString(), style: const TextStyle(color: Color(0xFF8B949E), fontSize: 11)),
                    ],
                  ],
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${(price / 1000).toStringAsFixed(0)}K đ',
                style: const TextStyle(color: Color(0xFF22C55E), fontSize: 13, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  GestureDetector(onTap: onEdit, child: Icon(LucideIcons.pencil, color: Colors.white.withValues(alpha: 0.5), size: 15)),
                  const SizedBox(width: 10),
                  GestureDetector(
                    onTap: onCancel,
                    child: const Icon(LucideIcons.calendarX, color: Color(0xFFF97316), size: 15),
                  ),
                  const SizedBox(width: 10),
                  GestureDetector(onTap: onDelete, child: const Icon(LucideIcons.trash2, color: Color(0xFFEF4444), size: 15)),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AddButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _AddButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFFE50914),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(LucideIcons.plus, color: Colors.white, size: 14),
            const SizedBox(width: 6),
            Text(label, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}

class _FormField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String? hint;
  const _FormField({required this.label, required this.controller, this.hint});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 12)),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          style: const TextStyle(color: Colors.white, fontSize: 13),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.25), fontSize: 13),
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

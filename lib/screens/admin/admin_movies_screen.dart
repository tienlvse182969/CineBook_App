import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:ve_xem_phim/screens/admin/admin_showtimes_screen.dart';
import 'package:ve_xem_phim/screens/admin/admin_snacks_screen.dart';
import 'package:ve_xem_phim/services/api_service.dart';

class AdminMoviesScreen extends StatefulWidget {
  const AdminMoviesScreen({super.key});

  @override
  State<AdminMoviesScreen> createState() => _AdminMoviesScreenState();
}

class _AdminMoviesScreenState extends State<AdminMoviesScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  List<Map<String, dynamic>> _movies = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadMovies();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadMovies() async {
    setState(() => _isLoading = true);
    try {
      final list = await ApiService.getMovies();
      if (mounted) setState(() { _movies = list.map((m) => {'movie_id': m.id, 'title': m.title, 'genre': m.genre, 'status': m.status, 'duration_minutes': 0, 'age_restriction': 0}).toList(); _isLoading = false; });
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildTabBar(),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _MoviesTab(movies: _movies, isLoading: _isLoading, onRefresh: _loadMovies),
              const AdminShowtimesScreen(),
              const AdminSnacksScreen(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTabBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF1C2128),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF30363D)),
        ),
        child: TabBar(
          controller: _tabController,
          indicatorSize: TabBarIndicatorSize.tab,
          indicator: BoxDecoration(
            borderRadius: BorderRadius.circular(9),
            color: const Color(0xFFE50914),
          ),
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white38,
          labelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
          dividerColor: Colors.transparent,
          padding: const EdgeInsets.all(4),
          tabs: const [Tab(text: 'Phim'), Tab(text: 'Lịch chiếu'), Tab(text: 'Đồ ăn')],
        ),
      ),
    );
  }
}

class _MoviesTab extends StatelessWidget {
  final List<Map<String, dynamic>> movies;
  final bool isLoading;
  final Future<void> Function() onRefresh;

  const _MoviesTab({required this.movies, required this.isLoading, required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      color: const Color(0xFFE50914),
      backgroundColor: const Color(0xFF161B22),
      onRefresh: onRefresh,
      child: isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFE50914)))
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 14, 20, 8),
                  child: Row(
                    children: [
                      Text(
                        '${movies.length} phim',
                        style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 13),
                      ),
                      const Spacer(),
                      _AddButton(
                        label: 'Thêm phim',
                        onTap: () => _showMovieForm(context, null, onRefresh),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                    itemCount: movies.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 8),
                    itemBuilder: (context, i) => _MovieRow(
                      movie: movies[i],
                      onEdit: () => _showMovieForm(context, movies[i], onRefresh),
                      onDelete: () => _confirmDelete(context, movies[i], onRefresh),
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  static void _showMovieForm(BuildContext context, Map<String, dynamic>? movie, Future<void> Function() refresh) {
    final titleCtrl = TextEditingController(text: movie?['title']?.toString() ?? '');
    final genreCtrl = TextEditingController(text: movie?['genre']?.toString() ?? '');
    final directorCtrl = TextEditingController(text: movie?['director']?.toString() ?? '');
    final descCtrl = TextEditingController(text: movie?['description']?.toString() ?? '');
    String status = movie?['status']?.toString() ?? 'NOW_SHOWING';
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
                  movie == null ? 'Thêm phim mới' : 'Sửa phim',
                  style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                _FormField(label: 'Tên phim *', controller: titleCtrl),
                const SizedBox(height: 10),
                _FormField(label: 'Thể loại', controller: genreCtrl),
                const SizedBox(height: 10),
                _FormField(label: 'Đạo diễn', controller: directorCtrl),
                const SizedBox(height: 10),
                _FormField(label: 'Mô tả', controller: descCtrl, maxLines: 3),
                const SizedBox(height: 10),
                Text('Trạng thái', style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 12)),
                const SizedBox(height: 6),
                Row(
                  children: ['NOW_SHOWING', 'UPCOMING', 'ENDED'].map((s) {
                    final active = status == s;
                    final labels = {'NOW_SHOWING': 'Đang chiếu', 'UPCOMING': 'Sắp chiếu', 'ENDED': 'Kết thúc'};
                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: GestureDetector(
                          onTap: () => setModal(() => status = s),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            decoration: BoxDecoration(
                              color: active ? const Color(0xFFE50914).withValues(alpha: 0.2) : Colors.white.withValues(alpha: 0.06),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: active ? const Color(0xFFE50914).withValues(alpha: 0.5) : Colors.transparent),
                            ),
                            child: Text(labels[s]!, textAlign: TextAlign.center, style: TextStyle(color: active ? const Color(0xFFE50914) : Colors.white54, fontSize: 11, fontWeight: FontWeight.w600)),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: saving ? null : () async {
                      if (titleCtrl.text.trim().isEmpty) return;
                      setModal(() => saving = true);
                      try {
                        final body = {'title': titleCtrl.text.trim(), 'genre': genreCtrl.text.trim(), 'director': directorCtrl.text.trim(), 'description': descCtrl.text.trim(), 'status': status};
                        if (movie == null) {
                          body['api_movie_id'] = 'manual-${DateTime.now().millisecondsSinceEpoch}';
                          await ApiService.createMovie(body);
                        } else {
                          await ApiService.updateMovie((movie['movie_id'] as num).toInt(), body);
                        }
                        Navigator.pop(ctx);
                        await refresh();
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
                    child: saving ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Text('Lưu', style: TextStyle(fontWeight: FontWeight.w600)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static void _confirmDelete(BuildContext context, Map<String, dynamic> movie, Future<void> Function() refresh) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF161B22),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Xóa phim', style: TextStyle(color: Colors.white)),
        content: Text('Xóa "${movie['title']}"?', style: TextStyle(color: Colors.white.withValues(alpha: 0.6))),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text('Hủy', style: TextStyle(color: Colors.white.withValues(alpha: 0.5)))),
          TextButton(
            onPressed: () async {
              try {
                await ApiService.deleteMovie((movie['movie_id'] as num).toInt());
                Navigator.pop(ctx);
                await refresh();
              } catch (e) {
                Navigator.pop(ctx);
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

class _MovieRow extends StatelessWidget {
  final Map<String, dynamic> movie;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _MovieRow({required this.movie, required this.onEdit, required this.onDelete});

  Color get _statusColor {
    switch (movie['status']) {
      case 'NOW_SHOWING': return const Color(0xFF22C55E);
      case 'UPCOMING':   return const Color(0xFF3B82F6);
      default:           return Colors.white38;
    }
  }

  String get _statusLabel {
    switch (movie['status']) {
      case 'NOW_SHOWING': return 'Đang chiếu';
      case 'UPCOMING':   return 'Sắp chiếu';
      default:           return 'Kết thúc';
    }
  }

  @override
  Widget build(BuildContext context) {
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
              color: const Color(0xFFE50914).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(LucideIcons.film, color: Color(0xFFE50914), size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(movie['title']?.toString() ?? '', style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600), overflow: TextOverflow.ellipsis),
                const SizedBox(height: 4),
                Row(children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(color: _statusColor.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(6)),
                    child: Text(_statusLabel, style: TextStyle(color: _statusColor, fontSize: 10, fontWeight: FontWeight.w600)),
                  ),
                  const SizedBox(width: 6),
                  Text(movie['genre']?.toString() ?? '', style: const TextStyle(color: Color(0xFF8B949E), fontSize: 11), overflow: TextOverflow.ellipsis),
                ]),
              ],
            ),
          ),
          IconButton(icon: Icon(LucideIcons.pencil, color: Colors.white.withValues(alpha: 0.5), size: 16), onPressed: onEdit, padding: const EdgeInsets.all(6)),
          IconButton(icon: Icon(LucideIcons.trash2, color: const Color(0xFFE50914).withValues(alpha: 0.7), size: 16), onPressed: onDelete, padding: const EdgeInsets.all(6)),
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
  final int maxLines;
  const _FormField({required this.label, required this.controller, this.maxLines = 1});

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

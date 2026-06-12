import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:ve_xem_phim/models/movie.dart';
import 'package:ve_xem_phim/screens/booking/seat_selection_screen.dart';
import 'package:ve_xem_phim/widgets/auth_widgets.dart';

class MovieDetailScreen extends StatelessWidget {
  final Movie movie;
  const MovieDetailScreen({super.key, required this.movie});

  Color get _ageColor {
    switch (movie.ageRating) {
      case 'P':   return const Color(0xFF4CAF50);
      case 'K':   return const Color(0xFF2196F3);
      case 'T13': return const Color(0xFFFFC107);
      case 'T16': return const Color(0xFFFF9800);
      case 'T18': return const Color(0xFFF44336);
      default:    return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF080C14),
      body: Stack(
        children: [
          // Background glow orbs
          _buildBgGlow(),
          // Scrollable content
          SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildPoster(context),
                _buildBody(),
              ],
            ),
          ),
          // Floating back button
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: _BackButton(),
            ),
          ),
          // Pinned bottom button
          Positioned(
            bottom: 0, left: 0, right: 0,
            child: _buildBottomBar(context),
          ),
        ],
      ),
    );
  }

  // ── Background ──────────────────────────────────────────────

  Widget _buildBgGlow() {
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
            width: 260,
            height: 260,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: movie.colors.first.withValues(alpha: 0.25),
            ),
          ),
        ),
      ),
      Positioned(
        bottom: 200, left: -80,
        child: ImageFiltered(
          imageFilter: ImageFilter.blur(sigmaX: 50, sigmaY: 50),
          child: Container(
            width: 280,
            height: 280,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: movie.colors.last.withValues(alpha: 0.18),
            ),
          ),
        ),
      ),
    ]);
  }

  // ── Poster / Trailer ─────────────────────────────────────────

  Widget _buildPoster(BuildContext context) {
    return SizedBox(
      height: 320,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Gradient background
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: movie.colors,
              ),
            ),
          ),
          // Decorative circles
          Positioned(
            top: -40, right: -40,
            child: Container(
              width: 220, height: 220,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.05),
              ),
            ),
          ),
          Positioned(
            bottom: 60, left: -60,
            child: Container(
              width: 200, height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.04),
              ),
            ),
          ),
          // Big background icon
          Center(
            child: Icon(LucideIcons.film, size: 130, color: Colors.white.withValues(alpha: 0.07)),
          ),
          // Trailer play button
          Center(
            child: GestureDetector(
              onTap: () => _showTrailerDialog(context),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(50),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                  child: Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.18),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.35), width: 1.5),
                    ),
                    child: const Icon(LucideIcons.play, color: Colors.white, size: 30),
                  ),
                ),
              ),
            ),
          ),
          // "TRAILER" label
          Positioned(
            top: 56,
            left: 0, right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.35),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
                ),
                child: const Text(
                  'TRAILER',
                  style: TextStyle(color: Colors.white70, fontSize: 10, letterSpacing: 2, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ),
          // Rating badge (top right)
          Positioned(
            top: 52, right: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: _ageColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                movie.ageRating,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
              ),
            ),
          ),
          // Bottom fade
          Positioned(
            bottom: 0, left: 0, right: 0,
            child: Container(
              height: 80,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, const Color(0xFF080C14)],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showTrailerDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(children: [
          const Icon(LucideIcons.play, color: Color(0xFFE50914), size: 20),
          const SizedBox(width: 10),
          const Text('Xem trailer', style: TextStyle(color: Colors.white, fontSize: 16)),
        ]),
        content: Text(
          'Trailer của "${movie.title}" sẽ có trong phiên bản tiếp theo.',
          style: const TextStyle(color: Colors.white70, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Đóng', style: TextStyle(color: Color(0xFFE50914))),
          ),
        ],
      ),
    );
  }

  // ── Body ─────────────────────────────────────────────────────

  Widget _buildBody() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Text(
            movie.title,
            style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold, height: 1.2),
          ),
          const SizedBox(height: 10),
          // Genre chips
          _buildGenreChips(),
          const SizedBox(height: 16),
          // Quick info row
          _buildQuickInfo(),
          const SizedBox(height: 20),
          // Description
          _buildSection(
            icon: LucideIcons.alignLeft,
            title: 'Mô tả',
            child: Text(
              movie.description,
              style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 14, height: 1.7),
            ),
          ),
          const SizedBox(height: 16),
          // Age rating
          _buildSection(
            icon: LucideIcons.shieldCheck,
            title: 'Kiểm duyệt độ tuổi',
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                  decoration: BoxDecoration(
                    color: _ageColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: _ageColor.withValues(alpha: 0.5)),
                  ),
                  child: Text(
                    movie.ageRating,
                    style: TextStyle(color: _ageColor, fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    movie.ageRatingDesc,
                    style: TextStyle(color: Colors.white.withValues(alpha: 0.65), fontSize: 13, height: 1.5),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Details grid
          _buildSection(
            icon: LucideIcons.info,
            title: 'Thông tin phim',
            child: Column(
              children: [
                _buildDetailRow(LucideIcons.user, 'Đạo diễn', movie.director),
                const SizedBox(height: 12),
                _buildDetailRow(LucideIcons.globe, 'Ngôn ngữ', movie.language),
                const SizedBox(height: 12),
                _buildDetailRow(LucideIcons.calendar, 'Khởi chiếu', movie.firstShowing),
                const SizedBox(height: 12),
                _buildDetailRow(LucideIcons.clock, 'Thời lượng', movie.duration),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Cast
          _buildSection(
            icon: LucideIcons.users,
            title: 'Diễn viên',
            child: SizedBox(
              height: 96,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: movie.cast.length,
                separatorBuilder: (_, i) => const SizedBox(width: 12),
                itemBuilder: (context, i) => _CastCard(name: movie.cast[i], index: i),
              ),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildGenreChips() {
    final genres = movie.genre.split(' • ');
    return Wrap(
      spacing: 8,
      children: genres.map((g) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
        ),
        child: Text(g, style: TextStyle(color: Colors.white.withValues(alpha: 0.75), fontSize: 12)),
      )).toList(),
    );
  }

  Widget _buildQuickInfo() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.white.withValues(alpha: 0.11)),
          ),
          child: Row(
            children: [
              Expanded(child: _QuickInfoItem(icon: LucideIcons.star, label: 'Đánh giá', value: movie.rating, highlight: true)),
              _divider(),
              Expanded(child: _QuickInfoItem(icon: LucideIcons.clock, label: 'Thời lượng', value: movie.duration)),
              _divider(),
              Expanded(child: _QuickInfoItem(icon: LucideIcons.calendar, label: 'Khởi chiếu', value: movie.year)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _divider() => Container(width: 1, height: 36, color: Colors.white.withValues(alpha: 0.1));

  Widget _buildSection({required IconData icon, required String title, required Widget child}) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Icon(icon, color: const Color(0xFFE50914), size: 16),
            const SizedBox(width: 8),
            Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 15)),
          ]),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: Colors.white38, size: 16),
        const SizedBox(width: 10),
        SizedBox(
          width: 80,
          child: Text(label, style: TextStyle(color: Colors.white.withValues(alpha: 0.45), fontSize: 13)),
        ),
        Expanded(
          child: Text(value, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500)),
        ),
      ],
    );
  }

  Widget _buildBottomBar(BuildContext context) {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: EdgeInsets.fromLTRB(20, 12, 20, MediaQuery.of(context).padding.bottom + 12),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.4),
            border: Border(top: BorderSide(color: Colors.white.withValues(alpha: 0.08))),
          ),
          child: GlassPrimaryButton(
            label: 'Đặt vé ngay',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => SeatSelectionScreen(movie: movie),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Sub-widgets ───────────────────────────────────────────────

class _BackButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
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
    );
  }
}

class _QuickInfoItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool highlight;

  const _QuickInfoItem({
    required this.icon,
    required this.label,
    required this.value,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = highlight ? const Color(0xFFFFB300) : Colors.white;
    return Column(
      children: [
        Icon(icon, color: highlight ? const Color(0xFFFFB300) : Colors.white54, size: 18),
        const SizedBox(height: 6),
        Text(
          value,
          style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 13),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(color: Colors.white.withValues(alpha: 0.4), fontSize: 11),
        ),
      ],
    );
  }
}

class _CastCard extends StatelessWidget {
  final String name;
  final int index;

  const _CastCard({required this.name, required this.index});

  static const _colors = [
    [Color(0xFF1A237E), Color(0xFF4A148C)],
    [Color(0xFF880E4F), Color(0xFF4E342E)],
    [Color(0xFF006064), Color(0xFF1B5E20)],
    [Color(0xFF0D47A1), Color(0xFF311B92)],
    [Color(0xFF37474F), Color(0xFF1A237E)],
  ];

  @override
  Widget build(BuildContext context) {
    final colors = _colors[index % _colors.length];
    final initials = name.split(' ').take(2).map((w) => w[0]).join();
    return Column(
      children: [
        Container(
          width: 60, height: 60,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: colors,
            ),
            border: Border.all(color: Colors.white.withValues(alpha: 0.12), width: 1.5),
          ),
          child: Center(
            child: Text(
              initials,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ),
        ),
        const SizedBox(height: 6),
        SizedBox(
          width: 70,
          child: Text(
            name.split(' ').last,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: Colors.white.withValues(alpha: 0.65), fontSize: 11),
          ),
        ),
      ],
    );
  }
}

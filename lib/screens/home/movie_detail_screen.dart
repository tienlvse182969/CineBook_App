import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:ve_xem_phim/models/movie.dart';
import 'package:ve_xem_phim/models/review.dart';
import 'package:ve_xem_phim/screens/booking/seat_selection_screen.dart';
import 'package:ve_xem_phim/services/api_service.dart';
import 'package:ve_xem_phim/widgets/auth_widgets.dart';

class MovieDetailScreen extends StatefulWidget {
  final Movie movie;
  const MovieDetailScreen({super.key, required this.movie});

  @override
  State<MovieDetailScreen> createState() => _MovieDetailScreenState();
}

class _MovieDetailScreenState extends State<MovieDetailScreen> {
  Movie get movie => widget.movie;

  ReviewSummary? _reviewSummary;
  List<MovieReview> _reviews = [];
  bool _loadingReviews = true;

  @override
  void initState() {
    super.initState();
    _loadReviews();
  }

  Future<void> _loadReviews() async {
    if (movie.id == null) {
      if (mounted) setState(() => _loadingReviews = false);
      return;
    }
    try {
      final json = await ApiService.getMovieReviews(movie.id!);
      if (!mounted) return;
      final summaryJson = json['review_summary'] as Map<String, dynamic>? ?? {};
      final reviewsJson = json['reviews'] as List<dynamic>? ?? [];
      setState(() {
        _reviewSummary = ReviewSummary.fromJson(summaryJson);
        _reviews = reviewsJson
            .map((r) => MovieReview.fromJson(r as Map<String, dynamic>))
            .toList();
        _loadingReviews = false;
      });
    } catch (_) {
      if (mounted) setState(() => _loadingReviews = false);
    }
  }

  Color get _ageColor {
    switch (movie.ageRating) {
      case 'P':
        return const Color(0xFF4CAF50);
      case 'K':
        return const Color(0xFF2196F3);
      case 'T13':
        return const Color(0xFFFFC107);
      case 'T16':
        return const Color(0xFFFF9800);
      case 'T18':
        return const Color(0xFFF44336);
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF080C14),
      body: Stack(
        children: [
          _buildBgGlow(),
          SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [_buildPoster(context), _buildBody(context)],
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: _BackButton(),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _buildBottomBar(context),
          ),
        ],
      ),
    );
  }

  // ── Background ──────────────────────────────────────────────

  Widget _buildBgGlow() {
    return Stack(
      children: [
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
          top: -60,
          right: -60,
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
          bottom: 200,
          left: -80,
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
      ],
    );
  }

  // ── Poster / Trailer ─────────────────────────────────────────

  Widget _buildPoster(BuildContext context) {
    return SizedBox(
      height: 320,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: movie.colors,
              ),
            ),
          ),
          if (movie.posterUrl != null)
            Image.network(
              movie.posterUrl!,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) =>
                  const SizedBox.shrink(),
            ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(
                    alpha: movie.posterUrl == null ? 0.0 : 0.12,
                  ),
                  Colors.black.withValues(alpha: 0.25),
                  const Color(0xFF080C14),
                ],
              ),
            ),
          ),
          Positioned(
            top: -40,
            right: -40,
            child: Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.05),
              ),
            ),
          ),
          Positioned(
            bottom: 60,
            left: -60,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.04),
              ),
            ),
          ),
          if (movie.posterUrl != null)
            Positioned.fill(
              child: Image.network(
                movie.posterUrl!,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => Center(
                  child: Icon(
                    LucideIcons.film,
                    size: 130,
                    color: Colors.white.withValues(alpha: 0.07),
                  ),
                ),
              ),
            )
          else
            Center(
              child: Icon(
                LucideIcons.film,
                size: 130,
                color: Colors.white.withValues(alpha: 0.07),
              ),
            ),
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
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.35),
                        width: 1.5,
                      ),
                    ),
                    child: const Icon(
                      LucideIcons.play,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: 56,
            left: 0,
            right: 0,
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
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 10,
                    letterSpacing: 2,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: 52,
            right: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: _ageColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                movie.ageRating,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
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
        title: Row(
          children: [
            const Icon(LucideIcons.play, color: Color(0xFFE50914), size: 20),
            const SizedBox(width: 10),
            const Text(
              'Xem trailer',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ],
        ),
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

  Widget _buildBody(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            movie.title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.bold,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 10),
          _buildGenreChips(),
          const SizedBox(height: 16),
          _buildQuickInfo(),
          const SizedBox(height: 20),
          _buildSection(
            icon: LucideIcons.alignLeft,
            title: 'Mô tả',
            child: Text(
              movie.description,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.7),
                fontSize: 14,
                height: 1.7,
              ),
            ),
          ),
          const SizedBox(height: 16),
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
                    style: TextStyle(
                      color: _ageColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    movie.ageRatingDesc,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.65),
                      fontSize: 13,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
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
          _buildSection(
            icon: LucideIcons.users,
            title: 'Diễn viên',
            child: SizedBox(
              height: 96,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: movie.cast.length,
                separatorBuilder: (_, i) => const SizedBox(width: 12),
                itemBuilder: (context, i) =>
                    _CastCard(name: movie.cast[i], index: i),
              ),
            ),
          ),
          const SizedBox(height: 16),
          _buildReviewsSection(context),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildGenreChips() {
    final genres = movie.genre.split(' • ');
    return Wrap(
      spacing: 8,
      children: genres
          .map(
            (g) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
              ),
              child: Text(
                g,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.75),
                  fontSize: 12,
                ),
              ),
            ),
          )
          .toList(),
    );
  }

  Widget _buildQuickInfo() {
    final ratingLabel =
        (_reviewSummary != null && _reviewSummary!.reviewCount > 0)
        ? '${_reviewSummary!.averageScore.toStringAsFixed(1)}/5'
        : movie.rating;

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
              Expanded(
                child: _QuickInfoItem(
                  icon: LucideIcons.star,
                  label: 'Đánh giá',
                  value: ratingLabel,
                  highlight: true,
                ),
              ),
              _divider(),
              Expanded(
                child: _QuickInfoItem(
                  icon: LucideIcons.clock,
                  label: 'Thời lượng',
                  value: movie.duration,
                ),
              ),
              _divider(),
              Expanded(
                child: _QuickInfoItem(
                  icon: LucideIcons.calendar,
                  label: 'Khởi chiếu',
                  value: movie.year,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _divider() => Container(
    width: 1,
    height: 36,
    color: Colors.white.withValues(alpha: 0.1),
  );

  Widget _buildSection({
    required IconData icon,
    required String title,
    required Widget child,
  }) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: const Color(0xFFE50914), size: 16),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
            ],
          ),
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
          child: Text(
            label,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.45),
              fontSize: 13,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  // ── Reviews section ──────────────────────────────────────────

  Widget _buildReviewsSection(BuildContext context) {
    return _buildSection(
      icon: LucideIcons.star,
      title: 'Đánh giá người dùng',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (_reviewSummary != null && _reviewSummary!.reviewCount > 0) ...[
                _StarRow(score: _reviewSummary!.averageScore.round()),
                const SizedBox(width: 8),
                Text(
                  '${_reviewSummary!.averageScore.toStringAsFixed(1)} · ${_reviewSummary!.reviewCount} đánh giá',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.5),
                    fontSize: 12,
                  ),
                ),
              ] else if (!_loadingReviews) ...[
                Text(
                  'Chưa có đánh giá',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.3),
                    fontSize: 12,
                  ),
                ),
              ],
              const Spacer(),
              if (ApiService.token != null && movie.id != null)
                GestureDetector(
                  onTap: () => _showReviewDialog(context),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE50914).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: const Color(0xFFE50914).withValues(alpha: 0.35),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(LucideIcons.pencil, size: 11, color: Color(0xFFE50914)),
                        SizedBox(width: 5),
                        Text(
                          'Viết đánh giá',
                          style: TextStyle(
                            color: Color(0xFFE50914),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
          if (_loadingReviews) ...[
            const SizedBox(height: 16),
            const Center(
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Color(0xFFE50914),
              ),
            ),
            const SizedBox(height: 8),
          ] else if (_reviews.isEmpty) ...[
            const SizedBox(height: 14),
            Text(
              'Hãy là người đầu tiên đánh giá phim này!',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.3),
                fontSize: 13,
              ),
            ),
          ] else ...[
            const SizedBox(height: 14),
            ..._reviews.take(5).map(_buildReviewItem),
          ],
        ],
      ),
    );
  }

  Widget _buildReviewItem(MovieReview review) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF1A237E), Color(0xFF880E4F)],
              ),
              border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
            ),
            child: Center(
              child: Text(
                review.initials,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        review.reviewerName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      review.dateLabel,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.3),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                _StarRow(score: review.score),
                if (review.comment != null && review.comment!.isNotEmpty) ...[
                  const SizedBox(height: 5),
                  Text(
                    '"${review.comment}"',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.6),
                      fontSize: 13,
                      fontStyle: FontStyle.italic,
                      height: 1.4,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showReviewDialog(BuildContext context) {
    int selectedScore = 0;
    bool isSubmitting = false;
    final commentCtrl = TextEditingController();

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
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.12),
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color(0xFFFFB300).withValues(alpha: 0.1),
                          ),
                          child: const Icon(
                            LucideIcons.star,
                            color: Color(0xFFFFB300),
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Đánh giá phim',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                movie.title,
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.4),
                                  fontSize: 12,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 22),
                    Text(
                      'Chọn số sao:',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.6),
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(5, (i) {
                        final filled = i < selectedScore;
                        return GestureDetector(
                          onTap: () =>
                              setDialogState(() => selectedScore = i + 1),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 6),
                            child: Icon(
                              LucideIcons.star,
                              size: 38,
                              color: filled
                                  ? const Color(0xFFFFB300)
                                  : Colors.white.withValues(alpha: 0.2),
                            ),
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      'Nhận xét (tùy chọn):',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.6),
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.06),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.12),
                        ),
                      ),
                      child: TextField(
                        controller: commentCtrl,
                        maxLines: 3,
                        maxLength: 1000,
                        style: const TextStyle(color: Colors.white, fontSize: 13),
                        decoration: InputDecoration(
                          hintText: 'Chia sẻ cảm nhận của bạn về phim...',
                          hintStyle: TextStyle(
                            color: Colors.white.withValues(alpha: 0.22),
                            fontSize: 13,
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.all(12),
                          counterStyle: TextStyle(
                            color: Colors.white.withValues(alpha: 0.25),
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed:
                                isSubmitting ? null : () => Navigator.pop(ctx),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.white70,
                              side: BorderSide(
                                color: Colors.white.withValues(alpha: 0.2),
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 13),
                            ),
                            child: const Text('Hủy'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: (isSubmitting || selectedScore == 0)
                                ? null
                                : () async {
                                    setDialogState(() => isSubmitting = true);
                                    try {
                                      await ApiService.submitReview(
                                        movie.id!,
                                        selectedScore,
                                        commentCtrl.text.trim().isEmpty
                                            ? null
                                            : commentCtrl.text.trim(),
                                      );
                                      if (!mounted) return;
                                      Navigator.of(this.context).pop();
                                      ScaffoldMessenger.of(this.context).showSnackBar(
                                        SnackBar(
                                          content: const Text(
                                            'Đã gửi đánh giá thành công',
                                          ),
                                          backgroundColor: const Color(0xFF4CAF50),
                                          behavior: SnackBarBehavior.floating,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          margin: const EdgeInsets.all(16),
                                        ),
                                      );
                                      _loadReviews();
                                    } catch (e) {
                                      setDialogState(() => isSubmitting = false);
                                      if (!mounted) return;
                                      ScaffoldMessenger.of(this.context).showSnackBar(
                                        SnackBar(
                                          content: Text('Lỗi: $e'),
                                          backgroundColor: const Color(0xFFE50914),
                                          behavior: SnackBarBehavior.floating,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          margin: const EdgeInsets.all(16),
                                        ),
                                      );
                                    }
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFE50914),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 13),
                              elevation: 0,
                              disabledBackgroundColor:
                                  const Color(0xFFE50914).withValues(alpha: 0.35),
                            ),
                            child: isSubmitting
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Text(
                                    'Gửi đánh giá',
                                    style: TextStyle(fontWeight: FontWeight.bold),
                                  ),
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
    );
  }

  Widget _buildBottomBar(BuildContext context) {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: EdgeInsets.fromLTRB(
            20,
            12,
            20,
            MediaQuery.of(context).padding.bottom + 12,
          ),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.4),
            border: Border(
              top: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
            ),
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
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.35),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
            ),
            child: const Icon(
              LucideIcons.arrowLeft,
              color: Colors.white,
              size: 20,
            ),
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
        Icon(
          icon,
          color: highlight ? const Color(0xFFFFB300) : Colors.white54,
          size: 18,
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.4),
            fontSize: 11,
          ),
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
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: colors,
            ),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.12),
              width: 1.5,
            ),
          ),
          child: Center(
            child: Text(
              initials,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
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
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.65),
              fontSize: 11,
            ),
          ),
        ),
      ],
    );
  }
}

class _StarRow extends StatelessWidget {
  final int score;
  const _StarRow({required this.score});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(
        5,
        (i) => Icon(
          LucideIcons.star,
          size: 13,
          color: i < score
              ? const Color(0xFFFFB300)
              : Colors.white.withValues(alpha: 0.18),
        ),
      ),
    );
  }
}

import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:ve_xem_phim/models/movie.dart';
import 'package:ve_xem_phim/screens/home/movie_detail_screen.dart';
import 'package:ve_xem_phim/screens/profile/profile_screen.dart';
import 'package:ve_xem_phim/screens/support/support_chat_screen.dart';
import 'package:ve_xem_phim/services/api_service.dart';
import 'package:ve_xem_phim/widgets/auth_widgets.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  List<Movie> _nowShowing = [];
  List<Movie> _upcoming = [];
  bool _isLoading = true;
  Object? _error;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    _loadMovies();
  }

  void _onSearchChanged() {
    setState(() => _searchQuery = _searchController.text.trim().toLowerCase());
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadMovies() async {
    setState(() { _isLoading = true; _error = null; });
    try {
      final results = await Future.wait([
        ApiService.getMovies(status: 'NOW_SHOWING'),
        ApiService.getMovies(status: 'UPCOMING'),
      ]);
      if (!mounted) return;
      setState(() {
        _nowShowing = results[0];
        _upcoming = results[1];
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() { _error = e; _isLoading = false; });
    }
  }

  List<Movie> get _searchResults {
    final all = [..._nowShowing, ..._upcoming];
    if (_searchQuery.isEmpty) return all;
    return all.where((m) =>
      m.title.toLowerCase().contains(_searchQuery) ||
      m.genre.toLowerCase().contains(_searchQuery)
    ).toList();
  }

  @override
  Widget build(BuildContext context) {
    final isSearching = _searchQuery.isNotEmpty;
    final searchResults = isSearching ? _searchResults : <Movie>[];

    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: _buildFab(context),
      body: AuthBackground(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: _buildHeader(context)),
            SliverToBoxAdapter(child: const SizedBox(height: 16)),
            SliverToBoxAdapter(child: _buildSearchBar()),
            SliverToBoxAdapter(child: const SizedBox(height: 20)),
            if (_isLoading)
              const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator(color: Color(0xFFE50914))),
              )
            else if (_error != null)
              SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(LucideIcons.wifiOff, color: Colors.white38, size: 48),
                      const SizedBox(height: 16),
                      const Text(
                        'Không thể tải dữ liệu phim',
                        style: TextStyle(color: Colors.white60, fontSize: 15),
                      ),
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: _loadMovies,
                        child: const Text('Thử lại', style: TextStyle(color: Color(0xFFE50914))),
                      ),
                    ],
                  ),
                ),
              )
            else if (isSearching) ...[
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Text(
                    searchResults.isEmpty
                        ? 'Không tìm thấy phim nào'
                        : 'Kết quả: ${searchResults.length} phim',
                    style: TextStyle(color: Colors.white.withValues(alpha: 0.45), fontSize: 13),
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 14)),
              if (searchResults.isEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 40),
                    child: Column(
                      children: [
                        const Icon(LucideIcons.searchX, color: Colors.white24, size: 52),
                        const SizedBox(height: 14),
                        Text(
                          'Thử tìm tên khác nhé!',
                          style: TextStyle(color: Colors.white38, fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  sliver: SliverGrid(
                    delegate: SliverChildBuilderDelegate(
                      (_, i) => _CompactMovieCard(movie: searchResults[i]),
                      childCount: searchResults.length,
                    ),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 10,
                      childAspectRatio: 0.65,
                    ),
                  ),
                ),
            ] else ...[
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 400,
                  child: _MovieCarousel(movies: _nowShowing),
                ),
              ),
              SliverToBoxAdapter(child: const SizedBox(height: 28)),
              SliverToBoxAdapter(child: _buildSectionHeader('Đang chiếu', LucideIcons.film)),
              SliverToBoxAdapter(child: const SizedBox(height: 14)),
              SliverToBoxAdapter(child: _buildMovieRow(_nowShowing, context)),
              SliverToBoxAdapter(child: const SizedBox(height: 28)),
              SliverToBoxAdapter(child: _buildSectionHeader('Sắp chiếu', LucideIcons.calendar)),
              SliverToBoxAdapter(child: const SizedBox(height: 14)),
              SliverToBoxAdapter(child: _buildMovieRow(_upcoming, context)),
            ],
            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
    );
  }

  Widget _buildFab(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const SupportChatScreen()),
      ),
      child: ClipOval(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFFE50914),
              border: Border.all(color: Colors.white.withValues(alpha: 0.25), width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFE50914).withValues(alpha: 0.5),
                  blurRadius: 24,
                  spreadRadius: 2,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(LucideIcons.headset, color: Colors.white, size: 24),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    LucideIcons.clapperboard,
                    color: Color(0xFFE50914),
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'CineBook',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                'Chào mừng trở lại!',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.45),
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const Spacer(),
          _GlassIconButton(
            icon: LucideIcons.user,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ProfileScreen()),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.07),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.13),
                width: 1.5,
              ),
            ),
            child: TextField(
              controller: _searchController,
              style: const TextStyle(color: Colors.white, fontSize: 14),
              cursorColor: const Color(0xFFE50914),
              decoration: InputDecoration(
                hintText: 'Tìm kiếm phim...',
                hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.3), fontSize: 14),
                prefixIcon: Icon(LucideIcons.search, color: Colors.white.withValues(alpha: 0.35), size: 18),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: Icon(LucideIcons.x, color: Colors.white.withValues(alpha: 0.45), size: 18),
                        onPressed: () => _searchController.clear(),
                      )
                    : null,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFFE50914), size: 18),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMovieRow(List<Movie> movies, BuildContext context) {
    return SizedBox(
      height: 200,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        scrollDirection: Axis.horizontal,
        itemCount: movies.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (_, i) => _CompactMovieCard(movie: movies[i]),
      ),
    );
  }
}

// ── Sub-widgets ───────────────────────────────────────────────

class _GlassIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  const _GlassIconButton({required this.icon, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.07),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withValues(alpha: 0.13)),
            ),
            child: Icon(icon, color: Colors.white70, size: 18),
          ),
        ),
      ),
    );
  }
}

class _MovieCarousel extends StatefulWidget {
  final List<Movie> movies;
  const _MovieCarousel({required this.movies});

  @override
  State<_MovieCarousel> createState() => _MovieCarouselState();
}

class _MovieCarouselState extends State<_MovieCarousel> {
  static const int _virtualMultiplier = 500;
  int _realIndex = 0;
  late final PageController _controller;
  Timer? _timer;

  int get _initialVirtualPage =>
      widget.movies.length * (_virtualMultiplier ~/ 2);

  @override
  void initState() {
    super.initState();
    _controller = PageController(
      viewportFraction: 0.87,
      initialPage: _initialVirtualPage,
    );
    _startAutoScroll();
  }

  void _startAutoScroll() {
    _timer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (!mounted || !_controller.hasClients) return;
      _controller.nextPage(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: PageView.builder(
            controller: _controller,
            itemCount: widget.movies.length * _virtualMultiplier,
            onPageChanged: (i) =>
                setState(() => _realIndex = i % widget.movies.length),
            itemBuilder: (context, i) {
              final idx = i % widget.movies.length;
              return AnimatedScale(
                scale: idx == _realIndex ? 1.0 : 0.94,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOut,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: _MovieCard(movie: widget.movies[idx]),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 14),
        _buildDots(),
      ],
    );
  }

  Widget _buildDots() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(widget.movies.length, (i) {
        final isActive = i == _realIndex;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
          margin: const EdgeInsets.symmetric(horizontal: 3),
          width: isActive ? 22 : 6,
          height: 6,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(3),
            color: isActive
                ? const Color(0xFFE50914)
                : Colors.white.withValues(alpha: 0.22),
          ),
        );
      }),
    );
  }
}

class _MovieCard extends StatelessWidget {
  final Movie movie;
  const _MovieCard({required this.movie});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => MovieDetailScreen(movie: movie)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: movie.colors,
            ),
          ),
          child: Stack(
            children: [
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
                bottom: 140, left: -60,
                child: Container(
                  width: 200, height: 200,
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
                      child: Icon(LucideIcons.film, size: 110, color: Colors.white.withValues(alpha: 0.08)),
                    ),
                  ),
                )
              else
                Center(
                  child: Icon(LucideIcons.film, size: 110, color: Colors.white.withValues(alpha: 0.08)),
                ),
              Positioned(
                bottom: 0, left: 0, right: 0,
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                  ),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
                    child: Container(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.45),
                        border: Border(
                          top: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            movie.title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              height: 1.2,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            movie.genre,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.55),
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 14),
                          Row(
                            children: [
                              Expanded(
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Flexible(
                                      child: _InfoChip(icon: LucideIcons.star, label: movie.rating, highlight: true),
                                    ),
                                    const SizedBox(width: 10),
                                    _InfoChip(icon: LucideIcons.clock, label: movie.duration),
                                    const SizedBox(width: 10),
                                    _InfoChip(icon: LucideIcons.calendar, label: movie.year),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 10),
                              SizedBox(
                                height: 34,
                                child: ElevatedButton(
                                  onPressed: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (_) => MovieDetailScreen(movie: movie)),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFFE50914),
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    elevation: 0,
                                    padding: const EdgeInsets.symmetric(horizontal: 16),
                                  ),
                                  child: const Text(
                                    'Đặt vé',
                                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
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
            ],
          ),
        ),
      ),
    );
  }
}

class _CompactMovieCard extends StatelessWidget {
  final Movie movie;
  const _CompactMovieCard({required this.movie});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => MovieDetailScreen(movie: movie)),
      ),
      child: SizedBox(
        width: 130,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: movie.colors,
              ),
            ),
            child: Stack(
              children: [
                if (movie.posterUrl != null)
                  Positioned.fill(
                    child: Image.network(
                      movie.posterUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => Center(
                        child: Icon(LucideIcons.film, size: 40, color: Colors.white.withValues(alpha: 0.15)),
                      ),
                    ),
                  )
                else
                  Center(
                    child: Icon(LucideIcons.film, size: 40, color: Colors.white.withValues(alpha: 0.15)),
                  ),
                Positioned(
                  bottom: 0, left: 0, right: 0,
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(10, 28, 10, 10),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, Colors.black.withValues(alpha: 0.88)],
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          movie.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            height: 1.3,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 5),
                        Row(
                          children: [
                            const Icon(LucideIcons.star, color: Color(0xFFFFB300), size: 11),
                            const SizedBox(width: 3),
                            Flexible(
                              child: Text(
                                movie.rating,
                                style: const TextStyle(
                                  color: Color(0xFFFFB300),
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool highlight;

  const _InfoChip({
    required this.icon,
    required this.label,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          color: highlight ? const Color(0xFFFFB300) : Colors.white54,
          size: 13,
        ),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            label,
            style: TextStyle(
              color: highlight ? const Color(0xFFFFB300) : Colors.white60,
              fontSize: 12,
              fontWeight: highlight ? FontWeight.w600 : FontWeight.normal,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

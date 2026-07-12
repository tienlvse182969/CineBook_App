import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:ve_xem_phim/models/booking_info.dart';
import 'package:ve_xem_phim/models/movie.dart';
import 'package:ve_xem_phim/models/showtime.dart';
import 'package:ve_xem_phim/screens/booking/snack_screen.dart';
import 'package:ve_xem_phim/services/api_service.dart';
import 'package:ve_xem_phim/widgets/auth_widgets.dart';

enum _SeatType { regular, vip, booked }

class _Seat {
  final int? id;
  final String row;
  final int col;
  final _SeatType type;
  final int price;
  bool isSelected = false;

  _Seat({this.id, required this.row, required this.col, required this.type, required this.price});

  String get label => '$row$col';

}

class SeatSelectionScreen extends StatefulWidget {
  final Movie movie;
  const SeatSelectionScreen({super.key, required this.movie});

  @override
  State<SeatSelectionScreen> createState() => _SeatSelectionScreenState();
}

class _SeatSelectionScreenState extends State<SeatSelectionScreen> {
  static const _cols = 10;
  static const _rowLabels = ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I'];
  static const _vipRows = {'E', 'F', 'G'};

  static const int _weekPageBase = 500;

  late DateTime _todayDate;
  late DateTime _currentWeekMonday;
  late DateTime _selectedDate;
  final PageController _weekPageController = PageController(initialPage: _weekPageBase);
  List<ShowtimeData> _allApiShowtimes = [];
  List<ShowtimeData> _showtimes = [];
  ShowtimeData? _selectedShowtime;
  List<List<_Seat>> _rows = [];
  bool _loadingShowtimes = true;
  bool _loadingSeats = false;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _todayDate = DateTime(now.year, now.month, now.day);
    _currentWeekMonday = _todayDate.subtract(Duration(days: _todayDate.weekday - 1));
    _selectedDate = _todayDate;
    _rows = _buildRows([]);
    _loadApiShowtimes();
  }

  @override
  void dispose() {
    _weekPageController.dispose();
    super.dispose();
  }

  List<DateTime> _datesForWeekPage(int page) {
    final monday = _currentWeekMonday.add(Duration(days: (page - _weekPageBase) * 7));
    return List.generate(7, (i) => monday.add(Duration(days: i)));
  }

  void _jumpToWeekOfDate(DateTime date) {
    final monday = date.subtract(Duration(days: date.weekday - 1));
    final page = _weekPageBase + monday.difference(_currentWeekMonday).inDays ~/ 7;
    if (_weekPageController.hasClients) {
      _weekPageController.jumpToPage(page);
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_weekPageController.hasClients) _weekPageController.jumpToPage(page);
      });
    }
  }

  // ── Seat generation ─────────────────────────────────────────

  List<List<_Seat>> _buildRows(List<String> bookedSeats) {
    final basePrice = _selectedShowtime?.price ?? 75000;
    final bookedSet = bookedSeats.toSet();
    return _rowLabels.map((row) {
      final isVip = _vipRows.contains(row);
      return List.generate(_cols, (ci) {
        final col = ci + 1;
        final label = '$row$col';
        return _Seat(
          row: row, col: col,
          type: bookedSet.contains(label)
              ? _SeatType.booked
              : (isVip ? _SeatType.vip : _SeatType.regular),
          price: bookedSet.contains(label)
              ? 0
              : (isVip ? (basePrice * 1.25).round() : basePrice),
        );
      });
    }).toList();
  }

  List<List<_Seat>> _buildRowsFromApiSeats(List<ApiSeat> seats) {
    final basePrice = _selectedShowtime?.price ?? 75000;
    final byLabel = {for (final seat in seats) seat.label: seat};
    return _rowLabels.map((row) {
      return List.generate(_cols, (ci) {
        final col = ci + 1;
        final label = '$row$col';
        final apiSeat = byLabel[label];
        final type = apiSeat == null ||
                apiSeat.physicalStatus != 'ACTIVE' ||
                apiSeat.bookingStatus == 'BOOKED'
            ? _SeatType.booked
            : (apiSeat.type == 'VIP' || apiSeat.type == 'COUPLE' ? _SeatType.vip : _SeatType.regular);
        return _Seat(
          id: apiSeat?.id,
          row: row,
          col: col,
          type: type,
          price: type == _SeatType.booked
              ? 0
              : (type == _SeatType.vip ? (basePrice * 1.25).round() : basePrice),
        );
      });
    }).toList();
  }

  // ── Selection handlers ──────────────────────────────────────

  void _selectDate(DateTime date) {
    final times = _allApiShowtimes
        .where((t) => _sameDay(t.startTime ?? date, date))
        .toList();
    setState(() {
      _selectedDate = date;
      _showtimes = times;
      _selectedShowtime = times.isEmpty ? null : times[0];
      _rows = _buildRows(times.isEmpty ? [] : times[0].bookedSeats);
    });
    if (_selectedShowtime != null) _loadSeatsForSelected();
  }

  void _selectShowtime(ShowtimeData showtime) {
    setState(() {
      _selectedShowtime = showtime;
      _rows = _buildRows(showtime.bookedSeats);
    });
    _loadSeatsForSelected();
  }

  Future<void> _loadApiShowtimes() async {
    final movieId = widget.movie.id;
    if (movieId == null) {
      setState(() { _loadingShowtimes = false; _hasError = true; });
      return;
    }
    setState(() { _loadingShowtimes = true; _hasError = false; });
    try {
      final times = await ApiService.getShowtimes(movieId: movieId);
      if (!mounted) return;
      final dates = times
          .map((t) => t.startTime)
          .whereType<DateTime>()
          .map((d) => DateTime(d.year, d.month, d.day))
          .toSet()
          .toList()
        ..sort();
      final firstDate = dates.isEmpty ? _selectedDate : dates[0];
      final firstShowtimes = times
          .where((t) => _sameDay(t.startTime ?? firstDate, firstDate))
          .toList();
      setState(() {
        _allApiShowtimes = times;
        _selectedDate = firstDate;
        _showtimes = firstShowtimes;
        _selectedShowtime = firstShowtimes.isEmpty ? null : firstShowtimes[0];
        _loadingShowtimes = false;
      });
      _jumpToWeekOfDate(firstDate);
      if (_selectedShowtime != null) await _loadSeatsForSelected();
    } catch (_) {
      if (mounted) setState(() { _loadingShowtimes = false; _hasError = true; });
    }
  }

  Future<void> _loadSeatsForSelected() async {
    final showtime = _selectedShowtime;
    final showtimeId = showtime?.id;
    if (showtimeId == null) return;
    setState(() => _loadingSeats = true);
    try {
      final seats = await ApiService.getSeats(showtimeId);
      if (!mounted) return;
      setState(() => _rows = _buildRowsFromApiSeats(seats));
    } catch (_) {
      if (mounted) setState(() => _rows = _buildRows(showtime?.bookedSeats ?? []));
    } finally {
      if (mounted) setState(() => _loadingSeats = false);
    }
  }

  void _toggle(_Seat seat) {
    if (seat.type == _SeatType.booked) return;
    setState(() => seat.isSelected = !seat.isSelected);
  }

  // ── Price helpers ───────────────────────────────────────────

  List<_Seat> get _selected =>
      _rows.expand((r) => r).where((s) => s.isSelected).toList();

  int get _totalPrice => _selected.fold(0, (sum, s) => sum + s.price);

  String _fmt(int price) {
    if (price == 0) return '0 đ';
    final s = price.toString();
    final buf = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write('.');
      buf.write(s[i]);
    }
    buf.write(' đ');
    return buf.toString();
  }

  String _priceBreakdown(List<_Seat> seats) {
    final basePrice = _selectedShowtime?.price ?? 75000;
    final regular = seats.where((s) => s.type == _SeatType.regular).length;
    final vip = seats.where((s) => s.type == _SeatType.vip).length;
    final parts = <String>[];
    if (regular > 0) parts.add('$regular × ${_fmt(basePrice)}');
    if (vip > 0) parts.add('$vip × ${_fmt((basePrice * 1.25).round())}');
    return parts.join('  +  ');
  }

  // ── Age confirmation dialog ─────────────────────────────────

  Color get _ageColor {
    switch (widget.movie.ageRating) {
      case 'P':   return const Color(0xFF4CAF50);
      case 'K':   return const Color(0xFF2196F3);
      case 'T13': return const Color(0xFFFFC107);
      case 'T16': return const Color(0xFFFF9800);
      case 'T18': return const Color(0xFFF44336);
      default:    return Colors.grey;
    }
  }

  String get _ageMessage {
    final rating = widget.movie.ageRating;
    if (rating == 'P') {
      return 'Tôi xác nhận mua vé cho người xem thuộc mọi lứa tuổi.';
    }
    final num = rating.replaceAll(RegExp(r'[^0-9]'), '');
    return 'Tôi xác nhận mua vé cho người xem từ đủ $num tuổi trở lên '
        'và đồng ý cung cấp giấy tờ tùy thân để xác thực độ tuổi người xem '
        'theo quy định của Bộ Văn Hóa, Thể Thao Và Du Lịch.';
  }

  void _showAgeDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.65),
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
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
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Icon
                  Container(
                    width: 56, height: 56,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _ageColor.withValues(alpha: 0.12),
                      border: Border.all(color: _ageColor.withValues(alpha: 0.45), width: 1.5),
                    ),
                    child: Icon(LucideIcons.shieldCheck, color: _ageColor, size: 26),
                  ),
                  const SizedBox(height: 16),
                  // Title
                  const Text(
                    'Xác nhận độ tuổi',
                    style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  // Age badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: _ageColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: _ageColor.withValues(alpha: 0.4)),
                    ),
                    child: Text(
                      widget.movie.ageRating,
                      style: TextStyle(color: _ageColor, fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Message
                  Text(
                    _ageMessage,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white.withValues(alpha: 0.65), fontSize: 13, height: 1.65),
                  ),
                  const SizedBox(height: 24),
                  // Buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(ctx),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.white70,
                            side: BorderSide(color: Colors.white.withValues(alpha: 0.2)),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          child: const Text('Hủy bỏ'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(ctx);
                            _navigateToSnacks(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFE50914),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            elevation: 0,
                          ),
                          child: const Text('Xác nhận', style: TextStyle(fontWeight: FontWeight.bold)),
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
    );
  }

  void _navigateToSnacks(BuildContext context) {
    final showtime = _selectedShowtime;
    if (showtime == null) return;
    final selected = _selected;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SnackScreen(
          booking: BookingInfo(
            movie: widget.movie,
            date: _selectedDate,
            showtime: showtime,
            seatLabels: selected.map((s) => s.label).toList(),
            seatIds: selected.map((s) => s.id).whereType<int>().toList(),
            regularCount: selected.where((s) => s.type == _SeatType.regular).length,
            vipCount: selected.where((s) => s.type == _SeatType.vip).length,
            ticketTotal: _totalPrice,
          ),
        ),
      ),
    );
  }

  // ── Date helpers ────────────────────────────────────────────

  static String _weekdayLabel(int wd) {
    const m = {1: 'T2', 2: 'T3', 3: 'T4', 4: 'T5', 5: 'T6', 6: 'T7', 7: 'CN'};
    return m[wd] ?? '';
  }

  static bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  static String _pad2(int n) => n.toString().padLeft(2, '0');

  static String _weekRangeLabel(DateTime start, DateTime end) {
    final startStr = '${_pad2(start.day)}/${_pad2(start.month)}';
    final endStr = '${_pad2(end.day)}/${_pad2(end.month)}/${end.year}';
    return '$startStr - $endStr';
  }

  static Color _dotColor(double fraction) {
    if (fraction > 0.65) return const Color(0xFFFF5252);
    if (fraction > 0.38) return const Color(0xFFFFAB40);
    return const Color(0xFF69F0AE);
  }

  // ── Build ────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF080C14),
      body: Stack(
        children: [
          _buildBg(),
          Column(
            children: [
              SafeArea(bottom: false, child: _buildHeader(context)),
              const SizedBox(height: 14),
              _buildDatePicker(),
              const SizedBox(height: 12),
              _buildShowtimePicker(),
              if (_loadingShowtimes || _loadingSeats)
                const Padding(
                  padding: EdgeInsets.only(top: 8),
                  child: LinearProgressIndicator(color: Color(0xFFE50914), minHeight: 2),
                ),
              const SizedBox(height: 16),
              _buildScreenIndicator(),
              const SizedBox(height: 12),
              _buildLegend(),
              const SizedBox(height: 12),
              Expanded(child: _buildSeatGrid()),
              const SizedBox(height: 130),
            ],
          ),
          Positioned(
            bottom: 0, left: 0, right: 0,
            child: _buildBottomPanel(context),
          ),
        ],
      ),
    );
  }

  // ── Background ──────────────────────────────────────────────

  Widget _buildBg() {
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
            width: 260, height: 260,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: widget.movie.colors.first.withValues(alpha: 0.15),
            ),
          ),
        ),
      ),
      Positioned(
        bottom: 160, left: -80,
        child: ImageFiltered(
          imageFilter: ImageFilter.blur(sigmaX: 50, sigmaY: 50),
          child: Container(
            width: 220, height: 220,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: widget.movie.colors.last.withValues(alpha: 0.1),
            ),
          ),
        ),
      ),
    ]);
  }

  // ── Header ──────────────────────────────────────────────────

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 16, 0),
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
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.movie.title,
                  style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Row(children: [
                  Icon(LucideIcons.clock, color: Colors.white.withValues(alpha: 0.4), size: 11),
                  const SizedBox(width: 4),
                  Text(widget.movie.duration, style: TextStyle(color: Colors.white.withValues(alpha: 0.4), fontSize: 12)),
                ]),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Date picker ─────────────────────────────────────────────

  Widget _buildDatePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 6),
          child: AnimatedBuilder(
            animation: _weekPageController,
            builder: (context, _) {
              final page = _weekPageController.hasClients && _weekPageController.page != null
                  ? _weekPageController.page!.round()
                  : _weekPageBase;
              final dates = _datesForWeekPage(page);
              return Row(children: [
                Icon(LucideIcons.calendarDays, size: 12, color: Colors.white.withValues(alpha: 0.35)),
                const SizedBox(width: 6),
                Text(
                  _weekRangeLabel(dates.first, dates.last),
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.35), fontSize: 11),
                ),
                const Spacer(),
                Icon(LucideIcons.chevronLeft, size: 12, color: Colors.white.withValues(alpha: 0.25)),
                const SizedBox(width: 2),
                Text('Vuốt xem tuần khác', style: TextStyle(color: Colors.white.withValues(alpha: 0.25), fontSize: 10)),
                const SizedBox(width: 2),
                Icon(LucideIcons.chevronRight, size: 12, color: Colors.white.withValues(alpha: 0.25)),
              ]);
            },
          ),
        ),
        SizedBox(
          height: 88,
          child: PageView.builder(
            controller: _weekPageController,
            onPageChanged: (page) => _selectDate(_datesForWeekPage(page)[0]),
            itemBuilder: (context, page) {
              final dates = _datesForWeekPage(page);
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: Row(
                  children: dates.map((date) {
                    final isSelected = _sameDay(date, _selectedDate);
                    final isToday = _sameDay(date, _todayDate);
                    final times = _allApiShowtimes.where((t) => _sameDay(t.startTime ?? date, date)).toList();
                    final avgFraction = times.isEmpty
                        ? 0.2
                        : times.map((t) => t.bookedFraction).fold(0.0, (a, b) => a + b) / times.length;

                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 3),
                        child: GestureDetector(
                          onTap: () => _selectDate(date),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            curve: Curves.easeOut,
                            padding: const EdgeInsets.symmetric(vertical: 9),
                            decoration: BoxDecoration(
                              color: isSelected ? const Color(0xFFE50914) : Colors.white.withValues(alpha: 0.07),
                              borderRadius: BorderRadius.circular(13),
                              border: Border.all(
                                color: isSelected
                                    ? const Color(0xFFE50914)
                                    : isToday
                                        ? Colors.white.withValues(alpha: 0.35)
                                        : Colors.white.withValues(alpha: 0.09),
                                width: isToday && !isSelected ? 1.5 : 1.0,
                              ),
                              boxShadow: isSelected
                                  ? [BoxShadow(color: const Color(0xFFE50914).withValues(alpha: 0.35), blurRadius: 10, spreadRadius: 1)]
                                  : null,
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  isToday ? 'H.nay' : _weekdayLabel(date.weekday),
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: isSelected ? Colors.white : Colors.white.withValues(alpha: 0.45),
                                    fontSize: isToday ? 9 : 10,
                                    fontWeight: FontWeight.w500,
                                    height: 1.2,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${date.day}',
                                  style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold, height: 1),
                                ),
                                const SizedBox(height: 5),
                                Container(
                                  width: 5, height: 5,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: isSelected ? Colors.white.withValues(alpha: 0.65) : _dotColor(avgFraction),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // ── Showtime picker ─────────────────────────────────────────

  Widget _buildShowtimePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
          child: Row(children: [
            Icon(LucideIcons.clapperboard, size: 12, color: Colors.white.withValues(alpha: 0.35)),
            const SizedBox(width: 6),
            Text('Suất chiếu', style: TextStyle(color: Colors.white.withValues(alpha: 0.35), fontSize: 11)),
          ]),
        ),
        SizedBox(
          height: 50,
          child: _showtimes.isEmpty
              ? Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Center(
                    child: Text(
                      _hasError ? 'Không thể tải suất chiếu' : 'Không có suất chiếu cho ngày này',
                      style: TextStyle(color: Colors.white.withValues(alpha: 0.3), fontSize: 12),
                    ),
                  ),
                )
              : ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            itemCount: _showtimes.length,
            separatorBuilder: (_, i) => const SizedBox(width: 8),
            itemBuilder: (context, i) {
              final showtime = _showtimes[i];
              final isSelected = showtime.time == _selectedShowtime?.time && showtime.hall == _selectedShowtime?.hall;
              final isSoldOut = showtime.isSoldOut;
              final dot = _dotColor(showtime.bookedFraction);

              return GestureDetector(
                onTap: isSoldOut ? null : () => _selectShowtime(showtime),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeOut,
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFFE50914)
                        : isSoldOut
                            ? Colors.white.withValues(alpha: 0.03)
                            : Colors.white.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xFFE50914)
                          : isSoldOut
                              ? Colors.white.withValues(alpha: 0.06)
                              : Colors.white.withValues(alpha: 0.13),
                    ),
                    boxShadow: isSelected
                        ? [BoxShadow(color: const Color(0xFFE50914).withValues(alpha: 0.3), blurRadius: 8)]
                        : null,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (!isSoldOut) ...[
                        Container(
                          width: 5, height: 5,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isSelected ? Colors.white.withValues(alpha: 0.7) : dot,
                          ),
                        ),
                        const SizedBox(width: 7),
                      ],
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            showtime.time,
                            style: TextStyle(
                              color: isSelected
                                  ? Colors.white
                                  : isSoldOut
                                      ? Colors.white.withValues(alpha: 0.22)
                                      : Colors.white.withValues(alpha: 0.88),
                              fontSize: 14,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                            ),
                          ),
                          if (isSoldOut)
                            Text('Hết vé', style: TextStyle(color: Colors.white.withValues(alpha: 0.2), fontSize: 9))
                          else
                            Text(
                              showtime.hall,
                              style: TextStyle(
                                color: isSelected
                                    ? Colors.white.withValues(alpha: 0.7)
                                    : Colors.white.withValues(alpha: 0.35),
                                fontSize: 9,
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // ── Screen indicator ────────────────────────────────────────

  Widget _buildScreenIndicator() {
    return Column(children: [
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Container(
          height: 5,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            gradient: LinearGradient(colors: [
              Colors.transparent,
              Colors.white.withValues(alpha: 0.7),
              Colors.transparent,
            ]),
            boxShadow: [BoxShadow(color: Colors.white.withValues(alpha: 0.2), blurRadius: 18, spreadRadius: 3)],
          ),
        ),
      ),
      const SizedBox(height: 8),
      Text('M À N   H Ì N H', style: TextStyle(color: Colors.white.withValues(alpha: 0.28), fontSize: 10, letterSpacing: 2)),
    ]);
  }

  // ── Legend ──────────────────────────────────────────────────

  Widget _buildLegend() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _LegendItem(fill: Colors.white.withValues(alpha: 0.08), border: Colors.white.withValues(alpha: 0.22), label: 'Thường'),
        const SizedBox(width: 14),
        _LegendItem(fill: const Color(0xFFFFC107).withValues(alpha: 0.1), border: const Color(0xFFFFC107).withValues(alpha: 0.6), label: 'VIP', labelColor: const Color(0xFFFFC107)),
        const SizedBox(width: 14),
        _LegendItem(fill: const Color(0xFFE50914).withValues(alpha: 0.85), border: const Color(0xFFE50914), label: 'Đã chọn', labelColor: const Color(0xFFE50914)),
        const SizedBox(width: 14),
        _LegendItem(fill: Colors.white.withValues(alpha: 0.04), border: Colors.white.withValues(alpha: 0.08), label: 'Đã đặt', labelColor: Colors.white.withValues(alpha: 0.28)),
      ],
    );
  }

  // ── Seat grid ───────────────────────────────────────────────

  Widget _buildSeatGrid() {
    const outerPad = 16.0;
    const labelW   = 20.0;
    const labelGap = 8.0;
    const seatGap  = 6.0;
    const aisle    = 16.0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: outerPad),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final seatW = (constraints.maxWidth - labelW - labelGap - _cols * seatGap - aisle) / _cols;
          final seatH = (seatW * 0.82).clamp(18.0, 36.0);

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: _rows
                  .map((row) => _buildSeatRow(row, seatW, seatH, seatGap, aisle, labelW, labelGap))
                  .toList(),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSeatRow(List<_Seat> seats, double seatW, double seatH,
      double seatGap, double aisle, double labelW, double labelGap) {
    final isVip = _vipRows.contains(seats.first.row);
    final half = _cols ~/ 2;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          SizedBox(
            width: labelW,
            child: Text(
              seats.first.row,
              style: TextStyle(
                color: isVip ? const Color(0xFFFFC107).withValues(alpha: 0.8) : Colors.white.withValues(alpha: 0.32),
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          SizedBox(width: labelGap),
          ...seats.sublist(0, half).map((s) => Padding(
            padding: EdgeInsets.symmetric(horizontal: seatGap / 2),
            child: _SeatWidget(seat: s, width: seatW, height: seatH, onTap: () => _toggle(s)),
          )),
          SizedBox(width: aisle),
          ...seats.sublist(half).map((s) => Padding(
            padding: EdgeInsets.symmetric(horizontal: seatGap / 2),
            child: _SeatWidget(seat: s, width: seatW, height: seatH, onTap: () => _toggle(s)),
          )),
        ],
      ),
    );
  }

  // ── Bottom panel ────────────────────────────────────────────

  Widget _buildBottomPanel(BuildContext context) {
    final selected = _selected;
    final hasSelection = selected.isNotEmpty;

    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
        child: Container(
          padding: EdgeInsets.fromLTRB(20, 16, 20, MediaQuery.of(context).padding.bottom + 16),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.55),
            border: Border(top: BorderSide(color: Colors.white.withValues(alpha: 0.08))),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(children: [
                Icon(LucideIcons.calendarCheck, size: 12, color: Colors.white.withValues(alpha: 0.35)),
                const SizedBox(width: 5),
                Text(
                  '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}  ·  ${_selectedShowtime?.time ?? '--:--'}',
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.35), fontSize: 11),
                ),
                if (_selectedShowtime != null) ...[
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.06),
                      borderRadius: BorderRadius.circular(5),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                    ),
                    child: Text(
                      _selectedShowtime!.hall,
                      style: TextStyle(color: Colors.white.withValues(alpha: 0.45), fontSize: 10),
                    ),
                  ),
                ],
              ]),
              const SizedBox(height: 4),
              Row(children: [
                Icon(LucideIcons.ticket, size: 11, color: Colors.white.withValues(alpha: 0.25)),
                const SizedBox(width: 5),
                Text(
                  _selectedShowtime != null
                      ? '${_selectedShowtime!.availableSeats} ghế còn trống'
                      : 'Chưa chọn suất chiếu',
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.28), fontSize: 10),
                ),
              ]),
              const SizedBox(height: 10),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(children: [
                          Icon(LucideIcons.ticket, color: Colors.white.withValues(alpha: 0.38), size: 12),
                          const SizedBox(width: 6),
                          Text(
                            'Ghế đã chọn  •  ${selected.length} ghế',
                            style: TextStyle(color: Colors.white.withValues(alpha: 0.38), fontSize: 11),
                          ),
                        ]),
                        const SizedBox(height: 8),
                        if (hasSelection)
                          Wrap(
                            spacing: 6, runSpacing: 6,
                            children: selected.map((s) => _SeatBadge(seat: s)).toList(),
                          )
                        else
                          Text('Chưa chọn ghế nào', style: TextStyle(color: Colors.white.withValues(alpha: 0.22), fontSize: 13)),
                      ],
                    ),
                  ),
                  const SizedBox(width: 20),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Tổng cộng', style: TextStyle(color: Colors.white.withValues(alpha: 0.38), fontSize: 11)),
                      const SizedBox(height: 4),
                      Text(_fmt(_totalPrice), style: const TextStyle(color: Color(0xFFE50914), fontSize: 22, fontWeight: FontWeight.bold)),
                      if (hasSelection)
                        Text(
                          _priceBreakdown(selected),
                          style: TextStyle(color: Colors.white.withValues(alpha: 0.28), fontSize: 10),
                          textAlign: TextAlign.right,
                        ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 14),
              GlassPrimaryButton(
                label: hasSelection ? 'Xác nhận đặt vé  (${selected.length} ghế)' : 'Chọn ghế để tiếp tục',
                onPressed: hasSelection ? () => _showAgeDialog(context) : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Sub-widgets ─────────────────────────────────────────────────

class _SeatWidget extends StatelessWidget {
  final _Seat seat;
  final double width;
  final double height;
  final VoidCallback onTap;

  const _SeatWidget({required this.seat, required this.width, required this.height, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final Color fill;
    final Color border;

    if (seat.isSelected) {
      fill = const Color(0xFFE50914).withValues(alpha: 0.85);
      border = const Color(0xFFE50914);
    } else if (seat.type == _SeatType.booked) {
      fill = Colors.white.withValues(alpha: 0.04);
      border = Colors.white.withValues(alpha: 0.08);
    } else if (seat.type == _SeatType.vip) {
      fill = const Color(0xFFFFC107).withValues(alpha: 0.1);
      border = const Color(0xFFFFC107).withValues(alpha: 0.6);
    } else {
      fill = Colors.white.withValues(alpha: 0.08);
      border = Colors.white.withValues(alpha: 0.22);
    }

    final radius = (width * 0.22).clamp(3.0, 8.0);

    return GestureDetector(
      onTap: seat.type == _SeatType.booked ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: width, height: height,
        decoration: BoxDecoration(
          color: fill,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(radius), topRight: Radius.circular(radius),
            bottomLeft: Radius.circular(radius * 0.4), bottomRight: Radius.circular(radius * 0.4),
          ),
          border: Border.all(color: border, width: 1.2),
          boxShadow: seat.isSelected
              ? [BoxShadow(color: const Color(0xFFE50914).withValues(alpha: 0.4), blurRadius: 6)]
              : null,
        ),
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color fill;
  final Color border;
  final String label;
  final Color? labelColor;

  const _LegendItem({required this.fill, required this.border, required this.label, this.labelColor});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 16, height: 13,
          decoration: BoxDecoration(
            color: fill,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(4), topRight: Radius.circular(4),
              bottomLeft: Radius.circular(2), bottomRight: Radius.circular(2),
            ),
            border: Border.all(color: border, width: 1.2),
          ),
        ),
        const SizedBox(width: 5),
        Text(label, style: TextStyle(color: labelColor ?? Colors.white.withValues(alpha: 0.5), fontSize: 11)),
      ],
    );
  }
}

class _SeatBadge extends StatelessWidget {
  final _Seat seat;
  const _SeatBadge({required this.seat});

  @override
  Widget build(BuildContext context) {
    final isVip = seat.type == _SeatType.vip;
    final color = isVip ? const Color(0xFFFFC107) : const Color(0xFFE50914);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.45)),
      ),
      child: Text(seat.label, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600)),
    );
  }
}

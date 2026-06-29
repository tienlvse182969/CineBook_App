import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:ve_xem_phim/models/booking_record.dart';
import 'package:ve_xem_phim/models/movie.dart';
import 'package:ve_xem_phim/models/showtime.dart';
import 'package:ve_xem_phim/models/snack.dart';
import 'package:ve_xem_phim/models/user_profile.dart';

class ApiService {
  ApiService._();

  static String get baseUrl {
    const env = String.fromEnvironment('API_BASE_URL', defaultValue: '');
    if (env.isNotEmpty) return env;
    // Web (Chrome/Edge) dùng localhost, Android emulator dùng 10.0.2.2
    return kIsWeb ? 'http://localhost:3000' : 'http://10.0.2.2:3000';
  }

  static String? token;
  static String? userRole;
  static UserProfile? currentUser;

  static Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    if (token != null) 'Authorization': 'Bearer $token',
  };

  // ─── Auth ───────────────────────────────────────────────────────────────────

  static Future<String> login(String email, String password) async {
    final json = await _postJson(Uri.parse('$baseUrl/api/auth/login'), {
      'email': email,
      'password': password,
    });
    token = json['token']?.toString();
    userRole = (json['user']?['role']?.toString() ?? 'user').toUpperCase();
    return userRole!;
  }

  static Future<void> requestRegistrationOtp(String email) =>
      _postJson(Uri.parse('$baseUrl/api/auth/register/request-otp'), {'email': email});

  static Future<void> register({
    required String fullName,
    required String email,
    required String phone,
    required String password,
    required DateTime dateOfBirth,
    required String otp,
  }) async {
    final json = await _postJson(Uri.parse('$baseUrl/api/auth/register'), {
      'full_name': fullName,
      'email': email,
      'phone': phone.isEmpty ? null : phone,
      'password': password,
      'date_of_birth': _dateOnly(dateOfBirth),
      'otp': otp,
    });
    token = json['token']?.toString();
    userRole = json['user']?['role']?.toString() ?? 'USER';
  }

  static void logout() {
    token = null;
    userRole = null;
  }

  // ─── Movies ─────────────────────────────────────────────────────────────────

  static Future<List<Movie>> getMovies({String? status}) async {
    final uri = Uri.parse(
      '$baseUrl/api/movies',
    ).replace(queryParameters: status == null ? null : {'status': status});
    final data = await _getList(uri);
    return data.map((item) => Movie.fromJson(item)).toList();
  }

  static Future<Map<String, dynamic>> createMovie(Map<String, dynamic> body) =>
      _postJson(Uri.parse('$baseUrl/api/movies'), body);

  static Future<Map<String, dynamic>> updateMovie(int id, Map<String, dynamic> body) =>
      _putJson(Uri.parse('$baseUrl/api/movies/$id'), body);

  static Future<void> deleteMovie(int id) =>
      _delete(Uri.parse('$baseUrl/api/movies/$id'));

  // ─── Showtimes ──────────────────────────────────────────────────────────────

  static Future<List<ShowtimeData>> getShowtimes({required int movieId}) async {
    final uri = Uri.parse(
      '$baseUrl/api/showtimes',
    ).replace(queryParameters: {'movie_id': '$movieId'});
    final data = await _getList(uri);
    return data.map((item) => ShowtimeData.fromJson(item)).toList();
  }

  static Future<List<Map<String, dynamic>>> getAllShowtimes() async {
    final data = await _getList(Uri.parse('$baseUrl/api/showtimes'));
    return data;
  }

  static Future<ShowtimeData> getShowtimeWithSeats(ShowtimeData showtime) async {
    if (showtime.id == null) return showtime;
    final uri = Uri.parse('$baseUrl/api/showtimes/${showtime.id}/seats');
    final data = await _getList(uri);
    final booked = data
        .where((seat) => seat['booking_status'] == 'BOOKED')
        .map((seat) => '${seat['row_name']}${seat['seat_number']}')
        .toList();
    return showtime.copyWithBookedSeats(booked);
  }

  static Future<List<ApiSeat>> getSeats(int showtimeId) async {
    final uri = Uri.parse('$baseUrl/api/showtimes/$showtimeId/seats');
    final data = await _getList(uri);
    return data.map(ApiSeat.fromJson).toList();
  }

  static Future<Map<String, dynamic>> createShowtime(Map<String, dynamic> body) =>
      _postJson(Uri.parse('$baseUrl/api/showtimes'), body);

  static Future<Map<String, dynamic>> updateShowtime(int id, Map<String, dynamic> body) =>
      _putJson(Uri.parse('$baseUrl/api/showtimes/$id'), body);

  static Future<void> deleteShowtime(int id) =>
      _delete(Uri.parse('$baseUrl/api/showtimes/$id'));

  // ─── Snacks ─────────────────────────────────────────────────────────────────

  static Future<List<SnackCategory>> getSnackCategories() async {
    final data = await _getList(
      Uri.parse('$baseUrl/api/snacks?status=AVAILABLE'),
    );
    final items = data
        .map(SnackItem.fromJson)
        .where((item) => item.id > 0)
        .toList();
    final groups = <String, List<SnackItem>>{};
    for (final item in items) {
      groups.putIfAbsent(_categoryName(item.type), () => []).add(item);
    }
    return groups.entries
        .map((entry) => SnackCategory(name: entry.key, items: entry.value))
        .toList();
  }

  static Future<List<Map<String, dynamic>>> getAllSnacks() =>
      _getList(Uri.parse('$baseUrl/api/snacks'));

  static Future<Map<String, dynamic>> createSnack(Map<String, dynamic> body) =>
      _postJson(Uri.parse('$baseUrl/api/snacks'), body);

  static Future<Map<String, dynamic>> updateSnack(int id, Map<String, dynamic> body) =>
      _putJson(Uri.parse('$baseUrl/api/snacks/$id'), body);

  static Future<void> deleteSnack(int id) =>
      _delete(Uri.parse('$baseUrl/api/snacks/$id'));

  static Future<List<BookingRecord>> getMyBookings() async {
    final data = await _getList(Uri.parse('$baseUrl/api/bookings/my'));
    return data.map(BookingRecord.fromJson).toList();
  }

  static Future<Map<String, dynamic>> createBooking({
    required int showtimeId,
    required List<int> seatIds,
    required Map<int, int> snackQty,
    required String paymentMethod,
  }) {
    final snacks = snackQty.entries
        .where((entry) => entry.value > 0)
        .map((entry) => {'snack_id': entry.key, 'quantity': entry.value})
        .toList();
    return _postJson(Uri.parse('$baseUrl/api/bookings'), {
      'showtime_id': showtimeId,
      'seat_ids': seatIds,
      'snacks': snacks,
      'payment_method': paymentMethod,
    });
  }

  // ─── Admin ──────────────────────────────────────────────────────────────────

  static Future<Map<String, dynamic>> getAdminStats() =>
      _getMap(Uri.parse('$baseUrl/api/admin/stats'));

  static Future<Map<String, dynamic>> getBookingAnalytics() =>
      _getMap(Uri.parse('$baseUrl/api/admin/bookings/analytics'));

  static Future<Map<String, dynamic>> getAdminBookings({int page = 1, String? status, String? dateRange}) async {
    final params = <String, String>{'page': '$page', 'limit': '15'};
    if (status != null) params['status'] = status;
    if (dateRange != null) params['date_range'] = dateRange;
    final uri = Uri.parse('$baseUrl/api/admin/bookings').replace(queryParameters: params);
    return _getMap(uri);
  }

  static Future<void> cancelBooking(int bookingId) =>
      _patchJson(Uri.parse('$baseUrl/api/admin/bookings/$bookingId/cancel'), {});

  static Future<Map<String, dynamic>> cancelShowtime(int showtimeId) async {
    final response = await http.patch(
      Uri.parse('$baseUrl/api/admin/showtimes/$showtimeId/cancel'),
      headers: _headers,
      body: jsonEncode({}),
    );
    final body = _decode(response);
    return body is Map<String, dynamic> ? body : {};
  }

  static Future<Map<String, dynamic>> getRevenueReport({
    String period = 'month',
    int? year,
    int? month,
    int? quarter,
  }) async {
    final params = <String, String>{'period': period};
    if (year != null) params['year'] = '$year';
    if (month != null) params['month'] = '$month';
    if (quarter != null) params['quarter'] = '$quarter';
    final uri = Uri.parse('$baseUrl/api/admin/revenue').replace(queryParameters: params);
    return _getMap(uri);
  }

  static Future<Map<String, dynamic>> getAdminUsers({int page = 1, String? search}) async {
    final params = <String, String>{'page': '$page', 'limit': '15'};
    if (search != null && search.isNotEmpty) params['search'] = search;
    final uri = Uri.parse('$baseUrl/api/admin/users').replace(queryParameters: params);
    return _getMap(uri);
  }

  static Future<void> toggleUserStatus(int userId) =>
      _patchJson(Uri.parse('$baseUrl/api/admin/users/$userId/status'), {});

  static Future<List<Map<String, dynamic>>> getAdminRooms() =>
      _getList(Uri.parse('$baseUrl/api/admin/rooms'));

  static Future<void> toggleSeatStatus(int seatId) =>
      _patchJson(Uri.parse('$baseUrl/api/admin/seats/$seatId/status'), {});

  // ─── HTTP helpers ───────────────────────────────────────────────────────────

  static Future<List<Map<String, dynamic>>> _getList(Uri uri) async {
    final response = await http.get(uri, headers: _headers);
    final json = _decode(response);
    if (json is List) return json.cast<Map<String, dynamic>>();
    throw Exception('Unexpected response from $uri');
  }

  static Future<Map<String, dynamic>> _getMap(Uri uri) async {
    final response = await http.get(uri, headers: _headers);
    final json = _decode(response);
    if (json is Map<String, dynamic>) return json;
    throw Exception('Unexpected response from $uri');
  }

  static Future<Map<String, dynamic>> _postJson(
    Uri uri,
    Map<String, dynamic> body,
  ) async {
    final response = await http.post(
      uri,
      headers: _headers,
      body: jsonEncode(body),
    );
    final json = _decode(response);
    if (json is Map<String, dynamic>) return json;
    throw Exception('Unexpected response from $uri');
  }

  static Future<Map<String, dynamic>> _putJson(Uri uri, Map<String, dynamic> body) async {
    final response = await http.put(uri, headers: _headers, body: jsonEncode(body));
    final json = _decode(response);
    if (json is Map<String, dynamic>) return json;
    throw Exception('Unexpected response from $uri');
  }

  static Future<void> _patchJson(Uri uri, Map<String, dynamic> body) async {
    final response = await http.patch(uri, headers: _headers, body: jsonEncode(body));
    if (response.statusCode < 200 || response.statusCode >= 300) {
      final decoded = response.body.isEmpty ? null : jsonDecode(response.body);
      if (decoded is Map && decoded['message'] != null) throw Exception(decoded['message']);
      throw Exception('HTTP ${response.statusCode}');
    }
  }

  static Future<void> _delete(Uri uri) async {
    final response = await http.delete(uri, headers: _headers);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      final decoded = response.body.isEmpty ? null : jsonDecode(response.body);
      if (decoded is Map && decoded['message'] != null) throw Exception(decoded['message']);
      throw Exception('HTTP ${response.statusCode}');
    }
  }

  static dynamic _decode(http.Response response) {
    final body = response.body.isEmpty ? null : jsonDecode(response.body);
    if (response.statusCode >= 200 && response.statusCode < 300) return body;
    if (body is Map && body['message'] != null) throw Exception(body['message']);
    throw Exception('HTTP ${response.statusCode}');
  }

  static String _categoryName(String type) {
    switch (type) {
      case 'POPCORN':
        return 'Bắp rang';
      case 'COMBO':
        return 'Combo tiết kiệm';
      case 'DRINK':
        return 'Nước uống';
      default:
        return 'Đồ ăn vặt';
    }
  }

  static String _dateOnly(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
}

class ApiSeat {
  final int id;
  final String label;
  final String type;
  final String physicalStatus;
  final String bookingStatus;

  const ApiSeat({
    required this.id,
    required this.label,
    required this.type,
    required this.physicalStatus,
    required this.bookingStatus,
  });

  factory ApiSeat.fromJson(Map<String, dynamic> json) => ApiSeat(
    id: (json['seat_id'] as num?)?.toInt() ?? 0,
    label: '${json['row_name']}${json['seat_number']}',
    type: json['type']?.toString() ?? 'STANDARD',
    physicalStatus: json['physical_status']?.toString() ?? 'ACTIVE',
    bookingStatus: json['booking_status']?.toString() ?? 'AVAILABLE',
  );
}

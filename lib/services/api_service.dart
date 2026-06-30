import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:ve_xem_phim/models/booking_record.dart';
import 'package:ve_xem_phim/models/movie.dart';
import 'package:ve_xem_phim/models/showtime.dart';
import 'package:ve_xem_phim/models/snack.dart';
import 'package:ve_xem_phim/models/user_profile.dart';

class ApiService {
  ApiService._();

  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:3000',
  );

  static String? token;
  static UserProfile? currentUser;

  static Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    if (token != null) 'Authorization': 'Bearer $token',
  };

  static Future<List<Movie>> getMovies({String? status}) async {
    final uri = Uri.parse(
      '$baseUrl/api/movies',
    ).replace(queryParameters: status == null ? null : {'status': status});
    final data = await _getList(uri);
    return data.map((item) => Movie.fromJson(item)).toList();
  }

  static Future<List<ShowtimeData>> getShowtimes({required int movieId}) async {
    final uri = Uri.parse(
      '$baseUrl/api/showtimes',
    ).replace(queryParameters: {'movie_id': '$movieId'});
    final data = await _getList(uri);
    return data.map((item) => ShowtimeData.fromJson(item)).toList();
  }

  static Future<ShowtimeData> getShowtimeWithSeats(
    ShowtimeData showtime,
  ) async {
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

  static Future<void> login(String email, String password) async {
    final json = await _postJson(Uri.parse('$baseUrl/api/auth/login'), {
      'email': email,
      'password': password,
    });
    token = json['token']?.toString();
    final userJson = json['user'];
    if (userJson is Map<String, dynamic>) {
      currentUser = UserProfile.fromJson(userJson);
    }
  }

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
    final userJson2 = json['user'];
    if (userJson2 is Map<String, dynamic>) {
      currentUser = UserProfile.fromJson(userJson2);
    }
  }

  static Future<void> requestRegistrationOtp(String email) async {
    await _postJson(Uri.parse('$baseUrl/api/auth/register/request-otp'), {
      'email': email.trim(),
    });
  }

  static Future<List<BookingRecord>> getMyBookings() async {
    final data = await _getList(Uri.parse('$baseUrl/api/bookings/me'));
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

  /// Khởi tạo giao dịch thanh toán cho [bookingId] với một cổng cụ thể
  /// (ví dụ 'MOMO'). Trả về `data` chứa orderId, payUrl, deeplink...
  static Future<Map<String, dynamic>> createPayment({
    required int bookingId,
    required String paymentMethod,
  }) async {
    final json = await _postJson(Uri.parse('$baseUrl/api/payments/create'), {
      'bookingId': bookingId,
      'paymentMethod': paymentMethod,
    });
    final data = json['data'];
    if (data is Map<String, dynamic>) return data;
    throw Exception('Phản hồi khởi tạo thanh toán không hợp lệ');
  }

  /// Lấy trạng thái thanh toán theo orderId.
  /// Trả về map gồm `payment_status` và `booking_status`.
  static Future<Map<String, dynamic>> getPaymentStatus(String orderId) async {
    final json = await _getJson(
      Uri.parse('$baseUrl/api/payments/status/$orderId'),
    );
    final data = json['data'];
    if (data is Map<String, dynamic>) return data;
    throw Exception('Không lấy được trạng thái thanh toán');
  }

  static Future<Map<String, dynamic>> _getJson(Uri uri) async {
    final response = await http.get(uri, headers: _headers);
    final json = _decode(response);
    if (json is Map<String, dynamic>) return json;
    throw Exception('Unexpected response from $uri');
  }

  static Future<List<Map<String, dynamic>>> _getList(Uri uri) async {
    final response = await http.get(uri, headers: _headers);
    final json = _decode(response);
    if (json is List) {
      return json.cast<Map<String, dynamic>>();
    }
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

  static dynamic _decode(http.Response response) {
    final body = response.body.isEmpty ? null : jsonDecode(response.body);
    if (response.statusCode >= 200 && response.statusCode < 300) return body;
    if (body is Map && body['message'] != null) {
      throw Exception(body['message']);
    }
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

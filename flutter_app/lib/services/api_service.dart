import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user.dart';
import '../models/listing.dart';
import '../models/booking.dart';
import '../models/payment_result.dart';

class ApiService {
  static const String baseUrl = 'http://192.168.8.41/Nalivata%20-%20Server';
  
  String? _token;

  void setToken(String? token) {
    _token = token;
  }

  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    if (_token != null) 'Authorization': 'Bearer $_token',
  };

  Future<Map<String, dynamic>> signup(String name, String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/routes/api.php?api=signup'),
        headers: _headers,
        body: jsonEncode({
          'name': name,
          'email': email,
          'password': password,
        }),
      ).timeout(const Duration(seconds: 10));

      final responseBody = response.body;
      if (responseBody.isEmpty) {
        return {'status': 'error', 'message': 'Empty response from server'};
      }

      final decoded = jsonDecode(responseBody);
      return decoded;
    } catch (e) {
      return {'status': 'error', 'message': 'Network error: $e'};
    }
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/routes/api.php?api=login'),
        headers: _headers,
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      return jsonDecode(response.body);
    } catch (e) {
      return {'status': 'error', 'message': 'Network error: $e'};
    }
  }

  Future<Map<String, dynamic>> getCurrentUser() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/routes/api.php?api=user'),
        headers: _headers,
      );

      return jsonDecode(response.body);
    } catch (e) {
      return {'status': 'error', 'message': 'Network error: $e'};
    }
  }

  Future<List<Listing>> searchListings({
    String? type,
    String? location,
    double? minPrice,
    double? maxPrice,
    double? minRating,
    String? checkIn,
    String? checkOut,
  }) async {
    try {
      final queryParams = <String, String>{};
      queryParams['api'] = 'search';
      if (type != null) queryParams['type'] = type;
      if (location != null) queryParams['location'] = location;
      if (minPrice != null) queryParams['min_price'] = minPrice.toString();
      if (maxPrice != null) queryParams['max_price'] = maxPrice.toString();
      if (minRating != null) queryParams['min_rating'] = minRating.toString();
      if (checkIn != null) queryParams['check_in'] = checkIn;
      if (checkOut != null) queryParams['check_out'] = checkOut;

      final uri = Uri.parse('$baseUrl/routes/api.php').replace(queryParameters: queryParams);
      final response = await http.get(uri, headers: _headers).timeout(const Duration(seconds: 10));

      if (response.statusCode != 200) {
        print('API Error: Status ${response.statusCode}');
        return [];
      }

      final responseBody = response.body;
      if (responseBody.isEmpty) {
        print('API Error: Empty response');
        return [];
      }

      final data = jsonDecode(responseBody);
      if (data['status'] == 'success' && data['data'] != null) {
        return (data['data'] as List)
            .map((item) => Listing.fromJson(item))
            .toList();
      } else {
        print('API Error: ${data['message'] ?? 'Unknown error'}');
      }
      return [];
    } catch (e) {
      print('API Exception: $e');
      return [];
    }
  }

  Future<Listing?> getListingDetails(int id) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/routes/api.php?api=get_listing_details&id=$id'),
        headers: _headers,
      );

      final data = jsonDecode(response.body);
      if (data['status'] == 'success') {
        return Listing.fromJson(data['data']);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<Map<String, dynamic>> createBooking({
    required int listingId,
    required String checkIn,
    required String checkOut,
    required int guests,
  }) async {
    try {
      print('Creating booking with token: ${_token != null ? "Present" : "Missing"}');
      print('Headers: $_headers');
      
      final response = await http.post(
        Uri.parse('$baseUrl/routes/api.php?api=create_booking'),
        headers: _headers,
        body: jsonEncode({
          'listing_id': listingId,
          'check_in': checkIn,
          'check_out': checkOut,
          'guests': guests,
        }),
      ).timeout(const Duration(seconds: 30));

      print('Booking response status: ${response.statusCode}');
      print('Booking response body: ${response.body}');

      final data = jsonDecode(response.body);
      
      if (response.statusCode == 401) {
        return {
          'status': 'error',
          'message': 'Unauthorized - Please login again',
        };
      }
      
      return data;
    } catch (e) {
      print('Booking error: $e');
      return {'status': 'error', 'message': 'Network error: $e'};
    }
  }

  Future<List<Booking>> getMyBookings() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/routes/api.php?api=my_bookings'),
        headers: _headers,
      );

      final data = jsonDecode(response.body);
      if (data['status'] == 'success') {
        return (data['data'] as List)
            .map((item) => Booking.fromJson(item))
            .toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<Booking?> getBookingDetails(String bookingReference) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/routes/api.php?api=get_booking_details&reference=$bookingReference'),
        headers: _headers,
      );

      final data = jsonDecode(response.body);
      if (data['status'] == 'success') {
        return Booking.fromJson(data['data']);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<Map<String, dynamic>> cancelBooking(String bookingReference) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/routes/api.php?api=cancel_booking'),
        headers: _headers,
        body: jsonEncode({
          'booking_reference': bookingReference,
        }),
      );

      return jsonDecode(response.body);
    } catch (e) {
      return {'status': 'error', 'message': 'Network error: $e'};
    }
  }

  Future<PaymentResult> simulatePayment({
    required String bookingReference,
    required String paymentMethod,
  }) async {
    try {
      await Future.delayed(const Duration(seconds: 3));

      final response = await http.post(
        Uri.parse('$baseUrl/routes/api.php?api=pay_simulated'),
        headers: _headers,
        body: jsonEncode({
          'booking_reference': bookingReference,
          'payment_method': paymentMethod,
        }),
      );

      final data = jsonDecode(response.body);
      return PaymentResult.fromJson(data);
    } catch (e) {
      return PaymentResult(
        status: 'error',
        message: 'Network error: $e',
      );
    }
  }
}


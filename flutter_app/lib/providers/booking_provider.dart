import 'package:flutter/foundation.dart';
import '../models/booking.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';

class BookingProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  final AuthService _authService = AuthService();
  List<Booking> _bookings = [];
  Booking? _selectedBooking;
  bool _isLoading = false;

  List<Booking> get bookings => _bookings;
  Booking? get selectedBooking => _selectedBooking;
  bool get isLoading => _isLoading;

  Future<Map<String, dynamic>> createBooking({
    required int listingId,
    required String checkIn,
    required String checkOut,
    required int guests,
    String? token, // Optional token parameter
  }) async {
    _isLoading = true;
    notifyListeners();

    String? authToken = token;
    if (authToken == null) {
      await _authService.loadSavedAuth();
      authToken = _authService.token;
    }
    
    if (authToken == null || authToken.isEmpty) {
      _isLoading = false;
      notifyListeners();
      return {
        'status': 'error',
        'message': 'Unauthorized - Please login again',
      };
    }
    
    _apiService.setToken(authToken);
    print('BookingProvider: Token set for booking creation - ${authToken.substring(0, authToken.length > 20 ? 20 : authToken.length)}...');

    final result = await _apiService.createBooking(
      listingId: listingId,
      checkIn: checkIn,
      checkOut: checkOut,
      guests: guests,
    );

    _isLoading = false;
    notifyListeners();
    return result;
  }

  Future<void> loadMyBookings() async {
    _isLoading = true;
    notifyListeners();

    final token = _authService.token;
    if (token != null) {
      _apiService.setToken(token);
    }

    _bookings = await _apiService.getMyBookings();

    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadBookingDetails(String bookingReference) async {
    _isLoading = true;
    notifyListeners();

    final token = _authService.token;
    if (token != null) {
      _apiService.setToken(token);
    }

    _selectedBooking = await _apiService.getBookingDetails(bookingReference);

    _isLoading = false;
    notifyListeners();
  }

  Future<Map<String, dynamic>> cancelBooking(String bookingReference) async {
    _isLoading = true;
    notifyListeners();

    final token = _authService.token;
    if (token != null) {
      _apiService.setToken(token);
    }

    final result = await _apiService.cancelBooking(bookingReference);
    
    if (result['status'] == 'success') {
      await loadMyBookings();
    }

    _isLoading = false;
    notifyListeners();
    return result;
  }
}


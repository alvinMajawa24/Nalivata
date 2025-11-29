import 'package:flutter/foundation.dart';
import '../models/listing.dart';
import '../services/api_service.dart';

class ListingProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  List<Listing> _listings = [];
  Listing? _selectedListing;
  bool _isLoading = false;

  List<Listing> get listings => _listings;
  Listing? get selectedListing => _selectedListing;
  bool get isLoading => _isLoading;

  Future<void> searchListings({
    String? type,
    String? location,
    double? minPrice,
    double? maxPrice,
    double? minRating,
    String? checkIn,
    String? checkOut,
  }) async {
    _isLoading = true;
    notifyListeners();

    _listings = await _apiService.searchListings(
      type: type,
      location: location,
      minPrice: minPrice,
      maxPrice: maxPrice,
      minRating: minRating,
      checkIn: checkIn,
      checkOut: checkOut,
    );

    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadListingDetails(int id) async {
    _isLoading = true;
    notifyListeners();

    _selectedListing = await _apiService.getListingDetails(id);

    _isLoading = false;
    notifyListeners();
  }

  void clearListings() {
    _listings = [];
    notifyListeners();
  }
}


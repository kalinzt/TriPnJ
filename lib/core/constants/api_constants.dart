import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConstants {
  ApiConstants._();

  // API Keys
  static String get googlePlacesApiKey =>
      dotenv.env['GOOGLE_PLACES_API_KEY'] ?? '';

  static String get anthropicApiKey =>
      dotenv.env['ANTHROPIC_API_KEY'] ?? '';

  // Google Places API
  static const String googlePlacesBaseUrl =
      'https://maps.googleapis.com/maps/api/place';

  static const String placesNearbySearch = '$googlePlacesBaseUrl/nearbysearch/json';
  static const String placesDetails = '$googlePlacesBaseUrl/details/json';
  static const String placesAutocomplete = '$googlePlacesBaseUrl/autocomplete/json';
  static const String placesPhotos = '$googlePlacesBaseUrl/photo';

  // Anthropic API
  static const String anthropicBaseUrl = 'https://api.anthropic.com/v1';
  static const String anthropicMessages = '$anthropicBaseUrl/messages';
  static const String anthropicVersion = '2023-06-01';

  // Timeouts
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
}

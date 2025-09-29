import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import '../services/geofencing_service.dart';

// Provider untuk boundary data dari API - Pure API version
final officeBoundaryDataProvider = FutureProvider<Map<String, dynamic>>((
  ref,
) async {
  return await GeofencingService.fetchOfficeBoundaryData();
});

// Provider untuk status loading boundary
final boundaryLoadingProvider = Provider<bool>((ref) {
  final boundaryAsync = ref.watch(officeBoundaryDataProvider);
  return boundaryAsync.isLoading;
});

// Provider untuk office info dari API
final officeInfoProvider = Provider<Map<String, dynamic>>((ref) {
  final boundaryAsync = ref.watch(officeBoundaryDataProvider);

  return boundaryAsync.when(
    data: (boundaryData) => GeofencingService.getOfficeInfo(boundaryData),
    loading:
        () => {
          'name': 'Memuat...',
          'address': 'Mengambil data dari API...',
          'city': 'Jakarta',
          'source': 'LOADING',
          'pointCount': 0,
          'validationMethod': 'Loading...',
        },
    error:
        (_, __) => {
          'name': 'DPR/MPR RI (Error)',
          'address': 'Gagal mengambil data API',
          'city': 'Jakarta',
          'source': 'ERROR',
          'pointCount': 0,
          'validationMethod': 'Error Mode',
        },
  );
});

// Provider untuk validasi lokasi user dengan boundary data
final locationValidationProvider =
    FutureProvider.family<Map<String, dynamic>, Position>((
      ref,
      position,
    ) async {
      final boundaryData = await ref.watch(officeBoundaryDataProvider.future);
      return GeofencingService.validateLocation(position, boundaryData);
    });

// Provider untuk current user position
final currentPositionProvider = FutureProvider<Position>((ref) async {
  bool serviceEnabled;
  LocationPermission permission;

  // Test if location services are enabled.
  serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    throw Exception('Location services are disabled.');
  }

  permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      throw Exception('Location permissions are denied');
    }
  }

  if (permission == LocationPermission.deniedForever) {
    throw Exception('Location permissions are permanently denied');
  }

  return await Geolocator.getCurrentPosition(
    desiredAccuracy: LocationAccuracy.high,
  ).timeout(const Duration(seconds: 10));
});

// Provider untuk status validasi lokasi saat ini
final currentLocationValidationProvider =
    FutureProvider<LocationValidationResult>((ref) async {
      try {
        final position = await ref.watch(currentPositionProvider.future);
        final validation = await ref.watch(
          locationValidationProvider(position).future,
        );

        return LocationValidationResult(
          isValid: validation['isValid'] as bool,
          distance: validation['distance'] as double,
          position: position,
          accuracy: position.accuracy,
          method: validation['method'] as String,
          message: validation['message'] as String,
        );
      } catch (e) {
        throw Exception('Failed to validate location: $e');
      }
    });

// Data class untuk hasil validasi lokasi
class LocationValidationResult {
  final bool isValid;
  final double distance;
  final Position position;
  final double accuracy;
  final String method;
  final String message;

  const LocationValidationResult({
    required this.isValid,
    required this.distance,
    required this.position,
    required this.accuracy,
    required this.method,
    required this.message,
  });

  @override
  String toString() {
    return 'LocationValidationResult(isValid: $isValid, distance: ${distance.toStringAsFixed(1)}m, accuracy: ${accuracy.toStringAsFixed(1)}m, method: $method)';
  }
}

// Provider untuk stream position (real-time tracking)
final positionStreamProvider = StreamProvider<Position>((ref) {
  const LocationSettings locationSettings = LocationSettings(
    accuracy: LocationAccuracy.high,
    distanceFilter: 10, // Update setiap 10 meter
    timeLimit: Duration(seconds: 5),
  );

  return Geolocator.getPositionStream(locationSettings: locationSettings);
});

import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';

class LatLng {
  final double latitude;
  final double longitude;

  const LatLng(this.latitude, this.longitude);

  @override
  String toString() => 'LatLng($latitude, $longitude)';
}

class GeofencingService {
  static const String _overpassApiUrl =
      'https://overpass-api.de/api/interpreter?data=[out:json][timeout:25];(way(1376005634);>;);out%20geom;';

  static const double _fallbackRadiusMeters =
      500.0; // Backup radius jika API gagal

  /// Fetch boundary data from OpenStreetMap Overpass API - Pure API version
  static Future<Map<String, dynamic>> fetchOfficeBoundaryData() async {
    try {

      final response = await http
          .get(
            Uri.parse(_overpassApiUrl),
            headers: {'User-Agent': 'PPNPM-DPR-Mobile-App'},
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final elements = data['elements'] as List;

        // Find the way element that has geometry
        final wayElement = elements.firstWhere(
          (element) => element['type'] == 'way' && element['geometry'] != null,
          orElse:
              () => throw Exception('No way geometry found in API response'),
        );

        final geometry = wayElement['geometry'] as List;

        // Convert to LatLng format
        List<LatLng> boundaryPoints = [];
        for (var point in geometry) {
          boundaryPoints.add(
            LatLng(
              (point['lat'] as num).toDouble(),
              (point['lon'] as num).toDouble(),
            ),
          );
        }

        // Calculate center from API data
        LatLng center = _calculatePolygonCenter(boundaryPoints);

        // Extract metadata from API
        final tags = wayElement['tags'] ?? {};

        return {
          'success': true,
          'source': 'API',
          'boundary': boundaryPoints,
          'center': center,
          'name': tags['name'] ?? 'DPR/MPR RI',
          'address': tags['addr:street'] ?? 'Jalan Jenderal Gatot Subroto',
          'city': tags['addr:city'] ?? 'Jakarta Pusat',
          'website': tags['website'] ?? '',
          'pointCount': boundaryPoints.length,
        };
      } else {
        throw Exception('API returned status ${response.statusCode}');
      }
    } catch (e) {
      return _getFallbackData();
    }
  }

  /// Fallback data - no hardcoded coordinates, radius-based only
  static Map<String, dynamic> _getFallbackData() {
    print('🔄 Using fallback: radius-based validation disabled');

    return {
      'success': false,
      'source': 'FALLBACK',
      'boundary': <LatLng>[], // Empty - using radius fallback
      'center': null, // No center available
      'name': 'DPR/MPR RI (Fallback Mode)',
      'address': 'Area sekitar kantor',
      'city': 'Jakarta Pusat',
      'website': '',
      'pointCount': 0,
      'fallbackRadius': _fallbackRadiusMeters,
    };
  }

  /// Calculate the center point of a polygon
  static LatLng _calculatePolygonCenter(List<LatLng> polygon) {
    if (polygon.isEmpty) return const LatLng(0, 0);

    double sumLat = 0;
    double sumLng = 0;

    for (final point in polygon) {
      sumLat += point.latitude;
      sumLng += point.longitude;
    }

    return LatLng(sumLat / polygon.length, sumLng / polygon.length);
  }

  /// Check if a point is inside a polygon using ray casting algorithm
  static bool isPointInPolygon(LatLng point, List<LatLng> polygon) {
    if (polygon.length < 3) return false;

    int intersections = 0;
    final double x = point.longitude;
    final double y = point.latitude;

    for (int i = 0; i < polygon.length - 1; i++) {
      final double x1 = polygon[i].longitude;
      final double y1 = polygon[i].latitude;
      final double x2 = polygon[i + 1].longitude;
      final double y2 = polygon[i + 1].latitude;

      // Check if point is on the edge
      if (_isOnEdge(x, y, x1, y1, x2, y2)) {
        return true;
      }

      // Ray casting algorithm
      if (((y1 > y) != (y2 > y)) &&
          (x < (x2 - x1) * (y - y1) / (y2 - y1) + x1)) {
        intersections++;
      }
    }

    return intersections % 2 == 1;
  }

  /// Check if point is on polygon edge
  static bool _isOnEdge(
    double px,
    double py,
    double x1,
    double y1,
    double x2,
    double y2,
  ) {
    const double tolerance = 0.00001; // About 1 meter tolerance

    // Calculate distance from point to line segment
    final double A = px - x1;
    final double B = py - y1;
    final double C = x2 - x1;
    final double D = y2 - y1;

    final double dot = A * C + B * D;
    final double lenSq = C * C + D * D;

    if (lenSq == 0) {
      // Line segment is a point
      return sqrt(A * A + B * B) <= tolerance;
    }

    final double param = dot / lenSq;

    double xx, yy;
    if (param < 0) {
      xx = x1;
      yy = y1;
    } else if (param > 1) {
      xx = x2;
      yy = y2;
    } else {
      xx = x1 + param * C;
      yy = y1 + param * D;
    }

    final double dx = px - xx;
    final double dy = py - yy;

    return sqrt(dx * dx + dy * dy) <= tolerance;
  }

  /// Calculate distance between two points in meters
  static double calculateDistance(LatLng point1, LatLng point2) {
    return Geolocator.distanceBetween(
      point1.latitude,
      point1.longitude,
      point2.latitude,
      point2.longitude,
    );
  }

  /// Validate location with pure API data or fallback
  static Map<String, dynamic> validateLocation(
    Position position,
    Map<String, dynamic> boundaryData,
  ) {
    final boundary = boundaryData['boundary'] as List<LatLng>;
    final center = boundaryData['center'] as LatLng?;

    if (boundaryData['success'] == true &&
        boundary.isNotEmpty &&
        center != null) {
      // Mode API: Use polygon validation
      bool isInside = isPointInPolygon(
        LatLng(position.latitude, position.longitude),
        boundary,
      );

      double distance = calculateDistance(
        LatLng(position.latitude, position.longitude),
        center,
      );

      return {
        'isValid': isInside,
        'method': 'POLYGON',
        'distance': distance,
        'message':
            isInside
                ? '✅ Anda berada di area kantor'
                : '❌ Anda berada di luar area kantor',
      };
    } else {
      // Mode Fallback: Allow all locations when API is not available
      return {
        'isValid': true,
        'method': 'FALLBACK',
        'distance': 0.0,
        'message': '', 
      };
    }
  }

  /// Get office information from boundary data
  static Map<String, dynamic> getOfficeInfo(Map<String, dynamic> boundaryData) {
    final center = boundaryData['center'] as LatLng?;

    return {
      'name': boundaryData['name'] ?? 'DPR/MPR RI Building',
      'address':
          boundaryData['address'] ??
          'Jl. Jenderal Gatot Subroto No.6, Jakarta Pusat',
      'city': boundaryData['city'] ?? 'Jakarta Pusat',
      'center':
          center != null
              ? {'latitude': center.latitude, 'longitude': center.longitude}
              : null,
      'validationMethod':
          boundaryData['success'] == true
              ? 'OpenStreetMap Polygon Boundary'
              : 'Fallback Mode',
      'wayId': '1376005634',
      'source': boundaryData['source'] ?? 'UNKNOWN',
      'pointCount': boundaryData['pointCount'] ?? 0,
    };
  }
}

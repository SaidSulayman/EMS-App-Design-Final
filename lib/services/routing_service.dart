import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

class RoutingService {
  // Using OSRM (Open Source Routing Machine) - free routing service
  static const String _osrmBaseUrl = 'https://router.project-osrm.org/route/v1/driving';

  /// Get route between two points following roads
  Future<List<LatLng>?> getRoute(LatLng start, LatLng end) async {
    try {
      final url = Uri.parse(
        '$_osrmBaseUrl/${start.longitude},${start.latitude};${end.longitude},${end.latitude}?overview=full&geometries=geojson',
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['code'] == 'Ok' && data['routes'] != null && data['routes'].isNotEmpty) {
          final geometry = data['routes'][0]['geometry'];
          final coordinates = geometry['coordinates'] as List;
          
          return coordinates.map((coord) {
            return LatLng(coord[1].toDouble(), coord[0].toDouble());
          }).toList();
        }
      }
      return null;
    } catch (e) {
      // Fallback: return direct line if routing fails
      return [start, end];
    }
  }

  /// Get route distance in meters
  Future<double?> getRouteDistance(LatLng start, LatLng end) async {
    try {
      final url = Uri.parse(
        '$_osrmBaseUrl/${start.longitude},${start.latitude};${end.longitude},${end.latitude}?overview=false',
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['code'] == 'Ok' && data['routes'] != null && data['routes'].isNotEmpty) {
          return (data['routes'][0]['distance'] as num).toDouble();
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Get route duration in seconds
  Future<int?> getRouteDuration(LatLng start, LatLng end) async {
    try {
      final url = Uri.parse(
        '$_osrmBaseUrl/${start.longitude},${start.latitude};${end.longitude},${end.latitude}?overview=false',
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['code'] == 'Ok' && data['routes'] != null && data['routes'].isNotEmpty) {
          return (data['routes'][0]['duration'] as num).toInt();
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Get point along route at given distance ratio (0.0 to 1.0)
  LatLng? getPointAlongRoute(List<LatLng> route, double ratio) {
    if (route.isEmpty) return null;
    if (route.length == 1) return route[0];
    
    ratio = ratio.clamp(0.0, 1.0);
    
    if (ratio == 0.0) return route.first;
    if (ratio == 1.0) return route.last;

    // Calculate total distance
    double totalDistance = 0;
    final distances = <double>[];
    for (int i = 0; i < route.length - 1; i++) {
      final dist = _calculateDistance(route[i], route[i + 1]);
      distances.add(dist);
      totalDistance += dist;
    }

    // Find segment
    final targetDistance = totalDistance * ratio;
    double currentDistance = 0;
    
    for (int i = 0; i < distances.length; i++) {
      if (currentDistance + distances[i] >= targetDistance) {
        final segmentRatio = (targetDistance - currentDistance) / distances[i];
        return _interpolatePoint(route[i], route[i + 1], segmentRatio);
      }
      currentDistance += distances[i];
    }

    return route.last;
  }

  double _calculateDistance(LatLng p1, LatLng p2) {
    const distance = Distance();
    return distance(p1, p2);
  }

  LatLng _interpolatePoint(LatLng p1, LatLng p2, double ratio) {
    return LatLng(
      p1.latitude + (p2.latitude - p1.latitude) * ratio,
      p1.longitude + (p2.longitude - p1.longitude) * ratio,
    );
  }
}


import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:maps_toolkit/maps_toolkit.dart' as mt;
import '../../../core/constants/app_colors.dart';

class PolygonResult {
  final String geojson;
  final double latitude;
  final double longitude;
  final double areaSqm;
  final double areaHectares;
  final double areaAcres;
  final double perimeterMeters;
  final double lengthMeters;
  final double widthMeters;

  PolygonResult({
    required this.geojson,
    required this.latitude,
    required this.longitude,
    required this.areaSqm,
    required this.areaHectares,
    required this.areaAcres,
    required this.perimeterMeters,
    required this.lengthMeters,
    required this.widthMeters,
  });
}

class MapPolygonPickerScreen extends StatefulWidget {
  final String? initialGeojson;
  
  const MapPolygonPickerScreen({super.key, this.initialGeojson});

  @override
  State<MapPolygonPickerScreen> createState() => _MapPolygonPickerScreenState();
}

class _MapPolygonPickerScreenState extends State<MapPolygonPickerScreen> {
  GoogleMapController? _mapController;
  List<LatLng> _polygonPoints = [];
  LatLng _initialLocation = const LatLng(18.5204, 73.8567); // Default to Pune
  bool _isLoadingLocation = true;

  double _areaAcres = 0;
  double _areaHectares = 0;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    if (widget.initialGeojson != null && widget.initialGeojson!.isNotEmpty) {
      try {
        final parsed = jsonDecode(widget.initialGeojson!);
        if (parsed['type'] == 'Polygon') {
          final coordinates = parsed['coordinates'][0] as List;
          setState(() {
            _polygonPoints = coordinates
                .map((coord) => LatLng(coord[1], coord[0]))
                .toList();
            // Remove the last point if it's the same as the first (closed ring)
            if (_polygonPoints.isNotEmpty &&
                _polygonPoints.first.latitude == _polygonPoints.last.latitude &&
                _polygonPoints.first.longitude == _polygonPoints.last.longitude) {
              _polygonPoints.removeLast();
            }
            if (_polygonPoints.isNotEmpty) {
              _initialLocation = _polygonPoints.first;
            }
          });
          _calculateMetrics();
        }
      } catch (e) {
        debugPrint('Error parsing GeoJSON: $e');
      }
    } else {
      await _getCurrentLocation();
    }
    setState(() {
      _isLoadingLocation = false;
    });
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }
    
    if (permission == LocationPermission.deniedForever) return;

    final position = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
    );
    setState(() {
      _initialLocation = LatLng(position.latitude, position.longitude);
    });
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    if (_polygonPoints.isNotEmpty) {
      _fitMapToPolygon();
    } else {
      _mapController?.animateCamera(
        CameraUpdate.newLatLngZoom(_initialLocation, 16.0),
      );
    }
  }

  void _fitMapToPolygon() {
    if (_polygonPoints.isEmpty || _mapController == null) return;
    
    double minLat = _polygonPoints.first.latitude;
    double minLong = _polygonPoints.first.longitude;
    double maxLat = _polygonPoints.first.latitude;
    double maxLong = _polygonPoints.first.longitude;
    
    for (var point in _polygonPoints) {
      if (point.latitude < minLat) minLat = point.latitude;
      if (point.latitude > maxLat) maxLat = point.latitude;
      if (point.longitude < minLong) minLong = point.longitude;
      if (point.longitude > maxLong) maxLong = point.longitude;
    }
    
    _mapController?.animateCamera(
      CameraUpdate.newLatLngBounds(
        LatLngBounds(
          southwest: LatLng(minLat, minLong),
          northeast: LatLng(maxLat, maxLong),
        ),
        50.0, // padding
      ),
    );
  }

  void _onMapTapped(LatLng position) {
    setState(() {
      _polygonPoints.add(position);
    });
    _calculateMetrics();
  }

  void _undoLastPoint() {
    if (_polygonPoints.isNotEmpty) {
      setState(() {
        _polygonPoints.removeLast();
      });
      _calculateMetrics();
    }
  }

  void _clearPolygon() {
    setState(() {
      _polygonPoints.clear();
      _areaAcres = 0;
      _areaHectares = 0;
    });
  }

  void _calculateMetrics() {
    if (_polygonPoints.length < 3) {
      setState(() {
        _areaAcres = 0;
        _areaHectares = 0;
      });
      return;
    }

    final mtPoints = _polygonPoints
        .map((p) => mt.LatLng(p.latitude, p.longitude))
        .toList();
        
    final areaSqm = mt.SphericalUtil.computeArea(mtPoints).toDouble();
    setState(() {
      _areaHectares = areaSqm / 10000.0;
      _areaAcres = areaSqm / 4046.8564224;
    });
  }

  void _confirmPolygon() {
    if (_polygonPoints.length < 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please draw at least 3 points to form a polygon.')),
      );
      return;
    }

    final mtPoints = _polygonPoints.map((p) => mt.LatLng(p.latitude, p.longitude)).toList();
    final areaSqm = mt.SphericalUtil.computeArea(mtPoints).toDouble();
    final areaHectares = areaSqm / 10000.0;
    final areaAcres = areaSqm / 4046.8564224;
    
    // Close the polygon for calculation
    mtPoints.add(mtPoints.first);
    final perimeterMeters = mt.SphericalUtil.computeLength(mtPoints).toDouble();
    
    double minLat = _polygonPoints.first.latitude;
    double minLong = _polygonPoints.first.longitude;
    double maxLat = _polygonPoints.first.latitude;
    double maxLong = _polygonPoints.first.longitude;
    double sumLat = 0;
    double sumLong = 0;
    
    for (var point in _polygonPoints) {
      if (point.latitude < minLat) minLat = point.latitude;
      if (point.latitude > maxLat) maxLat = point.latitude;
      if (point.longitude < minLong) minLong = point.longitude;
      if (point.longitude > maxLong) maxLong = point.longitude;
      sumLat += point.latitude;
      sumLong += point.longitude;
    }
    
    final centerLat = sumLat / _polygonPoints.length;
    final centerLong = sumLong / _polygonPoints.length;
    
    final lengthMeters = mt.SphericalUtil.computeDistanceBetween(mt.LatLng(minLat, centerLong), mt.LatLng(maxLat, centerLong)).toDouble();
    final widthMeters = mt.SphericalUtil.computeDistanceBetween(mt.LatLng(centerLat, minLong), mt.LatLng(centerLat, maxLong)).toDouble();

    // Construct GeoJSON
    final coordinates = _polygonPoints.map((p) => [p.longitude, p.latitude]).toList();
    // Close the ring
    coordinates.add([_polygonPoints.first.longitude, _polygonPoints.first.latitude]);
    
    final geojson = jsonEncode({
      "type": "Polygon",
      "coordinates": [coordinates]
    });

    Navigator.of(context).pop(PolygonResult(
      geojson: geojson,
      latitude: centerLat,
      longitude: centerLong,
      areaSqm: areaSqm,
      areaHectares: areaHectares,
      areaAcres: areaAcres,
      perimeterMeters: perimeterMeters,
      lengthMeters: lengthMeters,
      widthMeters: widthMeters,
    ));
  }

  @override
  Widget build(BuildContext context) {
    Set<Polygon> polygons = {};
    if (_polygonPoints.isNotEmpty) {
      polygons.add(Polygon(
        polygonId: const PolygonId('farm_polygon'),
        points: _polygonPoints,
        strokeWidth: 2,
        strokeColor: AppColors.primaryGreen,
        fillColor: AppColors.primaryGreen.withValues(alpha: 0.3),
      ));
    }

    Set<Marker> markers = {};
    for (int i = 0; i < _polygonPoints.length; i++) {
      markers.add(Marker(
        markerId: MarkerId('point_$i'),
        position: _polygonPoints[i],
        draggable: true,
        onDragEnd: (newPosition) {
          setState(() {
            _polygonPoints[i] = newPosition;
          });
          _calculateMetrics();
        },
      ));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Draw Farm Polygon'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: _confirmPolygon,
          ),
        ],
      ),
      body: _isLoadingLocation
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                GoogleMap(
                  onMapCreated: _onMapCreated,
                  initialCameraPosition: CameraPosition(
                    target: _initialLocation,
                    zoom: 16.0,
                  ),
                  mapType: MapType.satellite,
                  myLocationEnabled: true,
                  myLocationButtonEnabled: true,
                  onTap: _onMapTapped,
                  polygons: polygons,
                  markers: markers,
                ),
                Positioned(
                  bottom: 24,
                  left: 16,
                  right: 16,
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Area: ${_areaAcres.toStringAsFixed(2)} Acres / ${_areaHectares.toStringAsFixed(2)} Ha',
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Text('${_polygonPoints.length} Points'),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              OutlinedButton.icon(
                                onPressed: _clearPolygon,
                                icon: const Icon(Icons.delete),
                                label: const Text('Clear'),
                              ),
                              OutlinedButton.icon(
                                onPressed: _undoLastPoint,
                                icon: const Icon(Icons.undo),
                                label: const Text('Undo'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}

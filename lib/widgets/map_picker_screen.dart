import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

/// Kết quả trả về từ MapPickerScreen
class LocationResult {
  final double latitude;
  final double longitude;
  final String address;

  const LocationResult({
    required this.latitude,
    required this.longitude,
    required this.address,
  });
}

/// Màn hình chọn vị trí trên bản đồ OpenStreetMap.
/// Người dùng kéo thả pin để chọn toạ độ, có thể tìm kiếm địa chỉ.
class MapPickerScreen extends StatefulWidget {
  /// Toạ độ ban đầu (null = Hà Nội)
  final double? initialLatitude;
  final double? initialLongitude;

  /// Địa chỉ ban đầu
  final String? initialAddress;

  const MapPickerScreen({
    super.key,
    this.initialLatitude,
    this.initialLongitude,
    this.initialAddress,
  });

  @override
  State<MapPickerScreen> createState() => _MapPickerScreenState();
}

class _MapPickerScreenState extends State<MapPickerScreen> {
  late final MapController _mapController;
  late LatLng _selectedPosition;
  late TextEditingController _searchController;
  String _address = '';
  bool _isSearching = false;

  // Toạ độ mặc định: Hà Nội
  static const double _defaultLat = 21.0285;
  static const double _defaultLng = 105.8542;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _selectedPosition = LatLng(
      widget.initialLatitude ?? _defaultLat,
      widget.initialLongitude ?? _defaultLng,
    );
    _searchController = TextEditingController(text: widget.initialAddress ?? '');
    _address = widget.initialAddress ?? '';
  }

  @override
  void dispose() {
    _mapController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _searchLocation(String query) async {
    if (query.trim().isEmpty) return;
    setState(() => _isSearching = true);

    try {
      // Dùng Nominatim API (free, OpenStreetMap) để geocode
      final uri = Uri.parse(
        'https://nominatim.openstreetmap.org/search?q=${Uri.encodeComponent(query)}&format=json&limit=1',
      );
      final httpClient = HttpClient();
      final request = await httpClient.getUrl(uri);
      request.headers.set('User-Agent', 'TradeLink/1.0');
      final response = await request.close();
      final body = await response.transform(utf8.decoder).join();
      httpClient.close();

      final data = jsonDecode(body) as List;
      if (data.isNotEmpty) {
        final place = data[0] as Map<String, dynamic>;
        final lat = double.parse(place['lat'] as String);
        final lon = double.parse(place['lon'] as String);
        final displayName = place['display_name'] as String? ?? '';

        setState(() {
          _selectedPosition = LatLng(lat, lon);
          _address = displayName;
          _searchController.text = displayName;
        });
        _mapController.move(_selectedPosition, 15.0);
      }
    } catch (_) {
      // Im lặng khi lỗi geocode
    } finally {
      setState(() => _isSearching = false);
    }
  }

  void _confirm() {
    Navigator.of(context).pop(LocationResult(
      latitude: _selectedPosition.latitude,
      longitude: _selectedPosition.longitude,
      address: _address.isNotEmpty ? _address : '${_selectedPosition.latitude}, ${_selectedPosition.longitude}',
    ));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chọn vị trí trên bản đồ'),
        actions: [
          TextButton(
            onPressed: _confirm,
            child: const Text('Xác nhận'),
          ),
        ],
      ),
      body: Column(
        children: [
          // Thanh tìm kiếm
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Tìm địa chỉ...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _isSearching
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
                      )
                    : IconButton(
                        icon: const Icon(Icons.search),
                        onPressed: () => _searchLocation(_searchController.text),
                      ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
              ),
              onSubmitted: _searchLocation,
            ),
          ),

          // Bản đồ
          Expanded(
            child: Stack(
              alignment: Alignment.center,
              children: [
                FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: _selectedPosition,
                    initialZoom: 14.0,
                    onTap: (tapPosition, point) {
                      setState(() {
                        _selectedPosition = point;
                        _address = '';
                      });
                    },
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.tradelink.app',
                    ),
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: _selectedPosition,
                          width: 40,
                          height: 40,
                          child: const Icon(
                            Icons.location_on,
                            color: Colors.red,
                            size: 40,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                // Thông tin toạ độ bottom
                Positioned(
                  left: 12,
                  right: 12,
                  bottom: 16,
                  child: Card(
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (_address.isNotEmpty) ...[
                            Text(
                              _address,
                              style: theme.textTheme.bodySmall,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                          ],
                          Text(
                            '${_selectedPosition.latitude.toStringAsFixed(4)}°N, ${_selectedPosition.longitude.toStringAsFixed(4)}°E',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              fontFeatures: const [FontFeature.tabularFigures()],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

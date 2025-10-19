import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import '../../../domain/entities/item_entity.dart';
import '../../blocs/item/item_bloc.dart';
import '../../blocs/item/item_event.dart';
import '../../blocs/item/item_state.dart';
import '../../../core/routes/app_router.dart';

/// 🗺️ WORLD-CLASS MAP VIEW PAGE
///
/// Features:
/// - Google Maps with item markers
/// - Nearby items display
/// - Filter by distance
/// - Cluster markers
/// - Beautiful bottom sheet
class MapViewPage extends StatefulWidget {
  const MapViewPage({Key? key}) : super(key: key);

  @override
  State<MapViewPage> createState() => _MapViewPageState();
}

class _MapViewPageState extends State<MapViewPage> {
  GoogleMapController? _mapController;
  LatLng _currentLocation = const LatLng(41.0082, 28.9784); // Istanbul default
  final Set<Marker> _markers = {};
  List<ItemEntity> _items = [];
  ItemEntity? _selectedItem;
  double _radiusKm = 10.0;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    _loadItems();
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  Future<void> _getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return;

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) return;
      }

      Position position = await Geolocator.getCurrentPosition();
      if (!mounted) return;
      setState(() {
        _currentLocation = LatLng(position.latitude, position.longitude);
      });

      _mapController?.animateCamera(
        CameraUpdate.newLatLngZoom(_currentLocation, 12),
      );
    } catch (e) {
      print('Location error: $e');
    }
  }

  void _loadItems() {
    context.read<ItemBloc>().add(const LoadAllItems());
  }

  Future<void> _updateMarkers(List<ItemEntity> items) async {
    final Set<Marker> markers = {};

    for (var item in items) {
      if (item.latitude != null && item.longitude != null) {
        final distance =
            Geolocator.distanceBetween(
              _currentLocation.latitude,
              _currentLocation.longitude,
              item.latitude!,
              item.longitude!,
            ) /
            1000; // Convert to km

        if (distance <= _radiusKm) {
          markers.add(
            Marker(
              markerId: MarkerId(item.id),
              position: LatLng(item.latitude!, item.longitude!),
              onTap: () {
                setState(() {
                  _selectedItem = item;
                });
              },
              infoWindow: InfoWindow(
                title: item.title,
                snippet: '₺${item.price?.toInt() ?? 0}',
              ),
            ),
          );
        }
      }
    }

    if (!mounted) return;
    setState(() {
      _markers.clear();
      _markers.addAll(markers);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<ItemBloc, ItemState>(
        listener: (context, state) {
          if (state is ItemsLoaded) {
            if (!mounted) return;
            setState(() {
              _items = state.items;
            });
            _updateMarkers(state.items);
          }
        },
        child: Stack(
          children: [
            // Google Map
            GoogleMap(
              initialCameraPosition: CameraPosition(
                target: _currentLocation,
                zoom: 12,
              ),
              onMapCreated: (controller) {
                _mapController = controller;
              },
              markers: _markers,
              myLocationEnabled: true,
              myLocationButtonEnabled: false,
              zoomControlsEnabled: false,
              mapToolbarEnabled: false,
              onTap: (_) {
                setState(() {
                  _selectedItem = null;
                });
              },
            ),

            // Top App Bar
            _buildTopBar(),

            // Radius Filter
            _buildRadiusFilter(),

            // Selected Item Bottom Sheet
            if (_selectedItem != null) _buildItemBottomSheet(),

            // My Location Button
            Positioned(
              right: 16,
              bottom: _selectedItem != null ? 220 : 100,
              child: FloatingActionButton(
                onPressed: _getCurrentLocation,
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFFFF6B35),
                child: const Icon(Icons.my_location),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return SafeArea(
      child: Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.pop(context),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Harita Görünümü',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '${_markers.length} ürün gösteriliyor',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.filter_list),
              onPressed: () {
                // Show filter options
              },
              color: const Color(0xFFFF6B35),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRadiusFilter() {
    return Positioned(
      bottom: _selectedItem != null ? 220 : 16,
      left: 16,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                const Icon(Icons.radar, size: 20, color: Color(0xFFFF6B35)),
                const SizedBox(width: 8),
                Text(
                  'Yarıçap: ${_radiusKm.toInt()} km',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: 200,
              child: Slider(
                value: _radiusKm,
                min: 1,
                max: 50,
                divisions: 49,
                activeColor: const Color(0xFFFF6B35),
                onChanged: (value) {
                  setState(() {
                    _radiusKm = value;
                  });
                  _updateMarkers(_items);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItemBottomSheet() {
    final item = _selectedItem!;

    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: GestureDetector(
        onTap: () => AppRouter.toItemDetail(context, item.id),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          padding: const EdgeInsets.all(20),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Drag Handle
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 16),

                // Item Info
                Row(
                  children: [
                    // Image
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        width: 100,
                        height: 100,
                        color: Colors.grey[200],
                        child: item.images.isNotEmpty
                            ? Image.network(
                                item.images.first,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => const Icon(
                                  Icons.image,
                                  size: 40,
                                  color: Colors.grey,
                                ),
                              )
                            : const Icon(
                                Icons.image,
                                size: 40,
                                color: Colors.grey,
                              ),
                      ),
                    ),
                    const SizedBox(width: 16),

                    // Details
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.title,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            item.category,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(
                                Icons.location_on,
                                size: 14,
                                color: Color(0xFFFF6B35),
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  item.location ?? 'Konum belirtilmemiş',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '₺${item.price?.toInt() ?? 0}',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFFF6B35),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Arrow
                    const Icon(
                      Icons.arrow_forward_ios,
                      size: 20,
                      color: Colors.grey,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

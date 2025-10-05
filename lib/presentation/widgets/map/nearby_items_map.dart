import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../domain/entities/item_entity.dart';
import '../../../core/services/map_service.dart';

/// Nearby Items Map Widget
/// Shows multiple items on map (explore/search pages)
/// Based on Facebook Marketplace distance filtering
class NearbyItemsMap extends StatefulWidget {
  final List<ItemEntity> items;
  final double? userLatitude;
  final double? userLongitude;
  final Function(ItemEntity item)? onItemTap;
  final double radiusKm;

  const NearbyItemsMap({
    Key? key,
    required this.items,
    this.userLatitude,
    this.userLongitude,
    this.onItemTap,
    this.radiusKm = 25.0,
  }) : super(key: key);

  @override
  State<NearbyItemsMap> createState() => _NearbyItemsMapState();
}

class _NearbyItemsMapState extends State<NearbyItemsMap> {
  final MapService _mapService = MapService();
  GoogleMapController? _mapController;
  Set<Marker> _markers = {};
  ItemEntity? _selectedItem;

  @override
  void initState() {
    super.initState();
    _initializeMarkers();
  }

  @override
  void didUpdateWidget(NearbyItemsMap oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.items != widget.items) {
      _initializeMarkers();
    }
  }

  void _initializeMarkers() {
    final markers = <Marker>{};

    // Add user location marker
    if (widget.userLatitude != null && widget.userLongitude != null) {
      markers.add(
        Marker(
          markerId: const MarkerId('user'),
          position: LatLng(widget.userLatitude!, widget.userLongitude!),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
          infoWindow: const InfoWindow(title: 'Konumunuz'),
        ),
      );
    }

    // Add item markers
    for (final item in widget.items) {
      if (item.latitude != null && item.longitude != null) {
        // Check if within radius
        bool withinRadius = true;
        if (widget.userLatitude != null && widget.userLongitude != null) {
          withinRadius = _mapService.isWithinRadius(
            widget.userLatitude!,
            widget.userLongitude!,
            item.latitude!,
            item.longitude!,
            widget.radiusKm,
          );
        }

        if (withinRadius) {
          markers.add(
            Marker(
              markerId: MarkerId(item.id),
              position: LatLng(item.latitude!, item.longitude!),
              icon: BitmapDescriptor.defaultMarkerWithHue(
                BitmapDescriptor.hueRed,
              ),
              infoWindow: InfoWindow(
                title: item.title,
                snippet: '${item.price?.toStringAsFixed(0) ?? '0'} ₺',
              ),
              onTap: () {
                setState(() => _selectedItem = item);
              },
            ),
          );
        }
      }
    }

    setState(() => _markers = markers);
  }

  LatLng _getCenterPosition() {
    if (widget.userLatitude != null && widget.userLongitude != null) {
      return LatLng(widget.userLatitude!, widget.userLongitude!);
    }
    
    // If user location not available, use first item
    if (widget.items.isNotEmpty) {
      final firstItem = widget.items.firstWhere(
        (item) => item.latitude != null && item.longitude != null,
        orElse: () => widget.items.first,
      );
      if (firstItem.latitude != null && firstItem.longitude != null) {
        return LatLng(firstItem.latitude!, firstItem.longitude!);
      }
    }

    // Default to Istanbul
    return const LatLng(41.0082, 28.9784);
  }

  String _getDistanceText(ItemEntity item) {
    if (widget.userLatitude == null || widget.userLongitude == null) {
      return item.city ?? '';
    }
    if (item.latitude == null || item.longitude == null) {
      return item.city ?? '';
    }

    return _mapService.getFormattedDistance(
      widget.userLatitude!,
      widget.userLongitude!,
      item.latitude!,
      item.longitude!,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Map
        GoogleMap(
          initialCameraPosition: CameraPosition(
            target: _getCenterPosition(),
            zoom: 12,
          ),
          markers: _markers,
          onMapCreated: (controller) => _mapController = controller,
          myLocationEnabled: true,
          myLocationButtonEnabled: true,
          onTap: (_) => setState(() => _selectedItem = null),
        ),

        // Radius indicator
        if (widget.userLatitude != null && widget.userLongitude != null)
          Positioned(
            top: 16,
            left: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 8,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.circle_outlined,
                    size: 16,
                    color: Colors.blue.shade700,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '${widget.radiusKm.round()} km yarıçap',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.blue.shade700,
                    ),
                  ),
                ],
              ),
            ),
          ),

        // Items count
        Positioned(
          top: 16,
          right: 16,
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 8,
            ),
            decoration: BoxDecoration(
              color: Colors.green.shade700,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              '${_markers.length - 1} ürün',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ),

        // Selected item card
        if (_selectedItem != null)
          Positioned(
            bottom: 16,
            left: 16,
            right: 16,
            child: Card(
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: InkWell(
                onTap: () {
                  if (widget.onItemTap != null) {
                    widget.onItemTap!(_selectedItem!);
                  }
                },
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      // Image
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: _selectedItem!.images.isNotEmpty
                            ? Image.network(
                                _selectedItem!.images.first,
                                width: 80,
                                height: 80,
                                fit: BoxFit.cover,
                              )
                            : Container(
                                width: 80,
                                height: 80,
                                color: Colors.grey.shade200,
                                child: const Icon(Icons.image),
                              ),
                      ),
                      const SizedBox(width: 12),
                      
                      // Info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _selectedItem!.title,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${_selectedItem!.price?.toStringAsFixed(0) ?? '0'} ₺',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.green.shade700,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(
                                  Icons.location_on,
                                  size: 14,
                                  color: Colors.grey.shade600,
                                ),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    _getDistanceText(_selectedItem!),
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      // Arrow
                      Icon(
                        Icons.arrow_forward_ios,
                        size: 16,
                        color: Colors.grey.shade400,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

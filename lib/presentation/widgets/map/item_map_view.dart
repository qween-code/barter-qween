import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../domain/entities/item_entity.dart';
import '../../../core/services/map_service.dart';

/// Item Map View Widget
/// Shows item location on map (item detail page)
/// Based on OfferUp map display UX
class ItemMapView extends StatefulWidget {
  final ItemEntity item;
  final double? userLatitude;
  final double? userLongitude;
  final bool showDistance;
  final bool showMeetupPoints;

  const ItemMapView({
    Key? key,
    required this.item,
    this.userLatitude,
    this.userLongitude,
    this.showDistance = true,
    this.showMeetupPoints = true,
  }) : super(key: key);

  @override
  State<ItemMapView> createState() => _ItemMapViewState();
}

class _ItemMapViewState extends State<ItemMapView> {
  final MapService _mapService = MapService();
  GoogleMapController? _mapController;
  Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    _initializeMarkers();
  }

  void _initializeMarkers() {
    final markers = <Marker>{};

    // Item location marker
    if (widget.item.latitude != null && widget.item.longitude != null) {
      markers.add(
        Marker(
          markerId: const MarkerId('item'),
          position: LatLng(widget.item.latitude!, widget.item.longitude!),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
          infoWindow: InfoWindow(
            title: widget.item.title,
            snippet: widget.item.fullAddress ?? 'Ürün lokasyonu',
          ),
        ),
      );
    }

    // User location marker
    if (widget.userLatitude != null && widget.userLongitude != null) {
      markers.add(
        Marker(
          markerId: const MarkerId('user'),
          position: LatLng(widget.userLatitude!, widget.userLongitude!),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
          infoWindow: const InfoWindow(
            title: 'Konumunuz',
          ),
        ),
      );
    }

    // Meetup points markers (if enabled)
    if (widget.showMeetupPoints && widget.item.preferredMeetupPoints != null) {
      // TODO: Add meetup point markers when we have coordinates
    }

    setState(() => _markers = markers);
  }

  LatLng _getCenterPosition() {
    if (widget.item.latitude != null && widget.item.longitude != null) {
      return LatLng(widget.item.latitude!, widget.item.longitude!);
    }
    return const LatLng(41.0082, 28.9784); // Istanbul center
  }

  String? _getDistanceText() {
    if (!widget.showDistance) return null;
    if (widget.item.latitude == null || widget.item.longitude == null) return null;
    if (widget.userLatitude == null || widget.userLongitude == null) return null;

    return _mapService.getFormattedDistance(
      widget.userLatitude!,
      widget.userLongitude!,
      widget.item.latitude!,
      widget.item.longitude!,
    );
  }

  void _openFullMap() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FullMapView(
          item: widget.item,
          userLatitude: widget.userLatitude,
          userLongitude: widget.userLongitude,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.item.latitude == null || widget.item.longitude == null) {
      return const SizedBox.shrink();
    }

    final distanceText = _getDistanceText();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              const Icon(Icons.location_on, size: 20),
              const SizedBox(width: 8),
              const Text(
                'Konum',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (distanceText != null) ...[
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    distanceText,
                    style: TextStyle(
                      color: Colors.blue.shade700,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),

        // Map
        GestureDetector(
          onTap: _openFullMap,
          child: Container(
            height: 200,
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
            ),
            clipBehavior: Clip.antiAlias,
            child: Stack(
              children: [
                GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: _getCenterPosition(),
                    zoom: 14,
                  ),
                  markers: _markers,
                  onMapCreated: (controller) => _mapController = controller,
                  zoomControlsEnabled: false,
                  scrollGesturesEnabled: false,
                  zoomGesturesEnabled: false,
                  tiltGesturesEnabled: false,
                  rotateGesturesEnabled: false,
                ),
                // Tap to expand hint
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.open_in_full, size: 14),
                        SizedBox(width: 4),
                        Text(
                          'Genişlet',
                          style: TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // Address
        if (widget.item.fullAddress != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Row(
              children: [
                Icon(Icons.place, size: 16, color: Colors.grey.shade600),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    widget.item.fullAddress!,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ),
              ],
            ),
          ),

        // Meetup location hint
        if (widget.item.meetupLocation != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.handshake, size: 20, color: Colors.green.shade700),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Buluşma Noktası',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.green.shade700,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          widget.item.meetupLocation!,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.green.shade900,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

/// Full screen map view
class FullMapView extends StatefulWidget {
  final ItemEntity item;
  final double? userLatitude;
  final double? userLongitude;

  const FullMapView({
    Key? key,
    required this.item,
    this.userLatitude,
    this.userLongitude,
  }) : super(key: key);

  @override
  State<FullMapView> createState() => _FullMapViewState();
}

class _FullMapViewState extends State<FullMapView> {
  final MapService _mapService = MapService();
  GoogleMapController? _mapController;
  Set<Marker> _markers = {};
  List<SafeMeetupPoint> _safePlaces = [];

  @override
  void initState() {
    super.initState();
    _initializeMarkers();
    _loadSafePlaces();
  }

  void _initializeMarkers() {
    final markers = <Marker>{};

    if (widget.item.latitude != null && widget.item.longitude != null) {
      markers.add(
        Marker(
          markerId: const MarkerId('item'),
          position: LatLng(widget.item.latitude!, widget.item.longitude!),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
          infoWindow: InfoWindow(
            title: widget.item.title,
            snippet: widget.item.fullAddress ?? 'Ürün lokasyonu',
          ),
        ),
      );
    }

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

    setState(() => _markers = markers);
  }

  void _loadSafePlaces() {
    final city = widget.item.city ?? 'İstanbul';
    setState(() {
      _safePlaces = _mapService.getSafeMeetupSuggestions(city);
    });
  }

  LatLng _getCenterPosition() {
    if (widget.item.latitude != null && widget.item.longitude != null) {
      return LatLng(widget.item.latitude!, widget.item.longitude!);
    }
    return const LatLng(41.0082, 28.9784);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Konum Detayı'),
      ),
      body: Column(
        children: [
          // Map
          Expanded(
            child: GoogleMap(
              initialCameraPosition: CameraPosition(
                target: _getCenterPosition(),
                zoom: 13,
              ),
              markers: _markers,
              onMapCreated: (controller) => _mapController = controller,
              myLocationEnabled: true,
              myLocationButtonEnabled: true,
            ),
          ),

          // Safe meetup suggestions
          if (_safePlaces.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Güvenli Buluşma Noktaları',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 80,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _safePlaces.length,
                      itemBuilder: (context, index) {
                        final place = _safePlaces[index];
                        return Container(
                          width: 160,
                          margin: const EdgeInsets.only(right: 12),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: place.isOfficial
                                ? Colors.green.shade50
                                : Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: place.isOfficial
                                  ? Colors.green.shade200
                                  : Colors.blue.shade200,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    place.icon,
                                    style: const TextStyle(fontSize: 20),
                                  ),
                                  const SizedBox(width: 8),
                                  if (place.isOfficial)
                                    Icon(
                                      Icons.verified,
                                      size: 16,
                                      color: Colors.green.shade700,
                                    ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                place.name,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                place.description,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey.shade600,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        );
                      },
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

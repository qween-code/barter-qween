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

  Future<String?> _getDistanceText() async {
    if (!widget.showDistance) return null;
    if (widget.item.latitude == null || widget.item.longitude == null) return null;
    if (widget.userLatitude == null || widget.userLongitude == null) return null;

    // Calculate distance first, then format it
    final distance = await _mapService.calculateDistance(
      widget.userLatitude!,
      widget.userLongitude!,
      widget.item.latitude!,
      widget.item.longitude!,
    );
    return _mapService.getFormattedDistance(distance);
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

    return FutureBuilder<String?>(
      future: _getDistanceText(),
      builder: (context, snapshot) {
        final distanceText = snapshot.data;

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
                      onMapCreated: (GoogleMapController controller) {
                        _mapController = controller;
                      },
                      mapType: MapType.normal,
                      myLocationEnabled: false,
                      myLocationButtonEnabled: false,
                      zoomControlsEnabled: false,
                      mapToolbarEnabled: false,
                    ),
                    
                    // Tap to expand overlay
                    Positioned.fill(
                      child: Container(
                        color: Colors.transparent,
                        child: Center(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.7),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Text(
                              'Tam ekran için dokunun',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Address
            if (widget.item.fullAddress != null) ...[
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Icon(
                      Icons.place,
                      size: 16,
                      color: Colors.grey.shade600,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        widget.item.fullAddress!,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade700,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // Meetup points (if enabled)
            if (widget.showMeetupPoints && widget.item.preferredMeetupPoints != null) ...[
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.handshake,
                          size: 16,
                          color: Colors.green.shade600,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Güvenli Buluşma Noktaları',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.green.shade700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: widget.item.preferredMeetupPoints!.length,
                      itemBuilder: (context, index) {
                        final point = widget.item.preferredMeetupPoints![index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            children: [
                              Icon(
                                Icons.location_on_outlined,
                                size: 14,
                                color: Colors.grey.shade600,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  point,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey.shade700,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ],
        );
      },
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
  List<dynamic> _safePlaces = []; // TODO: Use SafeMeetupPoint when available

  @override
  void initState() {
    super.initState();
    _initializeMarkers();
    _loadSafePlaces();
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

    setState(() => _markers = markers);
  }

  void _loadSafePlaces() {
    // TODO: Load safe meetup places from service
    setState(() => _safePlaces = []);
  }

  LatLng _getCenterPosition() {
    if (widget.item.latitude != null && widget.item.longitude != null) {
      return LatLng(widget.item.latitude!, widget.item.longitude!);
    }
    return const LatLng(41.0082, 28.9784); // Istanbul center
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Konum'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.my_location),
            onPressed: () {
              // TODO: Center on user location
            },
          ),
        ],
      ),
      body: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: _getCenterPosition(),
          zoom: 14,
        ),
        markers: _markers,
        onMapCreated: (GoogleMapController controller) {
          _mapController = controller;
        },
        mapType: MapType.normal,
        myLocationEnabled: true,
        myLocationButtonEnabled: true,
        zoomControlsEnabled: true,
        mapToolbarEnabled: true,
      ),
    );
  }
}
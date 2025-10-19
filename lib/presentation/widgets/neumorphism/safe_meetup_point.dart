class SafeMeetupPoint {
  final String id;
  final String name;
  final String address;
  final double latitude;
  final double longitude;
  final String type; // "police", "mall", "cafe", "bank"
  final double safetyScore;
  final List<String> amenities;

  const SafeMeetupPoint({
    required this.id,
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.type,
    required this.safetyScore,
    required this.amenities,
  });
}

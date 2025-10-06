import 'package:equatable/equatable.dart';

class SafeMeetupPoint extends Equatable {
  final String id;
  final String name;
  final String address;
  final double latitude;
  final double longitude;
  final String type; // 'police', 'mall', 'bank', 'hospital', 'metro'
  final double safetyScore; // 0.0 to 1.0
  final bool is24Hours;
  final String? description;
  final DateTime createdAt;

  const SafeMeetupPoint({
    required this.id,
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.type,
    required this.safetyScore,
    this.is24Hours = false,
    this.description,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        address,
        latitude,
        longitude,
        type,
        safetyScore,
        is24Hours,
        description,
        createdAt,
      ];

  SafeMeetupPoint copyWith({
    String? id,
    String? name,
    String? address,
    double? latitude,
    double? longitude,
    String? type,
    double? safetyScore,
    bool? is24Hours,
    String? description,
    DateTime? createdAt,
  }) {
    return SafeMeetupPoint(
      id: id ?? this.id,
      name: name ?? this.name,
      address: address ?? this.address,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      type: type ?? this.type,
      safetyScore: safetyScore ?? this.safetyScore,
      is24Hours: is24Hours ?? this.is24Hours,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

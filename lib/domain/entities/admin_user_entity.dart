import 'package:equatable/equatable.dart';

class AdminUserEntity extends Equatable {
  final String id;
  final String email;
  final String name;
  final AdminRole role;
  final List<AdminPermission> permissions;
  final DateTime createdAt;
  final bool isActive;

  const AdminUserEntity({
    required this.id,
    required this.email,
    required this.name,
    required this.role,
    required this.permissions,
    required this.createdAt,
    required this.isActive,
  });

  @override
  List<Object?> get props => [id, email, name, role, permissions, createdAt, isActive];

  AdminUserEntity copyWith({
    String? id,
    String? email,
    String? name,
    AdminRole? role,
    List<AdminPermission>? permissions,
    DateTime? createdAt,
    bool? isActive,
  }) {
    return AdminUserEntity(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      role: role ?? this.role,
      permissions: permissions ?? this.permissions,
      createdAt: createdAt ?? this.createdAt,
      isActive: isActive ?? this.isActive,
    );
  }
}

enum AdminRole {
  superAdmin,    // Tüm yetkiler
  moderator,     // İlan onaylama
  support,       // Kullanıcı desteği
  analyst,       // Raporlama
}

enum AdminPermission {
  approveItems,
  rejectItems,
  banUsers,
  viewAnalytics,
  manageUsers,
  editItemTiers,
  viewReports,
}
// lib/features/auth/data/models/verification_models.dart

// ignore_for_file: always_specify_types

library verification_models;

// =============================================================================
// ENUMS
// =============================================================================

enum TrustStatus { verified, partial, unverified, pending }

enum AdminStatus { approved, pending, rejected, suspended }

// =============================================================================
// SchoolModel
// =============================================================================

class SchoolModel {
  const SchoolModel({
    required this.id,
    required this.name,
    required this.country,
    required this.city,
    required this.officialEmail,
    required this.website,
    required this.trustStatus,
    required this.trustScore,
  });

  factory SchoolModel.fromMap(Map<String, dynamic> map) {
    return SchoolModel(
      id: map['id'] as String? ?? '',
      name: map['name'] as String? ?? '',
      country: map['country'] as String? ?? '',
      city: map['city'] as String? ?? '',
      officialEmail: map['officialEmail'] as String? ?? '',
      website: map['website'] as String? ?? '',
      trustStatus: _parseTrustStatus(map['trustStatus'] as String?),
      trustScore: (map['trustScore'] as num?)?.toDouble() ?? 0.0,
    );
  }

  /// Empty/default factory for UI initialization
  factory SchoolModel.empty() {
    return const SchoolModel(
      id: '',
      name: '',
      country: '',
      city: '',
      officialEmail: '',
      website: '',
      trustStatus: TrustStatus.pending,
      trustScore: 0.0,
    );
  }

  final String id;
  final String name;
  final String country;
  final String city;
  final String officialEmail;
  final String website;
  final TrustStatus trustStatus;

  /// Value between 0.0 and 1.0
  final double trustScore;

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'country': country,
      'city': city,
      'officialEmail': officialEmail,
      'website': website,
      'trustStatus': trustStatus.name,
      'trustScore': trustScore,
    };
  }

  SchoolModel copyWith({
    String? id,
    String? name,
    String? country,
    String? city,
    String? officialEmail,
    String? website,
    TrustStatus? trustStatus,
    double? trustScore,
  }) {
    return SchoolModel(
      id: id ?? this.id,
      name: name ?? this.name,
      country: country ?? this.country,
      city: city ?? this.city,
      officialEmail: officialEmail ?? this.officialEmail,
      website: website ?? this.website,
      trustStatus: trustStatus ?? this.trustStatus,
      trustScore: trustScore ?? this.trustScore,
    );
  }

  static TrustStatus _parseTrustStatus(String? value) {
    switch (value) {
      case 'verified':
        return TrustStatus.verified;
      case 'partial':
        return TrustStatus.partial;
      case 'unverified':
        return TrustStatus.unverified;
      default:
        return TrustStatus.pending;
    }
  }

  @override
  String toString() =>
      'SchoolModel(id: $id, name: $name, trustScore: $trustScore)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SchoolModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

// =============================================================================
// AdminModel
// =============================================================================

class AdminModel {
  const AdminModel({
    required this.uid,
    required this.schoolId,
    required this.verificationDocUrl,
    required this.adminStatus,
    required this.isEmailDomainMatch,
  });

  factory AdminModel.fromMap(Map<String, dynamic> map) {
    return AdminModel(
      uid: map['uid'] as String? ?? '',
      schoolId: map['schoolId'] as String? ?? '',
      verificationDocUrl: map['verificationDocUrl'] as String? ?? '',
      adminStatus: _parseAdminStatus(map['adminStatus'] as String?),
      isEmailDomainMatch: map['isEmailDomainMatch'] as bool? ?? false,
    );
  }

  /// Empty/default factory for UI initialization
  factory AdminModel.empty() {
    return const AdminModel(
      uid: '',
      schoolId: '',
      verificationDocUrl: '',
      adminStatus: AdminStatus.pending,
      isEmailDomainMatch: false,
    );
  }

  final String uid;
  final String schoolId;
  final String verificationDocUrl;
  final AdminStatus adminStatus;
  final bool isEmailDomainMatch;

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'uid': uid,
      'schoolId': schoolId,
      'verificationDocUrl': verificationDocUrl,
      'adminStatus': adminStatus.name,
      'isEmailDomainMatch': isEmailDomainMatch,
    };
  }

  AdminModel copyWith({
    String? uid,
    String? schoolId,
    String? verificationDocUrl,
    AdminStatus? adminStatus,
    bool? isEmailDomainMatch,
  }) {
    return AdminModel(
      uid: uid ?? this.uid,
      schoolId: schoolId ?? this.schoolId,
      verificationDocUrl: verificationDocUrl ?? this.verificationDocUrl,
      adminStatus: adminStatus ?? this.adminStatus,
      isEmailDomainMatch: isEmailDomainMatch ?? this.isEmailDomainMatch,
    );
  }

  static AdminStatus _parseAdminStatus(String? value) {
    switch (value) {
      case 'approved':
        return AdminStatus.approved;
      case 'rejected':
        return AdminStatus.rejected;
      case 'suspended':
        return AdminStatus.suspended;
      default:
        return AdminStatus.pending;
    }
  }

  @override
  String toString() =>
      'AdminModel(uid: $uid, schoolId: $schoolId, adminStatus: $adminStatus)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AdminModel && other.uid == uid;
  }

  @override
  int get hashCode => uid.hashCode;
}

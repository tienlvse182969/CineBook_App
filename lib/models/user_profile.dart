class UserProfile {
  final int id;
  final String fullName;
  final String email;
  final String? phone;
  final String? dateOfBirth;
  final DateTime? memberSince;

  const UserProfile({
    required this.id,
    required this.fullName,
    required this.email,
    this.phone,
    this.dateOfBirth,
    this.memberSince,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    final createdAtStr = json['created_at']?.toString();
    return UserProfile(
      id: (json['user_id'] as num?)?.toInt() ?? 0,
      fullName: json['full_name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      phone: json['phone']?.toString(),
      dateOfBirth: json['date_of_birth']?.toString(),
      memberSince: createdAtStr != null ? DateTime.tryParse(createdAtStr) : null,
    );
  }

  String get initials {
    final parts = fullName.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return 'U';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  String get memberSinceLabel {
    if (memberSince == null) return 'Tháng 01, 2025';
    const months = [
      'Tháng 01', 'Tháng 02', 'Tháng 03', 'Tháng 04',
      'Tháng 05', 'Tháng 06', 'Tháng 07', 'Tháng 08',
      'Tháng 09', 'Tháng 10', 'Tháng 11', 'Tháng 12',
    ];
    return '${months[memberSince!.month - 1]}, ${memberSince!.year}';
  }
}

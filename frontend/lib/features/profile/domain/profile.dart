class UserProfile {
  const UserProfile({
    required this.id,
    required this.email,
    required this.role,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
    id: (json['sub'] ?? json['id'] ?? '').toString(),
    email: (json['email'] ?? '').toString(),
    role: (json['role'] ?? '').toString(),
  );

  final String id;
  final String email;
  final String role;

  String get initials =>
      email.isEmpty ? '?' : email.substring(0, 1).toUpperCase();
}

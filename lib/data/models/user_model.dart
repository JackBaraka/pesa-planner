class AppUser {
  final String uid;
  final String? email;
  final String? phone;
  final String displayName;

  AppUser({
    required this.uid,
    this.email,
    this.phone,
    required this.displayName,
  });
}

extension AppUserExtension on AppUser {
  bool get isEmailVerified => email != null && email!.isNotEmpty;

  String get displayNameOrEmail =>
      displayName.isNotEmpty ? displayName : (email ?? 'No Email');
}

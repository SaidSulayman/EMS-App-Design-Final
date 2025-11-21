class UserModel {
  final String name;
  final String email;
  final String phone;

  UserModel({
    required this.name,
    required this.email,
    required this.phone,
  });

  String get initials {
    final names = name.split(' ');
    if (names.length >= 2) {
      return '${names[0][0]}${names[1][0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : 'U';
  }
}

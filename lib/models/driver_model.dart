class DriverModel {
  final String name;
  final double rating;
  final String vehicleNumber;
  final String? photoUrl;
  final String phoneNumber;

  DriverModel({
    required this.name,
    required this.rating,
    required this.vehicleNumber,
    this.photoUrl,
    required this.phoneNumber,
  });

  String get initials {
    final names = name.split(' ');
    if (names.length >= 2) {
      return '${names[0][0]}${names[1][0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : 'D';
  }
}

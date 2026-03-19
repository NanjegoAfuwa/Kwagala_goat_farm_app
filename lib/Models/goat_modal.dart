class Goat {
  final String id;
  final String name;
  final String breed;
  final String gender;
  final int ageMonths;
  final double weight;
  final String healthStatus;
  final DateTime dateAdded;
  final String image;

  Goat({
    required this.id,
    required this.name,
    required this.breed,
    required this.gender,
    required this.ageMonths,
    required this.weight,
    required this.healthStatus,
    required this.dateAdded,
    required this.image,
  });

  // Convert Goat object to Map (for Firebase / database)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'breed': breed,
      'gender': gender,
      'ageMonths': ageMonths,
      'weight': weight,
      'healthStatus': healthStatus,
      'dateAdded': dateAdded.toIso8601String(),
      'image': image,
    };
  }

  // Convert Map to Goat object
  factory Goat.fromMap(Map<String, dynamic> map) {
    return Goat(
      id: map['id'],
      name: map['name'],
      breed: map['breed'],
      gender: map['gender'],
      ageMonths: map['ageMonths'],
      weight: map['weight'].toDouble(),
      healthStatus: map['healthStatus'],
      dateAdded: DateTime.parse(map['dateAdded']),
      image: map['image'],
    );
  }
}
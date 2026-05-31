class GoatModel {
  final int id;
  final String name;
  final String tagNumber;
  final String breed;
  final String gender;
  final String age;
  final double weight;
  final bool isPregnant;
  final DateTime? breedingDate;
  final int? gestationDaysRemaining;
  final DateTime dateAdded;
  final String healthStatus;

  GoatModel({
    required this.id,
    required this.name,
    required this.tagNumber,
    required this.breed,
    required this.gender,
    required this.age,
    required this.weight,
    required this.isPregnant,
    this.breedingDate,
    this.gestationDaysRemaining,
    required this.dateAdded,
    required this.healthStatus,
  });

  // Factory constructor to turn Django JSON into a structural Dart instance safely
  factory GoatModel.fromJson(Map<String, dynamic> json) {
    return GoatModel(
      // Safeguard ID parsing using safe null-coalescing type checks
      id: json['id'] is int ? json['id'] : (int.tryParse(json['id']?.toString() ?? '0') ?? 0),
      name: json['name'] ?? 'Unnamed Goat',
      tagNumber: json['tag_id'] ?? json['tag_number'] ?? 'N/A',
      breed: json['breed'] ?? 'Unknown',
      gender: json['gender'] ?? 'Female',
      age: json['age'] ?? 'Unknown',
      weight: json['weight'] != null
          ? (double.tryParse(json['weight'].toString()) ?? 0.0)
          : 0.0,
      isPregnant: json['is_pregnant'] ?? false,
      breedingDate: json['breeding_date'] != null
          ? DateTime.tryParse(json['breeding_date'])
          : null,
      gestationDaysRemaining: json['gestation_days_remaining'],
      // Provide a timestamp fallback in case date_added payload strings return empty
      dateAdded: json['date_added'] != null
          ? DateTime.parse(json['date_added'])
          : DateTime.now(),
      healthStatus: json['health_status'] ?? 'Healthy',
    );
  }

  // Map layout serialization so Flutter can sync additions back to Django
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'tag_id': tagNumber,
      'breed': breed,
      'gender': gender,
      'age': age,
      'weight': weight,
      'is_pregnant': isPregnant,
      'breeding_date': breedingDate?.toIso8601String().split('T')[0],
      'health_status': healthStatus,
    };
  }
}
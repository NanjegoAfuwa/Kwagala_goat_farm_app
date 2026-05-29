class GoatModel {
  final int id;
  final String name;
  final String tagNumber;
  final String breed;
  final String gender;
  final DateTime dateAdded;
  final String? healthStatus;

  GoatModel({
    required this.id,
    required this.name,
    required this.tagNumber,
    required this.breed,
    required this.gender,
    required this.dateAdded,
    this.healthStatus,
  });

  // Factory constructor to turn Django JSON into a structural Dart instance safely
  factory GoatModel.fromJson(Map<String, dynamic> json) {
    return GoatModel(
      // Safeguard ID parsing using safe null-coalescing type checks
      id: json['id'] is int ? json['id'] : (int.tryParse(json['id']?.toString() ?? '0') ?? 0),
      name: json['name'] ?? 'Unnamed Goat',
      tagNumber: json['tag_number'] ?? 'N/A',
      breed: json['breed'] ?? 'Unknown',
      gender: json['gender'] ?? 'Unknown',
      // Provide a timestamp fallback in case date_added payload strings return empty
      dateAdded: json['date_added'] != null 
          ? DateTime.parse(json['date_added']) 
          : DateTime.now(),
      healthStatus: json['health_status'],
    );
  }

  // FIXED: Added mapping layout serialization so Flutter can sync additions back to Django
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'tag_number': tagNumber,
      'breed': breed,
      'gender': gender,
      'date_added': dateAdded.toIso8601String(),
      'health_status': healthStatus,
    };
  }
}
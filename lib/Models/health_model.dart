class HealthRecord {
  final String id;
  final String goatId;
  final String treatment;
  final DateTime date;
  final String notes;

  HealthRecord({
    required this.id,
    required this.goatId,
    required this.treatment,
    required this.date,
    required this.notes,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'goatId': goatId,
      'treatment': treatment,
      'date': date.toIso8601String(),
      'notes': notes,
    };
  }

  factory HealthRecord.fromMap(Map<String, dynamic> map) {
    return HealthRecord(
      id: map['id'],
      goatId: map['goatId'],
      treatment: map['treatment'],
      date: DateTime.parse(map['date']),
      notes: map['notes'],
    );
  }
}
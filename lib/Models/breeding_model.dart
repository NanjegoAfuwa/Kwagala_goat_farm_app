class Breeding {
  final String id;
  final String motherId;
  final String fatherId;
  final DateTime breedingDate;
  final DateTime expectedBirth;
  final int kidsBorn;

  Breeding({
    required this.id,
    required this.motherId,
    required this.fatherId,
    required this.breedingDate,
    required this.expectedBirth,
    required this.kidsBorn,
  });
}
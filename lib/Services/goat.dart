import '../Models/goat.dart';

class GoatService {

  // Temporary goat list (acts like a database)
  final List<Goat> _goats = [];

  // Get all goats
  List<Goat> getGoats() {
    return _goats;
  }

  // Add a new goat
  void addGoat(Goat goat) {
    _goats.add(goat);
  }

  // Delete a goat
  void deleteGoat(String id) {
    _goats.removeWhere((goat) => goat.id == id);
  }

  // Update goat
  void updateGoat(Goat updatedGoat) {
    int index = _goats.indexWhere((goat) => goat.id == updatedGoat.id);

    if (index != -1) {
      _goats[index] = updatedGoat;
    }
  }
}
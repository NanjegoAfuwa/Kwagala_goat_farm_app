import 'package:flutter/material.dart';
import 'add_goat.dart'; // ✅ Added import for Add Goat screen

class GoatsScreen extends StatefulWidget {
  const GoatsScreen({Key? key}) : super(key: key);

  @override
  State<GoatsScreen> createState() => _GoatsScreenState();
}

class _GoatsScreenState extends State<GoatsScreen> {
  final TextEditingController _searchController = TextEditingController();

  String selectedBreed = "All Breeds";
  String selectedGender = "All";

  final List<String> breeds = [
    "All Breeds",
    "Boer",
    "Kalahari",
    "Savanna",
    "Local"
  ];

  final List<String> genders = ["All", "Male", "Female"];

  final List<Map<String, String>> goats = [
    {
      "id": "GT001",
      "name": "Lucky",
      "breed": "Boer",
      "gender": "Male",
      "age": "14 months",
      "weight": "32 kg",
      "dateAdded": "12 Jan 2026",
      "tag": "A101"
    },
    {
      "id": "GT002",
      "name": "Daisy",
      "breed": "Kalahari",
      "gender": "Female",
      "age": "10 months",
      "weight": "28 kg",
      "dateAdded": "05 Feb 2026",
      "tag": "B204"
    },
  ];

  List<Map<String, String>> get filteredGoats {
    return goats.where((goat) {
      final matchesSearch = goat["name"]!
          .toLowerCase()
          .contains(_searchController.text.toLowerCase());

      final matchesBreed =
          selectedBreed == "All Breeds" || goat["breed"] == selectedBreed;

      final matchesGender =
          selectedGender == "All" || goat["gender"] == selectedGender;

      return matchesSearch && matchesBreed && matchesGender;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),

      appBar: AppBar(
        automaticallyImplyLeading: false,
        elevation: 4,
        backgroundColor: Colors.green.shade700,
        centerTitle: false,
        titleSpacing: 0,
        iconTheme: const IconThemeData(color: Colors.white),

        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(3),
          child: Container(
            height: 3,
            color: Colors.orange,
          ),
        ),

        title: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            const SizedBox(width: 4),
            const Text(
              "Goats",
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 18,
                color: Colors.white,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),

      // ✅ FIXED BUTTON NAVIGATION
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.orange,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddGoatScreen(),
            ),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text("Add Goat"),
      ),

      body: Column(
        children: [
          _buildSearchAndFilters(),
          const SizedBox(height: 10),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: filteredGoats.length,
              itemBuilder: (context, index) {
                final goat = filteredGoats[index];
                return GoatCard(
                  id: goat["id"]!,
                  name: goat["name"]!,
                  breed: goat["breed"]!,
                  gender: goat["gender"]!,
                  age: goat["age"]!,
                  weight: goat["weight"]!,
                  dateAdded: goat["dateAdded"]!,
                  tag: goat["tag"]!,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilters() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Column(
        children: [
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: "Search goat...",
              prefixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: Colors.grey.shade100,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _dropdown(
                  selectedBreed,
                  breeds,
                  (val) => setState(() => selectedBreed = val!),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _dropdown(
                  selectedGender,
                  genders,
                  (val) => setState(() => selectedGender = val!),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _dropdown(
      String value, List<String> items, Function(String?) onChanged) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButton<String>(
        value: value,
        isExpanded: true,
        underline: const SizedBox(),
        items: items
            .map((item) =>
                DropdownMenuItem(value: item, child: Text(item)))
            .toList(),
        onChanged: onChanged,
      ),
    );
  }
}

// =====================
// GOAT CARD
// =====================
class GoatCard extends StatelessWidget {
  final String id;
  final String name;
  final String breed;
  final String gender;
  final String age;
  final String weight;
  final String dateAdded;
  final String tag;

  const GoatCard({
    Key? key,
    required this.id,
    required this.name,
    required this.breed,
    required this.gender,
    required this.age,
    required this.weight,
    required this.dateAdded,
    required this.tag,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool isMale = gender == "Male";

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 55,
            height: 55,
            decoration: BoxDecoration(
              color:
                  isMale ? Colors.green.shade50 : Colors.orange.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.pets,
              color: isMale ? Colors.green : Colors.orange,
              size: 30,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "$id - $name",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 6),
                Text("Tag: $tag"),
                Text("Breed: $breed"),
                Text("Age: $age"),
                Text("Weight: $weight"),
                Text("Date Added: $dateAdded"),
                const SizedBox(height: 6),
                Text(
                  gender,
                  style: TextStyle(
                    color: isMale ? Colors.green : Colors.orange,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.more_vert, color: Colors.grey),
        ],
      ),
    );
  }
}
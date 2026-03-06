import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class EditFarmScreen extends StatefulWidget {
  const EditFarmScreen({Key? key}) : super(key: key);

  @override
  State<EditFarmScreen> createState() => _EditFarmScreenState();
}

class _EditFarmScreenState extends State<EditFarmScreen> {
  // Existing farm info
  String existingName = "Kwagala Goat Farm";
  String existingLog = "Leading goat farm in Uganda, focusing on quality breeding and care.";
  String existingLocation = "Kampala, Uganda";
  int existingGoats = 25;
  String existingHealthStatus = "Healthy";

  // Controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _logController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _goatsController = TextEditingController();
  final TextEditingController _healthController = TextEditingController();

  File? _farmImage; // Selected image file
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _nameController.text = existingName;
    _logController.text = existingLog;
    _locationController.text = existingLocation;
    _goatsController.text = existingGoats.toString();
    _healthController.text = existingHealthStatus;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _logController.dispose();
    _locationController.dispose();
    _goatsController.dispose();
    _healthController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _farmImage = File(image.path);
      });
    }
  }

  void _saveFarmInfo() {
    String name = _nameController.text;
    String log = _logController.text;
    String location = _locationController.text;
    int goats = int.tryParse(_goatsController.text) ?? 0;
    String health = _healthController.text;

    // TODO: Save logic
    print("Farm Name: $name");
    print("Log: $log");
    print("Location: $location");
    print("Number of Goats: $goats");
    print("Health Status: $health");
    print("Image: ${_farmImage?.path ?? 'No image changed'}");

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Farm info updated successfully!")),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: AppBar(
          backgroundColor: Colors.green.shade700,
          title: const Text("Edit Farm Info"),
          centerTitle: true,
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(3),
            child: Container(
              color: Colors.orange,
              height: 3,
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // ================= Top Farm Image Card =================
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green.shade700,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Stack(
                      children: [
                        CircleAvatar(
                          radius: width * 0.15,
                          backgroundColor: Colors.white,
                          backgroundImage: _farmImage != null
                              ? FileImage(_farmImage!)
                              : const AssetImage('assets/farm_placeholder.jpg')
                                  as ImageProvider,
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: InkWell(
                            onTap: _pickImage,
                            child: CircleAvatar(
                              radius: width * 0.05,
                              backgroundColor: Colors.white,
                              child: Icon(
                                Icons.edit,
                                size: width * 0.05,
                                color: Colors.orange,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      existingName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      existingLocation,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // ================= Editable Form =================
              Column(
                children: [
                  _buildTextField(controller: _nameController, label: "Farm Name", icon: Icons.home_work),
                  const SizedBox(height: 12),
                  _buildTextField(controller: _logController, label: "Farm Log", icon: Icons.description, maxLines: 3),
                  const SizedBox(height: 12),
                  _buildTextField(controller: _locationController, label: "Location", icon: Icons.location_on),
                  const SizedBox(height: 12),
                  _buildTextField(controller: _goatsController, label: "Number of Goats", icon: Icons.pets, keyboardType: TextInputType.number),
                  const SizedBox(height: 12),
                  _buildTextField(controller: _healthController, label: "Health Status", icon: Icons.health_and_safety),
                ],
              ),

              const SizedBox(height: 30),

              // ================= Save Button =================
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _saveFarmInfo,
                  child: const Text("Save Changes", style: TextStyle(fontSize: 16, color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade700,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ================= Helper Method for Input Fields =================
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Focus(
      child: Builder(
        builder: (context) {
          final hasFocus = Focus.of(context).hasFocus;
          return TextField(
            controller: controller,
            maxLines: maxLines,
            keyboardType: keyboardType,
            decoration: InputDecoration(
              labelText: label,
              prefixIcon: Icon(icon, color: Colors.orange),
              filled: true,
              fillColor: Colors.white,
              focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.orange, width: 2)),
              enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.white, width: 2)),
            ),
          );
        },
      ),
    );
  }
}
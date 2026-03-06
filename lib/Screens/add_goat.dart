import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class AddGoatScreen extends StatefulWidget {
  const AddGoatScreen({Key? key}) : super(key: key);

  @override
  State<AddGoatScreen> createState() => _AddGoatScreenState();
}

class _AddGoatScreenState extends State<AddGoatScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _breedController = TextEditingController();
  final TextEditingController _genderController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _healthController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();

  // Image Picker
  File? _goatImage;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _goatImage = File(image.path);
      });
    }
  }

  void _saveGoat() {
    if (_formKey.currentState!.validate()) {
      String name = _nameController.text;
      String breed = _breedController.text;
      String gender = _genderController.text;
      String age = _ageController.text;
      String weight = _weightController.text;
      String health = _healthController.text;
      String date = _dateController.text;

      print("Goat Name: $name");
      print("Breed: $breed");
      print("Gender: $gender");
      print("Age: $age");
      print("Weight: $weight");
      print("Health: $health");
      print("Date Added: $date");
      print("Image Path: ${_goatImage?.path ?? 'No image selected'}");

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Goat added successfully!"),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _breedController.dispose();
    _genderController.dispose();
    _ageController.dispose();
    _weightController.dispose();
    _healthController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text("Add Goat"),
        centerTitle: true,
        backgroundColor: Colors.green,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(2),
          child: Container(
            color: Colors.orange,
            height: 2,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Goat Image
              Stack(
                children: [
                  CircleAvatar(
                    radius: width * 0.2,
                    backgroundColor: Colors.white,
                    backgroundImage: _goatImage != null
                        ? FileImage(_goatImage!)
                        : const AssetImage('assets/goat_placeholder.jpg')
                            as ImageProvider,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: InkWell(
                      onTap: _pickImage,
                      child: CircleAvatar(
                        radius: width * 0.06,
                        backgroundColor: Colors.orange,
                        child: const Icon(
                          Icons.edit,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Goat Details Form
              _buildTextField(_nameController, "Goat Name", Icons.pets),
              const SizedBox(height: 12),
              _buildTextField(_breedController, "Breed", Icons.home_work),
              const SizedBox(height: 12),
              _buildTextField(_genderController, "Gender", Icons.wc),
              const SizedBox(height: 12),
              _buildTextField(_ageController, "Age (months)", Icons.calendar_today,
                  keyboardType: TextInputType.number),
              const SizedBox(height: 12),
              _buildTextField(
                  _weightController, "Weight (kg)", Icons.line_weight,
                  keyboardType: TextInputType.number),
              const SizedBox(height: 12),
              _buildTextField(_healthController, "Health Status", Icons.health_and_safety),
              const SizedBox(height: 12),
              _buildTextField(_dateController, "Date Added", Icons.date_range),

              const SizedBox(height: 30),

              // Save Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _saveGoat,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    "Add Goat",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
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

  // Helper for Text Fields with orange label on focus
  Widget _buildTextField(
      TextEditingController controller, String label, IconData icon,
      {TextInputType keyboardType = TextInputType.text}) {
    return Focus(
      child: Builder(builder: (context) {
        final hasFocus = Focus.of(context).hasFocus;
        return TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          validator: (val) {
            if (val == null || val.isEmpty) return "Please enter $label";
            return null;
          },
          decoration: InputDecoration(
            labelText: label,
            labelStyle: TextStyle(
              color: hasFocus ? Colors.orange : Colors.grey.shade700, // 🔹 Label turns orange on focus
            ),
            prefixIcon: Icon(icon, color: Colors.green.shade700),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.orange, width: 2),
            ),
          ),
        );
      }),
    );
  }
}
import 'package:flutter/material.dart';

class AddGoatScreen extends StatefulWidget {
  @override
  _AddGoatScreenState createState() => _AddGoatScreenState();
}

class _AddGoatScreenState extends State<AddGoatScreen> {
  final _formKey = GlobalKey<FormState>();

  TextEditingController tagController = TextEditingController();
  TextEditingController breedController = TextEditingController();
  TextEditingController ageController = TextEditingController();
  TextEditingController weightController = TextEditingController();

  String healthStatus = "Healthy";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Add Goat")),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Tag Number
              TextFormField(
                controller: tagController,
                decoration: InputDecoration(labelText: "Tag Number"),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Enter tag number';
                  }
                  return null;
                },
              ),

              // Breed
              TextFormField(
                controller: breedController,
                decoration: InputDecoration(labelText: "Breed"),
              ),

              // Age
              TextFormField(
                controller: ageController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: "Age (months)"),
              ),

              // Weight
              TextFormField(
                controller: weightController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: "Weight (kg)"),
              ),

              SizedBox(height: 20),

              // Health Dropdown
              DropdownButtonFormField(
                value: healthStatus,
                items: ["Healthy", "Sick", "Under Observation"]
                    .map((status) => DropdownMenuItem(
                          value: status,
                          child: Text(status),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    healthStatus = value!;
                  });
                },
                decoration: InputDecoration(labelText: "Health Status"),
              ),

              SizedBox(height: 30),

              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    // For now, just show the result
                    showDialog(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: Text("Goat Added"),
                        content: Text(
                          "Tag: ${tagController.text}\n"
                          "Breed: ${breedController.text}\n"
                          "Age: ${ageController.text}\n"
                          "Weight: ${weightController.text}\n"
                          "Health: $healthStatus",
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text("OK"),
                          )
                        ],
                      ),
                    );
                  }
                },
                child: Text("Save Goat"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

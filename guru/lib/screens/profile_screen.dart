import 'package:flutter/material.dart';
import '../services/mock_data.dart';
import 'assessments_screen.dart';
import 'package:camera/camera.dart'; // Import cameras

class UserProfileScreen extends StatefulWidget {
  final List<CameraDescription> cameras;

  const UserProfileScreen({super.key, required this.cameras});

  @override
  _UserProfileScreenState createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  
  final _firstNameController = TextEditingController(text: mockUser.firstName);
  final _lastNameController = TextEditingController(text: mockUser.lastName);
  final _heightController = TextEditingController(text: mockUser.height.toString());
  final _weightController = TextEditingController(text: mockUser.weight.toString());
  final _pincodeController = TextEditingController(text: mockUser.pincode);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Your Profile')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(controller: _firstNameController, decoration: const InputDecoration(labelText: 'First Name')),
              TextFormField(controller: _lastNameController, decoration: const InputDecoration(labelText: 'Last Name')),
              TextFormField(controller: _heightController, decoration: const InputDecoration(labelText: 'Height (cm)', suffixText: 'cm')),
              TextFormField(controller: _weightController, decoration: const InputDecoration(labelText: 'Weight (kg)', suffixText: 'kg')),
              TextFormField(controller: _pincodeController, decoration: const InputDecoration(labelText: 'Pincode')),
              
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    mockUser.firstName = _firstNameController.text;
                    mockUser.lastName = _lastNameController.text;
                    mockUser.height = double.tryParse(_heightController.text) ?? mockUser.height;
                    mockUser.weight = double.tryParse(_weightController.text) ?? mockUser.weight;
                    mockUser.pincode = _pincodeController.text;
                    
                    Navigator.push(context, MaterialPageRoute(builder: (context) => AssessmentsScreen(cameras: widget.cameras)));
                  }
                },
                child: const Text('Save & Proceed'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
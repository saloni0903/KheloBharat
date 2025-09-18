import 'package:flutter/material.dart';
import 'camera_screen.dart';
import '../services/mock_data.dart';
import 'package:camera/camera.dart'; 

class AssessmentsScreen extends StatelessWidget {
  final List<CameraDescription> cameras;
  const AssessmentsScreen({super.key, required this.cameras});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Assessments')),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.fitness_center),
            title: const Text('Your Stats'),
            subtitle: Text('BMI: ${mockUser.bmi.toStringAsFixed(2)}'),
            onTap: () {
              // Navigate to a dedicated dashboard screen
            },
          ),
          const Divider(),
          _buildAssessmentCard(
            context,
            'Vertical Jump',
            'Measure your explosive power!',
            true,
          ),
          _buildAssessmentCard(
            context,
            'Sit-ups',
            'Measure your core endurance.',
            false,
          ),
          _buildAssessmentCard(
            context,
            'Dash',
            'Measure your speed and agility.',
            false,
          ),
        ],
      ),
    );
  }

  Widget _buildAssessmentCard(BuildContext context, String title, String description, bool isActive) {
    return Card(
      child: ListTile(
        title: Text(title),
        subtitle: Text(description),
        trailing: isActive ? const Icon(Icons.play_circle_fill, color: Colors.green) : const Text('Coming Soon'),
        onTap: () {
          if (isActive) {
            Navigator.push(context, MaterialPageRoute(builder: (context) => CameraScreen(testType: title, cameras: cameras)));
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('This assessment is coming soon!')),
            );
          }
        },
      ),
    );
  }
}
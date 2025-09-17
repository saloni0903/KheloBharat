import 'dart:io';
import 'dart:isolate';
import 'package:flutter/material.dart';

// Make sure to fix imports according to your project name
import 'services/movenet_service.dart';
import 'services/api_service.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Jump Test Prototype',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const JumpCounterScreen(),
    );
  }
}

class JumpCounterScreen extends StatefulWidget {
  const JumpCounterScreen({super.key});

  @override
  _JumpCounterScreenState createState() => _JumpCounterScreenState();
}

class _JumpCounterScreenState extends State<JumpCounterScreen> {
  final ApiService _apiService = ApiService();
  String _statusMessage = 'Press the button to start the jump test.';

  Future<void> _startJumpTest() async {
    setState(() {
      _statusMessage = 'Recording video...';
    });

    // Dummy video path (replace with real camera integration later)
    final videoPath = 'path/to/recorded/video.mp4';

    setState(() {
      _statusMessage = 'Video recorded. Analyzing on-device...';
    });

    // Spawn isolate for AI analysis
    final ReceivePort receivePort = ReceivePort();
    await Isolate.spawn(jumpAnalysisEntryPoint, [receivePort.sendPort, videoPath]);

    JumpAnalysisResult result = await receivePort.first;

    setState(() {
      _statusMessage = 'Analysis complete. Jumps detected: ${result.jumpCount}';
    });

    if (result.jumpCount > 0) {
      final clipFile = File(result.proofClipPath);

      // TODO: implement real file upload
      // String clipUrl = await _apiService.uploadFile(clipFile);

      String clipUrl = 'https://your-storage.com/proof-clip.mp4';

      final success = await _apiService.submitJumpCount(
        athleteId: 'athlete_123',
        jumpCount: result.jumpCount,
        proofClipUrl: clipUrl,
      );

      if (success) {
        setState(() {
          _statusMessage = 'Submission successful! Check the dashboard.';
        });
      } else {
        setState(() {
          _statusMessage = 'Submission failed. Check logs.';
        });
      }
    } else {
      setState(() {
        _statusMessage = 'No jumps detected.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Rapid Prototype Demo')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              ElevatedButton.icon(
                onPressed: _startJumpTest,
                icon: const Icon(Icons.fitness_center),
                label: const Text('Start Jump Test'),
              ),
              const SizedBox(height: 20),
              Text(_statusMessage),
            ],
          ),
        ),
      ),
    );
  }
}

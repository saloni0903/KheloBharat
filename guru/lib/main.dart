import 'dart:isolate';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'services/movenet_service.dart';
import 'services/api_service.dart';

List<CameraDescription> cameras = [];

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    cameras = await availableCameras();
  } on CameraException catch (e) {
    print('Error: ${e.code}\nError Message: ${e.description}');
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AI Jump Detector',
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
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;

  @override
  void initState() {
    super.initState();
    if (cameras.isNotEmpty) {
      _controller = CameraController(cameras[0], ResolutionPreset.low);
      _initializeControllerFuture = _controller.initialize();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _startJumpTest() async {
    if (!mounted || _controller.value.isRecordingVideo) {
      return;
    }
    try {
      await _initializeControllerFuture;
      setState(() { _statusMessage = 'Recording...'; });
      await _controller.startVideoRecording();
      await Future.delayed(const Duration(seconds: 10));
      XFile videoFile = await _controller.stopVideoRecording();
      setState(() { _statusMessage = 'Analysis in progress...'; });

      // Pass video path to the Isolate
      JumpAnalysisResult result = await _runAnalysisInIsolate(videoFile.path);

      if (result.jumpCount > 0) {
        setState(() { _statusMessage = 'Jumps detected: ${result.jumpCount}'; });
        String clipUrl = await _apiService.uploadProofClip(File(result.proofClipPath));
        if (clipUrl.isNotEmpty) {
          final success = await _apiService.submitJumpCount(
            athleteId: 'athlete_123',
            jumpCount: result.jumpCount,
            proofClipUrl: clipUrl,
          );
          setState(() {
            _statusMessage = success ? 'Data submitted successfully!' : 'Submission failed.';
          });
        }
      } else {
        setState(() { _statusMessage = 'No jumps detected.'; });
      }
    } catch (e) {
      setState(() { _statusMessage = 'An error occurred: $e'; });
    }
  }

  Future<JumpAnalysisResult> _runAnalysisInIsolate(String videoPath) async {
    final ReceivePort receivePort = ReceivePort();
    await Isolate.spawn(jumpAnalysisEntryPoint, [receivePort.sendPort, videoPath]);
    return await receivePort.first;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('AI Jump Detector')),
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return Column(
              children: [
                Expanded(child: CameraPreview(_controller)),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      ElevatedButton(
                        onPressed: _startJumpTest,
                        child: const Text('Start Jump Test'),
                      ),
                      const SizedBox(height: 16),
                      Text(_statusMessage),
                    ],
                  ),
                ),
              ],
            );
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}
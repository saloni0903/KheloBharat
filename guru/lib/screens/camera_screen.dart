import 'dart:async';
import 'dart:io';
import 'dart:isolate';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/movenet_service.dart' show JumpAnalysisResult, jumpAnalysisEntryPoint;
import 'results_screen.dart';

class CameraScreen extends StatefulWidget {
  final String testType;
  final List<CameraDescription> cameras;

  const CameraScreen({super.key, required this.testType, required this.cameras});

  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;
  final ApiService _apiService = ApiService();
  String _statusMessage = 'Get ready...';
  int _countdown = 5;
  Timer? _countdownTimer;

  bool _isAnalyzing = false;
  bool _isRecording = false;

  @override
  void initState() {
    super.initState();
    if (widget.cameras.isNotEmpty) {
      _controller = CameraController(widget.cameras[0], ResolutionPreset.low, enableAudio: true);
      _initializeControllerFuture = _controller.initialize().then((_) {
        if (!mounted) return;
        setState(() {});
        _startCountdown();
      });
    }
  }

  void _startCountdown() {
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_countdown == 0) {
        timer.cancel();
        _startRecording();
      } else {
        setState(() {
          _statusMessage = 'Recording in $_countdown...';
          _countdown--;
        });
      }
    });
  }

  Future<void> _startRecording() async {
    if (!_controller.value.isInitialized || _controller.value.isRecordingVideo) {
      return;
    }
    try {
      setState(() { 
        _statusMessage = 'Recording for 10 seconds...'; 
        _isRecording = true;
      });
      await _controller.startVideoRecording();
      await Future.delayed(const Duration(seconds: 10));
      final videoFile = await _controller.stopVideoRecording();
      _processVideo(videoFile.path);
    } catch (e) {
      print(e);
      setState(() { 
        _statusMessage = 'Recording failed.'; 
        _isRecording = false;
      });
    }
  }

  Future<void> _processVideo(String videoPath) async {
    setState(() { 
      _statusMessage = 'Analysis in progress...'; 
      _isRecording = false;
      _isAnalyzing = true;
    });

    final receivePort = ReceivePort();
    await Isolate.spawn(jumpAnalysisEntryPoint, [receivePort.sendPort, videoPath]);
    
    final JumpAnalysisResult result = await receivePort.first;
    
    setState(() { _isAnalyzing = false; });
    
    if (result.jumpCount > 0) {
      setState(() { _statusMessage = 'Jumps detected: ${result.jumpCount}. Uploading...'; });
      final clipUrl = await _apiService.uploadProofClip(File(result.proofClipPath));
      
      final success = await _apiService.submitResult(
        athleteId: 'athlete_123',
        testType: widget.testType,
        jumpCount: result.jumpCount,
        proofClipUrl: clipUrl,
      );
      if (success) {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => ResultsScreen(score: result.jumpCount, testType: widget.testType)));
      } else {
        setState(() { _statusMessage = 'Submission failed.'; });
      }
    } else {
      setState(() { _statusMessage = 'No jumps detected.'; });
    }
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.testType)),
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return Stack(
              alignment: Alignment.bottomCenter,
              children: [
                if (_controller.value.isInitialized)
                  SizedBox(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height,
                    child: CameraPreview(_controller),
                  ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      if (_isRecording)
                        const LinearProgressIndicator(minHeight: 10),
                      if (_isAnalyzing)
                        const LinearProgressIndicator(minHeight: 10),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          _statusMessage,
                          style: const TextStyle(color: Colors.white, fontSize: 18),
                          textAlign: TextAlign.center,
                        ),
                      ),
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
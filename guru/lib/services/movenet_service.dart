import 'dart:isolate';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img_lib;
import 'package:video_player/video_player.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:math';

// Ported Angle Calculation from Python
double calculateAngle(a, b, c) {
  var p1 = a;
  var p2 = b;
  var p3 = c;
  var angle = (atan2(p3.dy - p2.dy, p3.dx - p2.dx) - atan2(p1.dy - p2.dy, p1.dx - p2.dx)) * 180 / pi;
  if (angle.abs() > 180) {
    angle = 360 - angle.abs();
  }
  return angle.abs();
}

// Data class to return results from Isolate
class JumpAnalysisResult {
  final int jumpCount;
  final String proofClipPath;
  JumpAnalysisResult(this.jumpCount, this.proofClipPath);
}

// Entry point for the Isolate
void jumpAnalysisEntryPoint(List<dynamic> args) async {
  SendPort sendPort = args[0];
  String videoPath = args[1];

  try {
    // Load the TFLite model from assets
    final interpreter = await Interpreter.fromAsset('movenet_singlepose_lightning.tflite');
    
    // Set up video controller
    final controller = VideoPlayerController.file(File(videoPath));
    await controller.initialize();
    
    int jumpCount = 0;
    bool inJumpMotion = false;
    double maxHipY = 0.0;
    
    // The frames processing logic is complex. This is a simplified loop.
    // In a real implementation, you'd capture and process frames sequentially.
    // Here, we'll just simulate the process for demonstration.
    for (int i = 0; i < 100; i++) { // Simulate 100 frames
      // In a real app, you'd get the current frame from the video controller.
      // E.g., from `controller.value.position`.
      
      // Dummy input data for the model
      var input = List.filled(1 * 192 * 192 * 3, 0).reshape([1, 192, 192, 3]);
      var output = List.filled(1 * 1 * 17 * 3, 0).reshape([1, 1, 17, 3]);
      
      interpreter.run(input, output);
      
      var keypoints = output[0][0]; // Assuming output is [1, 1, 17, 3]
      
      // Ported jump detection logic
      var leftHip = keypoints[11];
      var rightHip = keypoints[12];
      var leftKnee = keypoints[13];
      var leftAnkle = keypoints[15];

      double hipY = (leftHip[0] + rightHip[0]) / 2;
      double leftHipAngle = calculateAngle(leftAnkle, leftKnee, leftHip);

      if (hipY > maxHipY) {
        maxHipY = hipY;
      }
      
      if (hipY < maxHipY - 0.05 && leftHipAngle > 160) {
        if (!inJumpMotion) {
          inJumpMotion = true;
        }
      }
      
      if (inJumpMotion && hipY > maxHipY - 0.02) {
        jumpCount++;
        inJumpMotion = false;
        maxHipY = hipY;
      }
    }
    
    // Get temporary directory for proof clip
    final appDir = await getTemporaryDirectory();
    final proofClipPath = '${appDir.path}/proof_clip.mp4';
    
    // In a real app, you'd use a video editing library to trim the video here.
    // We'll just copy the original video as a placeholder.
    await File(videoPath).copy(proofClipPath);
    
    interpreter.close();
    controller.dispose();
    
    sendPort.send(JumpAnalysisResult(jumpCount, proofClipPath));

  } catch (e, stacktrace) {
    print('Isolate Error: $e');
    print(stacktrace);
    sendPort.send(JumpAnalysisResult(0, '')); // Send an error result
  }
}
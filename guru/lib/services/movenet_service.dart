import 'dart:io';
import 'dart:isolate';
import 'package:flutter/services.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:video_player/video_player.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:math';

// Data class to return results from Isolate
class JumpAnalysisResult {
  final int jumpCount;
  final String proofClipPath;
  JumpAnalysisResult(this.jumpCount, this.proofClipPath);
}

// Ported Angle Calculation from Python
double _calculateAngle(a, b, c) {
  var p1 = a;
  var p2 = b;
  var p3 = c;
  var angle = (atan2(p3.dy - p2.dy, p3.dx - p2.dx) -
      atan2(p1.dy - p2.dy, p1.dx - p2.dx)) * 180 / pi;
  if (angle.abs() > 180) {
    angle = 360 - angle.abs();
  }
  return angle.abs();
}

// Entry point for the Isolate
void jumpAnalysisEntryPoint(List<dynamic> args) async {
  SendPort sendPort = args[0];
  String videoPath = args[1];

  try {
    final interpreter = await Interpreter.fromAsset('assets/movenet_singlepose_lightning.tflite');
    final controller = VideoPlayerController.file(File(videoPath));
    await controller.initialize();
    
    int jumpCount = 0;
    bool inJumpMotion = false;
    double maxHipY = 0.0;

    // Simulate video frame processing
    const int numFrames = 100;
    for (int i = 0; i < numFrames; i++) {
      // NOTE: Here you'd extract frames from the video.
      // For this prototype, we'll use a simplified loop.
      
      // Dummy input and output tensors
      var input = [
        [
          [
            [0.0, 0.0, 0.0],
            [0.0, 0.0, 0.0]
          ]
        ]
      ];
      var output = List.filled(1 * 1 * 17 * 3, 0).reshape([1, 1, 17, 3]);
      
      interpreter.run(input, output);
      
      var keypoints = output[0][0];

      // Robust jump detection logic (ported from Python)
      var leftHip = keypoints[11];
      var rightHip = keypoints[12];
      var leftKnee = keypoints[13];
      var leftAnkle = keypoints[15];

      double hipY = (leftHip[0] + rightHip[0]) / 2;
      double leftHipAngle = _calculateAngle(leftAnkle, leftKnee, leftHip);

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
    
    final appDir = await getTemporaryDirectory();
    final proofClipPath = '${appDir.path}/proof_clip.mp4';
    await File(videoPath).copy(proofClipPath);
    
    interpreter.close();
    controller.dispose();
    
    sendPort.send(JumpAnalysisResult(jumpCount, proofClipPath));
  } catch (e, stacktrace) {
    print('Isolate Error: $e');
    print(stacktrace);
    sendPort.send(JumpAnalysisResult(0, ''));
  }
}
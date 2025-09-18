import 'dart:io';
import 'dart:isolate';
import 'package:flutter/widgets.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:math';

// Data class to return results from Isolate
class JumpAnalysisResult {
  final int jumpCount;
  final String proofClipPath;
  JumpAnalysisResult(this.jumpCount, this.proofClipPath);
}

double _calculateAngle(a, b, c) {
  final p1 = a;
  final p2 = b;
  final p3 = c;
  var angle = (atan2(p3.dy - p2.dy, p3.dx - p2.dx) -
      atan2(p1.dy - p2.dy, p1.dx - p2.dx)) * 180 / pi;
  if (angle.abs() > 180) {
    angle = 360 - angle.abs();
  }
  return angle.abs();
}

// Entry point for the Isolate
void jumpAnalysisEntryPoint(List<dynamic> args) async {
  WidgetsFlutterBinding.ensureInitialized();
  
  SendPort sendPort = args[0];
  String videoPath = args[1];

  try {
    final interpreter = await Interpreter.fromAsset('assets/movenet_singlepose_lightning.tflite');
    
    int jumpCount = 0;
    bool inJumpMotion = false;
    double maxHipY = 0.0;
    
    for (int i = 0; i < 100; i++) {
      var dummyLeftHipY = 0.5 + 0.2 * sin(2 * pi * i / 25);
      var leftHip = Point(0.5, dummyLeftHipY);
      
      if (leftHip.y > maxHipY) {
        maxHipY = leftHip.y;
      }
      
      if (leftHip.y < maxHipY - 0.05 && !inJumpMotion) {
          inJumpMotion = true;
      }
      
      if (inJumpMotion && leftHip.y > maxHipY - 0.02) {
        jumpCount++;
        inJumpMotion = false;
        maxHipY = leftHip.y;
      }
    }
    
    final appDir = await getTemporaryDirectory();
    final proofClipPath = '${appDir.path}/proof_clip.mp4';
    await File(videoPath).copy(proofClipPath);
    
    interpreter.close();
    
    sendPort.send(JumpAnalysisResult(jumpCount, proofClipPath));

  } catch (e, stacktrace) {
    print('Isolate Error: $e');
    print(stacktrace);
    sendPort.send(JumpAnalysisResult(0, ''));
  }
}
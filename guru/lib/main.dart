import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:permission_handler/permission_handler.dart';
import 'screens/profile_screen.dart';

List<CameraDescription> cameras = [];

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await [Permission.camera, Permission.storage, Permission.microphone].request();
  try {
    cameras = await availableCameras();
  } on CameraException catch (e) {
    print('Error getting cameras: ${e.code}\nError Message: ${e.description}');
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SAI Talent Assessment',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: UserProfileScreen(cameras: cameras), // FIX: Passing cameras list here
    );
  }
}
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class ApiService {
  // Use 10.0.2.2 for Android Emulator, or your local IP for a physical device.
  final String _baseUrl = 'http://10.0.2.2:8000';

  Future<bool> submitJumpCount({
    required String athleteId,
    required int jumpCount,
    required String proofClipUrl,
  }) async {
    final url = Uri.parse('$_baseUrl/submit_result');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'athlete_id': athleteId,
          'test_type': 'Vertical Jump',
          'jump_count': jumpCount,
          'proof_clip_url': proofClipUrl,
        }),
      );
      return response.statusCode == 200;
    } catch (e) {
      print('API call failed: $e');
      return false;
    }
  }

  // NOTE: In a real-world scenario, you would upload the file to a service like AWS S3 or Firebase Storage.
  // This function is a placeholder for that logic.
  Future<String> uploadProofClip(File clipFile) async {
    // Simulating a successful upload to a dummy URL.
    await Future.delayed(const Duration(seconds: 2));
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return 'https://your-storage-service.com/clips/athlete_${timestamp}.mp4';
  }
}
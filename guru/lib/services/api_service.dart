import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class ApiService {
  final String _baseUrl = 'http://10.0.2.2:8000'; // For Android Emulator

  Future<bool> submitResult({
    required String athleteId,
    required String testType,
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
          'test_type': testType,
          'jump_count': jumpCount,
          'proof_clip_url': proofClipUrl,
        }),
      );
      print('Response Status: ${response.statusCode}');
      print('Response Body: ${response.body}');
      return response.statusCode == 200;
    } catch (e) {
      print('API call failed: $e');
      return false;
    }
  }

  Future<String> uploadProofClip(File clipFile) async {
    print('Simulating proof clip upload...');
    await Future.delayed(const Duration(seconds: 2));
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final dummyUrl = 'https://your-storage-service.com/clips/athlete_$timestamp.mp4';
    print('Simulated upload complete. URL: $dummyUrl');
    return dummyUrl;
  }
}
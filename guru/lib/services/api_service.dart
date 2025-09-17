import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  final String _baseUrl = 'http://10.0.2.2:8000'; // Android Emulator ke liye

  // Agar tum physical device pe test kar rahe ho, apne laptop ka IP yahan daalna
  // Example: final String _baseUrl = 'http://192.168.1.5:8000';

  Future<bool> submitJumpCount({
    required String athleteId,
    required int jumpCount,
    required String proofClipUrl, // <-- naya field
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
          'proof_clip_url': proofClipUrl, // <-- backend schema ke hisaab se
        }),
      );

      if (response.statusCode == 200) {
        print('✅ Successfully submitted data to backend.');
        return true;
      } else {
        print('❌ Failed to submit data. Status code: ${response.statusCode}');
        print('Response body: ${response.body}');
        return false;
      }
    } catch (e) {
      print('⚠️ Error during API call: $e');
      return false;
    }
  }
}

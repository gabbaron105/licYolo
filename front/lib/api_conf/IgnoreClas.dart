import 'dart:convert';
import 'package:http/http.dart' as http;

class IgnoreService {
  static const String baseUrl = 'http://192.168.50.182:5000';

  static Future<Map<String, dynamic>> viewIgnoredClasses() async {
    final url = '$baseUrl/view-ignored-classes';
    print('Fetching ignored classes from: $url'); // Debug print
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      print('Response body: ${response.body}'); // Debug print
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load ignored classes');
    }
  }

  static Future<Map<String, dynamic>> editIgnoredClasses(List<int> newClasses, List<int> removeClasses) async {
    final url = '$baseUrl/edit-ignored-classes';
    print('Editing ignored classes at: $url'); // Debug print
    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'new_classes': newClasses,
        'remove_classes': removeClasses,
      }),
    );
    if (response.statusCode == 200) {
      print('Response body: ${response.body}'); // Debug print
      return json.decode(response.body);
    } else {
      throw Exception('Failed to edit ignored classes');
    }
  }
}
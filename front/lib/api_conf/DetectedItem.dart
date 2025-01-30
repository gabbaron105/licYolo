import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'http://192.168.50.182:5000';

  static Future<List<DetectedItem>> fetchAllItems() async {
    final url = '$baseUrl/get-all';
    print('Fetching all items from: $url'); 
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      print('Response body: ${response.body}'); 
      final Map<String, dynamic> jsonData = json.decode(response.body);
      final items = jsonData.entries.map((entry) => DetectedItem.fromJson(entry.value, entry.key)).toList();
      for (var item in items) {
        print('ItemID: ${item.itemID}'); 
      }
      return items;
    } else {
      throw Exception('Failed to load items');
    }
  }

  static Future<List<DetectedItem>> fetchItemsByClass(String className) async {
    final url = '$baseUrl/get-by-class/$className';
    print('Fetching items by class from: $url'); // Debug print
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      print('Response body: ${response.body}'); // Debug print
      final Map<String, dynamic> jsonData = json.decode(response.body);
      return jsonData.entries.map((entry) => DetectedItem.fromJson(entry.value, entry.key)).toList();
    } else {
      throw Exception('Failed to load items by class');
    }
  }

  static Future<String> fetchFrameImage(int frameNumber) async {
    final url = '$baseUrl/get-frame/$frameNumber';
    print('Fetching frame image from: $url'); // Debug print
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      return url;
    } else {
      throw Exception('Failed to load frame image');
    }
  }

  static Future<DetectedItem> fetchItemDetails(String itemId) async {
    final url = '$baseUrl/get-item-details/$itemId';
    print('Fetching item details from: $url'); // Debug print
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      print('Response body: ${response.body}'); // Debug print
      final Map<String, dynamic> jsonData = json.decode(response.body);
      return DetectedItem.fromJson(jsonData, itemId); 
    } else {
      throw Exception('Failed to load item details');
    }
  }
}

class DetectedItem {
  final String itemID; 
  final Bbox bbox;
  final Center center;
  final int objectClass;
  final String color;
  final int frame;
  final String name;
  final DateTime timestamp;

  DetectedItem({
    required this.itemID,
    required this.bbox,
    required this.center,
    required this.objectClass,
    required this.color,
    required this.frame,
    required this.name,
    required this.timestamp,
  });

  factory DetectedItem.fromJson(Map<String, dynamic> json, String itemID) {
    return DetectedItem(
      itemID: itemID, 
      bbox: Bbox.fromJson(json['bbox'] ?? {}),
      center: Center.fromJson(json['center'] ?? {}),
      objectClass: json['class'] ?? 0,
      color: json['color'] ?? '#000000',
      frame: json['frame'] ?? 0,
      name: json['name'] ?? 'Unknown',
      timestamp: DateTime.parse(json['timestamp'] ?? DateTime.now().toIso8601String()),
    );
  }
}

class Bbox {
  final double xmin;
  final double xmax;
  final double ymin;
  final double ymax;

  Bbox({
    required this.xmin,
    required this.xmax,
    required this.ymin,
    required this.ymax,
  });

  factory Bbox.fromJson(Map<String, dynamic> json) {
    return Bbox(
      xmin: (json['xmin'] ?? 0.0).toDouble(),
      xmax: (json['xmax'] ?? 0.0).toDouble(),
      ymin: (json['ymin'] ?? 0.0).toDouble(),
      ymax: (json['ymax'] ?? 0.0).toDouble(),
    );
  }
}

class Center {
  final double x;
  final double y;

  Center({
    required this.x,
    required this.y,
  });

  factory Center.fromJson(Map<String, dynamic> json) {
    return Center(
      x: (json['x'] ?? 0.0).toDouble(),
      y: (json['y'] ?? 0.0).toDouble(),
    );
  }
}

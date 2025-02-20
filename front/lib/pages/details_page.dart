import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../components/custom_navbar.dart';
import '../api_conf/DetectedItem.dart' as api;
import '../api_conf/Vision.dart';

class DetailsPage extends StatefulWidget {
  final String itemId;

  const DetailsPage({super.key, required this.itemId});

  @override
  _DetailsPageState createState() => _DetailsPageState();
}

class _DetailsPageState extends State<DetailsPage> {
  late Future<api.DetectedItem> itemDetails;
  late Future<Map<String, dynamic>> visionData;
  int _currentIndex = 0;
  final FlutterTts flutterTts = FlutterTts(); // Inicjalizacja TTS

  @override
  void initState() {
    super.initState();
    itemDetails = fetchItemDetails(widget.itemId);
  }

  Future<api.DetectedItem> fetchItemDetails(String itemId) async {
    try {
      final item = await api.ApiService.fetchItemDetails(itemId);
      visionData = VisionService.analyzeImage(item.itemID);
      return item;
    } catch (e) {
      throw Exception('Failed to fetch item details');
    }
  }

  Future<void> _speak(String text) async {
    await flutterTts.setLanguage("en-US"); 
    await flutterTts.setPitch(1.0);
    await flutterTts.speak(text);
  }

  Future<String> _fetchFrameImageUrl(int frameNumber) async {
    return await api.ApiService.fetchFrameImage(frameNumber);
  }

  @override
  void dispose() {
    flutterTts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.keyboard_arrow_left_rounded, size: 32),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text('Details'),
      ),
      body: FutureBuilder<api.DetectedItem>(
        future: itemDetails,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Failed to load item details'));
          } else if (!snapshot.hasData) {
            return Center(child: Text('Item not found'));
          } else {
            final itemDetails = snapshot.data!;
            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Text(
                        itemDetails.name,
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                    ),
                    SizedBox(height: 20),
                    Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 3,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  'Color: ${itemDetails.color}',
                                  style: TextStyle(fontSize: 16),
                                ),
                                SizedBox(width: 8),
                                Container(
                                  width: 16,
                                  height: 16,
                                  decoration: BoxDecoration(
                                    color: _getColorFromHex(itemDetails.color),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ],
                            ),
                            Text('Timestamp: ${itemDetails.timestamp}', style: TextStyle(fontSize: 16)),
                            Text('Frame: ${itemDetails.frame}', style: TextStyle(fontSize: 16)),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    FutureBuilder<String>(
                      future: _fetchFrameImageUrl(itemDetails.frame),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return Center(child: CircularProgressIndicator());
                        } else if (snapshot.hasError || !snapshot.hasData) {
                          return Center(child: Text('Failed to load image'));
                        } else {
                          return Container(
                            margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.grey.shade300,
                                width: 1.5,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.2),
                                  spreadRadius: 1,
                                  blurRadius: 4,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: AspectRatio(
                                aspectRatio: 800 / 600, // Match your image dimensions
                                child: Container(
                                  padding: EdgeInsets.all(8),
                                  child: Stack(
                                    fit: StackFit.expand,
                                    children: [
                                      Image.network(
                                        snapshot.data!,
                                        fit: BoxFit.contain,
                                      ),
                                      CustomPaint(
                                        painter: BoundingBoxPainter(
                                          bbox: itemDetails.bbox,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        }
                      },
                    ),
                    SizedBox(height: 20),
                    FutureBuilder<Map<String, dynamic>>(
                      future: visionData,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return Center(child: CircularProgressIndicator());
                        } else if (snapshot.hasError) {
                          return Center(child: Text('Failed to load vision data'));
                        } else {
                          final data = snapshot.data!;
                          return Padding(
                            padding: const EdgeInsets.only(top: 20.0),
                            child: Center(
                              child: Card(
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Text(
                                        'AI Analysis:',
                                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                                      ),
                                      GestureDetector(
                                        onTap: () => _speak(data['summary']),
                                        child: Text(
                                          'Description: ${data['summary']}',
                                          style: TextStyle(fontSize: 18, color: Colors.black),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        }
                      },
                    ),
                  ],
                ),
              ),
            );
          }
        },
      ),
      bottomNavigationBar: CustomNavBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }

  Color _getColorFromHex(String hexColor) {
    hexColor = hexColor.replaceAll("#", "");
    if (hexColor.length == 6) {
      hexColor = "FF$hexColor";
    }
    if (hexColor.length == 8) {
      return Color(int.parse("0x$hexColor"));
    }
    return Colors.black;
  }
}

class BoundingBoxPainter extends CustomPainter {
  final api.Bbox bbox;

  BoundingBoxPainter({required this.bbox});

  @override
  void paint(Canvas canvas, Size size) {
    // Box paint configuration
    final boxPaint = Paint()
      ..color = const Color.fromARGB(255, 255, 35, 19)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    // Hand icon paint configuration
    final handPaint = Paint()
      ..color = const Color.fromARGB(255, 255, 35, 19)
      ..style = PaintingStyle.fill;

    // Scale factors based on 800x600 image dimensions
    final double scaleX = size.width / 800;
    final double scaleY = size.height / 600;

    // Calculate scaled bounding box coordinates
    final double xmin = bbox.xmin.toDouble() * scaleX;
    final double ymin = bbox.ymin.toDouble() * scaleY;
    final double xmax = bbox.xmax.toDouble() * scaleX;
    final double ymax = bbox.ymax.toDouble() * scaleY;

    // Draw bounding box
    final bboxRect = Rect.fromLTRB(xmin, ymin, xmax, ymax);
    canvas.drawRect(bboxRect, boxPaint);

    // Draw hand icon
    // Calculate hand position (top-left corner of bbox)
    final handSize = 20.0;
    final handPath = Path();
    
    // Starting from top-left of bbox
    handPath.moveTo(xmin, ymin);
    // Thumb
    handPath.relativeLineTo(0, handSize * 0.6);
    handPath.relativeLineTo(handSize * 0.3, -handSize * 0.2);
    // Index finger
    handPath.relativeLineTo(handSize * 0.15, -handSize * 0.4);
    // Middle finger
    handPath.relativeLineTo(handSize * 0.15, -handSize * 0.3);
    // Ring finger
    handPath.relativeLineTo(handSize * 0.15, -handSize * 0.2);
    // Pinky
    handPath.relativeLineTo(handSize * 0.15, -handSize * 0.1);
    // Close the path
    handPath.close();

    // Draw hand icon
    canvas.drawPath(handPath, handPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

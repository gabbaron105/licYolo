import 'package:flutter/material.dart';
import '../components/custom_navbar.dart'; // Import the custom navigation bar
import '../api_conf/DetectedItem.dart' as api; // Import the API service with alias

class DetailsPage extends StatelessWidget {
  final String title;
  final String subtitle;
  final api.DetectedItem itemDetails;

  const DetailsPage({super.key, required this.title, required this.subtitle, required this.itemDetails});

  Future<String> _fetchFrameImageUrl(int frameNumber) async {
    return '${api.ApiService.baseUrl}/get-frame/$frameNumber';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.keyboard_arrow_left_rounded, size: 32), // Increased icon size
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text('Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              subtitle,
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            SizedBox(height: 20),
            FutureBuilder<String>(
              future: _fetchFrameImageUrl(itemDetails.frame),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Failed to load image'));
                } else {
                  return Column(
                    children: [
                      Container(
                        width: MediaQuery.of(context).size.width * 0.5,
                        height: MediaQuery.of(context).size.width * 0.5 * 9 / 16, // Maintain aspect ratio
                        child: CustomPaint(
                          painter: BoundingBoxPainter(
                            imageUrl: snapshot.data!,
                            bbox: itemDetails.bbox,
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                      Text(
                        'Class: ${itemDetails.objectClass}',
                        style: TextStyle(fontSize: 16),
                      ),
                      Text(
                        'Confidence: ${itemDetails.confidence}',
                        style: TextStyle(fontSize: 16),
                      ),
                      Row(
                        children: [
                          Text(
                            'Color: ${itemDetails.color}',
                            style: TextStyle(fontSize: 16),
                          ),
                          SizedBox(width: 10),
                          Container(
                            width: 20,
                            height: 20,
                            decoration: BoxDecoration(
                              color: _getColorFromHex(itemDetails.color),
                              shape: BoxShape.circle,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        'Timestamp: ${itemDetails.timestamp}',
                        style: TextStyle(fontSize: 16),
                      ),
                      Text(
                        'Frame: ${itemDetails.frame}',
                        style: TextStyle(fontSize: 16),
                      ),
                    ],
                  );
                }
              },
            ),
          ],
        ),
      ),
      bottomNavigationBar: CustomNavBar(
        currentIndex: 0, // Set the appropriate index for the details page
        onTap: (index) {
          // Handle navigation if needed
        },
      ),
    );
  }

  Color _getColorFromHex(String hexColor) {
    hexColor = hexColor.replaceAll("#", "");
    if (hexColor.length == 6) {
      hexColor = "FF" + hexColor;
    }
    if (hexColor.length == 8) {
      return Color(int.parse("0x$hexColor"));
    }
    return Colors.black;
  }
}

class BoundingBoxPainter extends CustomPainter {
  final String imageUrl;
  final api.Bbox bbox;

  BoundingBoxPainter({required this.imageUrl, required this.bbox});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.red
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    final imageRect = Rect.fromLTWH(0, 0, size.width, size.height);
    final bboxRect = Rect.fromLTWH(
      bbox.xmin.toDouble() * size.width / 640, // Assuming original image width is 640
      bbox.ymin.toDouble() * size.height / 360, // Assuming original image height is 360
      (bbox.xmax - bbox.xmin).toDouble() * size.width / 640,
      (bbox.ymax - bbox.ymin).toDouble() * size.height / 360,
    );

    final image = NetworkImage(imageUrl);
    image.resolve(ImageConfiguration()).addListener(
      ImageStreamListener((ImageInfo info, bool _) {
        final resizedImage = info.image;
        final resizedWidth = resizedImage.width * 0.5;
        final resizedHeight = resizedImage.height * 0.5;
        final resizedRect = Rect.fromLTWH(0, 0, resizedWidth.toDouble(), resizedHeight.toDouble());

        canvas.drawImageRect(resizedImage, imageRect, resizedRect, Paint());
        canvas.drawRect(bboxRect, paint);
      }),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}

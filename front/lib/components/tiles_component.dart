import 'package:flutter/material.dart';

class TilesComponent extends StatelessWidget {
  final List<Map<String, String>> tilesData; // Lista danych przekazywana do kafelków
  final Function(String, String) onTileClick; // Callback for tile clicks
  final double widthPercentage; // Width percentage for the tiles
  final bool displayIcons; // Flag to determine if icons should be displayed

  // Konstruktor przyjmuje dane
  const TilesComponent({super.key, required this.tilesData, required this.onTileClick, required this.widthPercentage, this.displayIcons = false});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 450, // Adjust the height as needed
      child: GridView.builder(
        physics: ClampingScrollPhysics(), // Enable scrolling within the grid
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3, // Number of columns
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
        ),
        itemCount: tilesData.length,
        itemBuilder: (context, index) {
          final tile = tilesData[index];
          return GestureDetector(
            onTap: () => onTileClick(tile['title']!, tile['subtitle']!),
            child: Container(
              width: MediaQuery.of(context).size.width * widthPercentage,
              padding: EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 6.0,
                    offset: Offset(2, 2),
                  ),
                ],
              ),
              child: Center(
                child: displayIcons
                    ? Icon(
                        _getIconData(tile['title']!),
                        size: 48, // Adjust the icon size as needed
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            tile['title']!,
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 4),
                          Text(
                            tile['subtitle']!,
                            style: TextStyle(fontSize: 14, color: _getColorFromHex(tile['subtitle']!)),
                          ),
                        ],
                      ),
              ),
            ),
          );
        },
      ),
    );
  }

  IconData _getIconData(String title) {
    switch (title.toLowerCase()) {
      case 'person':
        return Icons.person;
      case 'bicycle':
        return Icons.directions_bike;
      case 'car':
        return Icons.directions_car;
      case 'motorcycle':
        return Icons.motorcycle;
      case 'airplane':
        return Icons.airplanemode_active;
      case 'bus':
        return Icons.directions_bus;
      case 'train':
        return Icons.train;
      case 'truck':
        return Icons.local_shipping;
      case 'boat':
        return Icons.directions_boat;
      case 'traffic light':
        return Icons.traffic;
      case 'fire hydrant':
        return Icons.local_fire_department;
      case 'stop sign':
        return Icons.stop;
      case 'parking meter':
        return Icons.local_parking;
      case 'bench':
        return Icons.event_seat;
      case 'bird':
        return Icons.filter_hdr;
      case 'cat':
        return Icons.pets;
      case 'dog':
        return Icons.pets;
      case 'horse':
        return Icons.directions_run;
      case 'sheep':
        return Icons.filter_hdr;
      case 'cow':
        return Icons.filter_hdr;
      case 'elephant':
        return Icons.filter_hdr;
      case 'bear':
        return Icons.filter_hdr;
      case 'zebra':
        return Icons.filter_hdr;
      case 'giraffe':
        return Icons.filter_hdr;
      case 'backpack':
        return Icons.backpack;
      case 'umbrella':
        return Icons.beach_access;
      case 'handbag':
        return Icons.shopping_bag;
      case 'tie':
        return Icons.checkroom;
      case 'suitcase':
        return Icons.work;
      case 'frisbee':
        return Icons.sports;
      case 'skis':
        return Icons.ac_unit;
      case 'snowboard':
        return Icons.ac_unit;
      case 'sports ball':
        return Icons.sports_soccer;
      case 'kite':
        return Icons.toys;
      case 'baseball bat':
        return Icons.sports_baseball;
      case 'baseball glove':
        return Icons.sports_baseball;
      case 'skateboard':
        return Icons.sports;
      case 'surfboard':
        return Icons.surfing;
      case 'tennis racket':
        return Icons.sports_tennis;
      case 'bottle':
        return Icons.local_drink;
      case 'wine glass':
        return Icons.wine_bar;
      case 'cup':
        return Icons.local_cafe;
      case 'fork':
        return Icons.restaurant;
      case 'knife':
        return Icons.restaurant;
      case 'spoon':
        return Icons.restaurant;
      case 'bowl':
        return Icons.restaurant;
      case 'banana':
        return Icons.restaurant;
      case 'apple':
        return Icons.restaurant;
      case 'sandwich':
        return Icons.restaurant;
      case 'orange':
        return Icons.restaurant;
      case 'broccoli':
        return Icons.restaurant;
      case 'carrot':
        return Icons.restaurant;
      case 'hot dog':
        return Icons.restaurant;
      case 'pizza':
        return Icons.local_pizza;
      case 'donut':
        return Icons.donut_large;
      case 'cake':
        return Icons.cake;
      case 'chair':
        return Icons.event_seat;
      case 'couch':
        return Icons.weekend;
      case 'potted plant':
        return Icons.local_florist;
      case 'bed':
        return Icons.hotel;
      case 'dining table':
        return Icons.table_chart;
      case 'toilet':
        return Icons.wc;
      case 'tv':
        return Icons.tv;
      case 'laptop':
        return Icons.laptop;
      case 'mouse':
        return Icons.mouse;
      case 'remote':
        return Icons.settings_remote_rounded;
      case 'keyboard':
        return Icons.keyboard;
      case 'cell phone':
        return Icons.phone_android;
      case 'microwave':
        return Icons.microwave;
      case 'oven':
        return Icons.kitchen;
      case 'toaster':
        return Icons.kitchen;
      case 'sink':
        return Icons.kitchen;
      case 'refrigerator':
        return Icons.kitchen;
      case 'book':
        return Icons.book;
      case 'clock':
        return Icons.access_time;
      case 'vase':
        return Icons.local_florist;
      case 'scissors':
        return Icons.content_cut;
      case 'teddy bear':
        return Icons.toys;
      case 'hair drier':
        return Icons.dry;
      case 'toothbrush':
        return Icons.brush;
      default:
        return Icons.help_outline;
    }
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

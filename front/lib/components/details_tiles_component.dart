import 'package:flutter/material.dart';
import '../api_conf/DetectedItem.dart' as api; // Import the API service with alias

class DetailsTilesComponent extends StatelessWidget {
  final List<api.DetectedItem> tilesData; // Use DetectedItem class for tilesData
  final Function(String, String) onTileClick; // Callback for tile clicks
  final double widthPercentage; // Width percentage for the tiles

  const DetailsTilesComponent({super.key, required this.tilesData, required this.onTileClick, required this.widthPercentage});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 300, // Adjust the height
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
          final itemIDPart = tile.itemID.split('_').last; // Extract the part after the last '_'
          final color = tile.color.replaceAll('#', '0xff');
          final nameParts = tile.name.split(' '); // Split the name by spaces
          print('Tile title: ${tile.name}, ItemID part: $itemIDPart, Color: $color'); // Debug print
          return GestureDetector(
            onTap: () => onTileClick(tile.name, tile.color),
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Flexible(
                      child: Text(
                        nameParts.map((part) => part[0].toUpperCase() + part.substring(1)).join(' '),
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      itemIDPart,
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 4),
                    Text(
                      tile.color,
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(int.parse(color))),
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
}

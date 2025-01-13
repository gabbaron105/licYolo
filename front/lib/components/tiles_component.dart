import 'package:flutter/material.dart';
import '../api_conf/DetectedItem.dart' as api; 

class TilesComponent extends StatelessWidget {
  final List<api.DetectedItem> tilesData; 
  final Function(String, String) onTileClick; 
  final double widthPercentage; 
  const TilesComponent({super.key, required this.tilesData, required this.onTileClick, required this.widthPercentage});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 300, // Adjust the height
      child: GridView.builder(
        physics: ClampingScrollPhysics(), 
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3, 
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
        ),
        itemCount: tilesData.length,
        itemBuilder: (context, index) {
          final tile = tilesData[index];
          final itemIDPart = tile.itemID.split('_').last; 
          final color = tile.color.replaceAll('#', '0xff');
          final nameParts = tile.name.split(' '); 
          //print('Tile title: ${tile.name}, ItemID part: $itemIDPart, Color: $color'); 
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

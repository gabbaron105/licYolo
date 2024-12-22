import 'package:flutter/material.dart';

class TilesComponent extends StatelessWidget {
  final List<Map<String, String>> tilesData; // Lista danych przekazywana do kafelków
  final Function(String, String) onTileClick; // Callback for tile clicks

  // Konstruktor przyjmuje dane
  TilesComponent({required this.tilesData, required this.onTileClick});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3, // Liczba kafelków w jednym wierszu
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: tilesData.length,
      itemBuilder: (context, index) {
        final tile = tilesData[index];
        return GestureDetector(
          onTap: () => onTileClick(tile['title']!, tile['subtitle']!),
          child: _buildTile(tile['title']!, tile['subtitle']!),
        );
      },
    );
  }

  Widget _buildTile(String title, String subtitle) {
    return Container(
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
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}

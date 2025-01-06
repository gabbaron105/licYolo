import 'package:flutter/material.dart';
import '../components/tiles_component.dart';
import 'details_page.dart'; // Import the details page
import '../api_conf/DetectedItem.dart' as api; // Import the API service with alias
import '../components/custom_navbar.dart'; // Import the custom navigation bar

class FilteredItemsPage extends StatefulWidget {
  final String title;
  final List<api.DetectedItem> items;

  const FilteredItemsPage({super.key, required this.title, required this.items});

  @override
  _FilteredItemsPageState createState() => _FilteredItemsPageState();
}

class _FilteredItemsPageState extends State<FilteredItemsPage> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    print('Displaying ${widget.items.length} items for category ${widget.title}');
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SizedBox(
          height: 550,
          child: TilesComponent(
            tilesData: widget.items.map((item) {
              return {
                'title': item.name ?? 'Unknown Name',
                'subtitle': item.color ?? '#000000',
              };
            }).toList(),
            onTileClick: (title, subtitle) {
              final clickedItem = widget.items.firstWhere(
                (item) => item.name == title && item.color == subtitle,
                orElse: () => api.DetectedItem(
                  itemID: '0', // Use itemID
                  objectClass: 0,
                  bbox: api.Bbox(xmin: 0.0, ymin: 0.0, xmax: 0.0, ymax: 0.0),
                  center: api.Center(x: 0.0, y: 0.0),
                  confidence: 0.0,
                  frame: 0,
                  color: '#000000',
                  name: 'Unknown',
                  timestamp: DateTime.now(),
                ),
              );
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DetailsPage(
                    itemId: clickedItem.itemID, // Use itemID instead of id
                  ),
                ),
              );
            },
            widthPercentage: 0.5,
          ),
        ),
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
}

import 'package:flutter/material.dart';
import '../components/tiles_component.dart';
import 'details_page.dart'; // Import the new details page

class SearchPage extends StatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  final List<Map<String, String>> allItems = [
    {'title': 'Item 1', 'subtitle': 'All Data'},
    {'title': 'Item 2', 'subtitle': 'All Data'},
    {'title': 'Item 3', 'subtitle': 'All Data'},
    {'title': 'Item 4', 'subtitle': 'All Data'},
    {'title': 'Item 5', 'subtitle': 'All Data'},
    {'title': 'Item 6', 'subtitle': 'All Data'},
  ];

  List<Map<String, String>> get _filteredItems {
    if (_searchQuery.isEmpty) {
      return allItems;
    } else {
      return allItems
          .where((item) =>
              item['title']!.toLowerCase().contains(_searchQuery.toLowerCase()))
          .toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Search'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                margin: EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.12),
                padding: EdgeInsets.symmetric(horizontal: 16.0),
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
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    suffixIcon: IconButton(
                      icon: Icon(Icons.search),
                      onPressed: () {
                        setState(() {
                          _searchQuery = _searchController.text;
                        });
                      },
                    ),
                  ),
                  onSubmitted: (query) {
                    setState(() {
                      _searchQuery = query;
                    });
                  },
                ),
              ),
              SizedBox(height: 60), // Increased space between search bar and first tile
              ListView.builder(
                shrinkWrap: true,
                physics: ClampingScrollPhysics(), // Enable scrolling
                itemCount: _filteredItems.length,
                itemBuilder: (context, index) {
                  final tile = _filteredItems[index];
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DetailsPage(
                            title: tile['title']!,
                            subtitle: tile['subtitle']!,
                          ),
                        ),
                      );
                    },
                    child: Container(
                      margin: EdgeInsets.symmetric(vertical: 8.0),
                      padding: EdgeInsets.all(16.0),
                      width: double.infinity,
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
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            tile['title']!,
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 4),
                          Text(
                            tile['subtitle']!,
                            style: TextStyle(fontSize: 14, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

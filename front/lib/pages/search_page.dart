import 'package:flutter/material.dart';
import 'details_page.dart'; // Import the new details page
import '../api_conf/DetectedItem.dart' as api; // Import the API service with alias
import '../components/tiles_component.dart'; // Import the tiles component
import '../components/custom_navbar.dart'; // Import the custom navigation bar

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  List<api.DetectedItem> allItems = [];
  bool isLoading = true;
  int _currentIndex = 1;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    try {
      final items = await api.ApiService.fetchAllItems();
      setState(() {
        allItems = items;
        isLoading = false;
      });
      print('Data fetched successfully: ${items.length} items');
    } catch (e) {
      print('Failed to load data: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  List<api.DetectedItem> get _filteredItems {
    if (_searchQuery.isEmpty) {
      return allItems;
    } else {
      return allItems
          .where((item) => item.name.toLowerCase().contains(_searchQuery.toLowerCase()))
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
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
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
                    SizedBox(
                      height: 500, // Adjust the height as needed
                      child: TilesComponent(
                        tilesData: _filteredItems.map((item) {
                          return {
                            'title': item.name,
                            'subtitle': item.color,
                          };
                        }).toList(),
                        onTileClick: (title, subtitle) {
                          final clickedItem = allItems.firstWhere((item) => item.name == title && item.color == subtitle);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => DetailsPage(
                                itemId: clickedItem.itemID, 
                              ),
                            ),
                          );
                        },
                        widthPercentage: 0.5,
                      ),
                    ),
                  ],
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

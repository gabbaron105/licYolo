import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:front/pages/profile_page.dart';
import '../components/home_tiles_component.dart';
import '../components/custom_navbar.dart';
import 'search_page.dart';
import 'filtered_items_page.dart';
import '../api_conf/DetectedItem.dart' as api;

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;
  List<api.DetectedItem> allItems = [];
  bool isLoading = true;
  List<int> selectedClasses = [39, 65]; // Domyślne klasy

  @override
  void initState() {
    super.initState();
    _loadPreferences();
    fetchData();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadPreferences(); // Sprawdź, czy ustawienia się zmieniły
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      selectedClasses = prefs.getStringList('selectedClasses')?.map(int.parse).toList() ?? [39, 65];
      print('Updated selectedClasses: $selectedClasses'); // Debug
    });
  }

  Future<void> _savePreferences() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('selectedClasses', selectedClasses.map((e) => e.toString()).toList());
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

  void _openClassSelectionDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return ClassSelectionDialog(
          selectedClasses: selectedClasses,
          onSave: (newSelectedClasses) {
            setState(() {
              selectedClasses = newSelectedClasses;
              _savePreferences(); // Zapisz wybór
            });
            Navigator.pop(context);
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      _HomeContent(allItems: allItems, selectedClasses: selectedClasses),
      const SearchPage(),
      const ProfilePage(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Lost Objects'),
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : pages[_currentIndex],
      bottomNavigationBar: CustomNavBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openClassSelectionDialog, // 🔥 Przywrócono szybki wybór klas!
        child: const Icon(Icons.settings),
      ),
    );
  }
}

class _HomeContent extends StatelessWidget {
  final List<api.DetectedItem> allItems;
  final List<int> selectedClasses;

  const _HomeContent({required this.allItems, required this.selectedClasses});

  @override
  Widget build(BuildContext context) {
    final Map<String, int> categoryClassMap = {
      'cat': 15,
      'umbrella': 25,
      'handbag': 26,
      'tie': 27,
      'suitcase': 28,
      'frisbee': 30,
      'skis': 29,
      'snowboard': 31,
      'sports ball': 32,
      'kite': 33,
      'baseball bat': 34,
      'baseball glove': 35,
      'skateboard': 36,
      'surfboard': 37,
      'tennis racket': 38,
      'bottle': 39,
      'wine glass': 40,
      'cup': 41,
      'fork': 42,
      'knife': 43,
      'spoon': 44,
      'bowl': 45,
      'banana': 46,
      'apple': 47,
      'sandwich': 48,
      'orange': 49,
      'broccoli': 50,
      'carrot': 51,
      'hot dog': 52,
      'pizza': 53,
      'donut': 54,
      'cake': 55,
      'laptop': 63,
      'mouse': 64,
      'remote': 65,
      'keyboard': 66,
      'cell phone': 67,
      'book': 73,
      'clock': 74,
      'scissors': 76,
      'teddy bear': 77,
      'hair drier': 78,
      'toothbrush': 79
    };

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Categories',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 670,
              child: HomeTilesComponent(
                tilesData: allItems.where((item) => selectedClasses.contains(item.objectClass)).toList(),
                onTileClick: (title) {
                  final classNumber = categoryClassMap[title];
                  final filteredItems = allItems.where((item) => item.objectClass == classNumber).toList();
                  print('Filtered items for $title: ${filteredItems.length} items');
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => FilteredItemsPage(
                        title: title,
                        items: filteredItems,
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
    );
  }
}

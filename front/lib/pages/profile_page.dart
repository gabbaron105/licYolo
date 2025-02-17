import 'package:flutter/material.dart';
import 'package:front/components/custom_navbar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  int _currentIndex = 0;
  List<int> selectedClasses = [39, 65];
  Map<String, List<int>> presets = {};
  Map<String, bool> expandedPresets = {}; // Śledzenie, które presety są rozwinięte

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      selectedClasses = prefs.getStringList('selectedClasses')?.map(int.parse).toList() ?? [39, 65];

      final presetsString = prefs.getString('presets');
      if (presetsString != null) {
        presets = Map<String, List<int>>.from(
          json.decode(presetsString).map((key, value) => MapEntry(key, List<int>.from(value))),
        );
        expandedPresets = {for (var key in presets.keys) key: false}; // Wszystkie presety domyślnie zwinięte
      }
    });
  }

  Future<void> _savePreferences() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('selectedClasses', selectedClasses.map((e) => e.toString()).toList());
  }

  Future<void> _savePresets() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('presets', json.encode(presets));
  }

  void _createNewPreset() {
    List<int> tempSelectedClasses = List.from(selectedClasses);

    showDialog(
      context: context,
      builder: (context) {
        return ClassSelectionDialog(
          selectedClasses: tempSelectedClasses,
          onSave: (newClasses) {
            showDialog(
              context: context,
              builder: (context) {
                TextEditingController nameController = TextEditingController();
                return AlertDialog(
                  title: const Text("Nazwa Presetu"),
                  content: TextField(
                    controller: nameController,
                    decoration: const InputDecoration(hintText: "Wpisz nazwę presetu"),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () {
                        final presetName = nameController.text.trim();
                        if (presetName.isNotEmpty) {
                          setState(() {
                            presets[presetName] = List.from(newClasses);
                            _savePresets();
                          });
                          Navigator.pop(context);
                          Navigator.pop(context);
                        }
                      },
                      child: const Text("Zapisz"),
                    ),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }

  void _editPreset(String presetName) {
    List<int> tempSelectedClasses = List.from(presets[presetName]!);
    TextEditingController nameController = TextEditingController(text: presetName);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Edytuj Preset"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(hintText: "Nowa nazwa presetu"),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return ClassSelectionDialog(
                        selectedClasses: tempSelectedClasses,
                        onSave: (newClasses) {
                          setState(() {
                            presets.remove(presetName);
                            presets[nameController.text.trim()] = List.from(newClasses);
                            _savePresets();
                          });
                          Navigator.pop(context);
                          Navigator.pop(context);
                        },
                      );
                    },
                  );
                },
                child: const Text("Edytuj klasy"),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Anuluj"),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  presets.remove(presetName);
                  presets[nameController.text.trim()] = tempSelectedClasses;
                  _savePresets();
                });
                Navigator.pop(context);
              },
              child: const Text("Zapisz zmiany"),
            ),
          ],
        );
      },
    );
  }

  void _applyPreset(String presetName) {
    setState(() {
      selectedClasses = presets[presetName]!;
      _savePreferences();
    });
  }

  void _deletePreset(String presetName) {
    setState(() {
      presets.remove(presetName);
      _savePresets();
    });
  }

  void _togglePresetExpansion(String presetName) {
    setState(() {
      expandedPresets[presetName] = !(expandedPresets[presetName] ?? false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _createNewPreset,
            child: const Text('Utwórz nowy preset'),
          ),
          const SizedBox(height: 20),
          const Text(
            "Twoje Presety:",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          Expanded(
            child: ListView(
              children: presets.keys.map((presetName) {
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  child: Column(
                    children: [
                      ListTile(
                        title: Text(presetName, style: const TextStyle(fontWeight: FontWeight.bold)),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.arrow_drop_down),
                              onPressed: () => _togglePresetExpansion(presetName),
                            ),
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.orange),
                              onPressed: () => _editPreset(presetName),
                            ),
                            IconButton(
                              icon: const Icon(Icons.play_arrow, color: Colors.blue),
                              onPressed: () => _applyPreset(presetName),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _deletePreset(presetName),
                            ),
                          ],
                        ),
                      ),
                      if (expandedPresets[presetName] == true)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          child: Text(
                            presets[presetName]!.map((id) => classNames[id] ?? 'Unknown').join(', '),
                            style: const TextStyle(color: Colors.black54),
                          ),
                        ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
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
class ClassSelectionDialog extends StatefulWidget {
  final List<int> selectedClasses;
  final Function(List<int>) onSave;

  const ClassSelectionDialog({super.key, required this.selectedClasses, required this.onSave});

  @override
  _ClassSelectionDialogState createState() => _ClassSelectionDialogState();
}

class _ClassSelectionDialogState extends State<ClassSelectionDialog> {
  late List<int> _selectedClasses;

  @override
  void initState() {
    super.initState();
    _selectedClasses = List.from(widget.selectedClasses);
  }

  @override
  Widget build(BuildContext context) {
    final classNames = {
      15: 'cat',
      25: 'umbrella',
      26: 'handbag',
      27: 'tie',
      28: 'suitcase',
      30: 'frisbee',
      29: 'skis',
      31: 'snowboard',
      32: 'sports ball',
      33: 'kite',
      34: 'baseball bat',
      35: 'baseball glove',
      36: 'skateboard',
      37: 'surfboard',
      38: 'tennis racket',
      39: 'bottle',
      40: 'wine glass',
      41: 'cup',
      42: 'fork',
      43: 'knife',
      44: 'spoon',
      45: 'bowl',
      46: 'banana',
      47: 'apple',
      48: 'sandwich',
      49: 'orange',
      50: 'broccoli',
      51: 'carrot',
      52: 'hot dog',
      53: 'pizza',
      54: 'donut',
      55: 'cake',
      63: 'laptop',
      64: 'mouse',
      65: 'remote',
      66: 'keyboard',
      67: 'cell phone',
      73: 'book',
      74: 'clock',
      76: 'scissors',
      77: 'teddy bear',
      78: 'hair drier',
      79: 'toothbrush'
    };

    return AlertDialog(
      title: const Text('Select Classes'),
      content: SingleChildScrollView(
        child: Column(
          children: classNames.entries.map((entry) {
            return CheckboxListTile(
              title: Text(entry.value),
              value: _selectedClasses.contains(entry.key),
              onChanged: (bool? value) {
                setState(() {
                  if (value == true) {
                    _selectedClasses.add(entry.key);
                  } else {
                    _selectedClasses.remove(entry.key);
                  }
                });
              },
            );
          }).toList(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            widget.onSave(_selectedClasses);
          },
          child: const Text('Save Changes'),
        ),
      ],
    );
  }
}



// Mapowanie klas do nazw
const Map<int, String> classNames = {
  15: 'cat',
  25: 'umbrella',
  26: 'handbag',
  27: 'tie',
  28: 'suitcase',
  30: 'frisbee',
  29: 'skis',
  31: 'snowboard',
  32: 'sports ball',
  33: 'kite',
  34: 'baseball bat',
  35: 'baseball glove',
  36: 'skateboard',
  37: 'surfboard',
  38: 'tennis racket',
  39: 'bottle',
  40: 'wine glass',
  41: 'cup',
  42: 'fork',
  43: 'knife',
  44: 'spoon',
  45: 'bowl',
  46: 'banana',
  47: 'apple',
  48: 'sandwich',
  49: 'orange',
  50: 'broccoli',
  51: 'carrot',
  52: 'hot dog',
  53: 'pizza',
  54: 'donut',
  55: 'cake',
  63: 'laptop',
  64: 'mouse',
  65: 'remote',
  66: 'keyboard',
  67: 'cell phone',
  73: 'book',
  74: 'clock',
  76: 'scissors',
  77: 'teddy bear',
  78: 'hair drier',
  79: 'toothbrush'
};

// ignore_for_file: always_specify_types

import 'package:hive_flutter/hive_flutter.dart';

import '../../data/models/calculator/historyitem.dart';

class HiveService {
  static const String _historyBox = 'history'; // Box name that matches the UI

  static late Box<HistoryItem>
  _calculatorHistoryDataBox; // Typed box for HistoryItem
  static late Box<HistoryItem> _historyDataBox; // Box for UI access

  // Initialize Hive and open boxes
  static Future<void> init() async {
    await Hive.initFlutter();

    // Only register adapter if not already registered
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(HistoryItemAdapter());
    }

    // Open the 'history' box that the UI expects
    _historyDataBox = await Hive.openBox<HistoryItem>(_historyBox);
  }

  List<HistoryItem> getAllHistory() {
    return _historyDataBox.values.toList();
  }

  static Future<void> deleteUserData(String key) async {
    await _historyDataBox.delete(key);
  }

  static Future<void> clearUserData() async {
    await _historyDataBox.clear();
  }

  // History Methods
  Future<void> addHistoryItem(HistoryItem item) async {
    await _historyDataBox.add(item);
  }

  Future<void> deleteHistoryItem(int index) async {
    await _historyDataBox.deleteAt(index);
  }

  Future<void> clearHistory() async {
    await _historyDataBox.clear();
  }

  HistoryItem? getHistoryItem(int index) {
    return _historyDataBox.getAt(index);
  }

  // General Methods
  static Future<void> closeAllBoxes() async {
    await _calculatorHistoryDataBox.close();
    await _historyDataBox.close();
  }

  // Check if boxes are open
  static bool get isInitialized {
    return _calculatorHistoryDataBox.isOpen && _historyDataBox.isOpen;
  }
}

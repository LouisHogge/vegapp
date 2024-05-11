import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// A model class for handling synchronization related operations.
class SynchronizingModel extends ChangeNotifier {
  static final SynchronizingModel _singleton = SynchronizingModel._internal();
  int _synchronizeNumber = 1;
  bool _isSynchronizing = false;

  factory SynchronizingModel() {
    return _singleton;
  }

  SynchronizingModel._internal();

  /// Loads the synchronize number from shared preferences.
  Future<void> loadSynchronizeNumber() async {
    final prefs = await SharedPreferences.getInstance();
    _synchronizeNumber = prefs.getInt('synchronizeNumber') ?? 1;
  }

  /// Increments the synchronize number and saves it to shared preferences.
  void incrementSynchronizeNumber() async {
    _synchronizeNumber++;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('synchronizeNumber', _synchronizeNumber);
  }

  /// Resets the synchronize number to 1 and saves it to shared preferences.
  void resetSynchronizeNumber() async {
    _synchronizeNumber = 1;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('synchronizeNumber', _synchronizeNumber);
  }

  /// Returns the current synchronize number.
  int getSynchronizeNumber() {
    return _synchronizeNumber;
  }

  /// Returns whether the synchronization is currently in progress.
  bool getIsSynchronizing() {
    return _isSynchronizing;
  }

  /// Sets the synchronization status and notifies listeners.
  void setIsSynchronizing(bool b) {
    _isSynchronizing = b;
    notifyListeners();
  }
}

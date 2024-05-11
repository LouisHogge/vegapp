import 'package:shared_preferences/shared_preferences.dart';

/// A model class for managing the selected garden in the application.
class SelectedGardenModel {
  static final SelectedGardenModel _singleton = SelectedGardenModel._internal();

  int selectedGardenId = -1;
  String selectedGardenName = "";

  factory SelectedGardenModel() {
    return _singleton;
  }

  SelectedGardenModel._internal();

  /// Loads the selected garden ID from the shared preferences.
  Future<void> loadSelectedGardenId() async {
    final prefs = await SharedPreferences.getInstance();
    selectedGardenId = prefs.getInt('selectedGardenId') ?? -1;
  }

  /// Sets the selected garden ID and saves it to the shared preferences.
  void setSelectedGardenId(int id) async {
    selectedGardenId = id;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('selectedGardenId', selectedGardenId);
  }

  /// Returns the selected garden ID synchronously.
  int getSelectedGardenIdSync() {
    return selectedGardenId;
  }

  /// Loads the selected garden name from the shared preferences.
  Future<void> loadSelectedGardenName() async {
    final prefs = await SharedPreferences.getInstance();
    selectedGardenName = prefs.getString('selectedGardenName') ?? "";
  }

  /// Sets the selected garden name and saves it to the shared preferences.
  void setSelectedGardenName(String name) async {
    selectedGardenName = name;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selectedGardenName', selectedGardenName);
  }

  /// Returns the selected garden name synchronously.
  String getSelectedGardenNameSync() {
    return selectedGardenName;
  }
}

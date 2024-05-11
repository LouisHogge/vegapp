import '../models/garden_model.dart';
import 'database_helper.dart';

/// The controller class for managing gardens.
class GardenController {
  // online api urls
  final String gardenOnline =
      'https://springboot-api.apps.speam.montefiore.uliege.be/garden';

  // offline api urls
  final String gardenOffline = "garden";
  final String syncOffline = "sync";

  // ########
  // # CRUD #
  // ########

  /// Creates a new garden with the given [gardenId] and [gardenName].
  /// Returns `true` if the garden is created successfully, `false` otherwise.
  Future<bool> createGarden(int gardenId, String gardenName) async {
    if (!gardenName.startsWith("eyJhbGciOiJIUzI1NiJ9") &&
        !gardenName.startsWith("http")) {
      final db = await DatabaseHelper.instance.getDatabase();
      await db.insert(gardenOffline, {'name': gardenName, 'id': gardenId});
      return true;
    } else {
      return false;
    }
  }

  /// Retrieves all gardens from the local database.
  /// Returns a list of [GardenModel] objects representing the gardens.
  Future<List<GardenModel>> getAllGarden() async {
    final db = await DatabaseHelper.instance.getDatabase();
    final List<Map<String, dynamic>> maps = await db.query(gardenOffline);

    if (maps.isEmpty) {
      return [];
    }

    return List.generate(
        maps.length, (index) => GardenModel.fromJson(maps[index]));
  }
}

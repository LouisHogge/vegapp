import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import '../models/vegetable_model.dart';
import '../models/synchronizing_model.dart';
import '../models/calendar_model.dart';
import 'category_controller.dart';
import 'calendar_controller.dart';
import 'database_helper.dart';

/// Manages CRUD operations for vegetables.
class VegetableController {
  // online api urls
  final String vegetableOnline =
      'https://springboot-api.apps.speam.montefiore.uliege.be/vegetable';

  // offline api urls
  final String vegetableOffline = 'vegetable';
  final String syncOffline = "sync";

  final Function(String message) creationMessage;

  /// Constructor that initializes the VegetableController with a callback
  /// to handle messages during vegetable creation and editing.
  VegetableController(this.creationMessage);

  // ########
  // # CRUD #
  // ########

  /// Creates a vegetable record in the local database and prepares data for synchronization
  /// with the remote API based on garden and vegetable details.
  ///
  /// Performs validation on fields like [vegetableName], [harvestStart], [harvestEnd], etc.
  /// Returns true if the vegetable was successfully created, false otherwise.
  Future<bool> createVegetable(
      String vegetableName,
      int seedAvailability,
      int seedExpiration,
      int harvestStart,
      int harvestEnd,
      String plantStart,
      String plantEnd,
      int primaryCategoryId,
      int secondaryCategoryId,
      String note,
      int gardenId,
      String gardenName) async {
    if (gardenId == -1) {
      creationMessage("Please select a garden first.");
      return false;
    }
    if (vegetableName.isEmpty ||
        plantStart.isEmpty ||
        plantEnd.isEmpty ||
        harvestStart <= 0 ||
        harvestEnd <= 0 ||
        (seedAvailability == 1 && seedExpiration == 0) ||
        primaryCategoryId == 0) {
      creationMessage("Please fill in all fields.");
      return false;
    }
    if (harvestStart >= harvestEnd) {
      creationMessage("Harvest start should be smaller than harvest end.");
      return false;
    }
    if (harvestStart < 4 || harvestStart > 40) {
      creationMessage("Harvest start should be a valid amount of week.");
      return false;
    }
    if (harvestEnd < 4 || harvestEnd > 40) {
      creationMessage("Harvest end should be a valid amount of week.");
      return false;
    }
    if (seedAvailability == 1) {
      if (seedExpiration.toString().length != 4 ||
          seedExpiration < DateTime.now().year) {
        creationMessage(
            "Seed expiration should be a valid current or future 4-digit year.");
        return false;
      }
    }
    if (vegetableName.length > 255) {
      creationMessage("Vegetable name is too long.");
      return false;
    }

    final db = await DatabaseHelper.instance.getDatabase();
    Batch batch = db.batch();

    final existingVegetable = await db.query(vegetableOffline,
        where: 'category_primary_id = ? AND name = ?',
        whereArgs: [primaryCategoryId, vegetableName]);
    if (existingVegetable.isNotEmpty) {
      creationMessage("Vegetable already exists in this primary category.");
      return false;
    }

    CategoryController categoryController =
        CategoryController((String message) => '');

    final primaryCategory =
        await categoryController.getPrimaryCategoryById(primaryCategoryId);
    final String primaryCategoryName = primaryCategory.categoryName;

    if (primaryCategoryName == 'Bin' && secondaryCategoryId > 0) {
      creationMessage(
          "A vegetable with primary category \"Bin\" can not have a secondary category.");
      return false;
    }

    String secondaryCategoryName = 'null';
    if (secondaryCategoryId != 0) {
      final secondaryCategory = await categoryController
          .getSecondaryCategoryById(secondaryCategoryId);
      secondaryCategoryName = secondaryCategory.categoryName;
    }

    batch.insert(
        vegetableOffline,
        {
          'name': vegetableName,
          'harvest_end': harvestEnd,
          'harvest_start': harvestStart,
          'plant_start': plantStart,
          'plant_end': plantEnd,
          'seed_expiration': seedExpiration,
          'seed_availability': seedAvailability,
          'category_primary_id': primaryCategoryId,
          'category_secondary_id': secondaryCategoryId,
          'note': note,
          'garden_id': gardenId,
        },
        conflictAlgorithm: ConflictAlgorithm.replace);

    batch.insert(syncOffline, {
      'api_number': SynchronizingModel().getSynchronizeNumber(),
      'api_url':
          '$vegetableOnline/$primaryCategoryName/$gardenName/$secondaryCategoryName',
      'api_body': jsonEncode({
        'name': vegetableName,
        'harvest_end': harvestEnd,
        'harvest_start': harvestStart,
        'plant_start': plantStart,
        'plant_end': plantEnd,
        'seed_expiration': seedExpiration,
        'seed_availability': seedAvailability,
        'note': note
      }),
      'api_type': "post",
    });

    SynchronizingModel().incrementSynchronizeNumber();

    await batch.commit();

    creationMessage("Vegetable created successfully.");
    return true;
  }

  /// Retrieves all vegetable records associated with a given [gardenId].
  ///
  /// Returns a list of [VegetableModel] instances if successful.
  Future<List<VegetableModel>> getVegetablesByGardenId(int gardenId) async {
    final db = await DatabaseHelper.instance.getDatabase();
    final List<Map<String, dynamic>> maps = await db
        .query(vegetableOffline, where: 'garden_id = ?', whereArgs: [gardenId]);

    if (maps.isEmpty) {
      return [];
    }

    return List.generate(
        maps.length, (index) => VegetableModel.fromJson(maps[index]));
  }

  /// Retrieves multiple vegetables by their IDs.
  ///
  /// Returns a list of [VegetableModel] based on the provided list of [vegetableIds].
  Future<List<VegetableModel>> getVegetablesByIds(
      List<int> vegetableIds) async {
    final db = await DatabaseHelper.instance.getDatabase();
    List<VegetableModel> end = [];

    Future<void> processVegetable(int vegetableId) async {
      final List<Map<String, dynamic>> maps = await db
          .query(vegetableOffline, where: 'id = ?', whereArgs: [vegetableId]);

      end.add(VegetableModel.fromJson(maps.first));
    }

    // Process each vegetable using Future.forEach
    await Future.forEach<int>(vegetableIds, processVegetable);

    if (end.isEmpty) {
      return [];
    }

    return end;
  }

  /// Retrieves a single vegetable by its unique identifier [vegetableId].
  ///
  /// Throws an exception if the vegetable cannot be found in the local database.
  Future<VegetableModel> getVegetableById(int vegetableId) async {
    final db = await DatabaseHelper.instance.getDatabase();
    final List<Map<String, dynamic>> maps = await db
        .query(vegetableOffline, where: 'id = ?', whereArgs: [vegetableId]);

    if (maps.isEmpty) {
      throw Exception('Failed to load vegetable from local database');
    }

    return VegetableModel.fromJson(maps.first);
  }

  /// Retrieves all vegetables that belong to the specified primary category [primaryCategoryId].
  ///
  /// Returns a list of [VegetableModel] instances if successful.
  Future<List<VegetableModel>> getVegetablesByPrimaryCategory(
      int primaryCategoryId) async {
    final db = await DatabaseHelper.instance.getDatabase();

    final List<Map<String, dynamic>> maps = await db.query(vegetableOffline,
        where: 'category_primary_id = ?', whereArgs: [primaryCategoryId]);

    if (maps.isEmpty) {
      return [];
    }

    return List.generate(
        maps.length, (index) => VegetableModel.fromJson(maps[index]));
  }

  /// Retrieves all vegetables that belong to the specified secondary category [secondaryCategoryId].
  ///
  /// Returns a list of [VegetableModel] instances if successful.
  Future<List<VegetableModel>> getVegetablesBySecondaryCategory(
      int secondaryCategoryId) async {
    final db = await DatabaseHelper.instance.getDatabase();

    final List<Map<String, dynamic>> maps = await db.query(vegetableOffline,
        where: 'category_secondary_id = ?', whereArgs: [secondaryCategoryId]);

    if (maps.isEmpty) {
      return [];
    }

    return List.generate(
        maps.length, (index) => VegetableModel.fromJson(maps[index]));
  }

  /// Edits an existing vegetable entry, validating new entries and ensuring synchronization
  /// with remote API for changes.
  ///
  /// Returns true if the edit is successful, otherwise, it sends an appropriate message.
  Future<bool> editVegetable(
      int vegetableId,
      String vegetableName,
      int seedAvailability,
      int seedExpiration,
      int harvestStart,
      int harvestEnd,
      String plantStart,
      String plantEnd,
      int primaryCategoryId,
      int secondaryCategoryId,
      String note,
      int gardenId,
      String gardenName,
      String oldVegetableName,
      int oldPrimaryCategoryId,
      int oldSecondaryCategoryId) async {
    if (vegetableName.isEmpty ||
        plantStart.isEmpty ||
        plantEnd.isEmpty ||
        harvestStart <= 0 ||
        harvestEnd <= 0 ||
        (seedAvailability == 1 && seedExpiration == 0) ||
        primaryCategoryId == 0) {
      creationMessage("Please fill in all fields.");
      return false;
    }
    if (harvestStart >= harvestEnd) {
      creationMessage("Harvest start should be smaller than harvest end.");
      return false;
    }
    if (harvestStart < 4 || harvestStart > 40) {
      creationMessage("Harvest start should be a valid amount of week.");
      return false;
    }
    if (harvestEnd < 4 || harvestEnd > 40) {
      creationMessage("Harvest end should be a valid amount of week.");
      return false;
    }
    if (seedAvailability == 1) {
      if (seedExpiration.toString().length != 4 ||
          seedExpiration < DateTime.now().year) {
        creationMessage(
            "Seed expiration should be a valid current or future 4-digit year.");
        return false;
      }
    }
    if (vegetableName.length > 255) {
      creationMessage("Vegetable name is too long.");
      return false;
    }

    final db = await DatabaseHelper.instance.getDatabase();
    Batch batch = db.batch();

    if (vegetableName != oldVegetableName) {
      final existingVegetable = await db.query(vegetableOffline,
          where: 'category_primary_id = ? AND name = ?',
          whereArgs: [primaryCategoryId, vegetableName]);

      if (existingVegetable.isNotEmpty) {
        creationMessage("Vegetable already exists in this primary category.");
        return false;
      }
    }

    CategoryController categoryController =
        CategoryController((String message) => '');

    final primaryCategory =
        await categoryController.getPrimaryCategoryById(primaryCategoryId);
    final String primaryCategoryName = primaryCategory.categoryName;

    if (primaryCategoryName == 'Bin' && secondaryCategoryId > 0) {
      creationMessage(
          "A vegetable with primary category \"Bin\" can not have a secondary category.");
      return false;
    }
    if (primaryCategoryName == 'Bin' &&
        primaryCategoryId == oldPrimaryCategoryId) {
      creationMessage("Vegetable already deleted.");
      return false;
    }

    final oldPrimaryCategory =
        await categoryController.getPrimaryCategoryById(oldPrimaryCategoryId);
    final String oldPrimaryCategoryName = oldPrimaryCategory.categoryName;

    String secondaryCategoryName = 'null';
    if (secondaryCategoryId != 0) {
      final secondaryCategory = await categoryController
          .getSecondaryCategoryById(secondaryCategoryId);
      secondaryCategoryName = secondaryCategory.categoryName;
    }

    String oldSecondaryCategoryName = 'null';
    if (oldSecondaryCategoryId != 0) {
      final oldSecondaryCategory = await categoryController
          .getSecondaryCategoryById(oldSecondaryCategoryId);
      oldSecondaryCategoryName = oldSecondaryCategory.categoryName;
    }

    batch.update(
        vegetableOffline,
        {
          'name': vegetableName,
          'harvest_end': harvestEnd,
          'harvest_start': harvestStart,
          'plant_start': plantStart,
          'plant_end': plantEnd,
          'seed_expiration': seedExpiration,
          'seed_availability': seedAvailability,
          'category_primary_id': primaryCategoryId,
          'category_secondary_id': secondaryCategoryId,
          'note': note,
          'garden_id': gardenId,
        },
        where: 'id = ?',
        whereArgs: [vegetableId],
        conflictAlgorithm: ConflictAlgorithm.replace);

    batch.insert(syncOffline, {
      'api_number': SynchronizingModel().getSynchronizeNumber(),
      'api_url':
          '$vegetableOnline/$gardenName/$primaryCategoryName/$secondaryCategoryName/$oldVegetableName/$oldPrimaryCategoryName/$oldSecondaryCategoryName',
      'api_body': jsonEncode({
        'name': vegetableName,
        'harvest_end': harvestEnd,
        'harvest_start': harvestStart,
        'plant_start': plantStart,
        'plant_end': plantEnd,
        'seed_expiration': seedExpiration,
        'seed_availability': seedAvailability,
        'note': note
      }),
      'api_type': "put"
    });

    SynchronizingModel().incrementSynchronizeNumber();

    await batch.commit();

    CalendarController calendarController =
        CalendarController((String message) => '');
    VegetableController vegetableController =
        VegetableController((String message) => '');

    // Check if the vegetable is in the calendar
    final List<VegetableModel> calendarVegetables =
        await calendarController.getCalendarOffline(gardenId);
    bool isInCalendar = false;
    for (VegetableModel vegetable in calendarVegetables) {
      if (vegetable.id == vegetableId) {
        isInCalendar = true;
        break;
      }
    }

    // Reset the calendar state of the vegetable
    if (isInCalendar) {
      List<CalendarModel> lcm =
          await calendarController.offlineFillCalendar(gardenId);
      List<VegetableModel> lvm = await vegetableController
          .getVegetablesByIds(calendarController.getVegetablesIds(lcm));

      int vegetableIndex =
          lvm.indexWhere((vegetable) => vegetable.id == vegetableId);
      if (vegetableIndex != -1) {
        CalendarModel cm = lcm[vegetableIndex];
        calendarController.updatePlant(0, cm.id);
        calendarController.updateHarvest(0, cm.id);
        await calendarController.plantDone(0, cm.id);
        await calendarController.harvestDone(0, cm.id);
      }
    }

    if (primaryCategoryName == 'Bin') {
      creationMessage("Vegetable deleted successfully.");
    } else {
      creationMessage("Vegetable edited successfully.");
    }
    return true;
  }

  /// Specifically updates the notes for a given vegetable identified by [vegetableId],
  /// and synchronizes the update with the remote API.
  ///
  /// Intended for making minor, focused updates to an existing vegetable's notes.
  Future<void> editVegetableNotes(
      int vegetableId,
      String vegetableName,
      int seedAvailability,
      int seedExpiration,
      int harvestStart,
      int harvestEnd,
      String plantStart,
      String plantEnd,
      int primaryCategoryId,
      int secondaryCategoryId,
      String notes,
      String gardenName,
      String oldVegetableName,
      int oldPrimaryCategoryId,
      int oldSecondaryCategoryId) async {
    if (notes.length > 4 * 255) {
      creationMessage("Notes are too long.");
      return;
    }

    final db = await DatabaseHelper.instance.getDatabase();
    Batch batch = db.batch();

    CategoryController categoryController =
        CategoryController((String message) => '');

    final primaryCategory =
        await categoryController.getPrimaryCategoryById(primaryCategoryId);
    final String primaryCategoryName = primaryCategory.categoryName;

    final oldPrimaryCategory =
        await categoryController.getPrimaryCategoryById(oldPrimaryCategoryId);
    final String oldPrimaryCategoryName = oldPrimaryCategory.categoryName;

    String secondaryCategoryName = 'null';
    if (secondaryCategoryId != 0) {
      final secondaryCategory = await categoryController
          .getSecondaryCategoryById(secondaryCategoryId);
      secondaryCategoryName = secondaryCategory.categoryName;
    }

    String oldSecondaryCategoryName = 'null';
    if (oldSecondaryCategoryId != 0) {
      final oldSecondaryCategory = await categoryController
          .getSecondaryCategoryById(oldSecondaryCategoryId);
      oldSecondaryCategoryName = oldSecondaryCategory.categoryName;
    }

    batch.update(vegetableOffline, {'note': notes},
        where: 'id = ?', whereArgs: [vegetableId]);

    batch.insert(syncOffline, {
      'api_number': SynchronizingModel().getSynchronizeNumber(),
      'api_url':
          '$vegetableOnline/$gardenName/$primaryCategoryName/$secondaryCategoryName/$oldVegetableName/$oldPrimaryCategoryName/$oldSecondaryCategoryName',
      'api_body': jsonEncode({
        'name': vegetableName,
        'harvest_end': harvestEnd,
        'harvest_start': harvestStart,
        'plant_start': plantStart,
        'plant_end': plantEnd,
        'seed_expiration': seedExpiration,
        'seed_availability': seedAvailability,
        'note': notes
      }),
      'api_type': "put",
    });

    SynchronizingModel().incrementSynchronizeNumber();

    await batch.commit();
  }
}

import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import '../models/category_model.dart';
import '../models/synchronizing_model.dart';
import 'vegetable_controller.dart';
import 'database_helper.dart';

/// Manages CRUD operations for primary and secondary categories of vegetables.
class CategoryController {
  final Map<String, dynamic> affinityNames = {
    'Root': [
      'Root',
      'Nightshade',
      'Salad Green',
      'Cruciferous',
      'Alliums',
      'Podded',
      'Tubers',
      'Stem',
      'Leafy Green',
      'Brassica',
      'Solanaceous'
    ],
    'Nightshade': [
      'Root',
      'Nightshade',
      'Salad Green',
      'Cruciferous',
      'Alliums',
      'Podded',
      'Tubers',
      'Stem',
      'Leafy Green',
      'Brassica',
      'Solanaceous'
    ],
    'Salad Green': [
      'Root',
      'Nightshade',
      'Salad Green',
      'Cruciferous',
      'Alliums',
      'Podded',
      'Tubers',
      'Stem',
      'Leafy Green',
      'Brassica',
      'Solanaceous'
    ],
    'Cruciferous': [
      'Root',
      'Nightshade',
      'Salad Green',
      'Cruciferous',
      'Alliums',
      'Podded',
      'Tubers',
      'Stem',
      'Leafy Green',
      'Brassica',
      'Solanaceous'
    ],
    'Alliums': [
      'Root',
      'Nightshade',
      'Salad Green',
      'Cruciferous',
      'Alliums',
      'Podded',
      'Tubers',
      'Stem',
      'Leafy Green',
      'Brassica',
      'Solanaceous'
    ],
    'Podded': [
      'Root',
      'Nightshade',
      'Salad Green',
      'Cruciferous',
      'Alliums',
      'Podded',
      'Tubers',
      'Stem',
      'Leafy Green',
      'Brassica',
      'Solanaceous'
    ],
    'Tubers': [
      'Root',
      'Nightshade',
      'Salad Green',
      'Cruciferous',
      'Alliums',
      'Podded',
      'Tubers',
      'Stem',
      'Leafy Green',
      'Brassica',
      'Solanaceous'
    ],
    'Stem': [
      'Root',
      'Nightshade',
      'Salad Green',
      'Cruciferous',
      'Alliums',
      'Podded',
      'Tubers',
      'Stem',
      'Leafy Green',
      'Brassica',
      'Solanaceous'
    ],
    'Leafy Green': [
      'Root',
      'Nightshade',
      'Salad Green',
      'Cruciferous',
      'Alliums',
      'Podded',
      'Tubers',
      'Stem',
      'Leafy Green',
      'Brassica',
      'Solanaceous'
    ],
    'Brassica': [
      'Root',
      'Nightshade',
      'Salad Green',
      'Cruciferous',
      'Alliums',
      'Podded',
      'Tubers',
      'Stem',
      'Leafy Green',
      'Brassica',
      'Solanaceous'
    ],
    'Solanaceous': [
      'Root',
      'Nightshade',
      'Salad Green',
      'Cruciferous',
      'Alliums',
      'Podded',
      'Tubers',
      'Stem',
      'Leafy Green',
      'Brassica',
      'Solanaceous'
    ],
  };

  final Map<String, dynamic> affinityValues = {
    'Root': {
      'Root': 0,
      'Nightshade': 1,
      'Salad Green': 2,
      'Cruciferous': 0,
      'Alliums': 1,
      'Podded': 0,
      'Tubers': 0,
      'Stem': 0,
      'Leafy Green': 2,
      'Brassica': 0,
      'Solanaceous': 0
    },
    'Nightshade': {
      'Root': 1,
      'Nightshade': 0,
      'Salad Green': 0,
      'Cruciferous': 1,
      'Alliums': 2,
      'Podded': -1,
      'Tubers': 0,
      'Stem': 0,
      'Leafy Green': 0,
      'Brassica': -2,
      'Solanaceous': 1
    },
    'Salad Green': {
      'Root': 2,
      'Nightshade': 0,
      'Salad Green': 0,
      'Cruciferous': 0,
      'Alliums': 0,
      'Podded': 1,
      'Tubers': 0,
      'Stem': 0,
      'Leafy Green': 2,
      'Brassica': 0,
      'Solanaceous': 0
    },
    'Cruciferous': {
      'Root': 0,
      'Nightshade': 1,
      'Salad Green': 0,
      'Cruciferous': 0,
      'Alliums': 0,
      'Podded': 1,
      'Tubers': 0,
      'Stem': 0,
      'Leafy Green': 0,
      'Brassica': 0,
      'Solanaceous': 0
    },
    'Alliums': {
      'Root': 1,
      'Nightshade': 2,
      'Salad Green': 0,
      'Cruciferous': 0,
      'Alliums': 0,
      'Podded': -1,
      'Tubers': 0,
      'Stem': -1,
      'Leafy Green': 2,
      'Brassica': 2,
      'Solanaceous': 1
    },
    'Podded': {
      'Root': 0,
      'Nightshade': -1,
      'Salad Green': 1,
      'Cruciferous': 1,
      'Alliums': -1,
      'Podded': 0,
      'Tubers': -2,
      'Stem': 0,
      'Leafy Green': 1,
      'Brassica': 0,
      'Solanaceous': 0
    },
    'Tubers': {
      'Root': 0,
      'Nightshade': 0,
      'Salad Green': 0,
      'Cruciferous': 0,
      'Alliums': 0,
      'Podded': -2,
      'Tubers': 0,
      'Stem': 0,
      'Leafy Green': 0,
      'Brassica': 1,
      'Solanaceous': 1
    },
    'Stem': {
      'Root': 0,
      'Nightshade': 0,
      'Salad Green': 0,
      'Cruciferous': 0,
      'Alliums': 1,
      'Podded': 0,
      'Tubers': 0,
      'Stem': 0,
      'Leafy Green': 0,
      'Brassica': 0,
      'Solanaceous': 0
    },
    'Leafy Green': {
      'Root': 2,
      'Nightshade': 0,
      'Salad Green': 2,
      'Cruciferous': 0,
      'Alliums': 0,
      'Podded': 1,
      'Tubers': 0,
      'Stem': 0,
      'Leafy Green': 0,
      'Brassica': 0,
      'Solanaceous': -2
    },
    'Brassica': {
      'Root': 0,
      'Nightshade': -2,
      'Salad Green': 0,
      'Cruciferous': 0,
      'Alliums': 2,
      'Podded': 0,
      'Tubers': 1,
      'Stem': 0,
      'Leafy Green': 0,
      'Brassica': 0,
      'Solanaceous': 0
    },
    'Solanaceous': {
      'Root': 0,
      'Nightshade': 1,
      'Salad Green': 0,
      'Cruciferous': 0,
      'Alliums': 1,
      'Podded': 0,
      'Tubers': 1,
      'Stem': 0,
      'Leafy Green': -2,
      'Brassica': 0,
      'Solanaceous': 0
    },
  };

  final Map<int, String> categoryIndex = {
    0: 'Root',
    1: 'Nightshade',
    2: 'Salad Green',
    3: 'Cruciferous',
    4: 'Alliums',
    5: 'Podded',
    6: 'Tubers',
    7: 'Stem',
    8: 'Leafy Green',
    9: 'Brassica',
    10: 'Solanaceous',
  };

  final Function(String message) categoryMessage;

  /// Constructor that initializes the CategoryController with a callback
  /// to handle messages during operations.
  CategoryController(this.categoryMessage);

  // online api urls
  final String categorySecondaryOnline =
      'https://springboot-api.apps.speam.montefiore.uliege.be/categorySecondary';
  final String vegetableOnline =
      'https://springboot-api.apps.speam.montefiore.uliege.be/vegetable';

  // offline api urls
  final String primaryCategoryOffline = "category_primary";
  final String secondaryCategoryOffline = "category_secondary";
  final String syncOffline = "sync";
  final String vegetableOffline = 'vegetable';

  // ##################
  // # CRUD - primary #
  // ##################

  /// Retrieves all primary categories associated with a specific garden.
  ///
  /// Returns a list of [PrimaryCategoryModel] instances for the given [gardenId].
  Future<List<PrimaryCategoryModel>> getAllPrimaryCategories(
      int gardenId) async {
    final db = await DatabaseHelper.instance.getDatabase();

    final List<Map<String, dynamic>> maps = await db.query(
        primaryCategoryOffline,
        where: 'garden_id = ?',
        whereArgs: [gardenId]);

    if (maps.isEmpty) {
      return [];
    }

    return List.generate(
        maps.length, (index) => PrimaryCategoryModel.fromJson(maps[index]));
  }

  /// Retrieves a single primary category by its unique identifier [primaryCategoryId].
  ///
  /// Throws an exception if no category is found for the provided ID.
  Future<PrimaryCategoryModel> getPrimaryCategoryById(
      int primaryCategoryId) async {
    final db = await DatabaseHelper.instance.getDatabase();
    final List<Map<String, dynamic>> maps = await db.query(
        primaryCategoryOffline,
        where: 'id = ?',
        whereArgs: [primaryCategoryId]);

    if (maps.isEmpty) {
      throw Exception('No category found for the given ID');
    }

    return PrimaryCategoryModel.fromJson(maps.first);
  }

  // ####################
  // # CRUD - secondary #
  // ####################

  /// Creates a new secondary category within a garden.
  ///
  /// Validates [categoryName] and [categoryColor] for a given [gardenId] and [gardenName].
  /// Returns true if the category was successfully created, false otherwise.
  Future<bool> createSecondaryCategory(String categoryName,
      String categoryColor, int gardenId, String gardenName) async {
    if (gardenId == -1) {
      categoryMessage("Please select a garden first.");
      return false;
    }
    if (categoryName.isEmpty) {
      categoryMessage("Category name cannot be empty.");
      return false;
    }
    if (categoryName == 'null') {
      categoryMessage("Category name cannot be \"null\".");
      return false;
    }
    if (categoryName.length > 255) {
      categoryMessage("Category name is too long.");
      return false;
    }
    if (categoryColor.isEmpty) {
      categoryMessage("Please choose a color.");
      return false;
    }

    final db = await DatabaseHelper.instance.getDatabase();
    Batch batch = db.batch();

    final existingCategory = await db.query(secondaryCategoryOffline,
        where: 'garden_id = ? AND name = ?',
        whereArgs: [gardenId, categoryName]);
    if (existingCategory.isNotEmpty) {
      categoryMessage("Category already exists in this garden.");
      return false;
    }

    batch.insert(secondaryCategoryOffline,
        {'name': categoryName, 'color': categoryColor, 'garden_id': gardenId});

    batch.insert(syncOffline, {
      'api_number': SynchronizingModel().getSynchronizeNumber(),
      'api_url': '$categorySecondaryOnline/$gardenName',
      'api_body': jsonEncode({'name': categoryName, 'color': categoryColor}),
      'api_type': "post"
    });

    SynchronizingModel().incrementSynchronizeNumber();

    await batch.commit();

    categoryMessage("Category created successfully.");

    return true;
  }

  /// Retrieves all secondary categories for a given garden by [gardenId].
  ///
  /// Returns a list of [SecondaryCategoryModel] instances if successful.
  Future<List<SecondaryCategoryModel>> getAllSecondaryCategories(
      int gardenId) async {
    final db = await DatabaseHelper.instance.getDatabase();

    final List<Map<String, dynamic>> maps = await db.query(
        secondaryCategoryOffline,
        where: 'garden_id = ?',
        whereArgs: [gardenId]);

    if (maps.isEmpty) {
      return [];
    }

    return List.generate(
        maps.length, (index) => SecondaryCategoryModel.fromJson(maps[index]));
  }

  /// Retrieves a single secondary category by its unique identifier [secondaryCategoryId].
  ///
  /// Throws an exception if no category is found for the provided ID.
  Future<SecondaryCategoryModel> getSecondaryCategoryById(
      int secondaryCategoryId) async {
    final db = await DatabaseHelper.instance.getDatabase();
    final List<Map<String, dynamic>> maps = await db.query(
        secondaryCategoryOffline,
        where: 'id = ?',
        whereArgs: [secondaryCategoryId]);

    if (maps.isEmpty) {
      throw Exception('No category found for the given ID');
    }

    return SecondaryCategoryModel.fromJson(maps.first);
  }

  /// Edits an existing secondary category for a garden.
  ///
  /// Ensures [categoryName] and [categoryColor] validity for the given [categoryId] and [gardenId].
  /// Returns true if the category was successfully edited, false if the new name already exists.
  Future<bool> editSecondaryCategory(
      int categoryId,
      String categoryName,
      String categoryColor,
      int gardenId,
      String gardenName,
      String oldCategoryName) async {
    if (categoryName.isEmpty) {
      categoryMessage("Category name cannot be empty.");
      return false;
    }
    if (categoryName == 'null') {
      categoryMessage("Category name cannot be \"null\".");
      return false;
    }
    if (categoryName.trim().contains(' ')) {
      categoryMessage("Category name must be a single word.");
      return false;
    }
    if (categoryName.length > 255) {
      categoryMessage("Category name is too long.");
      return false;
    }
    if (categoryColor.isEmpty) {
      categoryMessage("Please choose a color.");
      return false;
    }

    final db = await DatabaseHelper.instance.getDatabase();
    Batch batch = db.batch();

    if (categoryName != oldCategoryName) {
      final existingCategory = await db.query(
        secondaryCategoryOffline,
        where: 'garden_id = ? AND name = ?',
        whereArgs: [gardenId, categoryName],
      );

      if (existingCategory.isNotEmpty) {
        categoryMessage("Category already exists in this garden.");
        return false;
      }
    }

    batch.update(secondaryCategoryOffline,
        {'name': categoryName, 'color': categoryColor, 'garden_id': gardenId},
        where: 'id = ?',
        whereArgs: [categoryId],
        conflictAlgorithm: ConflictAlgorithm.replace);

    batch.insert(syncOffline, {
      'api_number': SynchronizingModel().getSynchronizeNumber(),
      'api_url': '$categorySecondaryOnline/$gardenName/$oldCategoryName',
      'api_body': jsonEncode({'name': categoryName, 'color': categoryColor}),
      'api_type': "put",
    });

    SynchronizingModel().incrementSynchronizeNumber();

    await batch.commit();

    categoryMessage("Category edited successfully.");

    return true;
  }

  /// Deletes a secondary category identified by [categoryId],
  /// updating related vegetables to unlink them from the deleted category.
  ///
  /// Completes associated synchronizations with a server as defined by [gardenName].
  Future<void> deleteSecondaryCategory(
      int categoryId, String categoryName, String gardenName) async {
    VegetableController vegetableController =
        VegetableController((String message) => '');
    final vegetables =
        await vegetableController.getVegetablesBySecondaryCategory(categoryId);

    final db = await DatabaseHelper.instance.getDatabase();
    Batch batch = db.batch();

    for (var vegetable in vegetables) {
      batch.update(vegetableOffline, {'category_secondary_id': 0},
          where: 'id = ?',
          whereArgs: [vegetable.id],
          conflictAlgorithm: ConflictAlgorithm.replace);
    }

    batch.delete(secondaryCategoryOffline,
        where: 'id = ?', whereArgs: [categoryId]);

    batch.insert(syncOffline, {
      'api_number': SynchronizingModel().getSynchronizeNumber(),
      'api_url': '$categorySecondaryOnline/$categoryName/$gardenName',
      'api_body': jsonEncode({}),
      'api_type': "delete"
    });

    SynchronizingModel().incrementSynchronizeNumber();

    await batch.commit();

    categoryMessage("Category delited successfully.");
  }
}

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sqflite/sqflite.dart';
import '../models/category_model.dart';
import '../models/vegetable_model.dart';
import '../models/plot_model.dart';
import '../models/plant_model.dart';
import '../models/synchronizing_model.dart';
import 'category_controller.dart';
import 'vegetable_controller.dart';
import 'database_helper.dart';

/// Manages CRUD operations and other functionalities related to plots.
class PlotController {
  // online api urls
  final String plotsOnline =
      'https://springboot-api.apps.speam.montefiore.uliege.be/plots';
  final String plotOnline =
      'https://springboot-api.apps.speam.montefiore.uliege.be/plot';
  final String plantOnline =
      'https://springboot-api.apps.speam.montefiore.uliege.be/plant'; // planted

  // offline api urls
  final String plotOffline = 'plot';
  final String syncOffline = "sync";
  final String plantOffline = "planted";

  Map<String, VegetableModel?> slots = {};
  Map<String, PrimaryCategoryModel?> slotsCategories = {};
  Map<String, List<Color>> adjacent = {};
  Map<String, int> affinities = {};
  bool calendar = false;
  bool planted = false; // true when validate AND plot entirely filled.
  bool affinityDisplay = false;

  VegetableController vegetableController =
      VegetableController((String message) => '');
  CategoryController categoryController =
      CategoryController((String message) => '');

  final Function(String message) creationMessage;

  /// Constructor that initializes the PlotController with a callback
  /// to handle messages during plot operations.
  PlotController(this.creationMessage);

  setPlanted() => planted = true;
  setAffinity() => affinityDisplay = true;
  clearAffinity() => affinityDisplay = false;

  /// Validates the initial form data for a new plot creation.
  /// Checks if the [plotName] is a single word and validates the [mainLines] count.
  bool validateFirstForm(String plotName, int mainLines) {
    if (plotName.isEmpty || mainLines <= -1) {
      creationMessage("Please fill in all fields.");
      return false;
    }

    if (plotName.length > 255) {
      creationMessage("Plot name is too long.");
      return false;
    }

    if (mainLines <= 0) {
      creationMessage("Number of lines cannot be 0.");
      return false;
    }

    if (mainLines > 7) {
      creationMessage("Number of lines cannot exceed 7.");
      return false;
    }

    return true;
  }

  // ########
  // # CRUD #
  // ########

  /// Creates a new plot with detailed specifications about line arrangements and orientation,
  /// and synchronizes the creation with a remote API.
  ///
  /// Returns true if the plot was successfully created, false otherwise.
  Future<bool> createPlot(
      int gardenId,
      String gardenName,
      String plotName,
      List<int> secondaryLines,
      int plotVersion,
      int plotOrientation,
      int plotInCalendar,
      String note) async {
    if (gardenId == -1) {
      creationMessage("Please select a garden first.");
      return false;
    }
    // Check if any secondary line is less than 0
    for (int i = 0; i < secondaryLines.length; i++) {
      if (secondaryLines[i] < 0) {
        creationMessage("Please fill in all fields.");
        return false;
      }

      if (secondaryLines[i] > 7) {
        creationMessage("Number of secondary lines cannot exceed 7.");
        return false;
      }
    }

    final db = await DatabaseHelper.instance.getDatabase();
    Batch batch = db.batch();

    final existingPlot = await db.query(plotOffline,
        where: 'garden_id = ? AND name = ?', whereArgs: [gardenId, plotName]);
    if (existingPlot.isNotEmpty) {
      creationMessage("Plot already exists in this garden.");
      return false;
    }

    // Formatting the data including the number of secondary lines for each main line
    String plotPlantationLines = secondaryLines
        .asMap()
        .entries
        .map((entry) => "${entry.key + 1}.${entry.value}")
        .join('/');

    String currentDate = DateFormat('yyyy-MM-dd').format(DateTime.now());

    batch.insert(plotOffline, {
      'name': plotName,
      'nb_of_lines': plotPlantationLines,
      'creation_date': currentDate,
      'version': plotVersion,
      'orientation': plotOrientation,
      'in_calendar': plotInCalendar,
      'garden_id': gardenId,
      'note': note
    });

    batch.insert(syncOffline, {
      'api_number': SynchronizingModel().getSynchronizeNumber(),
      'api_url': '$plotOnline/$gardenName',
      'api_body': jsonEncode({
        'name': plotName,
        'nb_of_lines': plotPlantationLines,
        'creation_date': currentDate,
        'version': plotVersion,
        'orientation': plotOrientation,
        'in_calendar': plotInCalendar,
        'note': note
      }),
      'api_type': "post",
    });

    SynchronizingModel().incrementSynchronizeNumber();

    await batch.commit();

    creationMessage("Plot created successfully.");
    return true;
  }

  /// Executes planting of vegetables specified by [vegetableIds] into the [plotId],
  /// ensuring all slots in the plot are filled before committing the data.
  Future createPlanted(
      List<int?> vegetableIds,
      List<String> vegetableLocations,
      int plotId,
      bool allowed,
      String gardenName,
      String plotName,
      List<String?> vegetableName,
      int plotVersion) async {
    if (allowed) {
      int numberOfElements = vegetableIds.length;

      final db = await DatabaseHelper.instance.getDatabase();
      Batch batch = db.batch();

      for (int i = 0; i < numberOfElements; i++) {
        batch.insert(plantOffline, {
          'plot_id': plotId,
          'veggie_id': vegetableIds[i],
          'vegetable_location': vegetableLocations[i]
        });
      }

      for (int i = 0; i < numberOfElements; i++) {
        batch.insert(syncOffline, {
          'api_number': SynchronizingModel().getSynchronizeNumber(),
          'api_url':
              '$plantOnline/$plotName/${vegetableLocations[i]}/${vegetableName[i]}/$gardenName/$plotVersion',
          'api_body': jsonEncode({}),
          'api_type': "post"
        });
        SynchronizingModel().incrementSynchronizeNumber();
      }

      await batch.commit();

      setPlanted();

      creationMessage("Vegetables planted successfully.");
    } else {
      creationMessage("Please fill the plot entirely.");
    }
  }

  /// Retrieves all plots associated with a specific garden [gardenId].
  ///
  /// Returns a list of [PlotModel] instances if successful.
  Future<List<PlotModel>> getAllPlots(int gardenId) async {
    final db = await DatabaseHelper.instance.getDatabase();

    final List<Map<String, dynamic>> maps = await db
        .query(plotOffline, where: 'garden_id = ?', whereArgs: [gardenId]);

    if (maps.isEmpty) {
      return [];
    }

    return List.generate(
        maps.length, (index) => PlotModel.fromJson(maps[index]));
  }

  /// Retrieves a single plot by its unique identifier [plotId].
  ///
  /// Throws an exception if no plot is found for the provided ID.
  Future<PlotModel> getPlotById(int plotId) async {
    final db = await DatabaseHelper.instance.getDatabase();
    final List<Map<String, dynamic>> maps =
        await db.query(plotOffline, where: 'id = ?', whereArgs: [plotId]);

    if (maps.isEmpty) {
      throw Exception('No plot found for the given ID');
    }

    return PlotModel.fromJson(maps.first);
  }

  /// Retrieves all planted models for a given plot [plotId].
  ///
  /// Returns a list of [PlantedModel] instances representing the vegetables planted in the plot.
  Future<List<PlantedModel>> getPlantedById(int plotId) async {
    final db = await DatabaseHelper.instance.getDatabase();
    final List<Map<String, dynamic>> maps =
        await db.query('planted', where: 'plot_id = ?', whereArgs: [plotId]);

    if (maps.isEmpty) {
      return [];
    }

    return List.generate(
        maps.length, (index) => PlantedModel.fromJson(maps[index]));
  }

  /// Retrieves all plot IDs marked for inclusion in the calendar for a given garden [gardenId].
  Future<List<int>> getAllPlotForCalendarOn(int gardenId) async {
    final db = await DatabaseHelper.instance.getDatabase();

    final List<Map<String, dynamic>> maps = await db.query(plotOffline,
        columns: ['id'],
        where: 'garden_id = ? AND in_calendar = ?',
        whereArgs: [gardenId, 1]);

    if (maps.isEmpty) {
      return [];
    }

    // Extract the IDs from the query result
    List<int> plotIds = maps.map((map) => map['id'] as int).toList();
    return plotIds;
  }

  /// Retrieves all plot IDs marked for exclusion from the calendar for a given garden [gardenId].
  Future<List<int>> getAllPlotForCalendarOff(int gardenId) async {
    final db = await DatabaseHelper.instance.getDatabase();

    final List<Map<String, dynamic>> maps = await db.query(plotOffline,
        columns: ['id'],
        where: 'garden_id = ? AND in_calendar = ?',
        whereArgs: [gardenId, 0]);

    if (maps.isEmpty) {
      return [];
    }

    // Extract the IDs from the query result
    List<int> plotIds = maps.map((map) => map['id'] as int).toList();
    return plotIds;
  }

  /// Edits an existing plot's details including name, orientation, and line configuration,
  /// and synchronizes these changes with a remote API.
  ///
  /// Returns true if the plot was successfully updated, false otherwise.
  Future<bool> editPlot(
      int plotId,
      int gardenId,
      String gardenName,
      String plotName,
      List<int> secondaryLines,
      int plotVersion,
      int plotOrientation,
      int plotInCalendar,
      String note,
      String oldPlotName,
      int oldPlotOrientation,
      List<int> oldSecondaryLines) async {
    for (int i = 0; i < secondaryLines.length; i++) {
      if (secondaryLines[i] < 0) {
        creationMessage("Please fill in all fields.");
        return false;
      }

      if (secondaryLines[i] > 7) {
        creationMessage("Number of secondary lines cannot exceed 7.");
        return false;
      }
    }

    final db = await DatabaseHelper.instance.getDatabase();
    Batch batch = db.batch();

    if (plotName != oldPlotName) {
      final existingPlot = await db.query(plotOffline,
          where: 'garden_id = ? AND name = ?', whereArgs: [gardenId, plotName]);

      if (existingPlot.isNotEmpty) {
        creationMessage("Plot already exists in this garden.");
        return false;
      }
    }

    // Formatting the data including the number of secondary lines for each main line
    String plotPlantationLines = secondaryLines
        .asMap()
        .entries
        .map((entry) => "${entry.key + 1}.${entry.value}")
        .join('/');

    String oldPlotPlantationLines = oldSecondaryLines
        .asMap()
        .entries
        .map((entry) => "${entry.key + 1}.${entry.value}")
        .join('/');

    String currentDate = DateFormat('yyyy-MM-dd').format(DateTime.now());

    if (plotOrientation == oldPlotOrientation &&
        plotPlantationLines == oldPlotPlantationLines &&
        plotName != oldPlotName) {
      // if we only change the plot name

      batch.update(plotOffline, {'name': plotName},
          where: 'name = ?',
          whereArgs: [oldPlotName],
          conflictAlgorithm: ConflictAlgorithm.replace);

      batch.insert(syncOffline, {
        'api_number': SynchronizingModel().getSynchronizeNumber(),
        'api_url': '$plotOnline/$gardenName/$oldPlotName',
        'api_body': jsonEncode({
          'name': plotName,
          'nb_of_lines': plotPlantationLines,
          'creation_date': currentDate,
          'version': plotVersion - 1,
          'orientation': plotOrientation,
          'in_calendar': plotInCalendar,
          'note': note
        }),
        'api_type': "put",
      });
    } else if (plotName == oldPlotName &&
        (plotOrientation != oldPlotOrientation ||
            plotPlantationLines != oldPlotPlantationLines)) {
      // if we change the orientation or number of lines but not the name

      batch.insert(plotOffline, {
        'name': plotName,
        'nb_of_lines': plotPlantationLines,
        'creation_date': currentDate,
        'version': plotVersion,
        'orientation': plotOrientation,
        'in_calendar': plotInCalendar,
        'garden_id': gardenId,
        'note': note
      });

      batch.insert(syncOffline, {
        'api_number': SynchronizingModel().getSynchronizeNumber(),
        'api_url': '$plotOnline/$gardenName',
        'api_body': jsonEncode({
          'name': plotName,
          'nb_of_lines': plotPlantationLines,
          'creation_date': currentDate,
          'version': plotVersion,
          'orientation': plotOrientation,
          'in_calendar': plotInCalendar,
          'note': note
        }),
        'api_type': "post"
      });
    } else if (plotName != oldPlotName &&
        (plotOrientation != oldPlotOrientation ||
            plotPlantationLines != oldPlotPlantationLines)) {
      // if you change the orientation or the number of lines, you change the name

      final List<Map<String, dynamic>> oldPlots = await db
          .query(plotOffline, where: 'name = ?', whereArgs: [oldPlotName]);

      for (var oldPlot in oldPlots) {
        batch.insert(syncOffline, {
          'api_number': SynchronizingModel().getSynchronizeNumber(),
          'api_url': '$plotOnline/$gardenName/$oldPlotName',
          'api_body': jsonEncode({
            'name': plotName,
            'nb_of_lines': oldPlot['nb_of_lines'],
            'creation_date': oldPlot['creation_date'],
            'version': oldPlot['version'],
            'orientation': oldPlot['orientation'],
            'in_calendar': oldPlot['in_calendar'],
            'note': oldPlot['note']
          }),
          'api_type': "put"
        });
        SynchronizingModel().incrementSynchronizeNumber();
      }

      batch.update(plotOffline, {'name': plotName},
          where: 'name = ?',
          whereArgs: [oldPlotName],
          conflictAlgorithm: ConflictAlgorithm.replace);

      batch.insert(plotOffline, {
        'name': plotName,
        'nb_of_lines': plotPlantationLines,
        'creation_date': currentDate,
        'version': plotVersion,
        'orientation': plotOrientation,
        'in_calendar': plotInCalendar,
        'garden_id': gardenId,
        'note': note
      });

      batch.insert(syncOffline, {
        'api_number': SynchronizingModel().getSynchronizeNumber(),
        'api_url': '$plotOnline/$gardenName',
        'api_body': jsonEncode({
          'name': plotName,
          'nb_of_lines': plotPlantationLines,
          'creation_date': currentDate,
          'version': plotVersion,
          'orientation': plotOrientation,
          'in_calendar': plotInCalendar,
          'note': note
        }),
        'api_type': "post"
      });
    }

    SynchronizingModel().incrementSynchronizeNumber();

    await batch.commit();

    creationMessage("Plot edited successfully.");
    return true;
  }

  /// Specifically updates the notes for a given plot identified by [plotId],
  /// and synchronizes the update with the remote API.
  ///
  /// Intended for making minor, focused updates to an existing plot's notes.
  Future<void> editPlotNotes(
      int plotId,
      String gardenName,
      String plotName,
      String plotPlantationLines,
      int plotVersion,
      int plotOrientation,
      int plotInCalendar,
      String notes,
      String oldPlotName) async {
    if (notes.length > 4 * 255) {
      creationMessage("Notes are too long.");
      return;
    }

    String currentDate = DateFormat('yyyy-MM-dd').format(DateTime.now());

    final db = await DatabaseHelper.instance.getDatabase();
    Batch batch = db.batch();

    batch.update(plotOffline, {'note': notes},
        where: 'id = ?', whereArgs: [plotId]);

    batch.insert(syncOffline, {
      'api_number': SynchronizingModel().getSynchronizeNumber(),
      'api_url': '$plotOnline/$gardenName/$oldPlotName',
      'api_body': jsonEncode({
        'name': plotName,
        'nb_of_lines': plotPlantationLines,
        'creation_date': currentDate,
        'version': plotVersion,
        'orientation': plotOrientation,
        'in_calendar': plotInCalendar,
        'note': notes
      }),
      'api_type': "put"
    });

    SynchronizingModel().incrementSynchronizeNumber();

    await batch.commit();
  }

  /// Deletes a plot identified by [plotName] and synchronizes this deletion with a remote API.
  ///
  /// Sends a creation message upon successful deletion.
  Future<void> deletePlot(
      int gardenId, String plotName, String gardenName, int inCalendar) async {
    final db = await DatabaseHelper.instance.getDatabase();
    Batch batch = db.batch();

    batch.delete(plotOffline, where: 'name = ?', whereArgs: [plotName]);

    batch.insert(syncOffline, {
      'api_number': SynchronizingModel().getSynchronizeNumber(),
      'api_url': '$plotOnline/$gardenName/$plotName',
      'api_body': jsonEncode({}),
      'api_type': "delete"
    });

    SynchronizingModel().incrementSynchronizeNumber();

    await batch.commit();

    creationMessage("Plot deleted successfully.");
  }

  // #########
  // # Utils #
  // #########

  /// Marks the plot [plotId] for inclusion in the garden [gardenId]'s calendar.
  Future<void> toggleOn(int gardenId, int plotId) async {
    final db = await DatabaseHelper.instance.getDatabase();
    Batch batch = db.batch();

    batch.update(plotOffline, {'in_calendar': 1},
        where: 'garden_id = ? AND id = ?', whereArgs: [gardenId, plotId]);

    await batch.commit();

    creationMessage(
        "Activities of the plot successfully added in the calendar.");
  }

  /// Removes the plot [plotId] from the garden [gardenId]'s calendar.
  Future<void> toggleOff(int gardenId, int plotId) async {
    final db = await DatabaseHelper.instance.getDatabase();
    Batch batch = db.batch();

    batch.update(plotOffline, {'in_calendar': 0},
        where: 'garden_id = ? AND id = ?', whereArgs: [gardenId, plotId]);

    await batch.commit();

    creationMessage(
        "Activities of the plot successfully removed from the calendar.");
  }

  /// Simulates and determines affinities between vegetables based on their locations
  /// within a plot given the plot's line configuration [nbOfLines].
  Future<Map<String, List<Color>>> simulateAffinities(
      String lines, List<int> nbVeggiesPerLine) async {
    Map<String, List<Color>> vegetableAffinities = {};

    Map<int, Color> colors = {
      -2: Colors.red,
      -1: Colors.orange,
      0: Colors.white,
      1: Colors.yellow,
      2: Colors.green
    };

    final allLocations = slots.keys.toList();
    for (var location1 in allLocations) {
      for (var location2 in allLocations) {
        final pos =
            areLocationsAdjacent(location1, location2, lines, nbVeggiesPerLine);
        if (pos != -1) {
          // Whenever it's two vegetables next to each other left-right or up-down
          int? affinity = computeAffinity(
              slotsCategories[location1]!, slotsCategories[location2]!);
          // Basic affinities (no any)
          vegetableAffinities[location1] ??= [
            const Color(0xFF5B8E55), // Left
            const Color(0xFF5B8E55), // Right
            const Color(0xFF5B8E55) // Bottom
          ];
          vegetableAffinities[location2] ??= [
            const Color(0xFF5B8E55), // Left (top)
            const Color(0xFF5B8E55), // Right (bottom)
            const Color(0xFF5B8E55) // Bottom (right)
          ];
          //vegetableAffinities[location1]?[pos] = colors[affinity]!;
          //vegetableAffinities[location2]?[pos] = colors[affinity]!;

          if (pos == 2) {
            //vegetableAffinities[location1]?[0] = Colors.amber;
            //vegetableAffinities[location1]?[1] = Colors.amber;
            //vegetableAffinities[location2]?[0] = Colors.amber;
            vegetableAffinities[location2]?[1] = colors[affinity]!;
          }

          if (pos == 1) {
            //vegetableAffinities[location1]?[0] = Colors.amber;
            vegetableAffinities[location1]?[1] = colors[affinity]!;
            vegetableAffinities[location2]?[0] = Colors.amber;
            //vegetableAffinities[location2]?[1] = Colors.amber;
          }

          if (pos == 0) {
            // allow bottom (right) for location1
            vegetableAffinities[location1]?[2] = colors[affinity]!;
          }
          if (pos == -2) {
            // allow right (bottom) for location1, but not left (top) for location2
            vegetableAffinities[location1]?[1] = colors[affinity]!;
            vegetableAffinities[location2]?[0] = Colors.amber;
          }
          if (pos == -3) {
            // allow left (top) for location1, but not right (bottom) for location2
            vegetableAffinities[location1]?[0] = colors[affinity]!;
            vegetableAffinities[location2]?[1] = Colors.amber;
          }
        }
      }
    }
    //print("vegAf: $vegetableAffinities");

    return vegetableAffinities;
  }

  List<String> adjacentCasesBetweenTwoLines(
      String firstLine, String secondLine) {
    final List<String> adjacentCases = [];
    final List<String> firstLineNumbers = firstLine.split('.');
    final int firstPrincipalLine = int.parse(firstLineNumbers[0]);
    final int firstNumberOfCases =
        int.parse(firstLineNumbers[1]); // Number of vegetables
    final List<String> secondLineNumbers = secondLine.split('.');
    final int secondPrincipalLine = int.parse(secondLineNumbers[0]);
    final int secondNumberOfCases = int.parse(secondLineNumbers[1]);

    for (int i = 0; i < firstNumberOfCases; i++) {
      final double endOfFirstCase =
          (i + 1.0) / firstNumberOfCases; // Consider end of the case
      for (int j = 0; j < secondNumberOfCases; j++) {
        final double startOfSecondCase = j / secondNumberOfCases;
        if (endOfFirstCase > startOfSecondCase) {
          adjacentCases.add('$firstPrincipalLine.$i/$secondPrincipalLine.$j');
        }
      }
    }
    return adjacentCases;
  }

  List<String> adjacentCases(String nbOfLines) {
    final List<String> allAdjacentCases = [];
    final List<String> lines = nbOfLines.split('/');

    // Adjacent cases within lines
    for (final line in lines) {
      List<String> parts = line.split('.');
      int nbPrincipalLine = int.parse(parts[0]);
      int nbCasesLine = int.parse(parts[1]);
      for (int j = 0; j < nbCasesLine - 1; j++) {
        allAdjacentCases.add("$nbPrincipalLine.$j/$nbPrincipalLine.${j + 1}");
      }
    }

    // Adjacent cases between lines
    for (int i = 0; i < lines.length - 1; i++) {
      allAdjacentCases
          .addAll(adjacentCasesBetweenTwoLines(lines[i], lines[i + 1]));
    }

    return allAdjacentCases;
  }

  int areLocationsAdjacent(String location1, String location2, String nbOfLines,
      List<int> nbVeggiesPerLine) {
    final List<String> allAdjacentCases = adjacentCases(nbOfLines);

    // Check if both locations are found in the same adjacent case string
    for (final adjacentCase in allAdjacentCases) {
      if (adjacentCase.contains(location1) &&
          adjacentCase.contains(location2)) {
        List<String> parts1 = location1.split('.');
        List<String> parts2 = location2.split('.');

        int row = int.parse(parts1[0]); // Actual row
        int row2 = int.parse(parts2[0]);
        int column = int.parse(parts1[1]); // Number of vegetables
        int column2 = int.parse(parts2[1]);

        if (row > row2) {
          // One vegetable next to each other (Plot vertical), right
          return nbVeggiesPerLine[row - 1] > nbVeggiesPerLine[row2 - 1]
              ? -3
              : 2;
          // return 2;
        }

        if (row < row2) {
          // One vegetable next to each other (Plot vertical), left
          return nbVeggiesPerLine[row - 1] > nbVeggiesPerLine[row2 - 1]
              ? -2
              : 1;
          //return 1;
        }
        if ((row == row2 && column < column2)) {
          // One vegetable below another (Plot vertical)
          return 0;
        }
      }
    }
    return -1; // Not adjacent
  }

  int computeAffinity(
      PrimaryCategoryModel plant1, PrimaryCategoryModel plant2) {
    return categoryController.affinityValues[plant1.categoryName]
        [plant2.categoryName];
  }

  List<int> getVegetablesIds(plantedVegetables) {
    List<int> vegetablesIds = [];
    for (final plantedVegetable in plantedVegetables) {
      vegetablesIds.add(plantedVegetable.vegetableId);
    }

    return vegetablesIds;
  }

  void addVegetableToSlot(location, vegetable) => slots[location] = vegetable;
  void addCategoryToSlot(location, category) =>
      slotsCategories[location] = category;
  VegetableModel? getVegetableFromSlot(location) => slots[location];

  void addAffinities(location, affinities) => adjacent[location] = affinities;
  List<Color>? getAffinities(location) => adjacent[location];
}

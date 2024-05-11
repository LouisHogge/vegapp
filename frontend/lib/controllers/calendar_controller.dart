import 'dart:core';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import '../models/plant_model.dart';
import '../models/vegetable_model.dart';
import '../models/calendar_model.dart';
import 'plot_controller.dart';
import 'vegetable_controller.dart';
import 'category_controller.dart';
import 'database_helper.dart';

/// Manages calendar-related functionalities including plant and harvest tracking.
///
/// This controller integrates with various other controllers like [PlotController],
/// [VegetableController], and [CategoryController] to manage gardening activities
/// across a user-specified calendar.
class CalendarController {
  PlotController plotC = PlotController((String message) => '');
  VegetableController vegetableController =
      VegetableController((String message) => '');
  CategoryController categoryController =
      CategoryController((String message) => '');

  final String calendarOffline = "calendar";

  final Function(String message) creationMessage;
  CalendarController(this.creationMessage);

  final Map<String, Color> activities = {
    'plant': const Color(0xFF709731),
    'harvest': const Color(0xFF9B5366),
    'growing': const Color(0xFFA986E3),
    'sowing_in_place': const Color(0xFF4E45B5),
    'sowing_under_cover': const Color(0xFF4FAAA5),
    'sowing_in_the_nursery': const Color(0xFFF6795B)
  };

  final List<String> months = [
    'Jan.',
    'Feb.',
    'March',
    'April',
    'May',
    'June',
    'July',
    'Aug.',
    'Sept.',
    'Oct.',
    'Nov.',
    'Dec.'
  ];

  final Map<String, int> monthActivity = {
    'Jan.': 0,
    'Feb.': 1,
    'March': 2,
    'April': 3,
    'May': 4,
    'June': 5,
    'July': 6,
    'Aug.': 7,
    'Sept.': 8,
    'Oct.': 9,
    'Nov.': 10,
    'Dec.': 11
  };

  final Map<Color, String> prefixes = {
    const Color(0xFF709731): 'P',
    const Color(0xFF9B5366): 'H',
    const Color(0xFFA986E3): 'G',
    Colors.white.withOpacity(0.38999998569488525): ''
  };

  Map<int, int> plants = {};
  Map<int, int> harvests = {};

  Color? color = Colors.white.withOpacity(0.38999998569488525);

  /// Initializes the calendar with default values for plant and harvest states based on [cm].
  ///
  /// This function ensures that each plant's state is updated or fetched if not already set.
  void init(CalendarModel cm) {
    cm.plantDone != 0
        ? plants[cm.id] = cm.plantDone
        : getPlant(cm.id) != null
            ? plants[cm.id] = getPlant(cm.id)!
            : plants[cm.id] = 0;

    cm.harvestDone != 0
        ? harvests[cm.id] = cm.harvestDone
        : getHarvest(cm.id) != null
            ? harvests[cm.id] = getHarvest(cm.id)!
            : harvests[cm.id] = 0;
  }

  /// Determines if the [color] is allowed to represent an activity on the calendar.
  ///
  /// Only the specified shades of white and purple are considered valid for activity representation.
  bool isAllowed(Color? color) {
    return color == Colors.white.withOpacity(0.38999998569488525) ||
        color == const Color(0xFFA986E3);
  }

  /// Calculates and updates planting status based on provided planting and harvesting time frames.
  ///
  /// This method is pivotal in managing the planting lifecycle, from starting a new plant to
  /// updating or concluding its cycle in the given month.
  int isPlanted(int plantStartMonth, int plantEndMonth, int harvestStartMonth,
      int harvestEndMonth, int currentMonth, int id, CalendarModel cm) {
    if (plants[id]! < 0) {
      return plants[id]!;
    }

    int periodBegin = plants[id]! + harvestStartMonth;
    if (periodBegin > 11) {
      int beginFitsIn = periodBegin ~/ 12;

      periodBegin = periodBegin - (beginFitsIn * 12);
    }

    int periodEnd = plants[id]! + harvestEndMonth;
    if (periodEnd > 11) {
      int endFitsIn = periodEnd ~/ 12;

      periodEnd = periodEnd - (endFitsIn * 12);
    }

    if (plants[id] == 0) {
      if (plantStartMonth == plantEndMonth) {
        if (currentMonth == plantStartMonth) {
          plants[id] = currentMonth + 1; // current state
          updatePlant(currentMonth + 1, id);
          plantDone(currentMonth + 1, id); // future state
        }
      } else if (plantStartMonth < plantEndMonth) {
        if (currentMonth >= plantStartMonth && currentMonth <= plantEndMonth) {
          plants[id] = currentMonth + 1; // current state
          updatePlant(currentMonth + 1, id);
          plantDone(currentMonth + 1, id); // future state
        }
      } else if (plantEndMonth < plantStartMonth) {
        if ((currentMonth >= plantStartMonth && currentMonth <= 11) ||
            (currentMonth >= 0 && currentMonth <= plantEndMonth)) {
          plants[id] = currentMonth + 1; // current state
          updatePlant(currentMonth + 1, id);
          plantDone(currentMonth + 1, id); // future state
        }
      }
    } else if (plants[id]! > 0) {
      if (periodBegin == periodEnd) {
        if (currentMonth == periodBegin) {
          return plants[id]!;
        }
      } else if (periodBegin < periodEnd) {
        if (currentMonth >= periodBegin && currentMonth <= periodEnd) {
          return plants[id]!;
        }
      } else if (periodEnd < periodBegin) {
        if ((currentMonth >= periodBegin && currentMonth <= 11) ||
            (currentMonth >= 0 && currentMonth <= periodEnd)) {
          return plants[id]!;
        }
      }

      if (plantStartMonth == plantEndMonth) {
        if (currentMonth == plantStartMonth) {
          plants[id] = 0;
          updatePlant(0, id);
          updateHarvest(0, id);
          plantDone(0, id);
          harvestDone(0, id);
          cm.plantDone = 0;
          cm.harvestDone = 0;
        }
      } else if (plantStartMonth < plantEndMonth) {
        if (currentMonth >= plantStartMonth && currentMonth <= plantEndMonth) {
          plants[id] = 0;
          updatePlant(0, id);
          updateHarvest(0, id);
          plantDone(0, id);
          harvestDone(0, id);
          cm.plantDone = 0;
          cm.harvestDone = 0;
        }
      } else if (plantEndMonth < plantStartMonth) {
        if ((currentMonth >= plantStartMonth && currentMonth <= 11) ||
            (currentMonth >= 0 && currentMonth <= plantEndMonth)) {
          plants[id] = 0;
          updatePlant(0, id);
          updateHarvest(0, id);
          plantDone(0, id);
          harvestDone(0, id);
          cm.plantDone = 0;
          cm.harvestDone = 0;
        }
      }
    }

    return plants[id]!;
  }

  /// Updates the visual representation color based on the planting status of a vegetable.
  ///
  /// This method returns a color indicating whether a plant is actively growing or not.
  Color? planted(int plantStartMonth, int plantEndMonth, int currentMonth,
      Color? tmp, int id) {
    Color? color = tmp;

    if (plantStartMonth == plantEndMonth) {
      if (currentMonth == plantStartMonth) {
        currentMonth + 1 == plants[id]
            ? color = activities["plant"]
            : plants[id] == 0
                ? color = activities["plant"]
                : color = Colors.white.withOpacity(0.38999998569488525);
      }
    } else if (plantStartMonth < plantEndMonth) {
      if (currentMonth >= plantStartMonth && currentMonth <= plantEndMonth) {
        currentMonth + 1 == plants[id]
            ? color = activities["plant"]
            : plants[id] == 0
                ? color = activities["plant"]
                : color = Colors.white.withOpacity(0.38999998569488525);
      }
    } else if (plantEndMonth < plantStartMonth) {
      if ((currentMonth >= plantStartMonth && currentMonth <= 11) ||
          (currentMonth >= 0 && currentMonth <= plantEndMonth)) {
        currentMonth + 1 == plants[id]
            ? color = activities["plant"]
            : plants[id] == 0
                ? color = activities["plant"]
                : color = Colors.white.withOpacity(0.38999998569488525);
      }
    }
    return color;
  }

  /// Verifies and updates the harvest status for a given plant.
  ///
  /// This function is critical for tracking when plants are ready to be harvested,
  /// adjusting the visual cues accordingly.
  int? isHarvested(
      int harvestStartMonth, int harvestEndMonth, int currentMonth, int id) {
    if (plants[id]! <= 0) {
      return harvests[id];
    }

    int periodBegin = plants[id]! + harvestStartMonth;
    if (periodBegin > 11) {
      int beginFitsIn = periodBegin ~/ 12;

      periodBegin = periodBegin - (beginFitsIn * 12);
    }

    int periodEnd = plants[id]! + harvestEndMonth;
    if (periodEnd > 11) {
      int endFitsIn = periodEnd ~/ 12;

      periodEnd = periodEnd - (endFitsIn * 12);
    }

    if (periodBegin == periodEnd) {
      if (currentMonth == periodBegin) {
        harvests[id] = currentMonth + 1; // current state
        updateHarvest(currentMonth + 1, id);
        harvestDone(currentMonth + 1, id); // future st
      }
    } else if (periodBegin < periodEnd) {
      if (currentMonth >= periodBegin && currentMonth <= periodEnd) {
        harvests[id] = currentMonth + 1; // current state
        updateHarvest(currentMonth + 1, id);
        harvestDone(currentMonth + 1, id); // future st
      }
    } else if (periodEnd < periodBegin) {
      if ((currentMonth >= periodBegin && currentMonth <= 11) ||
          (currentMonth >= 0 && currentMonth <= periodEnd)) {
        harvests[id] = currentMonth + 1; // current state
        updateHarvest(currentMonth + 1, id);
        harvestDone(currentMonth + 1, id); // future st
      }
    }

    return harvests[id];
  }

  /// Updates the color representation based on harvesting status.
  ///
  /// Provides a visual indication of whether a plant is in its harvesting period using color coding.
  Color? harvested(int harvestStartMonth, int harvestEndMonth, int currentMonth,
      Color? tmp, int id) {
    Color? color = tmp;

    if (plants[id]! <= 0) {
      return color;
    }

    int periodBegin = plants[id]! + harvestStartMonth;
    if (periodBegin > 11) {
      int beginFitsIn = periodBegin ~/ 12;

      periodBegin = periodBegin - (beginFitsIn * 12);
    }

    int periodEnd = plants[id]! + harvestEndMonth;
    if (periodEnd > 11) {
      int endFitsIn = periodEnd ~/ 12;

      periodEnd = periodEnd - (endFitsIn * 12);
    }

    if (periodBegin == periodEnd) {
      if (currentMonth == periodBegin) {
        currentMonth + 1 == harvests[id]
            ? color = activities["harvest"]
            : harvests[id] == 0
                ? color = activities["harvest"]
                : color = Colors.white.withOpacity(0.38999998569488525);
      }
    } else if (periodBegin < periodEnd) {
      if (currentMonth >= periodBegin && currentMonth <= periodEnd) {
        currentMonth + 1 == harvests[id]
            ? color = activities["harvest"]
            : harvests[id] == 0
                ? color = activities["harvest"]
                : color = Colors.white.withOpacity(0.38999998569488525);
      }
    } else if (periodEnd < periodBegin) {
      if ((currentMonth >= periodBegin && currentMonth <= 11) ||
          (currentMonth >= 0 && currentMonth <= periodEnd)) {
        currentMonth + 1 == harvests[id]
            ? color = activities["harvest"]
            : harvests[id] == 0
                ? color = activities["harvest"]
                : color = Colors.white.withOpacity(0.38999998569488525);
      }
    }

    return color;
  }

  /// Represents a plant's growth phase visually with a specific color.
  ///
  /// Changes color to indicate active growth when between planting and harvesting timelines.
  Color? growing(int currentMonth, int harvestStartMonth, int harvestEndMonth,
      Color? tmp, int id) {
    Color? color = tmp;

    if (plants[id]! <= 0 || harvests[id] != 0) {
      return color;
    }

    int periodBegin = plants[id]!;
    if (periodBegin > 11) {
      int beginFitsIn = periodBegin ~/ 12;

      periodBegin = periodBegin - (beginFitsIn * 12);
    }

    int periodEnd = plants[id]! + harvestStartMonth - 1;
    if (periodEnd > 11) {
      int endFitsIn = periodEnd ~/ 12;

      periodEnd = periodEnd - (endFitsIn * 12);
    }

    if (periodBegin == periodEnd) {
      if (currentMonth == periodBegin) {
        color = activities['growing'];
      }
    } else if (periodBegin < periodEnd) {
      if (currentMonth >= periodBegin && currentMonth <= periodEnd) {
        color = activities['growing'];
      }
    } else if (periodEnd < periodBegin) {
      if ((currentMonth >= periodBegin && currentMonth <= 11) ||
          (currentMonth >= 0 && currentMonth <= periodEnd)) {
        color = activities['growing'];
      }
    }

    return color;
  }

  /// Retrieves a list of vegetable IDs from a collection of [CalendarModel] entries.
  ///
  /// This is used primarily for fetching and managing vegetable data associated with calendar events.
  List<int> getVegetablesIds(List<CalendarModel> vegetables) {
    List<int> vegetablesIds = [];
    for (final calendarVegetable in vegetables) {
      vegetablesIds.add(calendarVegetable.veggieId);
    }
    return vegetablesIds;
  }

  void updatePlant(int newPlant, int id) => plants[id] = newPlant;
  void updateHarvest(int newHarvest, int id) => harvests[id] = newHarvest;

  bool isDone(int id, int currentMonth) =>
      plants[id]! > 0 && currentMonth + 1 == plants[id]! ||
      harvests[id]! > 0 && currentMonth + 1 == harvests[id]!;

  int? getPlant(int id) => plants[id];
  int? getHarvest(int id) => harvests[id];
  int getMonthActivity(String plant) => monthActivity[plant] ?? -1;
  String? getPrefixColor(Color? color) => prefixes[color];

  // ########
  // # CRUD #
  // ########

  /// Synchronously fetches all calendar entries offline for a specified garden ID.
  ///
  /// This method retrieves and organizes vegetable-related data from an offline database.
  Future<List<VegetableModel>> getCalendarOffline(int gardenId) async {
    final db = await DatabaseHelper.instance.getDatabase();

    final List<Map<String, dynamic>> existingRecords = await db.query(
        calendarOffline,
        columns: ['veggie_id'],
        where: 'garden_id = ?',
        whereArgs: [gardenId]);

    final List<int> veggieIds = existingRecords
        .map<int>((record) => record['veggie_id'] as int)
        .toList();
    List<VegetableModel> vegetableModels = [];

    for (int i = 0; i < veggieIds.length; i++) {
      vegetableModels
          .add(await vegetableController.getVegetableById(veggieIds[i]));
    }

    return vegetableModels;
  }

  /// Fills the calendar with planting data while ensuring no duplicate records exist offline.
  ///
  /// This method is crucial for maintaining an accurate and clean calendar record,
  /// especially when toggling between different plot states.
  Future<List<CalendarModel>> offlineFillCalendar(int gardenId) async {
    var db = await DatabaseHelper.instance.getDatabase();

    List<PlantedModel> planted = [];

    List<int> plotIds = await plotC.getAllPlotForCalendarOn(gardenId);
    List<int> plotIdsOff = await plotC.getAllPlotForCalendarOff(gardenId);

    // Will retrieve all plots toggled ON.
    List<Map<String, dynamic>> result = await db.query('planted',
        where: 'plot_id IN (${List.filled(plotIds.length, '?').join(', ')})',
        whereArgs: plotIds);
    Set<int> seenUniqVeggieIds = {};
    List<Map<String, dynamic>> uniqList = result
        .where((element) => seenUniqVeggieIds.add(element["veggie_id"]))
        .toList();

    // get rid of the planted from category 'Bin'
    List<Map<String, dynamic>> filteredUniqList = [];
    for (final element in uniqList) {
      final vegetable =
          await vegetableController.getVegetableById(element['veggie_id']);
      final primaryCategory = await categoryController
          .getPrimaryCategoryById(vegetable.primaryCategoryId);
      if (primaryCategory.categoryName != "Bin") {
        filteredUniqList.add(element);
      }
    }
    uniqList = filteredUniqList;

    // Will retrieve all plots toggled OFF.
    List<Map<String, dynamic>> resultOff = await db.query('planted',
        where: 'plot_id IN (${List.filled(plotIdsOff.length, '?').join(', ')})',
        whereArgs: plotIdsOff);
    Set<int> seenUniqVeggieIdsOff = {};
    List<Map<String, dynamic>> uniqListOff = resultOff
        .where((element) => seenUniqVeggieIdsOff.add(element["veggie_id"]))
        .toList();

    resultOff = uniqListOff
        .where((element) => !uniqList
            .any((record) => record['veggie_id'] == element['veggie_id']))
        .toList();

    planted.addAll(List.generate(
        result.length, (index) => PlantedModel.fromJson(result[index])));

    Batch batch = db.batch();

    // Retrieve existing calendar models
    List<Map<String, dynamic>> existingRecords = await db
        .query(calendarOffline, where: 'garden_id = ?', whereArgs: [gardenId]);

    // === Remove duplicates ===
    Set<int> seenVeggieIds = {};
    List<Map<String, dynamic>> filteredList = [];
    if (existingRecords.isEmpty) {
      filteredList = result
          .where((element) => seenVeggieIds.add(element["veggie_id"]))
          .toList(); // Add new elements but without duplicates
    }
    if (existingRecords.isNotEmpty) {
      final t = result
          .where((mapA) => !existingRecords
              .any((mapB) => mapA["veggie_id"] == mapB["veggie_id"]))
          .toList(); // Consider new elements only and remove new duplicate elements
      filteredList = t
          .where((element) => seenVeggieIds.add(element["veggie_id"]))
          .toList();
    }

    if (true) {
      for (var element in filteredList) {
        batch.insert(
            calendarOffline,
            {
              'garden_id': gardenId,
              'harvest_done': 0,
              'plant_done': 0,
              'veggie_id': element['veggie_id'],
              'note': " ",
            },
            conflictAlgorithm: ConflictAlgorithm.ignore);
      }
      // Remove vegetables when toggle off
      for (final element in resultOff) {
        final veggieId = element['veggie_id'];
        batch.delete(calendarOffline,
            where: 'veggie_id = ?', whereArgs: [veggieId]);
      }
      await batch.commit();
      existingRecords = await db.query(calendarOffline,
          where: 'garden_id = ?', whereArgs: [gardenId]);
    }

    // A plot has been removed => reflect it into the calendar table
    if (uniqList.length != existingRecords.length) {
      for (final element in existingRecords) {
        final veggieId = element['veggie_id'];
        if (!uniqList.any((record) => record['veggie_id'] == veggieId)) {
          batch.delete(calendarOffline,
              where: 'veggie_id = ?', whereArgs: [veggieId]);
        }
      }
      await batch.commit();
      existingRecords = await db.query(calendarOffline,
          where: 'garden_id = ?', whereArgs: [gardenId]);
    }

    return List.generate(existingRecords.length,
        (index) => CalendarModel.fromJson(existingRecords[index]));
  }

  /// Edits the notes for a calendar entry offline, checking for length constraints.
  ///
  /// Ensures that calendar notes do not exceed allowable lengths to maintain data integrity.
  Future<void> editCalendareNotes(int calendarId, String notes) async {
    if (notes.length > 4 * 255) {
      creationMessage("Notes are too long.");
      return;
    }

    final db = await DatabaseHelper.instance.getDatabase();
    Batch batch = db.batch();

    batch.update(calendarOffline, {'note': notes},
        where: 'id = ?', whereArgs: [calendarId]);

    await batch.commit();
  }

  /// Marks a plant as completed in the calendar for a given month and ID.
  ///
  /// This updates the plant's state to 'done', signifying the completion of its planting cycle.
  Future<void> plantDone(int plantMonth, int id) async {
    final db = await DatabaseHelper.instance.getDatabase();

    await db.update(calendarOffline, {'plant_done': plantMonth},
        where: 'id = ?', whereArgs: [id]);
  }

  /// Marks a harvest as completed in the calendar for a given month and ID.
  ///
  /// Similar to [plantDone], this updates the harvest state to 'done', indicating the end of its cycle.
  Future<void> harvestDone(int harvestMonth, int id) async {
    final db = await DatabaseHelper.instance.getDatabase();

    await db.update(calendarOffline, {'harvest_done': harvestMonth},
        where: 'id = ?', whereArgs: [id]);
  }
}

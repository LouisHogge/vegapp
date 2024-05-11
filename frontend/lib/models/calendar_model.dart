/// Represents a calendar model.
class CalendarModel {
  final int id;
  final int gardenId;
  late int harvestDone;
  late int plantDone;
  final int veggieId;
  final String note;

  /// Constructs a [CalendarModel] instance.
  CalendarModel({
    required this.id,
    required this.gardenId,
    required this.harvestDone,
    required this.plantDone,
    required this.veggieId,
    required this.note,
  });

  /// Constructs a [CalendarModel] instance from a JSON map.'veggie_id', and 'note'.
  factory CalendarModel.fromJson(Map<String, dynamic> json) {
    return CalendarModel(
      id: json['id'],
      gardenId: json['garden_id'],
      harvestDone: json['harvest_done'],
      plantDone: json['plant_done'],
      veggieId: json['veggie_id'],
      note: json['note'],
    );
  }
}

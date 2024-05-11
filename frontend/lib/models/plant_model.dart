/// Represents a planted model.
class PlantedModel {
  final int id;
  final int plotId;
  final int vegetableId;
  final String vegetableLocation;

  /// Constructs a [PlantedModel] instance.
  PlantedModel({
    required this.id,
    required this.plotId,
    required this.vegetableId,
    required this.vegetableLocation,
  });

  /// Constructs a [PlantedModel] instance from a JSON map.
  factory PlantedModel.fromJson(Map<String, dynamic> json) {
    return PlantedModel(
      id: json['id'],
      plotId: json['plot_id'],
      vegetableId: json['veggie_id'],
      vegetableLocation: json['vegetable_location'],
    );
  }
}

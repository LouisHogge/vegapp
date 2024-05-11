/// Represents a vegetable model.
class VegetableModel {
  final int id;
  final String vegetableName;
  final int seedAvailability;
  final int seedExpiration;
  final int harvestStart;
  final int harvestEnd;
  final String plantStart;
  final String plantEnd;
  final int primaryCategoryId;
  final int secondaryCategoryId;
  final String note;
  final int gardenId;

  /// Constructs a [VegetableModel] instance.
  VegetableModel({
    required this.id,
    required this.vegetableName,
    required this.seedAvailability,
    required this.seedExpiration,
    required this.harvestStart,
    required this.harvestEnd,
    required this.plantStart,
    required this.plantEnd,
    required this.primaryCategoryId,
    required this.secondaryCategoryId,
    required this.note,
    required this.gardenId,
  });

  /// Constructs a [VegetableModel] instance from a JSON map.
  factory VegetableModel.fromJson(Map<String, dynamic> json) {
    return VegetableModel(
      id: json['id'],
      vegetableName: json['name'],
      seedAvailability: json['seed_availability'],
      seedExpiration: json['seed_expiration'],
      harvestStart: json['harvest_start'],
      harvestEnd: json['harvest_end'],
      plantStart: json['plant_start'],
      plantEnd: json['plant_end'],
      primaryCategoryId: json['category_primary_id'],
      secondaryCategoryId: json['category_secondary_id'],
      note: json['note'],
      gardenId: json['garden_id'],
    );
  }
}

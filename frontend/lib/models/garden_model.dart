/// Represents a garden model.
class GardenModel {
  final int gardenId;
  final String gardenName;

  /// Constructs a [GardenModel] instance.
  GardenModel({
    required this.gardenId,
    required this.gardenName,
  });

  /// Constructs a [GardenModel] instance from a JSON map.
  factory GardenModel.fromJson(Map<String, dynamic> json) {
    return GardenModel(
      gardenId: json['id'],
      gardenName: json['name'],
    );
  }
}

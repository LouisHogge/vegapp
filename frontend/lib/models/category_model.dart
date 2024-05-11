/// Represents a primary category model.
class PrimaryCategoryModel {
  final int primaryCategoryId;
  final String categoryName;
  final int gardenId;

  /// Constructs a [PrimaryCategoryModel] instance.
  PrimaryCategoryModel({
    required this.primaryCategoryId,
    required this.categoryName,
    required this.gardenId,
  });

  /// Constructs a [PrimaryCategoryModel] instance from a JSON object.
  factory PrimaryCategoryModel.fromJson(Map<String, dynamic> json) {
    return PrimaryCategoryModel(
      primaryCategoryId: json['id'],
      categoryName: json['name'],
      gardenId: json['garden_id'],
    );
  }
}

/// Represents a secondary category model.
class SecondaryCategoryModel {
  final int secondaryCategoryId;
  final String categoryName;
  final String categoryColor;
  final int gardenId;

  /// Constructs a [SecondaryCategoryModel] instance.
  SecondaryCategoryModel({
    required this.secondaryCategoryId,
    required this.categoryName,
    required this.categoryColor,
    required this.gardenId,
  });

  /// Constructs a [SecondaryCategoryModel] instance from a JSON object.
  factory SecondaryCategoryModel.fromJson(Map<String, dynamic> json) {
    return SecondaryCategoryModel(
      secondaryCategoryId: json['id'],
      categoryName: json['name'],
      categoryColor: json['color'],
      gardenId: json['garden_id'],
    );
  }
}

/// Represents a plot in a garden.
class PlotModel {
  final int id;
  final String plotName;
  final String plotPlantationLines;
  final String plotCreationDate;
  final int plotVersion;
  final int plotOrientation;
  late int plotInCalendar;
  final int gardenId;
  final String plotNote;

  /// Constructs a [PlotModel] instance.
  PlotModel({
    required this.id,
    required this.plotName,
    required this.plotPlantationLines,
    required this.plotCreationDate,
    required this.plotVersion,
    required this.plotOrientation,
    required this.plotInCalendar,
    required this.gardenId,
    required this.plotNote,
  });

  /// Constructs a [PlotModel] instance from a JSON object.
  factory PlotModel.fromJson(Map<String, dynamic> json) {
    return PlotModel(
      id: json['id'],
      plotName: json['name'],
      plotPlantationLines: json['nb_of_lines'],
      plotCreationDate: json['creation_date'],
      plotVersion: json['version'],
      plotOrientation: json['orientation'],
      plotInCalendar: json['in_calendar'],
      gardenId: json['garden_id'],
      plotNote: json['note'],
    );
  }
}

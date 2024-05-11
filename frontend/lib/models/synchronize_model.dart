/// Represents a synchronization model.
class SynchronizeModel {
  final int id;
  final int apiNumber;
  final String apiUrl;
  final String apiBody;
  final String apiType;

  /// Constructs a new [SynchronizeModel] instance.
  SynchronizeModel({
    required this.id,
    required this.apiNumber,
    required this.apiUrl,
    required this.apiBody,
    required this.apiType,
  });

  /// Constructs a new [SynchronizeModel] instance from a JSON map.
  factory SynchronizeModel.fromJson(Map<String, dynamic> json) {
    return SynchronizeModel(
      id: json['id'],
      apiNumber: json['api_number'],
      apiUrl: json['api_url'],
      apiBody: json['api_body'],
      apiType: json['api_type'],
    );
  }
}

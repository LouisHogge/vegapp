import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:sqflite/sqflite.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'garden_controller.dart';
import 'database_helper.dart';
import 'token.dart';

/// The controller responsible for initializing the app and garden data.
class InitController {
  // online api urls
  final String initOnline =
      'https://springboot-api.apps.speam.montefiore.uliege.be/init';

  // offline api urls
  final String vegetableOffline = 'vegetable';
  final String plotOffline = 'plot';
  final String plantOffline = 'planted';
  final String gardenOffline = 'garden';
  final String primaryCategoryOffline = 'category_primary';
  final String secondaryCategoryOffline = 'category_secondary';

  final Function(String message) initMessage;

  final Token _tokenController = Token();
  final GardenController _gardenController = GardenController();
  StreamSubscription<List<ConnectivityResult>>? connectivitySubscription;
  late bool isOnline;

  /// Creates an instance of [InitController] with the given [initMessage] callback.
  ///
  /// Initializes the connectivity stream subscription.
  InitController(this.initMessage) {
    connectivitySubscription = Connectivity()
        .onConnectivityChanged
        .listen((List<ConnectivityResult> result) {
      isOnline = isDeviceOnline(result);
    });
  }

  /// Checks if the device is online.
  ///
  /// Returns true if the device is connected to mobile data, Wi-Fi, or Ethernet.
  bool isDeviceOnline(List<ConnectivityResult> connectivityResults) {
    return connectivityResults.contains(ConnectivityResult.mobile) ||
        connectivityResults.contains(ConnectivityResult.wifi) ||
        connectivityResults.contains(ConnectivityResult.ethernet);
  }

  /// Initializes the app by fetching data from the server and storing it in the local database.
  ///
  /// Returns `true` if the initialization is successful, `false` otherwise.
  /// If there is no internet connection, returns `false` and displays a message.
  Future<bool> initApp(String token) async {
    List<ConnectivityResult> currentConnectivity =
        await Connectivity().checkConnectivity();
    isOnline = isDeviceOnline(currentConnectivity);

    if (!isOnline) {
      initMessage("No internet connection.");
      return false;
    }

    http.Response response;
    try {
      response = await http.get(Uri.parse(initOnline), headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      });
    } catch (e) {
      initMessage("No internet connection.");
      return false;
    }

    if (response.statusCode == 403) {
      initMessage("Wrong QR Code.");
      return false;
    } else if (response.statusCode == 200) {
      bool success = await _tokenController.storeToken(token);
      if (success) {
        final appData = jsonDecode(response.body);
        await _insertDataIntoDatabase(appData);
        initMessage("You are now logged in.");
        return true;
      } else {
        initMessage("Failed to store token.");
        return false;
      }
    } else {
      initMessage('Error with response: ${response.statusCode}');
      return false;
    }
  }

  /// Initializes a specific garden by fetching its data from the server and storing it in the local database.
  ///
  /// Returns `true` if the garden initialization is successful, `false` otherwise.
  /// If there is no internet connection, returns `false` and displays a message.
  Future<bool> initGarden(String gardenIdAndName) async {
    List<String> parts = gardenIdAndName.split(',');
    if (parts.length != 2) {
      initMessage("Invalid garden ID and name format.");
      return false;
    }
    int gardenId = int.tryParse(parts[0].trim()) ?? 0;
    String gardenName = parts[1].trim();

    final token = await _tokenController.getToken();

    List<ConnectivityResult> currentConnectivity =
        await Connectivity().checkConnectivity();
    isOnline = isDeviceOnline(currentConnectivity);

    if (!isOnline) {
      initMessage("No internet connection.");
      return false;
    }

    http.Response response;
    try {
      response = await http.get(Uri.parse('$initOnline/$gardenId'), headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      });
    } catch (e) {
      initMessage("No internet connection.");
      return false;
    }

    if (response.statusCode == 404) {
      initMessage("Wrong QR code.");
      return false;
    } else if (response.statusCode == 200) {
      bool created = await _gardenController.createGarden(gardenId, gardenName);

      if (!created) {
        initMessage("Failed to create garden.");
        return false;
      }

      final gardenData = jsonDecode(response.body);
      await _insertDataIntoDatabase(gardenData);

      initMessage("Garden initialized successfully.");
      return true;
    } else {
      initMessage('Error with response: ${response.statusCode}');
      return false;
    }
  }

  /// Inserts the given [jsonData] into the local database using batch operations.
  Future<void> _insertDataIntoDatabase(Map<String, dynamic> jsonData) async {
    final db = await DatabaseHelper.instance.getDatabase();
    Batch batch = db.batch();

    jsonData.forEach((key, value) {
      if (value is List && value.isNotEmpty) {
        switch (key) {
          case 'garden_list':
            _batchInsert(batch, gardenOffline, value);
            break;
          case 'category_primary_list':
            _batchInsert(batch, primaryCategoryOffline, value);
            break;
          case 'category_secondary_list':
            _batchInsert(batch, secondaryCategoryOffline, value);
            break;
          case 'veggie_list':
            _batchInsert(batch, vegetableOffline, value);
            break;
          case 'plot_list':
            _batchInsert(batch, plotOffline, value);
            break;
          case 'plant_list':
            _batchInsert(batch, plantOffline, value);
            break;
          default:
            break;
        }
      }
    });

    await batch.commit(noResult: true);
  }

  /// Inserts the given [items] into the database table specified by [table] using batch operations.
  void _batchInsert(Batch batch, String table, List<dynamic> items) {
    for (var item in items) {
      // Check and update 'category_secondary_id' if it's null
      if (table == vegetableOffline) {
        item['category_secondary_id'] = 0;
      }

      batch.insert(table, item, conflictAlgorithm: ConflictAlgorithm.replace);
    }
  }

  /// Disposes the InitController instance.
  ///
  /// Cancels the connectivity subscription.
  void dispose() {
    // Cancel the connectivity subscription when the controller is disposed
    connectivitySubscription?.cancel();
  }
}

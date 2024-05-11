import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:connectivity_plus/connectivity_plus.dart';
import '../models/synchronize_model.dart';
import '../models/synchronizing_model.dart';
import '../models/selected_garden_model.dart';
import 'init_controller.dart';
import 'database_helper.dart';
import 'routes.dart';
import 'token.dart';

/// Controller class responsible for synchronizing data with the server.
class SynchronizeController {
  final Function(String errorMessage) synchronizationMessage;
  StreamSubscription<List<ConnectivityResult>>? connectivitySubscription;
  final Token _tokenController = Token();
  final InitController initController = InitController((String message) => '');
  late bool isOnline;

  // online api urls
  final String syncOnline =
      'https://springboot-api.apps.speam.montefiore.uliege.be/sync';

  // offline api urls
  final String syncOffline = "sync";

  /// Constructor for the SynchronizeController class.
  ///
  /// Initializes the connectivity stream subscription.
  SynchronizeController(this.synchronizationMessage) {
    connectivitySubscription = Connectivity()
        .onConnectivityChanged
        .listen((List<ConnectivityResult> result) {
      isOnline = isDeviceOnline(result);
    });
  }

  /// Synchronizes data with the server.
  ///
  /// Retrieves the first API call from the local database and sends it to the server.
  /// If the synchronization is successful, retrieves the next API call and repeats the process.
  /// If there is no internet connection or there are no API calls to synchronize, returns early.
  Future<void> synchronizeData(NavigatorState navigator) async {
    SynchronizeModel? apiCall = await getFirstApiCall();

    if (apiCall == null) {
      synchronizationMessage("Nothing to synchronize.");
      return;
    }

    List<ConnectivityResult> currentConnectivity =
        await Connectivity().checkConnectivity();
    isOnline = isDeviceOnline(currentConnectivity);

    bool start = await startSync(apiCall.apiNumber);
    if (!start) {
      synchronizationMessage("No internet connection.");
      return;
    }

    while (apiCall != null && isOnline && start) {
      bool success = await attemptSyncWithRetries(apiCall, 3, navigator);

      if (!success) {
        if (isOnline) {
          synchronizationMessage("Synchronization terminated prematurely.");
          return;
        } else {
          synchronizationMessage("No internet connection.");
          return;
        }
      }

      apiCall = await getFirstApiCall();
    }

    closeSync();

    if (isOnline) {
      SynchronizingModel().resetSynchronizeNumber();
      synchronizationMessage("Synchronization finished.");
    } else {
      synchronizationMessage("No internet connection.");
    }
  }

  /// Starts the synchronization process with the server.
  ///
  /// Sends a POST request to the server to initialize the synchronization.
  /// Returns true if the synchronization is successfully started.
  /// If there is no internet connection, returns early.
  Future<bool> startSync(int apiNumber) async {
    // to init the sync with the online db only with the first api call
    if (apiNumber > 1) {
      return true;
    }

    final token = await _tokenController.getToken();

    bool success = false;
    while (!success && isOnline) {
      http.Response response;
      try {
        response =
            await http.post(Uri.parse(syncOnline), headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': "Bearer $token",
        });
      } catch (e) {
        return false;
      }

      var jsonResponse = json.decode(response.body);
      if (jsonResponse == 1) {
        success = true;
      } else {
        closeSync();
      }

      await Future.delayed(const Duration(seconds: 5));
    }

    if (success) {
      return true;
    } else {
      return false;
    }
  }

  /// Checks if the device is online.
  ///
  /// Returns true if the device is connected to mobile data, Wi-Fi, or Ethernet.
  bool isDeviceOnline(List<ConnectivityResult> connectivityResults) {
    return connectivityResults.contains(ConnectivityResult.mobile) ||
        connectivityResults.contains(ConnectivityResult.wifi) ||
        connectivityResults.contains(ConnectivityResult.ethernet);
  }

  /// Attempts to synchronize an API call with the server.
  ///
  /// Sends a PUT request to the server with the API call details.
  /// Retries the synchronization up to the specified number of times.
  /// Returns true if the synchronization is successful.
  Future<bool> attemptSyncWithRetries(
      SynchronizeModel apiCall, int retries, NavigatorState navigator) async {
    final token = await _tokenController.getToken();

    while (retries > 0 && isOnline) {
      http.Response response;
      try {
        response = await http.put(Uri.parse(syncOnline),
            headers: <String, String>{
              'Content-Type': 'application/json; charset=UTF-8',
              'Authorization': "Bearer $token",
            },
            body: jsonEncode({
              'api_number': apiCall.apiNumber,
              'url': apiCall.apiUrl,
              'body': jsonDecode(apiCall.apiBody),
              'request_type': apiCall.apiType,
            }));
      } catch (e) {
        return false;
      }

      if ((response.statusCode == 200 || response.statusCode == 201) &&
          response.body.isNotEmpty) {
        var jsonResponse = json.decode(response.body);

        int responseApiNumber = jsonResponse['api_number'];
        if (responseApiNumber == apiCall.apiNumber) {
          deleteApiCall(responseApiNumber);
          return true;
        } else {
          synchronizationMessage(
              "Local data corrupted, reset to last uncorrupted state.");

          synchronizeDataFromOnline(navigator);
          return false;
        }
      } else {
        retries--;
        if (retries > 0) {
          await Future.delayed(const Duration(seconds: 5));
        } else {
          synchronizationMessage(
              "Local data corrupted, reset to last uncorrupted state.");

          await synchronizeDataFromOnline(navigator);
          return false;
        }
      }
    }

    return false;
  }

  /// Closes the synchronization process with the server.
  ///
  /// Sends a DELETE request to the server to close the synchronization.
  /// Throws an exception if the request fails.
  /// Returns early if there is no internet connection.
  Future<void> closeSync() async {
    final token = await _tokenController.getToken();

    if (!isOnline) {
      return;
    }

    http.Response response;
    try {
      response =
          await http.delete(Uri.parse(syncOnline), headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': "Bearer $token",
      });
    } catch (e) {
      return;
    }

    if (response.statusCode == 200) {
      return;
    } else {
      throw Exception('Failed to delete api call.');
    }
  }

  Future<void> synchronizeDataFromOnline(NavigatorState navigator) async {
    final token = await _tokenController.getToken();

    await DatabaseHelper.deleteDatabaseFile();
    await DatabaseHelper.instance.getDatabase();

    bool success = false;
    while (!success) {
      success = await initController.initApp(token!);
      await Future.delayed(const Duration(seconds: 5));
    }

    closeSync();
    SynchronizingModel().resetSynchronizeNumber();
    SelectedGardenModel().setSelectedGardenId(-1);

    navigator.pushNamedAndRemoveUntil(
        Routes.gardens, (Route<dynamic> route) => false);
  }

  // ########
  // # CRUD #
  // ########

  /// Creates a new API call in the local database.
  ///
  /// Inserts the API call details into the 'sync' table.
  Future<void> createApiCall(
      int apiNumber, String apiUrl, String apiBody, String apiType) async {
    final db = await DatabaseHelper.instance.getDatabase();

    await db.insert('sync', {
      'api_number': apiNumber,
      'api_url': apiUrl,
      'api_body': apiBody,
      'api_type': apiType,
    });
    return;
  }

  /// Retrieves all API calls from the local database.
  ///
  /// Returns a list of [SynchronizeModel] objects representing the API calls.
  Future<List<SynchronizeModel>> getAllApiCalls() async {
    final db = await DatabaseHelper.instance.getDatabase();
    final List<Map<String, dynamic>> maps = await db.query(syncOffline);

    if (maps.isEmpty) {
      return [];
    }

    return List.generate(
        maps.length, (index) => SynchronizeModel.fromJson(maps[index]));
  }

  /// Retrieves the first API call from the local database.
  ///
  /// Returns a [SynchronizeModel] object representing the API call.
  /// Returns null if there are no API calls in the database.
  Future<SynchronizeModel?> getFirstApiCall() async {
    final db = await DatabaseHelper.instance.getDatabase();
    final List<Map<String, dynamic>> maps =
        await db.query(syncOffline, orderBy: 'api_number', limit: 1);

    if (maps.isEmpty) {
      return null;
    }

    return SynchronizeModel.fromJson(maps.first);
  }

  /// Deletes an API call from the local database.
  ///
  /// Deletes the API call with the specified API number from the 'sync' table.
  Future<void> deleteApiCall(int apiNumber) async {
    final db = await DatabaseHelper.instance.getDatabase();
    await db
        .delete(syncOffline, where: 'api_number = ?', whereArgs: [apiNumber]);
  }

  /// Disposes the SynchronizeController instance.
  ///
  /// Cancels the connectivity subscription.
  void dispose() {
    // Cancel the connectivity subscription when the controller is disposed
    connectivitySubscription?.cancel();
  }
}

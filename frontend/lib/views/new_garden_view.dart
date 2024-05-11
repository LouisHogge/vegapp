import 'package:flutter/material.dart';
import '../models/garden_model.dart';
import '../models/selected_garden_model.dart';
import '../controllers/qr_code_scanner.dart';
import '../controllers/garden_controller.dart';
import '../controllers/init_controller.dart';
import '../controllers/routes.dart';
import 'custom_app_bar.dart';
import 'custom_bottom_bar.dart';

/// Represents the UI for creating a new garden.
///
/// This stateful widget facilitates the addition of a new garden via QR code scanning
/// and integration with the garden initialization and management processes.
class NewGardenView extends StatefulWidget {
  const NewGardenView({Key? key}) : super(key: key);

  @override
  NewGardenViewState createState() => NewGardenViewState();
}

/// Manages the state of [NewGardenView], handling the garden creation workflow.
///
/// It utilizes both [InitController] for initializing garden data and [GardenController]
/// for fetching and setting garden details, managing UI state based on processing status.
class NewGardenViewState extends State<NewGardenView> {
  final GardenController _gardenController = GardenController();
  late InitController _initController;
  bool _isProcessing = false;

  /// Initializes [_initController] with a callback for displaying messages.
  ///
  /// Sets up the state necessary for garden creation when the widget is instantiated.
  @override
  void initState() {
    super.initState();
    _initController =
        InitController((String message) => showMessageSnackBar(message));
  }

  /// Constructs the UI for the new garden creation screen.
  ///
  /// Includes components like [CustomAppBar], [QRCodeScanner], and [CustomBottomBar]. The QR
  /// scanner is set to initiate the garden setup upon successful scan, updating the UI based
  /// on the outcome and potentially navigating to the home screen.
  @override
  Widget build(BuildContext context) {
    final navigator = Navigator.of(context);

    return Scaffold(
        appBar: const CustomAppBar(title: "New Garden"),
        body: QRCodeScanner(onResult: (result) async {
          if (!_isProcessing && result.code != null) {
            setState(() {
              _isProcessing = true;
            });

            bool success = await _initController.initGarden(result.code!);

            if (success) {
              List<GardenModel> gardens =
                  await _gardenController.getAllGarden();
              GardenModel newGarden = gardens[gardens.length - 1];

              SelectedGardenModel().setSelectedGardenId(newGarden.gardenId);
              SelectedGardenModel().setSelectedGardenName(newGarden.gardenName);
              navigator.pushNamedAndRemoveUntil(
                  Routes.home, (Route<dynamic> route) => false);
            } else {
              await Future.delayed(const Duration(seconds: 3));
              setState(() {
                _isProcessing = false;
              });
            }
          }
        }),
        bottomNavigationBar:
            SelectedGardenModel().getSelectedGardenIdSync() > -1
                ? CustomBottomBar()
                : null);
  }

  /// Shows a snackbar notification with the provided [message].
  ///
  /// This method serves as the feedback mechanism for status updates during the garden setup process.
  void showMessageSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), duration: const Duration(seconds: 2)));
  }
}

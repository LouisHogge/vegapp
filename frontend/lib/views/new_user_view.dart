import 'package:flutter/material.dart';
import '../controllers/qr_code_scanner.dart';
import '../controllers/init_controller.dart';
import '../controllers/routes.dart';
import 'custom_app_bar.dart';
// import 'custom_bottom_bar.dart';

/// Represents the UI for creating a new user.
///
/// It is a stateful widget that integrates QR code scanning and application initialization
/// processes, providing a dynamic user onboarding experience.
class NewUserView extends StatefulWidget {
  const NewUserView({Key? key}) : super(key: key);

  @override
  NewUserViewState createState() => NewUserViewState();
}

/// Manages the state of [NewUserView], handling initial setup and QR code scanning.
///
/// It utilizes [InitController] to perform app initialization based on the QR code
/// scan results and manages UI updates based on the process status.
class NewUserViewState extends State<NewUserView> {
  late InitController initController;
  bool _isProcessing = false;

  /// Initializes [initController] with a callback for displaying messages.
  ///
  /// Sets up the initial state for [NewUserView] on widget creation.
  @override
  void initState() {
    super.initState();
    initController =
        InitController((String message) => showMessageSnackBar(message));
  }

  /// Builds the UI components for the new user screen.
  ///
  /// Includes a [CustomAppBar], [QRCodeScanner], and [CustomBottomBar]. The QR scanner activates
  /// the app initialization process upon successful scan and navigates to the next screen on success.
  @override
  Widget build(BuildContext context) {
    final navigator = Navigator.of(context);

    return Scaffold(
      appBar: const CustomAppBar(title: "New User"),
      body: QRCodeScanner(onResult: (result) async {
        if (!_isProcessing && result.code != null) {
          setState(() {
            _isProcessing = true;
          });

          bool success = await initController.initApp(result.code!);

          if (success) {
            navigator.pushNamedAndRemoveUntil(
                Routes.gardens, (Route<dynamic> route) => false);
          } else {
            await Future.delayed(const Duration(seconds: 3));
            setState(() {
              _isProcessing = false;
            });
          }
        }
      }),
      // for developpment purposes
      // bottomNavigationBar: CustomBottomBar()
    );
  }

  /// Displays a snackbar with a [message] for a short duration.
  ///
  /// This method is a callback used by [initController] to show status messages.
  void showMessageSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), duration: const Duration(seconds: 2)));
  }
}

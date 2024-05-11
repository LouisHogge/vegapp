import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/synchronizing_model.dart';
import '../models/selected_garden_model.dart';
import '../controllers/synchronize_controller.dart';
import '../controllers/routes.dart';
import 'custom_bottom_bar.dart';

/// Represents the main UI for the home screen in the garden management app.
///
/// This stateful widget serves as the central navigation hub to various features
/// of the application such as garden plots, seed catalogs, and other garden-related activities.
class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

/// Manages the state and behavior of the [HomeView].
///
/// It handles navigation to different parts of the application and manages synchronization
/// processes using [SynchronizeController].
class _HomeViewState extends State<HomeView> {
  final selectedGardenName = SelectedGardenModel().getSelectedGardenNameSync();
  late SynchronizeController syncController;

  /// Initializes [syncController] with a callback for displaying status messages.
  ///
  /// This method sets up essential controllers needed for the home screen upon widget initialization.
  @override
  void initState() {
    super.initState();
    syncController =
        SynchronizeController((String message) => showMessageSnackBar(message));
  }

  void navigateToCatalogView() {
    Navigator.of(context).pushNamed(Routes.categories);
  }

  void navigateToCalendarView() {
    Navigator.of(context).pushNamed(Routes.calendar);
  }

  void navigateToSeedView() {
    Navigator.of(context).pushNamed(Routes.seed);
  }

  void navigateToGardenView() {
    Navigator.of(context).pushNamed(Routes.gardens);
  }

  void navigateToPlotView() {
    Navigator.of(context).pushNamed(Routes.plots);
  }

  void navigateToVegetableCreationView() {
    Navigator.of(context).pushNamed(Routes.vegetableCreation);
  }

  /// Constructs the visual structure of the home screen.
  ///
  /// This includes dynamic layout adjustments based on screen size and the integration of various
  /// navigation and synchronization functionalities. It provides a circular menu for quick access
  /// to main features, managed by a [SynchronizingModel].
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    double margin = screenWidth * 0.07;
    double maxRadius = (screenWidth - margin * 2) / 2;

    if (screenWidth > (0.8 * screenHeight)) {
      margin = (0.8 * screenHeight) * 0.15;
      maxRadius = ((0.8 * screenHeight) - margin * 2) / 2;
    }

    return Scaffold(
        backgroundColor: const Color(0xFFF9F9F9),
        body: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          SizedBox(
              height:
                  (MediaQuery.of(context).padding.top + screenHeight * 0.01)),
          buildTitle(screenWidth, selectedGardenName),
          Expanded(
              child: Center(
                  child: Stack(alignment: Alignment.center, children: <Widget>[
            Consumer<SynchronizingModel>(builder: (context, model, child) {
              Color centerCircleColor;
              int syncNum = model.getSynchronizeNumber();
              if (syncNum >= 12) {
                centerCircleColor = const Color.fromRGBO(247, 115, 115, 0.66);
              } else if (syncNum >= 7) {
                centerCircleColor = const Color.fromRGBO(226, 174, 113, 1);
              } else if (syncNum >= 2) {
                centerCircleColor = const Color.fromRGBO(210, 205, 106, 1);
              } else {
                centerCircleColor = const Color.fromRGBO(142, 193, 58, 1);
              }
              return CustomPaint(
                  size: Size(0.8 * screenHeight, screenWidth),
                  painter: CirclePainter(centerCircleColor));
            }),
            ...buildButtons(
                maxRadius,
                screenWidth,
                navigateToCatalogView,
                navigateToCalendarView,
                navigateToPlotView,
                navigateToSeedView,
                navigateToGardenView,
                navigateToVegetableCreationView),
            Consumer<SynchronizingModel>(
                builder: (context, model, child) => SynchronizingModel()
                        .getIsSynchronizing()
                    ? const CircularProgressIndicator()
                    : buildButton(
                        top: maxRadius,
                        width: (maxRadius / 3) * 1,
                        height: (maxRadius / 3) * 1,
                        heroTag: "syncFAB",
                        decoration: const Icon(Icons.sync, color: Colors.black),
                        onPressed: () async {
                          if (!SynchronizingModel().getIsSynchronizing()) {
                            SynchronizingModel().setIsSynchronizing(true);
                            final navigator = Navigator.of(context);
                            await syncController
                                .synchronizeData(navigator)
                                .whenComplete(() {
                              SynchronizingModel().setIsSynchronizing(false);
                            });
                          }
                        })),
          ]))),
        ]),
        bottomNavigationBar: CustomBottomBar());
  }

  /// Displays a snackbar with a specified [message].
  ///
  /// This method is used for alerting the user about various events and status changes.
  void showMessageSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), duration: const Duration(seconds: 2)));
  }
}

/// Renders a centered title using [GoogleFonts] with the given [gardenName].
///
/// This method is designed to provide a responsive title display based on the screen width.
Widget buildTitle(double screenWidth, String gardenName) {
  return Center(
      child: Padding(
          padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
          child: Text(gardenName,
              textAlign: TextAlign.center,
              style: GoogleFonts.delius(
                  textStyle: TextStyle(
                      fontSize: screenWidth * 0.09,
                      fontWeight: FontWeight.w900)),
              softWrap: true)));
}

/// Generates a list of navigation buttons for key garden management activities.
///
/// Each button is configured to navigate to a specific view in the app, such as the catalog, calendar,
/// or plot overview. The arrangement and styling of buttons are adapted to screen dimensions.
List<Widget> buildButtons(
    double maxRadius,
    double screenWidth,
    navigateToCatalogView,
    navigateToCalendarView,
    navigateToPlotView,
    navigateToSeedView,
    navigateToGardenView,
    navigateToVegetableCreationView) {
  return [
    buildButton(
        top: (maxRadius / 3) * 0,
        width: (maxRadius / 3) * 1,
        height: (maxRadius / 3) * 1,
        heroTag: "gardenFAB",
        decoration: Image.asset("assets/garden2.png",
            width: screenWidth * 0.09, height: screenWidth * 0.09),
        onPressed: navigateToPlotView),
    buildButton(
        top: maxRadius / 2,
        left: maxRadius * 1.8,
        width: (maxRadius / 3) * 1,
        height: (maxRadius / 3) * 1,
        heroTag: "connectionFAB",
        decoration: Image.asset("assets/farmers.png",
            width: screenWidth * 0.10, height: screenWidth * 0.10),
        onPressed: navigateToGardenView),
    buildButton(
        top: maxRadius / 2,
        right: maxRadius * 1.8,
        width: (maxRadius / 3) * 1,
        height: (maxRadius / 3) * 1,
        heroTag: "calendarFAB",
        decoration: Image.asset("assets/calendar.png",
            width: screenWidth * 0.07, height: screenWidth * 0.07),
        onPressed: navigateToCalendarView),
    buildButton(
        top: maxRadius * 1.5,
        right: maxRadius * 1.8,
        width: (maxRadius / 3) * 1,
        height: (maxRadius / 3) * 1,
        heroTag: "catalogFAB",
        decoration: Image.asset("assets/categories.png",
            width: screenWidth * 0.08, height: screenWidth * 0.08),
        onPressed: navigateToCatalogView),
    buildButton(
        top: maxRadius * 1.5,
        left: maxRadius * 1.8,
        width: (maxRadius / 3) * 1,
        height: (maxRadius / 3) * 1,
        heroTag: "seedFAB",
        decoration: Image.asset("assets/seed.png",
            width: screenWidth * 0.09, height: screenWidth * 0.09),
        onPressed: navigateToSeedView),
    buildButton(
        top: maxRadius * 2,
        width: (maxRadius / 3) * 1,
        height: (maxRadius / 3.1) * 1,
        heroTag: "vegetableCreationFAB",
        decoration: Image.asset("assets/veg.png",
            width: screenWidth * 0.09, height: screenWidth * 0.09),
        onPressed: navigateToVegetableCreationView),
  ];
}

/// Creates a positioned floating action button with specific aesthetics and behavior.
///
/// This utility function customizes the position, size, and decoration of the button, intended for use
/// in the [buildButtons] function for dynamic UI layouts.
Widget buildButton(
    {required double top,
    required double width,
    required double height,
    double left = 0.0,
    double right = 0.0,
    String heroTag = "",
    required final decoration,
    required VoidCallback onPressed}) {
  return Positioned(
      top: top,
      left: left,
      right: right,
      child: SizedBox(
          width: width,
          height: height,
          child: FloatingActionButton(
              onPressed: onPressed,
              backgroundColor: Colors.white,
              shape: const CircleBorder(),
              heroTag: heroTag,
              child: decoration)));
}

/// Custom painter class used to draw concentric circles with a customizable center color.
///
/// This painter is employed in the [HomeView] to render a background visual element that represents
/// synchronization status with varying colors based on state.
class CirclePainter extends CustomPainter {
  final Color centerColor;

  CirclePainter(this.centerColor);

  @override
  void paint(Canvas canvas, Size size) {
    final colors = [
      const Color.fromRGBO(92, 141, 109, 1),
      const Color.fromRGBO(116, 165, 55, 1),
      centerColor,
    ];

    double margin = size.width * 0.07;
    double maxRadius = (size.width - margin * 2) / 2;

    if (size.width > size.height) {
      margin = size.height * 0.15;
      maxRadius = (size.height - margin * 2) / 2;
    }

    final center = Offset(size.width / 2, size.height / 2);

    for (int i = 0; i < 3; i++) {
      var radius = maxRadius / 3 * (3 - i);
      var circlePath = Path()
        ..addOval(Rect.fromCircle(center: center, radius: radius));

      // Shadow
      canvas.drawShadow(circlePath, Colors.black, 4.0, false);

      // Circle
      var paint = Paint()..color = colors[i];
      canvas.drawCircle(center, radius, paint);
    }
  }

  @override
  bool shouldRepaint(CirclePainter oldDelegate) =>
      oldDelegate.centerColor != centerColor;
}

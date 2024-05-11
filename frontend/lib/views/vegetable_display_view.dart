import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/category_model.dart';
import '../models/vegetable_model.dart';
import '../models/selected_garden_model.dart';
import '../controllers/routes.dart';
import '../controllers/vegetable_controller.dart';
import '../controllers/category_controller.dart';
import 'custom_bottom_bar.dart';
import 'custom_app_bar.dart';
import 'notes_view.dart';

/// Represents the stateful widget for displaying details about a vegetable.
///
/// This widget handles the entire view logic for displaying vegetable details, managing state,
/// and interacting with the vegetable and category controllers to fetch and display data.
class VegetableView extends StatefulWidget {
  final int vegetableId;

  const VegetableView({Key? key, required this.vegetableId}) : super(key: key);

  @override
  VegetableViewState createState() => VegetableViewState();
}

/// Manages the state of [VegetableView], handling lifecycle events and UI updates.
///
/// This class interacts with [VegetableController] and [CategoryController] to retrieve
/// and display the details of the vegetable, its categories, and associated actions like
/// editing and deleting. It utilizes [FutureBuilder] to handle asynchronous fetch operations.
class VegetableViewState extends State<VegetableView> {
  late VegetableController vegetableController;
  late CategoryController categoryController;
  NotesDialog notesDialog = NotesDialog();
  late Future<VegetableModel> futureVegetable;
  final selectedGardenId = SelectedGardenModel().getSelectedGardenIdSync();
  final selectedGardenName = SelectedGardenModel().getSelectedGardenNameSync();
  String notes = '';

  final Map<String, Color> colorMap = {
    'RED': Colors.red,
    'GREEN': Colors.green,
    'BLUE': Colors.blue,
    'ORANGE': Colors.orange,
    'PURPLE': Colors.purple,
    'YELLOW': Colors.yellow,
    'BROWN': Colors.brown,
    'GREY': Colors.grey,
  };

  /// Initializes controllers and fetches the vegetable data asynchronously.
  @override
  void initState() {
    super.initState();
    vegetableController =
        VegetableController((String message) => showMessageSnackBar(message));
    categoryController =
        CategoryController((String message) => showMessageSnackBar(message));
    futureVegetable = vegetableController.getVegetableById(widget.vegetableId);
  }

  /// Builds the main scaffold of the vegetable view including app bar, body and bottom bar.
  /// Uses [FutureBuilder] to resolve vegetable data and category data asynchronously.
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    double imageHeight = screenWidth * 0.15;

    return Scaffold(
        appBar: const CustomAppBar(title: "About Vegetable"),
        body: FutureBuilder<VegetableModel>(
            future: futureVegetable,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                final vegetable = snapshot.data!;

                return FutureBuilder<PrimaryCategoryModel>(
                    future: categoryController
                        .getPrimaryCategoryById(vegetable.primaryCategoryId),
                    builder: (context, categorySnapshot) {
                      if (categorySnapshot.hasData) {
                        final category = categorySnapshot.data!;
                        return SingleChildScrollView(
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                              SizedBox(height: screenHeight * 0.030),
                              Center(
                                  child: Image.asset(
                                      'assets/${category.categoryName}.png',
                                      height: imageHeight,
                                      fit: BoxFit.cover, errorBuilder:
                                          (BuildContext context,
                                              Object exception,
                                              StackTrace? stackTrace) {
                                return Image.asset('assets/default.png',
                                    height: imageHeight);
                              })),
                              buildTitle(vegetable.vegetableName, screenWidth),
                              buildExp(vegetable.seedExpiration, screenWidth),
                              SizedBox(height: screenHeight * 0.030),
                              Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                        child: buildCategories(
                                            screenWidth,
                                            screenHeight,
                                            vegetable.primaryCategoryId,
                                            vegetable.secondaryCategoryId)),
                                    SizedBox(width: screenWidth * 0.2),
                                    Expanded(
                                        child: buildActivities(
                                            screenWidth,
                                            screenHeight,
                                            vegetable.plantStart,
                                            vegetable.plantEnd,
                                            vegetable.harvestStart,
                                            vegetable.harvestEnd)),
                                  ]),
                              SizedBox(height: screenHeight * 0.03),
                              separate(screenWidth, screenHeight),
                              SizedBox(height: screenHeight * 0.03),
                              Padding(
                                  padding: EdgeInsets.only(
                                      left: screenWidth * 0.05,
                                      right: screenWidth * 0.05),
                                  child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                            child: buildNotesButton(
                                                screenWidth,
                                                screenHeight,
                                                selectedGardenName,
                                                vegetable.note,
                                                vegetable.id,
                                                vegetable.vegetableName,
                                                vegetable.vegetableName,
                                                vegetable.seedAvailability,
                                                vegetable.seedExpiration,
                                                vegetable.harvestStart,
                                                vegetable.harvestEnd,
                                                vegetable.plantStart,
                                                vegetable.plantEnd,
                                                vegetable.primaryCategoryId,
                                                vegetable.secondaryCategoryId,
                                                vegetable.primaryCategoryId,
                                                vegetable.secondaryCategoryId)),
                                        SizedBox(width: screenWidth * 0.03),
                                        Expanded(
                                            child: buildEditButton(
                                                vegetable, screenWidth)),
                                        SizedBox(width: screenWidth * 0.03),
                                        Expanded(
                                            child: buildDeleteButton(
                                                vegetable, screenWidth)),
                                      ])),
                            ]));
                      } else if (categorySnapshot.hasError) {
                        return Text("${categorySnapshot.error}");
                      }
                      return const CircularProgressIndicator();
                    });
              } else if (snapshot.hasError) {
                return Text("${snapshot.error}");
              }
              return const CircularProgressIndicator();
            }),
        bottomNavigationBar: CustomBottomBar());
  }

  /// Builds the title display widget for the vegetable name.
  Widget buildTitle(String name, double screenWidth) {
    return Center(
        child: Text(name,
            style: GoogleFonts.abrilFatface(
                textStyle: TextStyle(
                    color: const Color(0xFF5B8E55),
                    fontSize: screenWidth * 0.079625,
                    fontWeight: FontWeight.w400))));
  }

  /// Builds the expiration display for vegetable seeds.
  Widget buildExp(int exp, double screenWidth) {
    String displayText = exp == 0 ? "No seeds" : 'Until : $exp';
    return Center(
        child: Text(displayText,
            style: TextStyle(
                color: const Color(0xFF60655D),
                fontSize: screenWidth * 0.03,
                fontFamily: 'Croissant One',
                fontWeight: FontWeight.bold)));
  }

  /// Constructs the categories section with primary and secondary categories.
  ///
  /// This method fetches category details asynchronously and displays them.
  Widget buildCategories(double screenWidth, double screenHeight,
      int primaryCategoryId, int secondaryCategoryId) {
    return Padding(
        padding: EdgeInsets.only(left: screenWidth * 0.1),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Categories',
              style: TextStyle(
                  color: const Color(0xFF394434),
                  fontSize: screenWidth * 0.05,
                  fontFamily: 'Sarala',
                  fontWeight: FontWeight.w700)),
          FutureBuilder<PrimaryCategoryModel>(
              future:
                  categoryController.getPrimaryCategoryById(primaryCategoryId),
              builder: (context, categorySnapshot) {
                if (categorySnapshot.hasData) {
                  final category = categorySnapshot.data!;
                  return buildMarkerTextLine(category.categoryName,
                      Colors.black, screenWidth, screenHeight);
                } else if (categorySnapshot.hasError) {
                  return Text("${categorySnapshot.error}");
                }
                return const CircularProgressIndicator();
              }),
          FutureBuilder<SecondaryCategoryModel>(
              future: categoryController
                  .getSecondaryCategoryById(secondaryCategoryId),
              builder: (context, categorySnapshot) {
                if (categorySnapshot.connectionState ==
                    ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (!categorySnapshot.hasData) {
                  return SizedBox(height: screenHeight * 0.03);
                } else if (categorySnapshot.hasError) {
                  return Center(
                      child: Text('Error: ${categorySnapshot.error}'));
                } else {
                  final category = categorySnapshot.data!;
                  Color color =
                      colorMap[category.categoryColor.toUpperCase()] ??
                          Colors.pink;
                  return buildMarkerTextLine(
                      category.categoryName, color, screenWidth, screenHeight);
                }
              }),
        ]));
  }

  /// Constructs the activities section detailing planting and harvesting periods.
  Widget buildActivities(double screenWidth, double screenHeight,
      String plantStart, String plantEnd, int harvestStart, int harvestEnd) {
    return Padding(
        padding: EdgeInsets.only(right: screenWidth * 0.0),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Activities',
              style: TextStyle(
                  color: const Color(0xFF394434),
                  fontSize: screenWidth * 0.05,
                  fontFamily: 'Sarala',
                  fontWeight: FontWeight.w700)),
          buildMarkerTextLine('$plantStart - $plantEnd',
              const Color(0xFF709731), screenWidth, screenHeight),
          buildMarkerTextLine('$harvestStart - $harvestEnd',
              const Color(0xFF9B5366), screenWidth, screenHeight),
        ]));
  }

  /// Creates a text line with a leading color marker.
  ///
  /// This function builds a row containing a color marker followed by text. It is used to display
  /// category and activity details in a visually distinct manner.
  Widget buildMarkerTextLine(
      String text, Color color, double screenWidth, double screenHeight) {
    return Row(children: [
      buildMarker(color, screenWidth, screenHeight),
      SizedBox(width: screenWidth * 0.015),
      Text(text,
          style: TextStyle(
              color: const Color(0xFF60645D),
              fontSize: screenWidth * 0.035,
              fontStyle: FontStyle.italic,
              fontFamily: 'Scada',
              fontWeight: FontWeight.w400)),
    ]);
  }

  /// Creates a square color marker.
  ///
  /// This widget is used as a visual representation of a category or activity's associated color,
  /// enhancing readability and visual sorting in the UI.
  Widget buildMarker(Color color, double screenWidth, double screenHeight) {
    return Container(
        width: screenWidth * 0.03,
        height: screenWidth * 0.03,
        decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
            boxShadow: const [
              BoxShadow(
                  color: Color(0x3F000000),
                  blurRadius: 4,
                  offset: Offset(0, 4),
                  spreadRadius: 0),
            ]));
  }

  /// Builds a separator line.
  ///
  /// This widget creates a thin horizontal line, used to visually separate different sections
  /// of the UI.
  Widget separate(double screenWidth, double screenHeight) {
    return Container(
        width: screenWidth,
        height: screenHeight * 0.005,
        decoration: const BoxDecoration(color: Color(0xFFEEEFEE)));
  }

  /// Builds a button to handle notes associated with a vegetable.
  ///
  /// This button triggers a dialog for editing notes specific to the displayed vegetable.
  /// It is integral for maintaining notes related to planting and care within the app.
  Widget buildNotesButton(
          double screenWidth,
          double screenHeight,
          String gardenName,
          String notes,
          int vegetableId,
          String vegetableName,
          String oldVegetableName,
          int seedAvailability,
          int seedExpiration,
          int harvestStart,
          int harvestEnd,
          String plantStart,
          String plantEnd,
          int primaryCategoryId,
          int secondaryCategoryId,
          int oldPrimaryCategoryId,
          int oldSecondaryCategoryId) =>
      ElevatedButton(
          onPressed: () async {
            bool edited = await notesDialog.show(
                context,
                screenWidth,
                screenHeight,
                'Vegetable',
                gardenName,
                notes,
                vegetableId,
                -1,
                -1,
                vegetableName,
                '',
                oldVegetableName,
                '',
                seedAvailability,
                seedExpiration,
                harvestStart,
                harvestEnd,
                plantStart,
                plantEnd,
                primaryCategoryId,
                secondaryCategoryId,
                oldPrimaryCategoryId,
                oldSecondaryCategoryId,
                '',
                -1,
                -1,
                -1);

            if (edited) {
              setState(() {
                // Re-fetch the vegetable data
                futureVegetable =
                    vegetableController.getVegetableById(widget.vegetableId);
              });
            }
          },
          style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFD1EFE7),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10))),
          child: Text("Notes",
              style: TextStyle(
                  color: const Color(0xFF5FB9B4),
                  fontSize: screenWidth * 0.04)));

  /// Builds an edit button for modifying vegetable details.
  ///
  /// This button directs the user to a form where they can update the current vegetable's details,
  /// facilitating easy management and correction of vegetable data.
  Widget buildEditButton(VegetableModel vegetable, double screenWidth) =>
      ElevatedButton(
          onPressed: () {
            Navigator.of(context).pushNamed(Routes.vegetableCreation,
                arguments: VegetableCreationArguments(
                    vegetableId: vegetable.id,
                    vegetableName: vegetable.vegetableName,
                    seedExpiration: vegetable.seedExpiration,
                    harvestStart: vegetable.harvestStart,
                    harvestEnd: vegetable.harvestEnd,
                    plantStart: vegetable.plantStart,
                    plantEnd: vegetable.plantEnd,
                    primaryCategoryId: vegetable.primaryCategoryId,
                    secondaryCategoryId: vegetable.secondaryCategoryId,
                    note: vegetable.note));
          },
          style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFD1EFE7),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10))),
          child: Text("Edit",
              style: TextStyle(
                  color: const Color(0xFF5FB9B4),
                  fontSize: screenWidth * 0.04)));

  /// Constructs a delete button to remove a vegetable entry.
  ///
  /// This button initiates a process to safely remove a vegetable from the garden, including
  /// re-categorization before deletion to ensure data consistency.
  Widget buildDeleteButton(VegetableModel vegetable, double screenWidth) =>
      ElevatedButton(
          onPressed: () async {
            // Fetch the primary category ID for 'Bin'
            PrimaryCategoryModel binCategory = await categoryController
                .getAllPrimaryCategories(selectedGardenId)
                .then((categories) =>
                    categories.firstWhere((cat) => cat.categoryName == 'Bin'));

            bool success = await vegetableController.editVegetable(
                vegetable.id,
                vegetable.vegetableName,
                vegetable.seedAvailability,
                vegetable.seedExpiration,
                vegetable.harvestStart,
                vegetable.harvestEnd,
                vegetable.plantStart,
                vegetable.plantEnd,
                binCategory.primaryCategoryId,
                0,
                vegetable.note,
                selectedGardenId,
                selectedGardenName,
                vegetable.vegetableName,
                vegetable.primaryCategoryId,
                vegetable.secondaryCategoryId);

            if (success && mounted) {
              Navigator.of(context).pushNamed(Routes.categories);
            }
          },
          style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFD1EFE7),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10))),
          child: Text("Delete",
              style: TextStyle(
                  color: const Color(0xFF5FB9B4),
                  fontSize: screenWidth * 0.04)));

  /// Displays a snackbar with a custom message.
  ///
  /// This function is used throughout the app to provide feedback to the user about actions
  /// such as saving, editing, or deleting data.
  void showMessageSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), duration: const Duration(seconds: 2)));
  }
}

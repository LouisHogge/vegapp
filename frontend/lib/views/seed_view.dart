import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/category_model.dart';
import '../models/vegetable_model.dart';
import '../models/selected_garden_model.dart';
import '../controllers/category_controller.dart';
import '../controllers/vegetable_controller.dart';
import '../controllers/routes.dart';
import 'custom_bottom_bar.dart';
import 'custom_app_bar.dart';

/// Displays the seed catalog for a selected garden, with functionality to filter by seed status.
///
/// This stateful widget provides a detailed view of available seeds categorized by their quality,
/// age, and expiration. It facilitates navigation to vegetable details and allows for the addition
/// of new seeds to the garden.
class SeedView extends StatefulWidget {
  const SeedView({super.key});

  @override
  VegetableViewState createState() => VegetableViewState();
}

/// Manages the state and behavior of [SeedView].
///
/// It handles the display and filtering of seeds based on their quality, expiration, and planting year.
/// Includes dynamic color updates and category-based vegetable fetching.
class VegetableViewState extends State<SeedView> {
  late CategoryController categoryController;
  late VegetableController vegetableController;
  late Future<List<dynamic>> futureCategories;
  final selectedGardenId = SelectedGardenModel().getSelectedGardenIdSync();
  int? selectedCategoryId;
  String? selectedCategoryIdString;
  String selectedCategoryName = "";
  bool? isPrimary;
  bool isGoodButtonPressed = false;
  bool isYearButtonPressed = false;
  bool isExpiredButtonPressed = false;
  late Color defaultWidgetGoodColor;
  late Color widgetGoodColor = defaultWidgetGoodColor;
  late Color widgetYearColor = defaultWidgetGoodColor;
  late Color widgetExpiredColor = defaultWidgetGoodColor;
  Color buttonGoodColor = Colors.white;
  Color buttonYearColor = Colors.white;
  Color buttonExpiredColor = Colors.white;
  int seedExpiration = 0;

  /// Initializes controllers and sets up future categories upon widget creation.
  @override
  void initState() {
    super.initState();
    categoryController =
        CategoryController((String message) => showMessageSnackBar(message));
    vegetableController =
        VegetableController((String message) => showMessageSnackBar(message));

    futureCategories = getAllCategories();
  }

  /// Fetches both primary and secondary categories associated with the selected garden.
  Future<List<dynamic>> getAllCategories() async {
    var primaryCategories =
        await categoryController.getAllPrimaryCategories(selectedGardenId);

    if (primaryCategories.isNotEmpty) {
      primaryCategories = primaryCategories.sublist(1);
    }

    var secondaryCategories =
        await categoryController.getAllSecondaryCategories(selectedGardenId);
    return [...primaryCategories, ...secondaryCategories];
  }

  /// Fetches vegetables based on the selected category and its type (primary or secondary).
  Future<List<VegetableModel>> getVegetablesByCategory() async {
    if (isPrimary != null && isPrimary!) {
      var primaryCategories = await vegetableController
          .getVegetablesByPrimaryCategory(selectedCategoryId ?? -1);
      return primaryCategories;
    } else if (isPrimary != null && !isPrimary!) {
      var secondaryCategories = await vegetableController
          .getVegetablesBySecondaryCategory(selectedCategoryId ?? -1);
      return secondaryCategories;
    } else {
      return [];
    }
  }

  /// Constructs the user interface for the seed view.
  /// Includes dropdowns for category selection and status buttons to filter seeds.
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    defaultWidgetGoodColor = Theme.of(context).scaffoldBackgroundColor;

    return Scaffold(
        appBar: const CustomAppBar(title: "My Seeds"),
        body: FutureBuilder<List<VegetableModel>>(
            future: getVegetablesByCategory(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text("Error: ${snapshot.error}"));
              } else {
                return Column(children: [
                  SizedBox(height: screenHeight * 0.01),
                  SizedBox(
                      width: screenWidth * 0.6,
                      height: screenHeight * 0.12,
                      child: buildCategoryDropdown("Category")),
                  SizedBox(height: screenHeight * 0.03),
                  Row(children: [
                    SizedBox(
                        width: screenWidth * 0.3,
                        height: screenHeight * 0.08,
                        child: buildStatusButton(
                            'Good', screenWidth, screenHeight)),
                    SizedBox(width: screenWidth * 0.02),
                    SizedBox(
                        width: screenWidth * 0.35,
                        height: screenHeight * 0.08,
                        child: buildStatusButton(
                            'This year', screenWidth, screenHeight)),
                    SizedBox(width: screenWidth * 0.02),
                    SizedBox(
                        width: screenWidth * 0.3,
                        height: screenHeight * 0.08,
                        child: buildStatusButton(
                            'Expired', screenWidth, screenHeight)),
                  ]),
                  SizedBox(height: screenHeight * 0.05),
                  separate(screenWidth, screenHeight),
                  SizedBox(height: screenHeight * 0.01),
                  Text(selectedCategoryName,
                      style: GoogleFonts.abrilFatface(
                          textStyle: TextStyle(
                              color: const Color(0xFF835B46),
                              fontSize: screenWidth * 0.055,
                              fontWeight: FontWeight.w400,
                              height: 0))),
                  SizedBox(height: screenHeight * 0.01),
                  separate(screenWidth, screenHeight),
                  Expanded(
                      child: VegetableList(
                          vegetables: snapshot.data!,
                          isGoodButtonPressed: isGoodButtonPressed,
                          isYearButtonPressed: isYearButtonPressed,
                          isExpiredButtonPressed: isExpiredButtonPressed)),
                ]);
              }
            }),
        bottomNavigationBar: CustomBottomBar());
  }

  /// Builds a dropdown menu for category selection.
  Widget buildCategoryDropdown(String label) {
    return FutureBuilder<List<dynamic>>(
      future: futureCategories,
      builder: (BuildContext context, AsyncSnapshot<List<dynamic>> snapshot) {
        if (snapshot.hasData) {
          List<DropdownMenuItem<String>> dropdownItems = snapshot.data!
              .map((category) => DropdownMenuItem<String>(
                  value: category is PrimaryCategoryModel
                      ? "P.${category.primaryCategoryId}"
                      : "S.${(category as SecondaryCategoryModel).secondaryCategoryId}",
                  child: Text(category.categoryName)))
              .toList();

          return DropdownButtonFormField<String>(
              decoration: InputDecoration(
                  labelText: label,
                  focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Color(0xFF5B8E55)),
                      borderRadius: BorderRadius.circular(10))),
              value: selectedCategoryIdString,
              onChanged: (String? newValue) {
                setState(() {
                  selectedCategoryIdString = newValue;
                  isPrimary = selectedCategoryIdString![0] == 'P';
                  selectedCategoryId =
                      int.parse(selectedCategoryIdString!.split(".")[1]);

                  if (isPrimary!) {
                    selectedCategoryName = snapshot.data!
                        .whereType<PrimaryCategoryModel>()
                        .firstWhere((category) =>
                            category.primaryCategoryId == selectedCategoryId)
                        .categoryName;
                  } else {
                    selectedCategoryName = snapshot.data!
                        .whereType<SecondaryCategoryModel>()
                        .firstWhere((category) =>
                            category.secondaryCategoryId == selectedCategoryId)
                        .categoryName;
                  }
                });
              },
              items: dropdownItems);
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }
        return const CircularProgressIndicator();
      },
    );
  }

  /// Builds a button for selecting seed status ('Good', 'This year', 'Expired').
  Widget buildStatusButton(
      String label, double screenWidth, double screenHeight) {
    return InkWell(
        onTap: () => _pushedButton(label),
        child: Container(
            padding: EdgeInsets.symmetric(
                horizontal: screenWidth * 0.03, vertical: screenHeight * 0.01),
            decoration: BoxDecoration(
                color: _getWidgetColor(label),
                borderRadius: BorderRadius.circular(10)),
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(
                      width: screenWidth * 0.05,
                      height: screenWidth * 0.05,
                      child: ElevatedButton(
                          onPressed: () => _pushedButton(label),
                          style: ElevatedButton.styleFrom(
                              backgroundColor: _getButtonColor(label)),
                          child: Container())),
                  Text(label,
                      style: GoogleFonts.abrilFatface(
                          textStyle: TextStyle(
                              fontSize: screenWidth * 0.042,
                              fontWeight: FontWeight.w400,
                              color: _getPressedColor(label)))),
                ])));
  }

  /// Toggles the state of the status button when pressed and updates corresponding colors.
  void _pushedButton(String label) {
    setState(() {
      for (final buttonLabel in ['Good', 'This year', 'Expired']) {
        // Reset non-pressed button states
        if (buttonLabel != label) {
          _setButtonState(buttonLabel, false);
        } else {
          // The button concerned is pushed
          _setButtonState(label, !_isButtonPressed(label));
        }
      }
    });
  }

  /// Determines if a status button ('Good', 'This year', 'Expired') is pressed.
  bool _isButtonPressed(String label) {
    switch (label) {
      case 'Good':
        return isGoodButtonPressed;
      case 'This year':
        return isYearButtonPressed;
      case 'Expired':
        return isExpiredButtonPressed;
      default:
        return false;
    }
  }

  /// Sets the state of a status button and updates corresponding colors based on whether the button is pressed.
  void _setButtonState(String label, bool isPressed) {
    switch (label) {
      case 'Good':
        isGoodButtonPressed = isPressed;
        _updateColors('Good', isPressed);
        break;
      case 'This year':
        isYearButtonPressed = isPressed;
        _updateColors('This year', isPressed);
        break;
      case 'Expired':
        isExpiredButtonPressed = isPressed;
        _updateColors('Expired', isPressed);
        break;
    }
  }

  /// Updates the colors of widgets based on the pressed state of buttons to visually indicate selection.
  void _updateColors(String label, bool isPressed) {
    final pressedColor = isPressed ? _getPressedColor(label) : Colors.white;
    final widgetColor =
        isPressed ? const Color(0xFFEFEEF1) : defaultWidgetGoodColor;
    switch (label) {
      case 'Good':
        buttonGoodColor = pressedColor;
        widgetGoodColor = widgetColor;
        break;
      case 'This year':
        buttonYearColor = pressedColor;
        widgetYearColor = widgetColor;
        break;
      case 'Expired':
        buttonExpiredColor = pressedColor;
        widgetExpiredColor = widgetColor;
        break;
    }
  }

  /// Retrieves the appropriate color based on the pressed state of a button.
  Color _getPressedColor(String label) {
    switch (label) {
      case 'Good':
        return const Color(0xFF81A545);
      case 'This year':
        return const Color(0xFFFF8900);
      case 'Expired':
        return const Color(0xFFEC1212);
      default:
        return Colors.white;
    }
  }

  /// Retrieves the current color of a button based on its label.
  Color _getButtonColor(String label) {
    switch (label) {
      case 'Good':
        return buttonGoodColor;
      case 'This year':
        return buttonYearColor;
      case 'Expired':
        return buttonExpiredColor;
      default:
        return Colors.white;
    }
  }

  /// Retrieves the current color of a widget based on its label.
  Color _getWidgetColor(String label) {
    switch (label) {
      case 'Good':
        return widgetGoodColor;
      case 'This year':
        return widgetYearColor;
      case 'Expired':
        return widgetExpiredColor;
      default:
        return Colors.white;
    }
  }

  /// Creates a visual separator when a category is selected.
  Widget separate(double screenWidth, double screenHeight) {
    return selectedCategoryId != null
        ? Container(
            width: screenWidth,
            height: screenHeight * 0.0020,
            decoration: const BoxDecoration(color: Color(0xFF835B46)))
        : const SizedBox();
  }

  /// Displays a snackbar message in response to certain actions within the view.
  void showMessageSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), duration: const Duration(seconds: 2)));
  }
}

/// A list widget to display vegetables according to the selected seed status.
///
/// It provides a dynamic view that filters and shows vegetables based on seed quality, expiration, or planting year.
class VegetableList extends StatefulWidget {
  final List<VegetableModel> vegetables;
  final bool isGoodButtonPressed;
  final bool isYearButtonPressed;
  final bool isExpiredButtonPressed;

  const VegetableList(
      {Key? key,
      required this.vegetables,
      required this.isGoodButtonPressed,
      required this.isYearButtonPressed,
      required this.isExpiredButtonPressed})
      : super(key: key);

  @override
  State<VegetableList> createState() => _VegetableListState();
}

/// Manages the state and behavior of [VegetableList].
///
/// Represents the list view of vegetables that are filtered based on their seed status.
class _VegetableListState extends State<VegetableList> {
  Color boxColor = const Color(0xFF81A545);

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double fontSize = screenWidth * 0.04;
    double margin = screenWidth * 0.02;
    double paddingIn = screenWidth * 0.02;
    double paddingOut = screenWidth * 0.15;

    return Scaffold(
        body: ListView.builder(
            padding:
                EdgeInsets.symmetric(horizontal: paddingOut, vertical: margin),
            itemCount: widget.vegetables.length,
            itemBuilder: (context, index) {
              VegetableModel vegetable = widget.vegetables[index];
              bool showVegetable;
              int currentYear = DateTime.now().year;
              bool availability =
                  widget.vegetables[index].seedAvailability == 1 ? true : false;

              if (vegetable.seedExpiration == currentYear) {
                boxColor = const Color(0xFFFF8900);
              } else if (vegetable.seedExpiration < currentYear) {
                boxColor = const Color(0xFFEC1212);
              } else {
                boxColor = const Color(0xFF81A545);
              }

              showVegetable = (widget.isGoodButtonPressed &&
                      vegetable.seedExpiration > currentYear) ||
                  (widget.isYearButtonPressed &&
                      vegetable.seedExpiration == currentYear) ||
                  (widget.isExpiredButtonPressed &&
                      vegetable.seedExpiration < currentYear) ||
                  (!widget.isGoodButtonPressed &&
                      !widget.isYearButtonPressed &&
                      !widget.isExpiredButtonPressed);

              if (!showVegetable) {
                return const SizedBox.shrink();
              }

              return Stack(children: [
                Align(
                    alignment: Alignment.center,
                    child: ImageFiltered(
                        imageFilter: ImageFilter.blur(
                            sigmaX: !availability ? 1 : 0.0,
                            sigmaY: !availability ? 1 : 0.0),
                        child: Container(
                            margin: EdgeInsets.all(margin),
                            padding: EdgeInsets.all(paddingIn),
                            width: screenWidth * 0.8,
                            height: (screenWidth * 0.6) / 6,
                            decoration: BoxDecoration(
                                color: boxColor,
                                borderRadius: BorderRadius.circular(10)),
                            child: InkWell(
                                onTap: () {
                                  Navigator.of(context).pushNamed(
                                      Routes.vegetableDisplay,
                                      arguments: VegetableDisplayArguments(
                                          vegetableId: vegetable.id));
                                },
                                child: Center(
                                    child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                      SizedBox(
                                          child: Text(vegetable.vegetableName,
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: fontSize))),
                                      !availability
                                          ? SizedBox(
                                              child: Text('No seeds',
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: fontSize)))
                                          : SizedBox(
                                              child: Text(
                                                  'Until : ${vegetable.seedExpiration}',
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: fontSize)))
                                    ])))))),
                !availability
                    ? Positioned.fill(
                        child: GestureDetector(
                            onTap: () {
                              Navigator.of(context).pushNamed(
                                  Routes.vegetableDisplay,
                                  arguments: VegetableDisplayArguments(
                                      vegetableId: vegetable.id));
                            },
                            child: Transform.rotate(
                                angle: -0.35, // Radians for 30 degrees
                                child: Center(
                                    child: Text("Out of Stock",
                                        style: GoogleFonts.abrilFatface(
                                            color: const Color(0xFFB47C45),
                                            shadows: [
                                              const Shadow(
                                                  offset: Offset(-3.0, -1.0),
                                                  blurRadius: 7.0,
                                                  color: Colors.black),
                                            ],
                                            fontSize: fontSize, // 15
                                            fontWeight: FontWeight.w800))))))
                    : Positioned.fill(
                        child: GestureDetector(
                            onTap: () {
                              Navigator.of(context).pushNamed(
                                  Routes.vegetableDisplay,
                                  arguments: VegetableDisplayArguments(
                                      vegetableId: vegetable.id));
                            },
                            child: const Text("")))
              ]);
            }));
  }

  /// Displays a snackbar message in response to certain actions within the view.
  void showMessageSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), duration: const Duration(seconds: 2)));
  }
}

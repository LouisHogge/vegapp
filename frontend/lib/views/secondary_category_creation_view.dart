import 'package:flutter/material.dart';
import '../models/selected_garden_model.dart';
import '../controllers/category_controller.dart';
import '../controllers/routes.dart';
import 'custom_bottom_bar.dart';
import 'custom_app_bar.dart';

/// Represents the stateful widget for creating or editing a secondary category.
///
/// This view allows users to set the name and color for a secondary category. It supports
/// both creation and editing based on whether initial data is provided.
class SecondaryCategoryCreationView extends StatefulWidget {
  final SecondaryCategoryArguments? initialData;

  /// Constructs a [SecondaryCategoryCreationView] optionally with initial data for editing.
  const SecondaryCategoryCreationView({Key? key, this.initialData})
      : super(key: key);

  @override
  SecondaryCategoryCreationViewState createState() =>
      SecondaryCategoryCreationViewState();
}

/// Manages the state and interactions in [SecondaryCategoryCreationView].
///
/// This state class handles the UI and logic for creating or updating secondary categories,
/// managing form inputs and submission, and handling lifecycle states for controllers and text fields.
class SecondaryCategoryCreationViewState
    extends State<SecondaryCategoryCreationView> {
  late CategoryController categoryController;
  late TextEditingController categoryNameController;
  late TextEditingController categoryColorController;
  int categoryId = -1;
  String categoryName = '';
  String oldCategoryName = '';
  String pickedColor = 'RED'; // Default color
  bool edit = false; // Indicates whether the form is in edit mode
  final selectedGardenId = SelectedGardenModel().getSelectedGardenIdSync();
  final selectedGardenName = SelectedGardenModel().getSelectedGardenNameSync();

  /// Sets up controllers and initial data if editing an existing category.
  @override
  void initState() {
    super.initState();
    categoryController =
        CategoryController((String message) => showMessageSnackBar(message));

    categoryNameController = TextEditingController();

    if (widget.initialData != null) {
      edit = true;
      categoryId = widget.initialData!.categoryId;
      categoryName = widget.initialData!.categoryName;
      oldCategoryName = widget.initialData!.categoryName;
      pickedColor = widget.initialData!.categoryColor;

      categoryNameController =
          TextEditingController(text: widget.initialData?.categoryName);
      categoryColorController =
          TextEditingController(text: widget.initialData?.categoryColor);
    }
  }

  /// Cleans up controllers to avoid memory leaks.
  @override
  void dispose() {
    categoryNameController.dispose();
    super.dispose();
  }

  /// Builds the UI elements for category name and color selection.
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    double textSize = screenWidth * 0.04;

    List<Color> colorOptions = [
      Colors.red,
      Colors.green,
      Colors.blue,
      Colors.orange,
      Colors.purple,
      Colors.yellow,
      Colors.brown,
    ];
    Map<Color, String> reverseColorMap = {
      Colors.red: 'RED',
      Colors.green: 'GREEN',
      Colors.blue: 'BLUE',
      Colors.orange: 'ORANGE',
      Colors.purple: 'PURPLE',
      Colors.yellow: 'YELLOW',
      Colors.brown: 'BROWN',
    };

    return Scaffold(
        appBar: const CustomAppBar(title: "Secondary Category"),
        body: SingleChildScrollView(
            child: Padding(
                padding: EdgeInsets.all(screenHeight * 0.01),
                child: Column(children: [
                  buildTextField(
                      categoryNameController,
                      'Category Name',
                      'Enter category name...',
                      (value) => setState(() => categoryName = value)),
                  SizedBox(height: screenHeight * 0.03),
                  Text("Color Choice", style: TextStyle(fontSize: textSize)),
                  SizedBox(height: screenHeight * 0.01),
                  buildColorField(
                      screenWidth, screenHeight, colorOptions, reverseColorMap),
                  SizedBox(height: screenHeight * 0.03),
                  buildConfirmButton(edit),
                ]))),
        bottomNavigationBar: CustomBottomBar());
  }

  /// Builds a text field for inputting category name.
  ///
  /// The field updates the state of category name on change and validates the input.
  Widget buildTextField(TextEditingController controller, String label,
      String hint, ValueChanged<String> onChanged) {
    return TextField(
        controller: controller,
        decoration: InputDecoration(
            labelText: label,
            hintText: hint,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            focusedBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: Color(0xFF5B8E55)),
                borderRadius: BorderRadius.circular(10))),
        onChanged: onChanged);
  }

  /// Builds a selection field for choosing a category color.
  ///
  /// Displays color options as circular color buttons, updating the selected color on tap.
  Widget buildColorField(double screenWidth, double screenHeight,
      List<Color> colorOptions, Map<Color, String> reverseColorMap) {
    return Wrap(
      children: colorOptions.map((color) {
        bool isSelected = reverseColorMap[color] == pickedColor;
        return GestureDetector(
            onTap: () {
              setState(() {
                pickedColor = reverseColorMap[color] ?? 'RED';
              });
            },
            child: Container(
                width: screenWidth * 0.1,
                height: screenHeight * 0.05,
                margin: EdgeInsets.all(screenWidth * 0.01),
                decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    border: Border.all(
                        color: isSelected ? Colors.black : Colors.transparent,
                        width: 3))));
      }).toList(),
    );
  }

  /// Constructs the confirm button for the form.
  ///
  /// This button will submit the category data, handling both creation and updating
  /// depending on the edit mode.
  Widget buildConfirmButton(bool edit) => ElevatedButton(
      onPressed: () async {
        bool success = false;
        if (edit) {
          success = await categoryController.editSecondaryCategory(
              categoryId,
              categoryName,
              pickedColor,
              selectedGardenId,
              selectedGardenName,
              oldCategoryName);
        } else {
          success = await categoryController.createSecondaryCategory(
              categoryName, pickedColor, selectedGardenId, selectedGardenName);
        }

        if (success && mounted) {
          Navigator.of(context).pushNamedAndRemoveUntil(
              Routes.categories, (Route<dynamic> route) => false);
        }
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF5B8E55),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      child: const Text('Confirm', style: TextStyle(color: Colors.white)));

  /// Displays a snackbar message for feedback.
  ///
  /// Utilized to provide user feedback on operations such as create or update actions.
  void showMessageSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), duration: const Duration(seconds: 2)));
  }
}

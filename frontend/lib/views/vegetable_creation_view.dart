import 'package:flutter/material.dart';
import '../models/category_model.dart';
import '../models/selected_garden_model.dart';
import '../controllers/category_controller.dart';
import '../controllers/vegetable_controller.dart';
import '../controllers/routes.dart';
import 'custom_bottom_bar.dart';
import 'custom_app_bar.dart';

/// Represents the stateful widget for creating or editing vegetable entries.
///
/// This view allows users to input and modify details about a vegetable, including its name,
/// categories, planting, and harvesting data. It supports both creation and editing modes based on
/// whether initial data is provided.
class VegetableCreationView extends StatefulWidget {
  final VegetableCreationArguments? initialData;

  /// Constructs a [VegetableCreationView] optionally with initial data for editing.
  const VegetableCreationView({Key? key, this.initialData}) : super(key: key);

  @override
  VegetableCreationViewState createState() => VegetableCreationViewState();
}

/// Manages the state and interactions in [VegetableCreationView].
///
/// This state class handles the UI and logic for creating or updating vegetable entries,
/// managing form inputs and submission, and handling lifecycle states for controllers and text fields.
class VegetableCreationViewState extends State<VegetableCreationView> {
  late CategoryController categoryController;
  late VegetableController vegetableController;
  late TextEditingController nameController;
  late TextEditingController seedExpirationController;
  late TextEditingController harvestStartController;
  late TextEditingController harvestEndController;
  late Future<List<PrimaryCategoryModel>> futurePrimaryCategories;
  late Future<List<SecondaryCategoryModel>> futureSecondaryCategories;
  final selectedGardenId = SelectedGardenModel().getSelectedGardenIdSync();
  final selectedGardenName = SelectedGardenModel().getSelectedGardenNameSync();
  int seedYear = DateTime.now().year;
  bool edit = false; // Indicates whether the form is in edit mode

  // Form input variables
  int vegetableId = -1;
  String vegetableName = '';
  String oldVegetableName = '';
  int seedExpiration = 0;
  bool seedAvailability = false; // For the toggle
  int harvestStart = 0;
  int harvestEnd = 0;
  String plantStart = '';
  String plantEnd = '';
  int? primaryCategoryId;
  int? secondaryCategoryId;
  int? oldPrimaryCategoryId;
  int? oldSecondaryCategoryId;
  String note = '';

  /// Sets up controllers and initial data if editing an existing vegetable.
  @override
  void initState() {
    super.initState();
    vegetableController =
        VegetableController((String message) => showMessageSnackBar(message));
    categoryController =
        CategoryController((String message) => showMessageSnackBar(message));
    futurePrimaryCategories =
        categoryController.getAllPrimaryCategories(selectedGardenId);
    futureSecondaryCategories =
        categoryController.getAllSecondaryCategories(selectedGardenId);

    nameController = TextEditingController();
    seedExpirationController = TextEditingController();
    harvestStartController = TextEditingController();
    harvestEndController = TextEditingController();

    if (widget.initialData != null) {
      if (widget.initialData!.vegetableId != -1 &&
          widget.initialData!.vegetableId != -2) {
        edit = true;
        vegetableId = widget.initialData!.vegetableId;
        vegetableName = widget.initialData!.vegetableName;
        oldVegetableName = widget.initialData!.vegetableName;
        seedExpiration = widget.initialData!.seedExpiration;
        seedAvailability = widget.initialData!.seedExpiration > 0;
        plantStart = widget.initialData!.plantStart;
        plantEnd = widget.initialData!.plantEnd;
        harvestStart = widget.initialData!.harvestStart;
        harvestEnd = widget.initialData!.harvestEnd;
        primaryCategoryId = widget.initialData!.primaryCategoryId;
        oldPrimaryCategoryId = widget.initialData!.primaryCategoryId;
        note = widget.initialData!.note;
        if (widget.initialData!.secondaryCategoryId != 0) {
          secondaryCategoryId = widget.initialData!.secondaryCategoryId;
          oldSecondaryCategoryId = widget.initialData!.secondaryCategoryId;
        }

        nameController.text = vegetableName;
        seedExpirationController.text = seedExpiration.toString();
        harvestStartController.text = harvestStart.toString();
        harvestEndController.text = harvestEnd.toString();
      } else if (widget.initialData!.vegetableId == -1) {
        primaryCategoryId = widget.initialData!.primaryCategoryId;
      } else if (widget.initialData!.vegetableId == -2) {
        secondaryCategoryId = widget.initialData!.secondaryCategoryId;
      }
    }
  }

  /// Cleans up controllers to avoid memory leaks.
  @override
  void dispose() {
    nameController.dispose();
    seedExpirationController.dispose();
    harvestStartController.dispose();
    harvestEndController.dispose();
    super.dispose();
  }

  /// Builds the UI elements for vegetable data input fields.
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
        appBar: const CustomAppBar(title: "Vegetable"),
        body: GestureDetector(
            onTap: () {
              FocusScope.of(context).requestFocus(FocusNode());
            },
            child: SingleChildScrollView(
                child: Padding(
                    padding: EdgeInsets.all(screenHeight * 0.01),
                    child: Column(children: [
                      buildTextField(
                          nameController,
                          'Name',
                          'Enter vegetable name...',
                          (value) => setState(() => vegetableName = value)),
                      SizedBox(height: screenHeight * 0.01),
                      Row(children: [
                        Expanded(child: buildPrimaryCategoryDropdown()),
                        SizedBox(width: screenWidth * 0.02),
                        Expanded(child: buildSecondaryCategoryDropdown()),
                      ]),
                      SizedBox(height: screenHeight * 0.01),
                      Row(children: [
                        Expanded(
                            child: buildToggleField(
                                'Seed', screenWidth, screenHeight)),
                        SizedBox(width: screenWidth * 0.02),
                        Expanded(
                            child: buildYearInputField(seedExpirationController,
                                'Seed Expiration', 'In years')),
                      ]),
                      SizedBox(height: screenHeight * 0.01),
                      Row(children: [
                        Expanded(child: buildMonthPicker('Plant Start')),
                        SizedBox(width: screenWidth * 0.02),
                        Expanded(child: buildMonthPicker('Plant End')),
                      ]),
                      SizedBox(height: screenHeight * 0.01),
                      Row(children: [
                        Expanded(
                            child: buildNumericInputField(
                                harvestStartController,
                                'Harvest Start',
                                'In weeks',
                                (value) =>
                                    setState(() => harvestStart = value))),
                        SizedBox(width: screenWidth * 0.02),
                        Expanded(
                            child: buildNumericInputField(
                                harvestEndController,
                                'Harvest End',
                                'In weeks',
                                (value) => setState(() => harvestEnd = value))),
                      ]),
                      SizedBox(height: screenHeight * 0.01),
                      buildConfirmButton(edit),
                    ])))),
        bottomNavigationBar: CustomBottomBar());
  }

  /// Builds a text field for inputting vegetable name.
  ///
  /// The field updates the state of vegetable name on change and validates the input.
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

  /// Builds a toggle switch for seed availability.
  ///
  /// This switch controls whether seeds are available for the vegetable, impacting other form inputs.
  Widget buildToggleField(
      String label, double screenWidth, double screenHeight) {
    return Container(
        padding: EdgeInsets.symmetric(
            horizontal: screenWidth * 0.03, vertical: screenHeight * 0.01),
        decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFF7A747E), width: 1),
            borderRadius: BorderRadius.circular(10)),
        child:
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(label, style: TextStyle(fontSize: screenWidth * 0.05)),
          Switch(
              value: seedAvailability,
              onChanged: (value) {
                setState(() {
                  seedAvailability = value;
                  if (!seedAvailability) {
                    seedExpiration = 0; // Set to 0 when the toggle is off
                  }
                });
              },
              activeTrackColor: const Color(0xFF60B357),
              activeColor: const Color(0xFF5B8E55)),
        ]));
  }

  /// Builds a dropdown form field for selecting a planting or harvesting month.
  ///
  /// This method generates a dropdown menu for month selection, used for specifying plant start and end times.
  Widget buildMonthPicker(String label) {
    List<String> months = [
      "Jan.",
      "Feb.",
      "March",
      "April",
      "May",
      "June",
      "July",
      "Aug.",
      "Sept.",
      "Oct.",
      "Nov.",
      "Dec.",
    ];

    String currentValue = label == 'Plant Start' ? plantStart : plantEnd;

    return DropdownButtonFormField<String>(
        decoration: InputDecoration(
            labelText: label,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            focusedBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: Color(0xFF5B8E55)),
                borderRadius: BorderRadius.circular(10))),
        value: currentValue.isNotEmpty ? currentValue : null,
        items: months.map((String month) {
          return DropdownMenuItem<String>(value: month, child: Text(month));
        }).toList(),
        onChanged: (String? newValue) {
          setState(() {
            if (label == 'Plant Start') {
              plantStart = newValue ?? '';
            } else {
              plantEnd = newValue ?? '';
            }
          });
        });
  }

  /// Builds a numeric input field for entering time-related data, like seed expiration or harvest durations.
  ///
  /// This input field allows for the specification of numeric values related to the vegetable's lifecycle, such as the
  /// number of weeks until harvest starts or ends.
  Widget buildNumericInputField(TextEditingController controller, String label,
      String hint, void Function(int) onChanged) {
    return TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
            labelText: label,
            hintText: hint,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            focusedBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: Color(0xFF5B8E55)),
                borderRadius: BorderRadius.circular(10))),
        onChanged: (value) {
          onChanged(int.tryParse(value) ?? 0);
        });
  }

  /// Constructs the confirm button for the form.
  ///
  /// This button will submit the vegetable data, handling both creation and updating
  /// depending on the edit mode.
  Widget buildConfirmButton(bool edit) => ElevatedButton(
      onPressed: () async {
        bool success = false;
        if (edit) {
          success = await vegetableController.editVegetable(
              vegetableId,
              vegetableName,
              seedAvailability ? 1 : 0,
              seedExpiration,
              harvestStart,
              harvestEnd,
              plantStart,
              plantEnd,
              primaryCategoryId ?? 0,
              secondaryCategoryId ?? 0,
              note,
              selectedGardenId,
              selectedGardenName,
              oldVegetableName,
              oldPrimaryCategoryId ?? 0,
              oldSecondaryCategoryId ?? 0);
        } else {
          success = await vegetableController.createVegetable(
              vegetableName,
              seedAvailability ? 1 : 0,
              seedExpiration,
              harvestStart,
              harvestEnd,
              plantStart,
              plantEnd,
              primaryCategoryId ?? 0,
              secondaryCategoryId ?? 0,
              "",
              selectedGardenId,
              selectedGardenName);
        }

        if (success && mounted) {
          Navigator.of(context).pushNamedAndRemoveUntil(
              Routes.categories, (Route<dynamic> route) => false);
        }
      },
      style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF5B8E55),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
      child: const Text('Confirm', style: TextStyle(color: Colors.white)));

  /// Builds a dropdown for selecting primary category.
  ///
  /// This dropdown menu allows users to assign a primary category from a predefined list fetched asynchronously.
  Widget buildPrimaryCategoryDropdown() {
    return FutureBuilder<List<PrimaryCategoryModel>>(
        future: futurePrimaryCategories,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return DropdownButtonFormField<int>(
                decoration: InputDecoration(
                    labelText: "Primary Category",
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10)),
                    focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Color(0xFF5B8E55)),
                        borderRadius: BorderRadius.circular(10))),
                value: primaryCategoryId,
                onChanged: (newValue) {
                  setState(() {
                    primaryCategoryId = newValue ?? 0;
                  });
                },
                items: snapshot.data!
                    .map((category) => DropdownMenuItem<int>(
                        value: category.primaryCategoryId,
                        child: Text(category.categoryName)))
                    .toList());
          }
          return const CircularProgressIndicator();
        });
  }

  /// Builds a dropdown for selecting secondary category.
  ///
  /// Similar to the primary category dropdown, this allows for the selection of a secondary category, enhancing categorization options for the vegetable.
  Widget buildSecondaryCategoryDropdown() {
    return FutureBuilder<List<SecondaryCategoryModel>>(
        future: futureSecondaryCategories,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return DropdownButtonFormField<int>(
                decoration: InputDecoration(
                    labelText: "Secondary Category",
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10)),
                    focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Color(0xFF5B8E55)),
                        borderRadius: BorderRadius.circular(10))),
                value: secondaryCategoryId,
                onChanged: (newValue) {
                  setState(() {
                    secondaryCategoryId = newValue ?? 0;
                  });
                },
                items: snapshot.data!
                    .map((category) => DropdownMenuItem<int>(
                        value: category.secondaryCategoryId,
                        child: Text(category.categoryName)))
                    .toList());
          }
          return const CircularProgressIndicator();
        });
  }

  /// Builds a numeric input field specifically for entering the seed expiration year.
  ///
  /// This input field is enabled or disabled based on the [seedAvailability] toggle. It allows the user to enter
  /// the number of years until seed expiration, supporting dynamic input validation and updating the [seedExpiration]
  /// state based on the availability of seeds.
  Widget buildYearInputField(
      TextEditingController controller, String label, String hint) {
    return TextField(
        controller: controller,
        enabled: seedAvailability,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
            labelText: label,
            hintText: hint,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(
                    color: seedAvailability
                        ? const Color(0xFF5B8E55)
                        : Colors.grey),
                borderRadius: BorderRadius.circular(10)),
            disabledBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: Colors.grey),
                borderRadius: BorderRadius.circular(10))),
        onChanged: (value) {
          if (seedAvailability) {
            int? year = int.tryParse(value);
            if (year != null) {
              setState(() {
                seedExpiration = year;
              });
            }
          } else {
            setState(() {
              seedExpiration = 0;
            });
          }
        });
  }

  /// Displays a snackbar message for feedback.
  ///
  /// Utilized to provide user feedback on operations such as create or update actions.
  void showMessageSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), duration: const Duration(seconds: 2)));
  }
}

import 'package:flutter/material.dart';
import '../models/selected_garden_model.dart';
import '../controllers/plot_controller.dart';
import '../controllers/routes.dart';
import 'custom_bottom_bar.dart';
import 'custom_app_bar.dart';

/// Represents the stateful widget for creating or editing plot details.
///
/// This view allows users to input and modify details about a plot, such as its name, main lines,
/// orientation, and other plot-specific settings. It supports both creation and editing modes based
/// on whether initial data is provided.
class PlotCreationView extends StatefulWidget {
  final PlotCreationArguments? initialData;

  /// Constructs a [PlotCreationView] optionally with initial data for editing.
  const PlotCreationView({Key? key, this.initialData}) : super(key: key);

  @override
  PlotCreationViewState createState() => PlotCreationViewState();
}

/// Manages the state and interactions in [PlotCreationView].
///
/// This state class handles the UI and logic for creating or updating plot entries,
/// managing form inputs and submission, and handling lifecycle states for controllers and text fields.
class PlotCreationViewState extends State<PlotCreationView> {
  late PlotController plotController;
  late TextEditingController nameController;
  late TextEditingController mainLinesController;

  int? plotVersion;
  int? plotInCalendar;
  String? plotNote;

  // Form input variables
  int plotId = -1;
  List<int> secondaryLines = [];
  List<int> oldSecondaryLines = [];
  String plotName = '';
  String oldPlotName = '';
  int mainLines = -1;
  bool plotOrientation = false;
  bool oldPlotOrientation = false;
  Map<String, dynamic>? editArgs;

  /// Sets up controllers and initial data if editing an existing plot.
  @override
  void initState() {
    super.initState();
    plotController =
        PlotController((String message) => showMessageSnackBar(message));

    nameController = TextEditingController();
    mainLinesController = TextEditingController();

    if (widget.initialData != null) {
      plotId = widget.initialData!.plotId;
      plotName = widget.initialData!.plotName;
      oldPlotName = widget.initialData!.plotName;
      plotVersion = widget.initialData!.plotVersion;
      plotInCalendar = widget.initialData!.plotInCalendar;
      plotNote = widget.initialData!.plotNote;

      String plotPlantationLines = widget.initialData!.plotPlantationLines;
      List<String> pairs = plotPlantationLines.split('/');
      mainLines = pairs.length;
      for (var pair in pairs) {
        var splitPair = pair.split('.');
        if (splitPair.length == 2) {
          int? secondaryLine = int.tryParse(splitPair[1]);
          if (secondaryLine != null) {
            secondaryLines.add(secondaryLine);
            oldSecondaryLines.add(secondaryLine);
          }
        }
      }

      plotOrientation = widget.initialData!.plotOrientation == 1;
      oldPlotOrientation = widget.initialData!.plotOrientation == 1;

      editArgs = {
        'plotId': plotId,
        'plotVersion': plotVersion,
        'plotInCalendar': plotInCalendar,
        'secondaryLines': secondaryLines,
        'plotNote': plotNote,
        'oldPlotName': oldPlotName,
        'oldPlotOrientation': oldPlotOrientation,
        'oldSecondaryLines': oldSecondaryLines,
      };

      nameController.text = plotName;
      mainLinesController.text = mainLines.toString();
    }
  }

  /// Builds the UI elements for plot data input fields.
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
        appBar: const CustomAppBar(title: "Plot"),
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
                          'Enter plot name...',
                          (value) => setState(() => plotName = value)),
                      SizedBox(height: screenHeight * 0.01),
                      buildNumericInputField(
                          mainLinesController,
                          'Main Lines',
                          'Enter a number...',
                          (value) => setState(() => mainLines = value)),
                      SizedBox(height: screenHeight * 0.01),
                      buildToggleField(
                          'Orientation: H/V', screenWidth, screenHeight),
                      SizedBox(height: screenHeight * 0.01),
                      buildNextButton(),
                    ])))),
        bottomNavigationBar: CustomBottomBar());
  }

  /// Builds a text field for inputting plot name.
  ///
  /// The field updates the state of plot name on change and validates the input.
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

  /// Builds a numeric input field for entering the number of main lines in a plot.
  ///
  /// This input field allows for the specification of main lines, which is a critical part of plot configuration.
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
          onChanged(int.tryParse(value) ?? -1);
        });
  }

  /// Builds a toggle switch for plot orientation.
  ///
  /// This switch controls the orientation of the plot (Horizontal/Vertical), impacting how plants are displayed in the plot.
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
              value: plotOrientation,
              onChanged: (value) {
                setState(() {
                  plotOrientation = value;
                });
              },
              activeTrackColor: const Color(0xFF60B357),
              activeColor: const Color(0xFF5B8E55)),
        ]));
  }

  /// Constructs the 'Next' button for the form.
  ///
  /// This button will validate the current form and, if correct, navigate to the secondary lines creation view.
  Widget buildNextButton() => ElevatedButton(
      onPressed: () {
        if (plotController.validateFirstForm(plotName, mainLines)) {
          Navigator.of(context).pushNamed(Routes.plotCreationSecondaryLines,
              arguments: PlotCreationSecondaryLinesArguments(
                  mainLines: mainLines,
                  plotName: plotName,
                  plotOrientation:
                      plotOrientation ? 1 : 0, // 1 = vertical, 0 = horizontal
                  editArgs: editArgs ?? {}));
        }
      },
      style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF5B8E55),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
      child: const Text('Next', style: TextStyle(color: Colors.white)));

  /// Displays a snackbar message for feedback.
  ///
  /// Utilized to provide user feedback on operations such as create or update actions.
  void showMessageSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), duration: const Duration(seconds: 2)));
  }
}

/// Represents the subsequent stateful widget for configuring secondary lines in a plot.
///
/// This view is accessed after configuring primary details in [PlotCreationView] and is used to specify
/// the number of secondary lines per main line.
class PlotCreationSecondaryLines extends StatefulWidget {
  final int mainLines;
  final String plotName;
  final int plotOrientation;
  final Map<String, dynamic>? editArgs;

  /// Constructs a [PlotCreationSecondaryLines] with mandatory details from the first part of plot creation.
  const PlotCreationSecondaryLines(
      {Key? key,
      required this.mainLines,
      required this.plotName,
      required this.plotOrientation,
      required this.editArgs})
      : super(key: key);

  @override
  PlotCreationSecondaryLinesState createState() =>
      PlotCreationSecondaryLinesState();
}

/// Manages the state and interactions in [PlotCreationSecondaryLines].
///
/// Handles the detailed configuration of secondary lines associated with the main lines of a plot,
/// allowing users to specify exact configurations for planting.
class PlotCreationSecondaryLinesState
    extends State<PlotCreationSecondaryLines> {
  late PlotController plotController;
  late List<TextEditingController> inputControllers;
  final selectedGardenId = SelectedGardenModel().getSelectedGardenIdSync();
  final selectedGardenName = SelectedGardenModel().getSelectedGardenNameSync();
  List<int> secondaryLines = [];
  bool edit = false; // Indicates whether the form is in edit mode

  int? plotId;
  int? plotVersion;
  int? plotInCalendar;
  String? plotNote;
  String? oldPlotName;
  int? oldPlotOrientation;
  List<int>? oldSecondaryLines;

  /// Sets up the initial secondary lines based on main lines and populates form inputs.
  @override
  void initState() {
    super.initState();
    plotController =
        PlotController((String message) => showMessageSnackBar(message));

    secondaryLines = List.filled(widget.mainLines, -1, growable: true);

    inputControllers =
        List.generate(widget.mainLines, (_) => TextEditingController());

    if (widget.editArgs != null && widget.editArgs!.isNotEmpty) {
      edit = true;
      plotId = widget.editArgs!['plotId'];
      plotVersion = widget.editArgs!['plotVersion'];
      plotInCalendar = widget.editArgs!['plotInCalendar'];
      plotNote = widget.editArgs!['plotNote'];
      oldPlotName = widget.editArgs!['oldPlotName'];
      oldPlotOrientation = widget.editArgs!['oldPlotOrientation'] ? 1 : 0;
      oldSecondaryLines = widget.editArgs!['oldSecondaryLines'];

      var tempLines = widget.editArgs!['secondaryLines'] as List<int>;
      for (int i = 0; i < widget.mainLines; i++) {
        if (i < tempLines.length) {
          secondaryLines[i] = tempLines[i];
          inputControllers[i].text = tempLines[i].toString();
        }
      }
    }
  }

  /// Builds UI elements for dynamically entering the number of secondary lines based on the number of main lines.
  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
        appBar: const CustomAppBar(title: "Plot"),
        body: GestureDetector(
            onTap: () {
              FocusScope.of(context).requestFocus(FocusNode());
            },
            child: SingleChildScrollView(
                child: Padding(
                    padding: EdgeInsets.all(screenHeight * 0.01),
                    child: Column(children: [
                      ...List.generate(widget.mainLines * 2 - 1, (index) {
                        // even indexes = TextField, odd indexes = SizedBox
                        if (index % 2 == 0) {
                          return buildNumericInputField(
                              inputControllers[index ~/ 2], index ~/ 2);
                        } else {
                          return SizedBox(height: screenHeight * 0.01);
                        }
                      }),
                      SizedBox(height: screenHeight * 0.01),
                      buildConfirmButton(edit),
                    ])))),
        bottomNavigationBar: CustomBottomBar());
  }

  /// Builds a numeric input field dynamically for each main line to specify the number of secondary lines.
  ///
  /// These fields allow for the specification of secondary line counts per main line, affecting detailed plot configuration.
  Widget buildNumericInputField(TextEditingController controller, int index) {
    return TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
            labelText: 'Main Line ${index + 1}',
            hintText: 'How many secondary lines?',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            focusedBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: Color(0xFF5B8E55)),
                borderRadius: BorderRadius.circular(10))),
        onChanged: (value) {
          setState(() {
            int parsedValue = int.tryParse(value) ?? -1;
            secondaryLines[index] = parsedValue == 0 ? 1 : parsedValue;
          });
        });
  }

  /// Constructs the 'Confirm' button to finalize plot creation or editing.
  ///
  /// This button submits all plot details, creating or updating the plot configuration in the database.
  Widget buildConfirmButton(bool edit) => ElevatedButton(
      onPressed: () async {
        bool creationSuccess = false;
        if (edit) {
          creationSuccess = await plotController.editPlot(
              plotId!,
              selectedGardenId,
              selectedGardenName,
              widget.plotName,
              secondaryLines,
              plotVersion! + 1,
              widget.plotOrientation,
              plotInCalendar!,
              plotNote!,
              oldPlotName!,
              oldPlotOrientation!,
              oldSecondaryLines!);
        } else {
          creationSuccess = await plotController.createPlot(
              selectedGardenId,
              selectedGardenName,
              widget.plotName,
              secondaryLines,
              1,
              widget.plotOrientation,
              0,
              '');
        }

        if (creationSuccess && mounted) {
          Navigator.of(context).pushNamedAndRemoveUntil(
              Routes.plots, (Route<dynamic> route) => false);
        }
      },
      style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF5B8E55),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
      child: const Text('Confirm', style: TextStyle(color: Colors.white)));

  /// Displays a snackbar message for feedback.
  ///
  /// Utilized to provide user feedback on operations such as create or update actions.
  void showMessageSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), duration: const Duration(seconds: 2)));
  }
}

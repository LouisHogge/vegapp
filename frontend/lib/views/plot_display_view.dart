import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/category_model.dart';
import '../models/plot_model.dart';
import '../models/selected_garden_model.dart';
import '../models/vegetable_model.dart';
import '../models/plant_model.dart';
import '../controllers/category_controller.dart';
import '../controllers/vegetable_controller.dart';
import '../controllers/plot_controller.dart';
import '../controllers/routes.dart';
import 'notes_view.dart';
import 'custom_bottom_bar.dart';
import 'custom_app_bar.dart';

/// Represents the view for displaying plot details within a garden management app.
///
/// It uses [PlotDisplayViewState] to manage its state.
class PlotDisplayView extends StatefulWidget {
  final int plotId;
  final String plotName;

  const PlotDisplayView(
      {Key? key, required this.plotId, required this.plotName})
      : super(key: key);

  @override
  PlotDisplayViewState createState() => PlotDisplayViewState();
}

/// Manages the state of [PlotDisplayView], handling plot interactions and updates.
///
/// This state class includes interactions such as fetching plot data,
/// handling vegetable drops, and toggling various UI elements like calendar view.
class PlotDisplayViewState extends State<PlotDisplayView>
    with TickerProviderStateMixin {
  late VegetableController vegetableController;
  late CategoryController categoryController;
  late PlotController plotController;
  late Future<List<VegetableModel>> futureVegetables;
  late Future<int> futureMonths;
  late Future<PlotModel> futurePlot;
  late Future<List<PlantedModel>> futurePlanted;
  late AnimationController _controllers;

  VegetableModel? droppedVegetable;
  String vegetableName = '';
  int pushedMonth = -1;
  bool done = false;
  bool planted = false;
  bool toggle = false;
  bool pushedPlant = false;
  bool pushedHarvest = false;
  Color t = const Color(0xFF5B8E55);
  bool clear = false;

  final Map<String, Map<String, Map<int, Color?>>> veggies = {};
  final selectedGardenId = SelectedGardenModel().getSelectedGardenIdSync();

  bool accepted = false;
  bool dropped = false;
  bool simulate = false;
  bool validate = false;
  bool isSearching = false;
  bool calendar = false;
  String droppedVeggie = '';
  final Map<int, bool> plotLocks = {};
  List<int> vegetableIds = [];
  List<String> vegetableLocations = [];
  List<VegetableModel> vegetables = [];
  List<VegetableModel> filteredVegetables = [];
  String inputSearch = '';

  /// Initializes plot state, setting up controllers and fetching necessary data.
  ///
  /// Sets up controllers for managing vegetables, categories, and plots, and
  /// initiates data fetching for the associated plot.
  @override
  void initState() {
    super.initState();
    vegetableController =
        VegetableController((String message) => showMessageSnackBar(message));
    categoryController =
        CategoryController((String message) => showMessageSnackBar(message));
    plotController =
        PlotController((String message) => showMessageSnackBar(message));

    futureVegetables = vegetableController
        .getVegetablesByGardenId(selectedGardenId)
        .then((veggies) async {
      int currentYear = DateTime.now().year;
      List<Future<VegetableModel>> filteredVeggies = [];
      for (var veg in veggies) {
        if (veg.seedAvailability != 0 && veg.seedExpiration >= currentYear) {
          // Fetch the primary category for each vegetable asynchronously
          var category = await categoryController
              .getPrimaryCategoryById(veg.primaryCategoryId);
          if (category.categoryName != 'Bin') {
            filteredVeggies.add(Future.value(veg));
          }
        }
      }
      return await Future.wait(
          filteredVeggies); // Wait for all filters to complete
    });

    futurePlot = plotController.getPlotById(widget.plotId);
    futurePlanted = plotController.getPlantedById(widget.plotId);
    _controllers = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 300));
  }

  /// Refreshes the plot data based on interactions like simulation or validation toggles.
  ///
  /// This method can trigger a simulation which recalculates plot affinities and updates the UI accordingly.
  /// If [shouldToggle] is true, it also modifies UI elements to reflect new validation states.
  void refreshPlotData(simulate, [shouldToggle]) {
    setState(() {
      futurePlot = plotController.getPlotById(widget.plotId);
      if (simulate) {
        plotController.setAffinity();
        Future.delayed(const Duration(seconds: 5), () {
          setState(() {
            plotController.clearAffinity();
          });
        });
      }
      if (shouldToggle != null && shouldToggle) {
        toggle = true;
        validate = true;
      }
    });
  }

  /// Cleans up the controllers and any other resources to prevent memory leaks.
  @override
  void dispose() {
    _controllers.dispose();
    super.dispose();
  }

  /// Builds the UI for the plot display view.
  ///
  /// Constructs a [Scaffold] containing plot details, a custom app bar, and
  /// navigational controls. It manages and displays stateful data related to the plot.
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    double plotWidth = screenWidth * 2 / 3;
    double plotHeight = screenHeight * 2 / 6.5;

    return Scaffold(
        appBar: CustomAppBar(title: widget.plotName),
        body: FutureBuilder<PlotModel>(
            future: futurePlot,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                PlotModel plot = snapshot.data!;
                String lines = plot.plotPlantationLines;

                if (plot.plotInCalendar == 1) {
                  calendar = true;
                  toggle = true;
                }

                RegExp regex = RegExp(r'\.(\d+)');
                Iterable<RegExpMatch> matches = regex.allMatches(lines);
                List<int> nbVeggiesPerLine = [];
                for (RegExpMatch match in matches) {
                  nbVeggiesPerLine.add(int.parse(match.group(1)!));
                }

                return FutureBuilder<List<PlantedModel>>(
                    future: futurePlanted,
                    builder: (context, snapshot) {
                      List<PlantedModel> plantedVegetables = [];
                      if (snapshot.hasData) {
                        plantedVegetables = snapshot.data!;
                        if (plantedVegetables.isNotEmpty) {
                          toggle = true;
                          validate = true;
                        }
                      }
                      return Container(
                          color: const Color(0xFF5B8E55),
                          child: Column(children: [
                            SizedBox(height: screenHeight * 0.02),
                            Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  MyButtonWidget(
                                      validate: false,
                                      rotate: 0,
                                      simulateButton: true,
                                      button: "assets/simulate.png",
                                      buttonPressed:
                                          "assets/simulate_pressed.png",
                                      plotId: widget.plotId,
                                      plotLength: nbVeggiesPerLine
                                          .reduce((sum, e) => sum + e),
                                      droppedVegetables: plotController.slots,
                                      controller: plotController,
                                      gardenId: plot.gardenId,
                                      plotName: plot.plotName,
                                      plotPlantationLines:
                                          plot.plotPlantationLines,
                                      plotOrientation: plot.plotOrientation,
                                      plotVersion: plot.plotVersion,
                                      plotInCalendar: plot.plotInCalendar,
                                      plotNote: plot.plotNote,
                                      onEditCompleted: refreshPlotData),
                                  buildToggleField(
                                      plot, screenWidth, screenHeight),
                                  MyButtonWidget(
                                      validate: validate,
                                      rotate: 0,
                                      simulateButton: validate,
                                      button: "assets/validate.png",
                                      buttonPressed:
                                          "assets/validate_pressed.png",
                                      plotId: widget.plotId,
                                      plotLength: nbVeggiesPerLine
                                          .reduce((sum, e) => sum + e),
                                      droppedVegetables: plotController.slots,
                                      controller: plotController,
                                      gardenId: plot.gardenId,
                                      plotName: plot.plotName,
                                      plotPlantationLines:
                                          plot.plotPlantationLines,
                                      plotOrientation: plot.plotOrientation,
                                      plotVersion: plot.plotVersion,
                                      plotInCalendar: plot.plotInCalendar,
                                      plotNote: plot.plotNote,
                                      onEditCompleted: refreshPlotData),
                                ]),
                            SizedBox(height: screenHeight * 0.02),
                            Row(children: [
                              Column(children: [
                                MyButtonWidget(
                                    validate: false,
                                    rotate: 1000,
                                    simulateButton: true,
                                    button: "assets/note.png",
                                    buttonPressed: "assets/note.png",
                                    plotId: widget.plotId,
                                    plotLength: nbVeggiesPerLine
                                        .reduce((sum, e) => sum + e),
                                    droppedVegetables: plotController.slots,
                                    controller: plotController,
                                    gardenId: plot.gardenId,
                                    plotName: plot.plotName,
                                    plotPlantationLines:
                                        plot.plotPlantationLines,
                                    plotOrientation: plot.plotOrientation,
                                    plotVersion: plot.plotVersion,
                                    plotInCalendar: plot.plotInCalendar,
                                    plotNote: plot.plotNote,
                                    onEditCompleted: refreshPlotData),
                                SizedBox(height: screenHeight * 0.09),
                                MyButtonWidget(
                                    validate: validate,
                                    rotate: 1000,
                                    simulateButton: true,
                                    button: "assets/edit.png",
                                    buttonPressed: "assets/edit.png",
                                    plotId: widget.plotId,
                                    plotLength: nbVeggiesPerLine
                                        .reduce((sum, e) => sum + e),
                                    droppedVegetables: plotController.slots,
                                    controller: plotController,
                                    gardenId: plot.gardenId,
                                    plotName: plot.plotName,
                                    plotPlantationLines:
                                        plot.plotPlantationLines,
                                    plotOrientation: plot.plotOrientation,
                                    plotVersion: plot.plotVersion,
                                    plotInCalendar: plot.plotInCalendar,
                                    plotNote: plot.plotNote,
                                    onEditCompleted: refreshPlotData),
                                SizedBox(height: screenHeight * 0.09),
                                MyButtonWidget(
                                    validate: validate,
                                    rotate: 1000,
                                    simulateButton: true,
                                    button: "assets/delete.png",
                                    buttonPressed: "assets/delete.png",
                                    plotId: widget.plotId,
                                    plotLength: nbVeggiesPerLine
                                        .reduce((sum, e) => sum + e),
                                    droppedVegetables: plotController.slots,
                                    controller: plotController,
                                    gardenId: plot.gardenId,
                                    plotName: plot.plotName,
                                    plotPlantationLines:
                                        plot.plotPlantationLines,
                                    plotOrientation: plot.plotOrientation,
                                    plotVersion: plot.plotVersion,
                                    plotInCalendar: plot.plotInCalendar,
                                    plotNote: plot.plotNote,
                                    onEditCompleted: refreshPlotData),
                              ]),
                              Container(
                                  height: screenHeight * 0.38,
                                  width: screenWidth * 0.68,
                                  decoration: const ShapeDecoration(
                                      shape: RoundedRectangleBorder(
                                          side: BorderSide(
                                              width: 5,
                                              color: Color(0xFFB47C45)))),
                                  // Constrain the inner container's maximum width to 2/3 of the available space
                                  constraints: BoxConstraints(
                                      maxWidth: plotWidth,
                                      maxHeight: plotHeight),
                                  // Content of the plot (rows, columns)
                                  child: Container(
                                      color: const Color(0xFF5B8E55),
                                      child: plot.plotOrientation == 1
                                          ? buildVerticalPlot(
                                              plot.plotPlantationLines,
                                              nbVeggiesPerLine.length,
                                              nbVeggiesPerLine,
                                              plantedVegetables,
                                              screenWidth,
                                              screenHeight,
                                              plotWidth,
                                              plotHeight)
                                          : buildHorizontalPlot(
                                              plot.plotPlantationLines,
                                              nbVeggiesPerLine.length,
                                              nbVeggiesPerLine,
                                              plantedVegetables,
                                              screenWidth,
                                              screenHeight,
                                              plotWidth,
                                              plotHeight))),
                            ]),
                            // simulate & validate buttons
                            SizedBox(height: screenHeight * 0.02),
                            SizedBox(
                                width: screenWidth * 0.75,
                                height: screenHeight * 0.06,
                                child: buildSearchBar(
                                    vegetables, filteredVegetables)),
                            SizedBox(height: screenHeight * 0.02),
                            Expanded(
                                child: FutureBuilder<List<VegetableModel>>(
                                    future: futureVegetables,
                                    builder: (context, snapshot) {
                                      if (snapshot.hasData) {
                                        vegetables = snapshot.data!;
                                        filteredVegetables = vegetables
                                            .where((vegetable) => vegetable
                                                .vegetableName
                                                .toLowerCase()
                                                .contains(
                                                    inputSearch.toLowerCase()))
                                            .toList();

                                        return GridView.count(
                                            shrinkWrap: true,
                                            crossAxisCount: 4,
                                            children: List.generate(
                                                isSearching
                                                    ? filteredVegetables.length
                                                    : vegetables.length,
                                                (index) => vegetableTitle(
                                                    isSearching
                                                        ? filteredVegetables[
                                                            index]
                                                        : vegetables[index],
                                                    screenHeight,
                                                    screenWidth)));
                                      } else if (snapshot.hasError) {
                                        return Text("${snapshot.error}");
                                      }
                                      return const CircularProgressIndicator();
                                    })),
                          ]));
                    });
              } else if (snapshot.hasError) {
                return Text("${snapshot.error}");
              }
              return const CircularProgressIndicator();
            }),
        bottomNavigationBar: CustomBottomBar());
  }

  /// Builds the toggle switch field for enabling or disabling calendar view for the plot.
  ///
  /// [p] contains the current plot model data used to toggle and display status.
  Widget buildToggleField(
      PlotModel p, double screenWidth, double screenHeight) {
    return Column(children: [
      Text('Calendar',
          style: GoogleFonts.abrilFatface(
              textStyle: TextStyle(
                  color: Colors.white70,
                  fontSize: screenWidth * 0.05,
                  fontWeight: FontWeight.w400))),
      FutureBuilder<List<PlantedModel>>(
          future: futurePlanted,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return Opacity(
                  opacity: toggle ? 1.0 : 0.5,
                  child: Switch(
                      value: calendar,
                      onChanged: (value) {
                        if (!toggle) {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                              content: Text(
                                  "The Activities of the plot will be added in the calendar once validated."),
                              duration: Duration(seconds: 2)));
                          return;
                        }
                        setState(() {
                          calendar = value;
                          if (calendar) {
                            plotController.toggleOn(
                                selectedGardenId, widget.plotId);
                          } else {
                            plotController.toggleOff(
                                selectedGardenId, widget.plotId);
                            p.plotInCalendar = 0;
                          }
                        });
                      },
                      activeTrackColor: const Color(0xFF60B357),
                      activeColor: const Color(0xFF5B8E55)));
            } else if (snapshot.hasError) {
              return Text("${snapshot.error}");
            }
            return const CircularProgressIndicator();
          }),
    ]);
  }

  /// Builds a visual representation of a plot item, configured by the plot's layout and vegetable data.
  ///
  /// This widget is responsible for rendering each individual slot in the plot grid. It checks for affinities,
  /// displays the appropriate vegetable images, and allows for vegetable drag-and-drop functionality.
  /// [horizontal] specifies the orientation of the grid (horizontal or vertical),
  /// [lines], [line], [index], and [nbLines] define the plot's structure,
  /// and [vegetable] is the optional vegetable model to display.
  Widget _buildPlotItem(bool horizontal, String lines, int line, int index,
      int nbLines, List<int> nbVeggiesPerLine,
      [VegetableModel? vegetable]) {
    List<Color>? affinities =
        plotController.getAffinities("${line + 1}.$index");

    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    double plotWidth = screenWidth * 2 / 3;
    double plotHeight = screenHeight * 2 / 6.5;

    double x = 4;
    screenHeight < 800
        ? x = 4
        : screenHeight < 1100
            ? x = 15
            : x = 64;

    return Container(
        decoration: BoxDecoration(
            color: const Color(0xFF814F34),
            border: horizontal
                ? Border(
                    top: BorderSide(
                        color: affinities == null ||
                                !plotController.affinityDisplay
                            ? const Color(0xFF5B8E55)
                            : affinities[0],
                        width: line == 0 ||
                                (affinities != null &&
                                    affinities[0] == Colors.amber)
                            ? 0.0
                            : plotHeight / (20 * nbLines)),
                    right: BorderSide(
                        color: affinities == null ||
                                !plotController.affinityDisplay
                            ? const Color(0xFF5B8E55)
                            : affinities[2],
                        width: lines.contains("${line + 1}.${index + 1}")
                            ? 0.0
                            : plotHeight / (20 * nbLines)),
                    bottom: BorderSide(
                        color: affinities == null ||
                                !plotController.affinityDisplay
                            ? const Color(0xFF5B8E55)
                            : affinities[1],
                        width: line + 1 == nbLines ||
                                (affinities != null &&
                                    affinities[1] == Colors.amber)
                            ? 0.0
                            : plotWidth / (x * nbLines)),
                  )
                : Border(
                    left: BorderSide(
                        color: affinities == null ||
                                !plotController.affinityDisplay
                            ? const Color(0xFF5B8E55)
                            : affinities[0],
                        width: line == 0 ||
                                (affinities != null &&
                                    affinities[0] == Colors.amber)
                            ? 0.0
                            : plotWidth / (20 * nbLines)),
                    right: BorderSide(
                        color: affinities == null ||
                                !plotController.affinityDisplay
                            ? const Color(0xFF5B8E55)
                            : affinities[1],
                        width: line + 1 == nbLines ||
                                (affinities != null &&
                                    affinities[1] == Colors.amber)
                            ? 0.0
                            : plotWidth / (20 * nbLines)),
                    bottom: BorderSide(
                        color: affinities == null ||
                                !plotController.affinityDisplay
                            ? const Color(0xFF5B8E55)
                            : affinities[2],
                        width: lines.contains("${line + 1}.${index + 1}")
                            ? 0.0
                            : plotHeight / (15 * nbLines)),
                  )),
        child: vegetable != null
            ? FutureBuilder<PrimaryCategoryModel>(
                future: categoryController
                    .getPrimaryCategoryById(vegetable.primaryCategoryId),
                builder: (context, categorySnapshot) {
                  if (categorySnapshot.hasData) {
                    final category = categorySnapshot.data!;
                    plotController.addVegetableToSlot(
                        "${line + 1}.$index", vegetable);
                    plotController.addCategoryToSlot(
                        "${line + 1}.$index", category);
                    return Center(
                        child: Stack(children: [
                      Padding(
                          padding: const EdgeInsets.only(bottom: 10.0),
                          child: Image.asset(
                              "assets/${categorySnapshot.data!.categoryName}.png")),
                      // Container for the color bar
                      plotController.affinityDisplay
                          ? FutureBuilder<Map<String, List<Color>>>(
                              future: plotController.simulateAffinities(
                                  lines, nbVeggiesPerLine),
                              builder: (context, snapshot) {
                                if (snapshot.hasData) {
                                  final affinities = snapshot.data!;
                                  if (affinities["${line + 1}.$index"] !=
                                      null) {
                                    plotController.addAffinities(
                                        "${line + 1}.$index",
                                        affinities["${line + 1}.$index"]!);
                                  }
                                } else if (snapshot.hasError) {
                                  return Text("${snapshot.error}");
                                }
                                return const SizedBox();
                              })
                          : const SizedBox()
                    ]));
                  } else if (categorySnapshot.hasError) {
                    return Text("${categorySnapshot.error}");
                  }
                  return const CircularProgressIndicator();
                })
            : DragTarget<VegetableModel>(
                // Check if vegetable is acceptable
                onWillAccept: (VegetableModel? data) {
                  if (plotController.planted) {
                    plotController.creationMessage(
                        "You cannot add a new one as the plot is validated.");
                  }
                  return !plotController.planted && data != null;
                },
                // Handle successful drop event
                onAccept: (VegetableModel vegetable) => plotController
                    .addVegetableToSlot("${line + 1}.$index", vegetable),
                builder: (context, cd, rd) {
                  final vegetable =
                      plotController.getVegetableFromSlot("${line + 1}.$index");
                  if (vegetable != null) {
                    // Vegetable dropped in this slot, show it
                    return FutureBuilder<PrimaryCategoryModel>(
                        future: categoryController.getPrimaryCategoryById(
                            vegetable.primaryCategoryId),
                        builder: (context, categorySnapshot) {
                          if (categorySnapshot.hasData) {
                            final category = categorySnapshot.data!;
                            plotController.addCategoryToSlot(
                                "${line + 1}.$index", category);
                            return Center(
                                child: Stack(children: [
                              Padding(
                                  padding: const EdgeInsets.only(bottom: 10.0),
                                  child: Image.asset(
                                      "assets/${category.categoryName}.png")),
                              // Container for the color bar
                              plotController.affinityDisplay
                                  ? FutureBuilder<Map<String, List<Color>>>(
                                      future: plotController.simulateAffinities(
                                          lines, nbVeggiesPerLine),
                                      builder: (context, snapshot) {
                                        if (snapshot.hasData) {
                                          final affinities = snapshot.data!;
                                          if (affinities[
                                                  "${line + 1}.$index"] !=
                                              null) {
                                            plotController.addAffinities(
                                                "${line + 1}.$index",
                                                affinities[
                                                    "${line + 1}.$index"]!);
                                          }
                                        } else if (snapshot.hasError) {
                                          return Text("${snapshot.error}");
                                        }
                                        return const SizedBox();
                                      })
                                  : const SizedBox()
                            ]));
                          } else if (categorySnapshot.hasError) {
                            return Text("${categorySnapshot.error}");
                          }
                          return const CircularProgressIndicator();
                        });
                  } else {
                    // Empty slot, show "drop" image
                    return Center(child: Image.asset("assets/drop2.png"));
                  }
                }));
  }

  /// Constructs a vertical plot layout with dynamic vegetable slots based on the provided data.
  ///
  /// Creates a grid representing a vertical plot, managing its aspect ratio and alignment based on the
  /// number of lines and vegetables per line. It uses future builder to asynchronously fetch and display
  /// vegetable data.
  Widget buildVerticalPlot(
      String lines,
      int nbLines,
      List<int> nbVeggiesPerLine,
      List<PlantedModel> plantedVegetables,
      double screenWidth,
      double screenHeight,
      double plotWidth,
      double plotHeight) {
    return FutureBuilder<List<VegetableModel>>(
        future: vegetableController.getVegetablesByIds(
            plotController.getVegetablesIds(plantedVegetables)),
        builder: (context, snapshot) {
          List<VegetableModel> vegetables = [];
          if (snapshot.hasData) {
            vegetables = snapshot.data!;
            final double maxHeight = (plotHeight / plotWidth) * pow(nbLines, 2);
            return Row(children: [
              for (int line = 0; line < nbLines; line++)
                Expanded(child: LayoutBuilder(builder: (context, constraints) {
                  return GridView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 1,
                          mainAxisSpacing: 0.0,
                          // Spacing between items vertically
                          crossAxisSpacing: 0.0,
                          // Spacing between items horizontally
                          childAspectRatio:
                              (nbLines * nbVeggiesPerLine[line]) / maxHeight),
                      itemCount: nbVeggiesPerLine[line],
                      itemBuilder: (context, index) {
                        PlantedModel? p;
                        if (vegetables.isNotEmpty) {
                          p = plantedVegetables
                              .where((e) =>
                                  e.vegetableLocation == "${line + 1}.$index")
                              .first;
                        }
                        return vegetables.isEmpty
                            ? _buildPlotItem(false, lines, line, index, nbLines,
                                nbVeggiesPerLine)
                            : _buildPlotItem(
                                false,
                                lines,
                                line,
                                index,
                                nbLines,
                                nbVeggiesPerLine,
                                vegetables
                                    .where((e) => e.id == p?.vegetableId)
                                    .first);
                      });
                })),
            ]);
          } else if (snapshot.hasError) {
            return Text("${snapshot.error}");
          }
          return const CircularProgressIndicator();
        });
  }

  /// Constructs a horizontal plot layout that adjusts dynamically to the screen size and plot data.
  ///
  /// Similar to [buildVerticalPlot], but arranges the plot horizontally and manages the grid's aspect ratio
  /// to fit the screen width. It also handles asynchronous loading of vegetable data for display.
  Widget buildHorizontalPlot(
      String lines,
      int nbLines,
      List<int> nbVeggiesPerLine,
      List<PlantedModel> plantedVegetables,
      double screenWidth,
      double screenHeight,
      double plotWidth,
      double plotHeight) {
    List<int> vegetablesIds = [];
    for (final plantedVegetable in plantedVegetables) {
      vegetablesIds.add(plantedVegetable.vegetableId);
    }
    return FutureBuilder<List<VegetableModel>>(
        future: vegetableController.getVegetablesByIds(vegetablesIds),
        builder: (context, snapshot) {
          List<VegetableModel> vegetables = [];
          if (snapshot.hasData) {
            vegetables = snapshot.data!;
            return Column(children: [
              for (int line = 0; line < nbLines; line++)
                Expanded(child: LayoutBuilder(builder: (context, constraints) {
                  // Calculate maximum number of columns based on desired aspect ratio and available width
                  final double maxWidth = constraints.maxWidth;
                  // Calculate the available height for the grid
                  final double maxHeight =
                      (plotHeight / plotWidth).roundToDouble() *
                          pow(nbLines, 2);
                  final double desiredAspectRatio =
                      nbLines / nbVeggiesPerLine[line];
                  final int maxColumns =
                      (maxWidth / desiredAspectRatio).floor();
                  return GridView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount:
                              maxColumns.clamp(1, nbVeggiesPerLine[line]),
                          mainAxisSpacing: 0.0,
                          // Spacing between items vertically
                          crossAxisSpacing: 0.0,
                          // Spacing between items horizontally
                          childAspectRatio:
                              maxHeight / (nbLines * nbVeggiesPerLine[line])),
                      itemCount: nbVeggiesPerLine[line],
                      itemBuilder: (context, index) {
                        PlantedModel? p;
                        if (vegetables.isNotEmpty) {
                          p = plantedVegetables
                              .where((e) =>
                                  e.vegetableLocation == "${line + 1}.$index")
                              .first;
                        }
                        return vegetables.isEmpty
                            ? _buildPlotItem(true, lines, line, index, nbLines,
                                nbVeggiesPerLine)
                            : _buildPlotItem(
                                true,
                                lines,
                                line,
                                index,
                                nbLines,
                                nbVeggiesPerLine,
                                vegetables
                                    .where((e) => e.id == p?.vegetableId)
                                    .first);
                      });
                })),
            ]);
          } else if (snapshot.hasError) {
            return Text("${snapshot.error}");
          }
          return const CircularProgressIndicator();
        });
  }

  /// Creates a search bar for filtering vegetable entries.
  ///
  /// This widget allows users to input search terms to filter displayed vegetables in real-time.
  /// It updates the displayed list as the user types.
  Widget buildSearchBar(List<VegetableModel> vegetables,
      List<VegetableModel> filteredVegetables) {
    return TextField(
        decoration: InputDecoration(
            hintText: 'Search any seeds here...',
            hintStyle: const TextStyle(color: Colors.white),
            filled: true,
            fillColor: Colors.transparent,
            contentPadding: const EdgeInsets.all(10.0),
            border: OutlineInputBorder(
                borderSide: const BorderSide(color: Colors.white, width: 1.0),
                borderRadius: BorderRadius.circular(30.0)),
            enabledBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: Colors.white, width: 1.0),
                borderRadius: BorderRadius.circular(30.0)),
            focusedBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: Colors.white, width: 1.0),
                borderRadius: BorderRadius.circular(30.0)),
            prefixIcon: const Icon(Icons.search, color: Colors.white)),
        onChanged: (String value) {
          setState(() {
            value == '' ? isSearching = false : isSearching = true;
            inputSearch = value;
          });
        });
  }

  /// Displays a title and image for a vegetable in the grid.
  ///
  /// This widget visually represents a vegetable using its name and associated category image.
  /// It also supports drag operations for rearranging vegetables within the plot.
  Widget vegetableTitle(
      VegetableModel vegetable, double screenHeight, double screenWidth) {
    return FutureBuilder<PrimaryCategoryModel>(
        future: categoryController
            .getPrimaryCategoryById(vegetable.primaryCategoryId),
        builder: (context, categorySnapshot) {
          if (categorySnapshot.hasData) {
            final category = categorySnapshot.data!;
            return Container(
                decoration: const BoxDecoration(
                    image: DecorationImage(
                        image: AssetImage("assets/seeds.png"),
                        fit: BoxFit.contain)),
                child: Stack(children: [
                  Center(
                      child: Column(children: [
                    SizedBox(height: screenHeight * 0.062),
                    SizedBox(
                        width: screenHeight * 0.06,
                        height: screenHeight * 0.05,
                        child: Draggable(
                            childWhenDragging: const SizedBox(),
                            feedback: Image.asset(
                                "assets/${category.categoryName}.png"),
                            data: vegetable,
                            child: Image.asset(
                                "assets/${category.categoryName}.png"))),
                  ])),
                  Padding(
                      padding: EdgeInsets.all(screenHeight * 0.033),
                      child: Column(children: [
                        Center(
                            child: Text(vegetable.vegetableName,
                                textAlign: TextAlign.center,
                                style: GoogleFonts.croissantOne(
                                    textStyle: TextStyle(
                                        color: const Color(0xFF686666),
                                        fontSize: screenWidth * 0.023,
                                        fontWeight: FontWeight.w600)),
                                maxLines: 1)),
                      ])),
                ]));
          } else if (categorySnapshot.hasError) {
            return Text("${categorySnapshot.error}");
          }
          return const CircularProgressIndicator();
        });
  }

  /// Displays a message in a snack bar at the bottom of the screen.
  void showMessageSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), duration: const Duration(seconds: 2)));
  }
}

/// Custom button widget used in the plot display to handle various actions.
///
/// Actions can include editing plot details, simulating plot conditions, and validating changes.
class MyButtonWidget extends StatefulWidget {
  final bool validate;
  final String button;
  final String buttonPressed;
  final double rotate;
  final bool simulateButton;
  final int plotId;
  final int plotLength;
  final Map<String, VegetableModel?> droppedVegetables;
  final PlotController controller;
  final int gardenId;
  final String plotName;
  final String plotPlantationLines;
  final int plotOrientation;
  final int plotVersion;
  final int plotInCalendar;
  final String plotNote;
  final Function(bool simulate, [bool shouldToggle]) onEditCompleted;

  const MyButtonWidget(
      {Key? key,
      required this.validate,
      required this.rotate,
      required this.simulateButton,
      required this.button,
      required this.buttonPressed,
      required this.plotId,
      required this.plotLength,
      required this.droppedVegetables,
      required this.controller,
      required this.gardenId,
      required this.plotName,
      required this.plotPlantationLines,
      required this.plotOrientation,
      required this.plotVersion,
      required this.plotInCalendar,
      required this.plotNote,
      required this.onEditCompleted})
      : super(key: key);

  @override
  State<MyButtonWidget> createState() => _MyButtonWidgetState();
}

/// Manages the state of [MyButtonWidget] to handle button interactions for plot actions.
///
/// This class reacts to user inputs on various button interactions such as note taking, editing,
/// simulating, and deleting actions within a plot context. It manages the button state changes and triggers
/// necessary updates based on the type of interaction.
class _MyButtonWidgetState extends State<MyButtonWidget> {
  NotesDialog notesDialog = NotesDialog();
  final selectedGardenName = SelectedGardenModel().getSelectedGardenNameSync();
  bool isPressed = false;
  String imagePath = '';
  late PlotController plotController;

  /// Initializes the state for the button widget.
  ///
  /// Sets up the [PlotController] to handle plot-related actions and initializes the default image for the button based on the provided widget configuration.
  @override
  void initState() {
    super.initState();
    plotController =
        PlotController((String message) => showMessageSnackBar(message));
    imagePath = widget.button;
  }

  /// Builds the button widget according to the specified properties and user interactions.
  ///
  /// Depending on the button type (identified by [imagePath]), it handles different functionalities.
  ///
  /// The button's visual and functional behaviors are managed based on the validation state and other dynamic parameters.
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    switch (imagePath) {
      case "assets/note.png":
        {
          return InkResponse(
              onTap: () async {
                bool edited = await notesDialog.show(
                    context,
                    screenWidth,
                    screenHeight,
                    'Plot',
                    selectedGardenName,
                    widget.plotNote,
                    -1,
                    widget.plotId,
                    -1,
                    '',
                    widget.plotName,
                    '',
                    widget.plotName,
                    -1,
                    -1,
                    -1,
                    -1,
                    '',
                    '',
                    -1,
                    -1,
                    -1,
                    -1,
                    widget.plotPlantationLines,
                    widget.plotVersion,
                    widget.plotOrientation,
                    widget.plotInCalendar);

                if (edited) {
                  setState(() {
                    // Re-fetch the plot data
                    widget.onEditCompleted(false);
                  });
                }
              },
              splashFactory: InkSplash.splashFactory,
              child: SizedBox(
                  width: screenHeight * 0.1,
                  child: Transform(
                      alignment: Alignment.center,
                      transform: Matrix4.identity()
                        ..rotateZ(widget.rotate * 3.14),
                      child: Image.asset(imagePath))));
        }
      case "assets/edit.png":
        {
          return InkResponse(
              onTap: () {
                if (!widget.validate) {
                  Navigator.of(context).pushNamed(Routes.plotCreation,
                      arguments: PlotCreationArguments(
                          plotId: widget.plotId,
                          plotName: widget.plotName,
                          plotPlantationLines: widget.plotPlantationLines,
                          plotOrientation: widget.plotOrientation,
                          plotVersion: widget.plotVersion,
                          plotInCalendar: widget.plotInCalendar,
                          plotNote: widget.plotNote));
                } else {
                  plotController
                      .creationMessage("You cannot edit a validated plot.");
                }
              },
              splashFactory: InkSplash.splashFactory,
              child: SizedBox(
                  width: screenHeight * 0.1,
                  child: Transform(
                      alignment:
                          Alignment.center, // Rotate around the image center
                      transform: Matrix4.identity()
                        ..rotateZ(widget.rotate * 3.14), // Rotate on Z-axis
                      child: Image.asset(imagePath))));
        }
      case "assets/delete.png":
        {
          return InkResponse(
              onTap: () {
                if (!widget.validate) {
                  plotController.deletePlot(widget.gardenId, widget.plotName,
                      selectedGardenName, widget.plotInCalendar);

                  Navigator.of(context).pushNamed(Routes.plots);
                } else {
                  plotController
                      .creationMessage("You cannot delete a validated plot.");
                }
              },
              splashFactory: InkSplash.splashFactory,
              child: SizedBox(
                  width: screenHeight * 0.1,
                  child: Transform(
                      alignment: Alignment.center,
                      transform: Matrix4.identity()
                        ..rotateZ(widget.rotate * 3.14),
                      child: Image.asset(imagePath))));
        }
      case "assets/simulate.png":
        {
          return InkResponse(
              onTap: () {
                widget.onEditCompleted(true);
              },
              splashFactory: InkSplash.splashFactory,
              child: SizedBox(
                  width: screenWidth * 0.2,
                  child: Transform(
                      alignment:
                          Alignment.center, // Rotate around the image center
                      transform: Matrix4.identity()
                        ..rotateZ(widget.rotate * 3.14), // Rotate on Z-axis
                      child: Image.asset(imagePath))));
        }
      default:
        {
          return InkResponse(
              onTap: () {
                setState(() {
                  isPressed = !isPressed;
                  imagePath = widget.buttonPressed; // Change to pressed image
                });

                if (!widget.validate) {
                  final vegetableLocations =
                      widget.droppedVegetables.keys.toList();
                  final vegetableIds = widget.droppedVegetables.values
                      .toList()
                      .map((vegetable) => vegetable?.id)
                      .toList();
                  final vegetableNames = widget.droppedVegetables.values
                      .toList()
                      .map((vegetable) => vegetable?.vegetableName)
                      .toList();

                  widget.controller.createPlanted(
                      vegetableIds,
                      vegetableLocations,
                      widget.plotId,
                      vegetableIds.length == widget.plotLength,
                      selectedGardenName,
                      widget.plotName,
                      vegetableNames,
                      widget.plotVersion);

                  widget.onEditCompleted(
                      false, vegetableIds.length == widget.plotLength);
                } else {
                  plotController
                      .creationMessage("You have validated your plot already.");
                }
              },
              splashFactory: InkSplash.splashFactory,
              child: SizedBox(
                  width: screenWidth * 0.2,
                  child: Transform(
                      alignment: Alignment.center,
                      transform: Matrix4.identity()
                        ..rotateZ(widget.rotate * 3.14),
                      child: Image.asset(imagePath))));
        }
    }
  }

  /// Displays a message in a snack bar at the bottom of the screen.
  void showMessageSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), duration: const Duration(seconds: 2)));
  }
}

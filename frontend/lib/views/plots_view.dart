import 'package:flutter/material.dart';
import '../models/plot_model.dart';
import '../models/selected_garden_model.dart';
import '../controllers/routes.dart';
import '../controllers/plot_controller.dart';
import 'custom_app_bar.dart';
import 'custom_bottom_bar.dart';

/// Displays a list of plots associated with a selected garden.
///
/// This stateful widget allows users to view their plots, add new plots, and navigate to detailed
/// plot views. It uses a [PlotController] to fetch plot data based on the garden selected.
class PlotsView extends StatefulWidget {
  const PlotsView({super.key});

  @override
  PlotsViewState createState() => PlotsViewState();
}

/// Manages the state of [PlotsView], handling the fetching and display of plots.
///
/// It interacts with [PlotController] to retrieve plot data and manages navigation based
/// on plot selection.
class PlotsViewState extends State<PlotsView> {
  late PlotController plotController;
  late Future<List<PlotModel>> futurePlots;
  final selectedGardenId = SelectedGardenModel().getSelectedGardenIdSync();

  /// Initializes the state by setting up the [PlotController] and preparing the future for plot data.
  ///
  /// It fetches plot data, filters out duplicates, and ensures only the latest versions are displayed.
  @override
  void initState() {
    super.initState();
    plotController =
        PlotController((String message) => showMessageSnackBar(message));

    futurePlots = plotController.getAllPlots(selectedGardenId).then((plots) {
      // Remove duplicate plots with lowest version
      List<PlotModel> uniquePlots = [];
      for (var plot in plots) {
        bool isDuplicate = uniquePlots.any((p) => p.plotName == plot.plotName);
        if (!isDuplicate) {
          uniquePlots.add(plot);
        } else {
          PlotModel existingPlot =
              uniquePlots.firstWhere((p) => p.plotName == plot.plotName);
          if (plot.plotVersion > existingPlot.plotVersion) {
            uniquePlots.remove(existingPlot);
            uniquePlots.add(plot);
          }
        }
      }
      return uniquePlots;
    });
  }

  /// Builds the widget tree for the plots view.
  ///
  /// This method handles layout and data fetching logic, displaying a list of plots or
  /// a UI for adding new plots if no plots are found.
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    double horizontalMargin = screenWidth * 0.1;
    double verticalMargin = screenHeight * 0.015;

    return Scaffold(
        appBar: const CustomAppBar(title: "My Plots"),
        body: FutureBuilder<List<PlotModel>>(
            future: futurePlots,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text("Error: ${snapshot.error}"));
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return ListView.builder(
                    itemCount: 1, // Plus one for the add button
                    itemBuilder: (context, index) {
                      return _buildAddPlotButton(
                          context, horizontalMargin, verticalMargin);
                    });
              } else {
                List<PlotModel> plots = snapshot.data!;
                return ListView.builder(
                    itemCount: plots.length + 1, // Plus one for the add button
                    itemBuilder: (context, index) {
                      if (index == plots.length) {
                        return _buildAddPlotButton(
                            context, horizontalMargin, verticalMargin);
                      } else {
                        return _buildPlotItem(context, horizontalMargin,
                            verticalMargin, plots[index]);
                      }
                    });
              }
            }),
        bottomNavigationBar: CustomBottomBar());
  }

  /// Constructs an add plot button with specified margins.
  ///
  /// This widget is displayed when no plots are found, providing a way to navigate
  /// to the plot creation view.
  Widget _buildAddPlotButton(
      BuildContext context, double horizontalMargin, double verticalMargin) {
    return Card(
        margin: EdgeInsets.symmetric(
            horizontal: horizontalMargin, vertical: verticalMargin),
        child: ListTile(
            leading: const Icon(Icons.add, color: Color(0xFF5B8E55)),
            title: const Text('New plot',
                style: TextStyle(color: Color(0xFF5B8E55))),
            onTap: () {
              Navigator.of(context).pushNamed(Routes.plotCreation);
            }));
  }

  /// Creates a plot item card for each plot in the list.
  ///
  /// Each card is clickable and navigates to a detailed view of the plot, passing necessary
  /// plot information as arguments.
  Widget _buildPlotItem(BuildContext context, double horizontalMargin,
      double verticalMargin, PlotModel plot) {
    return Card(
        margin: EdgeInsets.symmetric(
            horizontal: horizontalMargin, vertical: verticalMargin),
        child: ListTile(
            title: Text(plot.plotName),
            trailing: const Icon(Icons.chevron_right, color: Color(0xFF5B8E55)),
            onTap: () {
              Navigator.of(context).pushNamed(Routes.plotDisplay,
                  arguments: PlotDisplayArguments(
                      plotId: plot.id, plotName: plot.plotName));
            }));
  }

  /// Displays a snackbar with a specified [message].
  ///
  /// This method is used for alerting the user about various events and status changes, especially errors.
  void showMessageSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), duration: const Duration(seconds: 2)));
  }
}

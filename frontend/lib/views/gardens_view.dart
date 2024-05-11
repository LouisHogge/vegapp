import 'package:flutter/material.dart';
import '../models/garden_model.dart';
import '../models/selected_garden_model.dart';
import '../controllers/routes.dart';
import '../controllers/garden_controller.dart';
import 'custom_app_bar.dart';
import 'custom_bottom_bar.dart';

/// Displays a list of gardens managed by the user.
///
/// This stateful widget allows users to view their gardens, add new gardens, and select
/// a garden to display details for. It uses a [GardenController] to fetch garden data.
class GardensView extends StatefulWidget {
  const GardensView({super.key});

  @override
  GardensViewState createState() => GardensViewState();
}

/// Manages the state of [GardensView], handling the fetching and display of gardens.
///
/// It interacts with [GardenController] to retrieve garden data and manages navigation
/// based on garden selection.
class GardensViewState extends State<GardensView> {
  final GardenController _gardenController = GardenController();

  /// Initializes the state by setting up necessary controllers.
  @override
  void initState() {
    super.initState();
  }

  /// Builds the widget tree for the gardens view.
  ///
  /// This method handles layout and data fetching logic, displaying a list of gardens or
  /// a message if no gardens are found. It also provides a UI for adding new gardens.
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    double horizontalMargin = screenWidth * 0.1;
    double verticalMargin = screenHeight * 0.015;

    return Scaffold(
        appBar: const CustomAppBar(title: "My Gardens"),
        body: FutureBuilder<List<GardenModel>>(
            future: _gardenController.getAllGarden(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text("Error: ${snapshot.error}"));
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return ListView.builder(
                    itemCount: 1, // Plus one for the add button
                    itemBuilder: (context, index) {
                      return _buildAddGardenButton(
                          context, horizontalMargin, verticalMargin);
                    });
              } else {
                List<GardenModel> gardens = snapshot.data!;
                return ListView.builder(
                    itemCount:
                        gardens.length + 1, // Plus one for the add button
                    itemBuilder: (context, index) {
                      if (index == gardens.length) {
                        return _buildAddGardenButton(
                            context, horizontalMargin, verticalMargin);
                      } else {
                        return _buildGardenItem(context, horizontalMargin,
                            verticalMargin, gardens[index]);
                      }
                    });
              }
            }),
        bottomNavigationBar:
            SelectedGardenModel().getSelectedGardenIdSync() > -1
                ? CustomBottomBar()
                : null);
  }

  /// Constructs an add garden button with specified margins.
  ///
  /// This widget is displayed at the end of the garden list and provides a way to navigate
  /// to the garden creation view.
  Widget _buildAddGardenButton(
      BuildContext context, double horizontalMargin, double verticalMargin) {
    return Card(
        margin: EdgeInsets.symmetric(
            horizontal: horizontalMargin, vertical: verticalMargin),
        child: ListTile(
            leading: const Icon(Icons.add, color: Color(0xFF5B8E55)),
            title: const Text('New garden',
                style: TextStyle(color: Color(0xFF5B8E55))),
            onTap: () {
              Navigator.of(context).pushNamed(Routes.newGarden);
            }));
  }

  /// Creates a garden item card for each garden in the list.
  ///
  /// Each card is clickable and sets the selected garden in [SelectedGardenModel], then navigates
  /// to the home screen showing details of the selected garden.
  Widget _buildGardenItem(BuildContext context, double horizontalMargin,
      double verticalMargin, GardenModel garden) {
    return Card(
        margin: EdgeInsets.symmetric(
            horizontal: horizontalMargin, vertical: verticalMargin),
        child: ListTile(
            title: Text(garden.gardenName),
            trailing: const Icon(Icons.chevron_right, color: Color(0xFF5B8E55)),
            onTap: () {
              SelectedGardenModel().setSelectedGardenId(garden.gardenId);
              SelectedGardenModel().setSelectedGardenName(garden.gardenName);

              Navigator.of(context).pushNamedAndRemoveUntil(
                  Routes.home, (Route<dynamic> route) => false);
            }));
  }

  /// Displays a snackbar with a specified [message].
  ///
  /// This method is used for alerting the user about various events and status changes.
  void showMessageSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), duration: const Duration(seconds: 2)));
  }
}

import 'package:flutter/material.dart';
import '../models/vegetable_model.dart';
import '../models/selected_garden_model.dart';
import '../controllers/vegetable_controller.dart';
import '../controllers/category_controller.dart';
import '../controllers/routes.dart';
import 'custom_bottom_bar.dart';
import 'custom_app_bar.dart';

/// Displays a detailed view for a secondary category, including vegetables associated with it,
/// and provides options to edit or delete the category.
///
/// This stateful widget enables navigation to vegetable details and allows the addition
/// of new vegetables to the category. It also includes edit and delete functionalities for the category.
class SecondaryCategoryView extends StatefulWidget {
  final int categoryId;
  final String categoryName;
  final String categoryColor;

  const SecondaryCategoryView(
      {Key? key,
      required this.categoryId,
      required this.categoryName,
      required this.categoryColor})
      : super(key: key);

  @override
  SecondaryCategoryViewState createState() => SecondaryCategoryViewState();
}

/// Manages the state and behavior of [SecondaryCategoryView].
///
/// It handles the display of vegetables and provides UI for category management including
/// editing and deleting the category.
class SecondaryCategoryViewState extends State<SecondaryCategoryView> {
  late VegetableController vegetableController;
  late CategoryController categoryController;
  late Future<List<VegetableModel>> futureVegetables;
  final selectedGardenName = SelectedGardenModel().getSelectedGardenNameSync();

  /// Initializes controllers for vegetable and category management,
  /// and fetches vegetable data for the secondary category.
  @override
  void initState() {
    super.initState();
    vegetableController =
        VegetableController((String message) => showMessageSnackBar(message));
    categoryController =
        CategoryController((String message) => showMessageSnackBar(message));
    futureVegetables =
        vegetableController.getVegetablesBySecondaryCategory(widget.categoryId);
  }

  /// Constructs the user interface for category details, including a vegetable list
  /// and buttons for editing and deleting the category.
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    double horizontalMargin = screenWidth * 0.15;
    double verticalMargin = screenHeight * 0.005;

    return Scaffold(
        appBar: CustomAppBar(title: widget.categoryName),
        backgroundColor: const Color(0xFF779D39),
        body: Column(children: [
          Padding(
              padding: EdgeInsets.only(
                  left: screenWidth * 0.1, right: screenWidth * 0.1),
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                        child: buildEditButton(widget.categoryId,
                            widget.categoryName, widget.categoryColor)),
                    SizedBox(width: screenWidth * 0.1),
                    Expanded(
                        child: buildDeleteButton(
                            widget.categoryId, widget.categoryName)),
                  ])),
          Padding(
              padding: EdgeInsets.symmetric(vertical: verticalMargin),
              child: Card(
                  margin:
                      EdgeInsets.symmetric(horizontal: horizontalMargin * 0.6),
                  color: const Color(0xFF9B5366),
                  child: ListTile(
                      title: Center(
                          child: Text('Vegetables',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: screenWidth * 0.07,
                                  fontWeight: FontWeight.bold)))))),
          Expanded(
              child: FutureBuilder<List<VegetableModel>>(
                  future: futureVegetables,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(child: Text("Error: ${snapshot.error}"));
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return ListView.builder(
                        itemCount: 1, // Plus one for the add button
                        itemBuilder: (context, index) {
                          return _buildAddVegetableButton(
                              context,
                              horizontalMargin,
                              verticalMargin,
                              widget.categoryId);
                        },
                      );
                    } else {
                      List<VegetableModel> vegetables = snapshot.data!;
                      return ListView.builder(
                          itemCount: vegetables.length +
                              1, // Plus one for the add button
                          itemBuilder: (context, index) {
                            if (index == vegetables.length) {
                              return _buildAddVegetableButton(
                                  context,
                                  horizontalMargin,
                                  verticalMargin,
                                  widget.categoryId);
                            } else {
                              return _buildVegetableItem(
                                  context,
                                  horizontalMargin,
                                  verticalMargin,
                                  vegetables[index]);
                            }
                          });
                    }
                  })),
        ]),
        bottomNavigationBar: CustomBottomBar());
  }

  /// Builds a card button to add a new vegetable to the category.
  ///
  /// This button navigates to the vegetable creation view with pre-set category details.
  Widget _buildAddVegetableButton(BuildContext context, double horizontalMargin,
      double verticalMargin, int secondaryCategoryId) {
    return Card(
        margin: EdgeInsets.symmetric(
            horizontal: horizontalMargin, vertical: verticalMargin),
        color: const Color(0xFF9B5366),
        child: ListTile(
            leading: const Icon(Icons.add, color: Colors.white),
            title: const Text('New Vegetable',
                style: TextStyle(color: Colors.white)),
            onTap: () {
              Navigator.of(context).pushNamed(Routes.vegetableCreation,
                  arguments: VegetableCreationArguments(
                      vegetableId: -2,
                      vegetableName: 'error2',
                      seedExpiration: -2,
                      harvestStart: -2,
                      harvestEnd: -2,
                      plantStart: 'error2',
                      plantEnd: 'error2',
                      primaryCategoryId: -2,
                      secondaryCategoryId: secondaryCategoryId,
                      note: ''));
            }));
  }

  /// Builds a list item for each vegetable in the category.
  ///
  /// Each item is clickable and navigates to the detailed vegetable view.
  Widget _buildVegetableItem(BuildContext context, double horizontalMargin,
      double verticalMargin, VegetableModel vegetable) {
    return Card(
        margin: EdgeInsets.symmetric(
            horizontal: horizontalMargin, vertical: verticalMargin),
        color: const Color(0xFF9B5366),
        child: ListTile(
            title: Center(
                child: Text(vegetable.vegetableName,
                    style: const TextStyle(color: Colors.white))),
            onTap: () {
              Navigator.of(context).pushNamed(Routes.vegetableDisplay,
                  arguments:
                      VegetableDisplayArguments(vegetableId: vegetable.id));
            }));
  }

  /// Builds an edit button for the category.
  ///
  /// This button navigates to the category editing view, carrying forward the current category details.
  Widget buildEditButton(
          int categoryId, String categoryName, String categoryColor) =>
      ElevatedButton(
          onPressed: () {
            Navigator.of(context).pushNamed(Routes.secondaryCategoryCreation,
                arguments: SecondaryCategoryArguments(
                    categoryId: categoryId,
                    categoryName: categoryName,
                    categoryColor: categoryColor));
          },
          style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFD1EFE7),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10))),
          child:
              const Text("Edit", style: TextStyle(color: Color(0xFF5FB9B4))));

  /// Builds a delete button for the category.
  ///
  /// This button triggers the deletion process for the category and navigates back to the categories list.
  Widget buildDeleteButton(int categoryId, String categoryName) =>
      ElevatedButton(
          onPressed: () {
            categoryController.deleteSecondaryCategory(
                categoryId, categoryName, selectedGardenName);
            Navigator.of(context).pushNamed(Routes.categories);
          },
          style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFD1EFE7),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10))),
          child:
              const Text("Delete", style: TextStyle(color: Color(0xFF5FB9B4))));

  /// Displays a snackbar message in response to certain actions within the view.
  void showMessageSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), duration: const Duration(seconds: 2)));
  }
}

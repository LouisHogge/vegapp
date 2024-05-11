import 'package:flutter/material.dart';
import '../models/category_model.dart';
import '../models/selected_garden_model.dart';
import '../controllers/category_controller.dart';
import '../controllers/routes.dart';
import 'custom_bottom_bar.dart';
import 'custom_app_bar.dart';

/// Displays a catalog of primary and secondary categories associated with a selected garden.
///
/// This stateful widget allows users to view categories, add new categories, and navigate to detailed
/// category views. It uses a [CategoryController] to fetch category data based on the garden selected.
class CategoriesView extends StatefulWidget {
  const CategoriesView({super.key});

  @override
  CategoriesViewState createState() => CategoriesViewState();
}

/// Manages the state of [CategoriesView], handling the fetching and display of categories.
///
/// It interacts with [CategoryController] to retrieve category data and manages navigation based
/// on category selection.
class CategoriesViewState extends State<CategoriesView> {
  late CategoryController categoryController;
  late Future<List<dynamic>> futureCategories;
  final selectedGardenId = SelectedGardenModel().getSelectedGardenIdSync();

  /// Color mapping and reverse mapping for display purposes in the UI.
  final Map<String, Color> colorMap = {
    'RED': Colors.red,
    'GREEN': Colors.green,
    'BLUE': Colors.blue,
    'ORANGE': Colors.orange,
    'PURPLE': Colors.purple,
    'YELLOW': Colors.yellow,
    'BROWN': Colors.brown,
  };
  Map<Color, String> reverseColorMap = {
    Colors.red: 'RED',
    Colors.green: 'GREEN',
    Colors.blue: 'BLUE',
    Colors.orange: 'ORANGE',
    Colors.purple: 'PURPLE',
    Colors.yellow: 'YELLOW',
    Colors.brown: 'BROWN',
  };

  /// Initializes the state by setting up the [CategoryController] and preparing the future for category data.
  ///
  /// Fetches both primary and secondary categories, combining them into a single list.
  @override
  void initState() {
    super.initState();
    categoryController =
        CategoryController((String message) => showMessageSnackBar(message));
    futureCategories = getAllCategories();
  }

  /// Fetches both primary and secondary categories associated with the selected garden.
  Future<List<dynamic>> getAllCategories() async {
    var primaryCategories =
        await categoryController.getAllPrimaryCategories(selectedGardenId);
    var secondaryCategories =
        await categoryController.getAllSecondaryCategories(selectedGardenId);
    return [...primaryCategories, ...secondaryCategories];
  }

  /// Refreshes the category list by re-fetching the categories.
  void refreshCategories() {
    setState(() {
      futureCategories = getAllCategories();
    });
  }

  /// Builds the widget tree for the categories view.
  ///
  /// This method handles layout and data fetching logic, displaying a grid of categories or
  /// a UI for adding new categories if no categories are found.
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    int crossAxisCount = screenWidth < 600 ? 4 : 6;
    double aspectRatio = screenWidth < 600 ? 1 : 1;
    double crossAxisSpacing = screenWidth * 0.01;
    double mainAxisSpacing = screenHeight * 0.01;
    double cardPadding = screenWidth * 0.02;
    double imageHeight = screenWidth * 0.06;
    double fontSize = screenWidth * 0.025;

    return Scaffold(
        appBar: const CustomAppBar(title: "My Catalog"),
        body: FutureBuilder<List<dynamic>>(
            future: futureCategories,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return GridView.builder(
                    padding: EdgeInsets.all(cardPadding),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        childAspectRatio: aspectRatio,
                        crossAxisSpacing: crossAxisSpacing,
                        mainAxisSpacing: mainAxisSpacing),
                    itemCount: 1,
                    itemBuilder: (context, index) {
                      return buildAddCategoryCard(
                          screenWidth, screenHeight, imageHeight);
                    });
              } else {
                List<dynamic> categories = snapshot.data!;
                return GridView.builder(
                    padding: EdgeInsets.all(cardPadding),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        childAspectRatio: aspectRatio,
                        crossAxisSpacing: crossAxisSpacing,
                        mainAxisSpacing: mainAxisSpacing),
                    itemCount: categories.length + 1,
                    itemBuilder: (context, index) {
                      if (index == categories.length) {
                        return buildAddCategoryCard(
                            screenWidth, screenHeight, imageHeight);
                      } else {
                        var category = categories[index];
                        if (category is PrimaryCategoryModel) {
                          return buildCategoryCard(
                              category.primaryCategoryId,
                              category.categoryName,
                              '',
                              mainAxisSpacing,
                              imageHeight,
                              fontSize);
                        } else if (category is SecondaryCategoryModel) {
                          return buildCategoryCard(
                              category.secondaryCategoryId,
                              category.categoryName,
                              category.categoryColor,
                              mainAxisSpacing,
                              imageHeight,
                              fontSize,
                              isSecondary: true);
                        }
                        return Container(); // Fallback empty container
                      }
                    });
              }
            }),
        bottomNavigationBar: CustomBottomBar());
  }

  /// Builds a card to add a new category.
  ///
  /// This card acts as a button to navigate to the category creation view.
  Widget buildAddCategoryCard(
      double screenWidth, double screenHeight, double imageHeight) {
    return GestureDetector(
        onTap: () =>
            Navigator.of(context).pushNamed(Routes.secondaryCategoryCreation),
        child: Card(
            elevation: 2.0,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            child: Icon(Icons.add, size: imageHeight)));
  }

  /// Builds a card for each category in the list.
  ///
  /// This card displays category details and navigates to specific category views when tapped.
  Widget buildCategoryCard(
      int categoryId,
      String categoryName,
      String colorName,
      double mainAxisSpacing,
      double imageHeight,
      double fontSize,
      {bool isSecondary = false}) {
    Color color = colorMap[colorName.toUpperCase()] ?? Colors.pink;

    return GestureDetector(
        onTap: () {
          if (isSecondary) {
            Navigator.of(context).pushNamed(Routes.secondaryCategory,
                arguments: SecondaryCategoryArguments(
                    categoryId: categoryId,
                    categoryName: categoryName,
                    categoryColor: colorName));
          } else {
            Navigator.of(context).pushNamed(Routes.primaryCategory,
                arguments: PrimaryCategoryArguments(
                    categoryId: categoryId, categoryName: categoryName));
          }
        },
        child: Card(
            color: isSecondary ? color : null,
            elevation: 2.0,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  isSecondary
                      ? Container()
                      : Image.asset('assets/$categoryName.png',
                          height: imageHeight, errorBuilder:
                              (BuildContext context, Object exception,
                                  StackTrace? stackTrace) {
                          return Image.asset('assets/default.png',
                              height: imageHeight);
                        }),
                  SizedBox(height: mainAxisSpacing),
                  Text(categoryName,
                      style: TextStyle(
                          fontSize: fontSize, fontWeight: FontWeight.bold)),
                ])));
  }

  /// Displays a snackbar with a specified [message].
  ///
  /// This method is used for alerting the user about various events and status changes, especially errors.
  void showMessageSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), duration: const Duration(seconds: 2)));
  }
}

import 'package:flutter/material.dart';
import 'package:dots_indicator/dots_indicator.dart';
import '../models/vegetable_model.dart';
import '../controllers/category_controller.dart';
import '../controllers/vegetable_controller.dart';
import '../controllers/routes.dart';
import 'custom_bottom_bar.dart';
import 'custom_app_bar.dart';

/// Displays a detailed view for a primary category, showing vegetables associated with it
/// and related affinities.
///
/// This stateful widget enables navigation to vegetable details and allows the addition of
/// new vegetables to the category.
class PrimaryCategoryView extends StatefulWidget {
  final int categoryId;
  final String categoryName;

  const PrimaryCategoryView(
      {Key? key, required this.categoryId, required this.categoryName})
      : super(key: key);

  @override
  PrimaryCategoryViewState createState() => PrimaryCategoryViewState();
}

/// Manages the state and behavior of [PrimaryCategoryView].
///
/// It handles the display of vegetables and affinities for the specified primary category,
/// including page navigation and dynamic updates.
class PrimaryCategoryViewState extends State<PrimaryCategoryView> {
  late PageController _pageController;
  late CategoryController categoryController;
  late VegetableController vegetableController;
  final ValueNotifier<int> _pageIndexNotifier = ValueNotifier(0);

  /// Initializes controllers for category and vegetable management,
  /// sets up page navigation listeners.
  @override
  void initState() {
    super.initState();
    categoryController =
        CategoryController((String message) => showMessageSnackBar(message));
    vegetableController =
        VegetableController((String message) => showMessageSnackBar(message));
    _pageController = PageController(initialPage: 0);
    _pageController.addListener(() {
      _pageIndexNotifier.value = _pageController.page!.round();
    });
  }

  /// Disposes the page controller and notifier on widget destruction to prevent memory leaks.
  @override
  void dispose() {
    _pageController.dispose();
    _pageIndexNotifier.dispose();
    super.dispose();
  }

  /// Constructs the user interface for category details, including a vegetable list
  /// and an affinity list displayed through a paged view.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: CustomAppBar(title: widget.categoryName),
        body: Column(children: [
          // Dot indicator for page navigation
          if (widget.categoryName != 'Bin')
            ValueListenableBuilder<int>(
                valueListenable: _pageIndexNotifier,
                builder: (context, value, child) {
                  return DotsIndicator(
                      dotsCount: 2,
                      position: value.toDouble(),
                      decorator: DotsDecorator(
                          activeColor: Colors.green,
                          size: const Size.square(9.0),
                          activeSize: const Size(18.0, 9.0),
                          activeShape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5.0))));
                }),
          Expanded(
              child: PageView(
            controller: _pageController,
            children: <Widget>[
              FutureBuilder<List<VegetableModel>>(
                  future: vegetableController
                      .getVegetablesByPrimaryCategory(widget.categoryId),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(child: Text("Error: ${snapshot.error}"));
                    } else if (snapshot.hasData) {
                      return VegetableList(
                          vegetables: snapshot.data!,
                          categoryId: widget.categoryId);
                    } else {
                      return const Center(
                          child: Text("No vegetables found in this category."));
                    }
                  }),
              if (widget.categoryName != 'Bin')
                AffinityList(
                    controller: categoryController,
                    categoryName: widget.categoryName),
            ],
          ))
        ]),
        bottomNavigationBar: CustomBottomBar());
  }

  /// Displays a snackbar message in response to certain actions within the view.
  void showMessageSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), duration: const Duration(seconds: 2)));
  }
}

/// A widget to display a list of vegetables belonging to a primary category.
///
/// Provides a visual representation and interaction mechanisms for each vegetable,
/// including navigation to detailed vegetable views.
class VegetableList extends StatelessWidget {
  final List<VegetableModel> vegetables;
  final int categoryId;

  const VegetableList(
      {Key? key, required this.vegetables, required this.categoryId})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    double horizontalMargin = screenWidth * 0.15;
    double verticalMargin = screenHeight * 0.005;

    return Scaffold(
        backgroundColor: const Color(0xFF779D39),
        body: Column(children: [
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
                                fontWeight: FontWeight.bold)))),
              )),
          Expanded(
              child: ListView.builder(
                  itemCount: vegetables.length + 1,
                  itemBuilder: (context, index) {
                    if (index == vegetables.length) {
                      // new vegetable button
                      return Card(
                          margin: EdgeInsets.symmetric(
                              horizontal: horizontalMargin,
                              vertical: verticalMargin),
                          color: const Color(0xFF9B5366),
                          child: ListTile(
                              leading:
                                  const Icon(Icons.add, color: Colors.white),
                              title: const Text('New vegetable',
                                  style: TextStyle(color: Colors.white)),
                              onTap: () {
                                Navigator.of(context).pushNamed(
                                    Routes.vegetableCreation,
                                    arguments: VegetableCreationArguments(
                                        vegetableId: -1,
                                        vegetableName: 'error',
                                        seedExpiration: -1,
                                        harvestStart: -1,
                                        harvestEnd: -1,
                                        plantStart: 'error',
                                        plantEnd: 'error',
                                        primaryCategoryId: categoryId,
                                        secondaryCategoryId: -1,
                                        note: ''));
                              }));
                    } else {
                      VegetableModel vegetable = vegetables[index];
                      return Card(
                          margin: EdgeInsets.symmetric(
                              horizontal: horizontalMargin,
                              vertical: verticalMargin),
                          color: const Color(0xFF9B5366),
                          child: ListTile(
                              title: Center(
                                  child: Text(vegetable.vegetableName,
                                      style: const TextStyle(
                                          color: Colors.white))),
                              onTap: () {
                                Navigator.of(context).pushNamed(
                                    Routes.vegetableDisplay,
                                    arguments: VegetableDisplayArguments(
                                        vegetableId: vegetable.id));
                              }));
                    }
                  })),
        ]));
  }
}

/// A widget to display a list of affinities associated with the primary category.
///
/// Provides an interactive list where each item represents a category affinity, allowing
/// users to view relationships between categories.
class AffinityList extends StatelessWidget {
  final CategoryController controller;
  final String categoryName;

  const AffinityList(
      {Key? key, required this.controller, required this.categoryName})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    double horizontalMargin = screenWidth * 0.15;
    double verticalMargin = screenHeight * 0.005;

    return Scaffold(
        backgroundColor: const Color(0xFF5B8E55),
        body: Column(children: [
          Padding(
              padding: EdgeInsets.symmetric(vertical: verticalMargin),
              child: Card(
                  margin:
                      EdgeInsets.symmetric(horizontal: horizontalMargin * 0.6),
                  color: const Color(0xFF9B5366),
                  child: ListTile(
                    title: Center(
                        child: Text('Affinities',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: screenWidth * 0.07,
                                fontWeight: FontWeight.bold))),
                  ))),
          Expanded(
              child: ListView.builder(
                  itemCount: controller.affinityNames[categoryName].length,
                  itemBuilder: (context, index) {
                    final category =
                        controller.affinityNames[categoryName][index];
                    final affinity = controller.affinityValues[categoryName]
                            [controller.categoryIndex[index]]
                        .toString();
                    if (category == categoryName) return const SizedBox();
                    return Card(
                        margin: EdgeInsets.symmetric(
                            horizontal: horizontalMargin,
                            vertical: verticalMargin),
                        color: const Color(0xFF9B5366),
                        child: ListTile(
                            title: Text(category,
                                style: const TextStyle(color: Colors.white)),
                            trailing: Text(affinity,
                                style: const TextStyle(color: Colors.white))));
                  })),
        ]));
  }
}

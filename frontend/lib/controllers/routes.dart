/// This file contains the definition of the [Routes] class and argument classes for dynamic routes.
/// The [Routes] class defines the route names and handles static and dynamic routes in the application.
/// It also provides a map of static routes and a method for generating dynamic routes based on route settings.
/// The argument classes define the arguments required for specific dynamic routes.
import 'package:flutter/material.dart';
import '../views/calendar_view.dart';
import '../views/home_view.dart';
import '../views/plot_display_view.dart';
import '../views/start_view.dart';
import '../views/categories_view.dart';
import '../views/seed_view.dart';
import '../views/primary_category_view.dart';
import '../views/secondary_category_view.dart';
import '../views/vegetable_display_view.dart';
import '../views/vegetable_creation_view.dart';
import '../views/gardens_view.dart';
import '../views/new_garden_view.dart';
import '../views/plots_view.dart';
import '../views/plot_creation_view.dart';
import '../views/new_user_view.dart';
import '../views/secondary_category_creation_view.dart';

/// The [SynchronizeArguments] class represents the arguments required for the '/synchronize' dynamic route.
class SynchronizeArguments {
  final String dateTime;

  SynchronizeArguments({required this.dateTime});
}

/// The [PrimaryCategoryArguments] class represents the arguments required for the '/primaryCategory' dynamic route.
class PrimaryCategoryArguments {
  final int categoryId;
  final String categoryName;

  PrimaryCategoryArguments(
      {required this.categoryId, required this.categoryName});
}

/// The [SecondaryCategoryArguments] class represents the arguments required for the '/secondaryCategory' dynamic route.
class SecondaryCategoryArguments {
  final int categoryId;
  final String categoryName;
  final String categoryColor;

  SecondaryCategoryArguments(
      {required this.categoryId,
      required this.categoryName,
      required this.categoryColor});
}

/// The [PlotDisplayArguments] class represents the arguments required for the '/plotDisplay' dynamic route.
class PlotDisplayArguments {
  final int plotId;
  final String plotName;

  PlotDisplayArguments({required this.plotId, required this.plotName});
}

/// The [VegetableDisplayArguments] class represents the arguments required for the '/vegetableDisplay' dynamic route.
class VegetableDisplayArguments {
  final int vegetableId;

  VegetableDisplayArguments({required this.vegetableId});
}

/// The [VegetableCreationArguments] class represents the arguments required for the '/vegetableCreation' dynamic route.
class VegetableCreationArguments {
  final int vegetableId;
  final String vegetableName;
  final int seedExpiration;
  final int harvestStart;
  final int harvestEnd;
  final String plantStart;
  final String plantEnd;
  final int primaryCategoryId;
  final int secondaryCategoryId;
  final String note;

  VegetableCreationArguments(
      {required this.vegetableId,
      required this.vegetableName,
      required this.seedExpiration,
      required this.harvestStart,
      required this.harvestEnd,
      required this.plantStart,
      required this.plantEnd,
      required this.primaryCategoryId,
      required this.secondaryCategoryId,
      required this.note});
}

/// The [PlotCreationArguments] class represents the arguments required for the '/plotCreation' dynamic route.
class PlotCreationArguments {
  final int plotId;
  final String plotName;
  final String plotPlantationLines;
  final int plotOrientation;
  final int plotVersion;
  final int plotInCalendar;
  final String plotNote;

  PlotCreationArguments(
      {required this.plotId,
      required this.plotName,
      required this.plotPlantationLines,
      required this.plotOrientation,
      required this.plotVersion,
      required this.plotInCalendar,
      required this.plotNote});
}

/// The [PlotCreationSecondaryLinesArguments] class represents the arguments required for the '/plotCreationSecondaryLines' dynamic route.
class PlotCreationSecondaryLinesArguments {
  final int mainLines;
  final String plotName;
  final int plotOrientation;
  final Map<String, dynamic> editArgs;

  PlotCreationSecondaryLinesArguments(
      {required this.mainLines,
      required this.plotName,
      required this.plotOrientation,
      required this.editArgs});
}

/// The [Routes] class defines the route names and handles static and dynamic routes in the application.
class Routes {
  // route names
  static const String home = '/home';
  static const String start = '/start';
  static const String categories = '/categories';
  static const String vegetableCreation = '/vegetableCreation';
  static const String primaryCategory = '/primaryCategory';
  static const String secondaryCategory = '/secondaryCategory';
  static const String secondaryCategoryCreation = '/secondaryCategoryCreation';
  static const String calendar = '/calendar';
  static const String seed = '/seed';
  static const String vegetableDisplay = '/vegetableDisplay';
  static const String gardens = '/gardens';
  static const String newGarden = '/newGarden';
  static const String plots = '/plots';
  static const String plotCreation = '/plotCreation';
  static const String plotDisplay = '/plotDisplay';
  static const String plotCreationSecondaryLines =
      '/plotCreationSecondaryLines';
  static const String newUser = '/newUser';

  // Static routes handling
  static Map<String, WidgetBuilder> get staticRoutes => {
        start: (context) => const StartView(),
        home: (context) => const HomeView(),
        categories: (context) => const CategoriesView(),
        calendar: (context) => const CalendarView(),
        seed: (context) => const SeedView(),
        gardens: (context) => const GardensView(),
        newGarden: (context) => const NewGardenView(),
        plots: (context) => const PlotsView(),
        newUser: (context) => const NewUserView(),
      };

  // Dynamic route handling
  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/primaryCategory':
        final args = settings.arguments as PrimaryCategoryArguments;
        final categoryId = args.categoryId;
        final categoryName = args.categoryName;
        return MaterialPageRoute(
            builder: (context) => PrimaryCategoryView(
                categoryId: categoryId, categoryName: categoryName));

      case '/secondaryCategory':
        final args = settings.arguments as SecondaryCategoryArguments;
        final categoryId = args.categoryId;
        final categoryName = args.categoryName;
        final categoryColor = args.categoryColor;
        return MaterialPageRoute(
            builder: (context) => SecondaryCategoryView(
                categoryId: categoryId,
                categoryName: categoryName,
                categoryColor: categoryColor));

      case '/plotCreationSecondaryLines':
        final args = settings.arguments as PlotCreationSecondaryLinesArguments;
        final mainLines = args.mainLines;
        final plotName = args.plotName;
        final plotOrientation = args.plotOrientation;
        final editArgs = args.editArgs;
        return MaterialPageRoute(
            builder: (context) => PlotCreationSecondaryLines(
                mainLines: mainLines,
                plotName: plotName,
                plotOrientation: plotOrientation,
                editArgs: editArgs));

      case '/plotCreation':
        final args = settings.arguments as PlotCreationArguments?;
        return MaterialPageRoute(
            builder: (context) => PlotCreationView(initialData: args));

      case '/plotDisplay':
        final args = settings.arguments as PlotDisplayArguments;
        final plotId = args.plotId;
        final plotName = args.plotName;
        return MaterialPageRoute(
            builder: (context) =>
                PlotDisplayView(plotId: plotId, plotName: plotName));

      case '/vegetableDisplay':
        final args = settings.arguments as VegetableDisplayArguments;
        final vegetableId = args.vegetableId;
        return MaterialPageRoute(
            builder: (context) => VegetableView(vegetableId: vegetableId));

      case '/vegetableCreation':
        final args = settings.arguments as VegetableCreationArguments?;
        return MaterialPageRoute(
            builder: (context) => VegetableCreationView(initialData: args));

      case '/secondaryCategoryCreation':
        final args = settings.arguments as SecondaryCategoryArguments?;
        return MaterialPageRoute(
            builder: (context) =>
                SecondaryCategoryCreationView(initialData: args));

      default:
        return null;
    }
  }
}

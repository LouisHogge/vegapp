import 'package:flutter/material.dart';
import '../controllers/routes.dart';

/// A custom bottom navigation bar widget.
class CustomBottomBar extends StatelessWidget {
  CustomBottomBar({Key? key}) : super(key: key);

  final Map<int, String> _routeNames = {
    0: Routes.categories,
    1: Routes.home,
    2: Routes.vegetableCreation,
  };

  /// Checks if the given [routeName] is the current route in the [context].
  bool isCurrentRoute(BuildContext context, String routeName) {
    return ModalRoute.of(context)?.settings.name == routeName;
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return BottomNavigationBar(
        onTap: (index) {
          String? routeName = _routeNames[index];
          if (routeName != null && !isCurrentRoute(context, routeName)) {
            if (routeName == Routes.home) {
              Navigator.pushNamedAndRemoveUntil(
                  context, routeName, (Route<dynamic> route) => false);
            } else {
              Navigator.of(context).pushNamed(routeName);
            }
          }
        },
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
              icon: Image.asset("assets/book_fill.png",
                  width: screenWidth * 0.12, height: screenWidth * 0.12),
              label: ''),
          BottomNavigationBarItem(
              icon: Image.asset("assets/home2.png",
                  width: screenWidth * 0.12, height: screenWidth * 0.12),
              label: ''),
          BottomNavigationBarItem(
              icon: Image.asset("assets/veg.png",
                  width: screenWidth * 0.12, height: screenWidth * 0.12),
              label: ''),
        ]);
  }
}

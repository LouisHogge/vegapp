import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controllers/routes.dart';

/// The start view of the application.
class StartView extends StatefulWidget {
  const StartView({super.key});

  @override
  State<StartView> createState() => _StartViewState();
}

class _StartViewState extends State<StartView> {
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
        body: Container(
            decoration: const BoxDecoration(
                image: DecorationImage(
                    image: AssetImage('assets/start.png'), fit: BoxFit.cover)),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              SizedBox(height: screenHeight * 0.15),
              buildTitle(screenWidth),
              SizedBox(height: screenHeight * 0.10),
              Center(
                  child: SizedBox(
                      width: screenWidth * 0.75,
                      height: screenHeight * 0.1,
                      child: FloatingActionButton(
                          onPressed: () =>
                              Navigator.of(context).pushNamed(Routes.newUser),
                          backgroundColor: const Color(0xFFE6FF50),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(75)),
                          foregroundColor: Colors.black,
                          splashColor: Colors.white.withOpacity(0.2),
                          highlightElevation: 4.0,
                          child: Text(
                            'GET STARTED',
                            style: GoogleFonts.blinker(
                                textStyle: TextStyle(
                                    fontSize: screenWidth * 0.08,
                                    fontWeight: FontWeight.w600)),
                            softWrap: true,
                          )))),
            ])));
  }
}

/// Builds the title widget for the start view.
Widget buildTitle(double screenWidth) {
  return Center(
      child: Text(
    'VegApp',
    style: GoogleFonts.lilyScriptOne(
        textStyle: TextStyle(
            fontSize: screenWidth * 0.1, fontWeight: FontWeight.w500)),
    softWrap: true,
  ));
}

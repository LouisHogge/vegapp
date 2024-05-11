import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// A custom app bar widget that displays a stylized title.
class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;

  @override
  final Size preferredSize;

  /// Creates a [CustomAppBar] widget.
  ///
  /// The [title] parameter is required and specifies the text to be displayed as the app bar title.
  /// The [preferredSize] parameter is optional and specifies the preferred size of the app bar.
  /// If not provided, it defaults to the height of a standard toolbar.
  const CustomAppBar({
    Key? key,
    required this.title,
    this.preferredSize = const Size.fromHeight(kToolbarHeight),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double fontSize = screenWidth * 0.08;
    // Split title into words
    List<String> words = title.split(' ');

    // Generate TextSpan children based on the number of words
    List<TextSpan> textSpans;
    if (words.length == 1) {
      textSpans = [
        TextSpan(
          text: words.first,
          style: GoogleFonts.abrilFatface(
            textStyle: TextStyle(
              color: const Color(0xFF5B8E55),
              fontSize: fontSize,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
      ];
    } else {
      // For more than 1 word
      // 1st word
      textSpans = [
        TextSpan(
          text: "${words.first} ",
          style: GoogleFonts.abrilFatface(
            textStyle: TextStyle(
              color: const Color(0xFF12121D),
              fontSize: fontSize,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
        // other words
        for (int i = 1; i < words.length; i++)
          TextSpan(
            text: "${words[i]} ",
            style: GoogleFonts.abrilFatface(
              textStyle: TextStyle(
                color: const Color(0xFF5B8E55),
                fontSize: fontSize,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
      ];
    }

    return AppBar(title: Text.rich(TextSpan(children: textSpans)));
  }
}

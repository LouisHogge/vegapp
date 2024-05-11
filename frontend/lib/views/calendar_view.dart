import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/calendar_model.dart';
import '../models/selected_garden_model.dart';
import '../models/vegetable_model.dart';
import '../controllers/calendar_controller.dart';
import '../controllers/vegetable_controller.dart';
import 'notes_view.dart';
import 'custom_bottom_bar.dart';
import 'custom_app_bar.dart';

/// Displays a calendar view for managing gardening activities.
///
/// This stateful widget coordinates interaction between user input and the
/// underlying models for gardens, vegetables, and calendar activities through
/// respective controllers.
class CalendarView extends StatefulWidget {
  const CalendarView({super.key});

  @override
  CalendarViewState createState() => CalendarViewState();
}

/// Manages the state and behavior of the [CalendarView] widget.
///
/// This class facilitates interactions with the [VegetableController] and [CalendarController],
/// handling the visualization of monthly gardening tasks and notes integration.
class CalendarViewState extends State<CalendarView>
    with TickerProviderStateMixin {
  late VegetableController vegetableController;
  late CalendarController calendarController;
  NotesDialog notesDialog = NotesDialog();
  late Future<List<VegetableModel>> futureVegetables;
  late Future<List<CalendarModel>> futureCalendar;
  late Future<int> futureMonths;
  final selectedGardenId = SelectedGardenModel().getSelectedGardenIdSync();
  final selectedGardenName = SelectedGardenModel().getSelectedGardenNameSync();

  String vegetableName = '';
  int _currentMonth = 1;
  int pushedMonth = -1;
  int plantedMonth = -1;
  bool done = false;
  bool pushedPlant = false;
  bool pushedHarvest = false;

  /// Initializes controller instances and fetches necessary data for the calendar.
  ///
  /// This includes initializing interactions with vegetable and calendar data sources
  /// to populate the view accordingly.
  @override
  void initState() {
    super.initState();
    vegetableController =
        VegetableController((String message) => showMessageSnackBar(message));
    calendarController =
        CalendarController((String message) => showMessageSnackBar(message));

    futureVegetables =
        vegetableController.getVegetablesByGardenId(selectedGardenId);
    futureCalendar = calendarController.offlineFillCalendar(selectedGardenId);
  }

  /// Updates the current month displayed in the calendar based on user navigation.
  ///
  /// Accepts a [delta] to adjust the current month, handling both forward and backward navigation.
  void updateMonth(int delta) {
    setState(() {
      _currentMonth = (_currentMonth + delta) % 12;
    });
  }

  /// Constructs the main UI components of the calendar view.
  ///
  /// This method sets up the calendar's structure, including navigation buttons, legends, and
  /// the dynamic grid for displaying monthly activities.
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
        appBar: const CustomAppBar(title: "My Calendar"),
        body: FutureBuilder<List<CalendarModel>>(
            future: futureCalendar,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                          child: AnimatedTextButton(
                              vegetableController: vegetableController,
                              currentMonth: _currentMonth,
                              updateMonth: updateMonth,
                              screenWidth: screenWidth)),
                      ...buildLegend(screenWidth),
                      SizedBox(height: screenHeight * 0.030),
                      Expanded(
                          child: buildCalendar(
                              _currentMonth,
                              calendarController.months,
                              screenWidth,
                              screenHeight,
                              snapshot.data!))
                    ]);
              } else if (snapshot.hasError) {
                return Text("test : ${snapshot.error}");
              }
              return const CircularProgressIndicator();
            }),
        bottomNavigationBar: CustomBottomBar());
  }

  /// Builds a legend to visually represent plant growth states in the calendar.
  ///
  /// This function generates a set of legend items with corresponding colors and labels.
  List<Widget> buildLegend(double screenWidth) {
    return [
      Center(
          child: addLegend(
              screenWidth,
              screenWidth * 0.15,
              const Color.fromRGBO(27, 196, 24, 0.29),
              "Plant",
              const Color(0xFF709731))),
      Center(
          child: addLegend(
              screenWidth,
              screenWidth * 0.2,
              const Color.fromRGBO(155, 83, 102, 0.29),
              "Harvest",
              const Color(0xFF9B5366))),
      Center(
          child: addLegend(
              screenWidth,
              screenWidth * 0.3,
              const Color.fromRGBO(169, 134, 227, 0.29),
              "Growing",
              const Color(0xFFA986E3))),
    ];
  }

  /// Creates a legend item widget with specified dimensions and colors.
  ///
  /// It represents a key in the calendar that explains the color coding of gardening activities.
  Widget addLegend(double screenWidth, double widthBox, Color boxColor,
      String legend, Color legendColor) {
    return Container(
        margin: const EdgeInsets.all(5.0),
        width: widthBox,
        height: (screenWidth * 0.4) / 6,
        decoration: BoxDecoration(
            color: boxColor, borderRadius: BorderRadius.circular(15)),
        child: Center(
            child: Text(legend,
                style: GoogleFonts.abrilFatface(
                    textStyle: TextStyle(
                        fontSize: screenWidth * 0.04, color: legendColor)))));
  }

  /// Constructs the monthly view of the calendar with planting and harvesting information.
  ///
  /// Displays the gardening activities planned for each month, utilizing dynamic sizing based on
  /// the screen dimensions.
  Widget buildCalendar(int currentMonth, List<String> months,
      double screenWidth, double screenHeight, List<CalendarModel> vegetables) {
    List<VegetableModel> vegetablesModel = [];

    return Container(
        decoration: const BoxDecoration(color: Color(0xFF5B8E55)),
        child: SingleChildScrollView(
            child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(children: [
                  Row(children: [
                    Text("Activities",
                        style: GoogleFonts.abrilFatface(
                            textStyle: TextStyle(
                                color: Colors.white,
                                fontSize: screenWidth * 0.06,
                                fontWeight: FontWeight.w400))),
                  ]),
                  SizedBox(height: screenHeight * 0.010),
                  Row(children: [
                    Container(
                        width: screenWidth * 0.15,
                        height: screenHeight * 0.092,
                        decoration: BoxDecoration(
                            color:
                                Colors.white.withOpacity(0.30000001192092896),
                            borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(25))),
                        child: Center(
                            child: Text('Veggies',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.abrilFatface(
                                    textStyle: TextStyle(
                                        color: Colors.white,
                                        fontSize: screenWidth * 0.040,
                                        fontWeight: FontWeight.w400,
                                        letterSpacing: -0.13))))),
                    Row(
                        children: months
                            .sublist(
                                // Calculate starting index based on currentMonth
                                (currentMonth - 1).clamp(0, months.length - 4),
                                // Calculate ending index (exclusive)
                                (currentMonth + 3).clamp(0, months.length))
                            .map((month) =>
                                showMonth(screenWidth, screenHeight, month))
                            .toList()),
                    Container(
                        width: screenWidth * 0.19,
                        height: screenHeight * 0.092,
                        decoration: BoxDecoration(
                            color:
                                Colors.white.withOpacity(0.30000001192092896),
                            borderRadius: const BorderRadius.only(
                                topRight: Radius.circular(25)),
                            border: Border(
                                bottom: BorderSide(
                                    width: 2,
                                    color: Colors.black
                                        .withOpacity(0.30000001192092896)))),
                        child: Center(
                            child: Text('Notes',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.abrilFatface(
                                    textStyle: TextStyle(
                                        color: Colors.white,
                                        fontSize: screenWidth * 0.040,
                                        fontWeight: FontWeight.w400,
                                        letterSpacing: -0.13))))),
                  ]),
                  vegetables.isEmpty
                      ? Row(children: [
                          Container(
                              width: screenWidth * 0.15,
                              height: screenHeight * 0.092,
                              decoration: BoxDecoration(
                                  color: Colors.white
                                      .withOpacity(0.30000001192092896),
                                  borderRadius: const BorderRadius.only(
                                      bottomLeft: Radius.circular(25)))),
                          Container(
                              width: screenWidth * 0.75,
                              height: screenHeight * 0.092,
                              padding: const EdgeInsets.symmetric(
                                  vertical: 11, horizontal: 10),
                              decoration: BoxDecoration(
                                  color: Colors.black
                                      .withOpacity(0.44999998807907104)),
                              child: Text("Create a plot and toggle it !",
                                  style: GoogleFonts.abrilFatface(
                                      textStyle: TextStyle(
                                          color: Colors.white
                                              .withOpacity(0.7399999976158142),
                                          fontSize: screenWidth * 0.055,
                                          fontWeight: FontWeight.w400)))),
                        ])
                      : FutureBuilder<List<VegetableModel>>(
                          future: vegetableController.getVegetablesByIds(
                              calendarController.getVegetablesIds(vegetables)),
                          builder: (context, snapshot) {
                            if (snapshot.hasData) {
                              vegetablesModel = snapshot.data!;
                              final showVegetables = vegetablesModel
                                  .map((vm) => showVegetable(
                                      screenWidth,
                                      screenHeight,
                                      vm,
                                      vegetables[vegetablesModel.indexOf(vm)],
                                      _currentMonth,
                                      vm == vegetablesModel.last))
                                  .toList();
                              return Column(children: [
                                const SizedBox(),
                                ...showVegetables
                                    .sublist(0, showVegetables.length)
                                    .map((vegetableTuple) => vegetableTuple)
                              ]);
                            } else if (snapshot.hasError) {
                              return Text("${snapshot.error}");
                            }
                            return const CircularProgressIndicator();
                          }),
                ]))));
  }

  /// Displays a single month as a part of the calendar's horizontal month navigation.
  ///
  /// This widget highlights the current month in focus within the user interface.
  Widget showMonth(double screenWidth, double screenHeight, String month) {
    return Container(
        width: screenWidth * 0.14,
        height: screenHeight * 0.092,
        decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.30000001192092896),
            border: Border(
                bottom: BorderSide(
                    width: 2,
                    color: Colors.black.withOpacity(0.30000001192092896)))),
        child: Center(
            child: Text(month,
                textAlign: TextAlign.center,
                style: GoogleFonts.abrilFatface(
                    textStyle: TextStyle(
                        color: Colors.white.withOpacity(0.30000001192092896),
                        fontSize: screenWidth * 0.035,
                        fontWeight: FontWeight.w400,
                        letterSpacing: -0.13)),
                maxLines: 1)));
  }

  /// Displays vegetable details within a calendar month, including interactive elements for planting and harvesting.
  ///
  /// This method uses [CalendarModel] and [VegetableModel] to render the state of each vegetable across the displayed months.
  Widget showVegetable(double screenWidth, double screenHeight,
      VegetableModel vm, CalendarModel cm, int currentMonth, bool last) {
    final int plantStartMonth =
        calendarController.getMonthActivity(vm.plantStart);
    final int plantEndMonth = calendarController.getMonthActivity(vm.plantEnd);
    final int harvestStartMonth = (vm.harvestStart / 4.0)
        .ceil(); // Only begin x weeks (given by harvestStart) after the vegetable is planted
    final int harvestEndMonth = (vm.harvestEnd / 4.0).ceil();

    return Row(children: [
      Container(
          width: screenWidth * 0.15,
          height: screenHeight * 0.092,
          decoration: !last
              ? BoxDecoration(
                  color: Colors.white.withOpacity(0.30000001192092896),
                  border: Border(
                      right: BorderSide(
                          width: 2,
                          color:
                              Colors.black.withOpacity(0.30000001192092896))))
              : BoxDecoration(
                  color: Colors.white.withOpacity(0.30000001192092896),
                  border: Border(
                      right: BorderSide(
                          width: 2,
                          color:
                              Colors.black.withOpacity(0.30000001192092896))),
                  borderRadius:
                      const BorderRadius.only(bottomLeft: Radius.circular(25))),
          child: Center(
              child: Text(vm.vegetableName,
                  style: GoogleFonts.abrilFatface(
                      textStyle: TextStyle(
                          color: Colors.white.withOpacity(0.4399999976158142),
                          fontSize: screenWidth * 0.035,
                          fontWeight: FontWeight.w400,
                          letterSpacing: -0.13)),
                  maxLines: 1))),
      Dismissible(
          key: UniqueKey(),
          background:
              Container(color: Colors.black.withOpacity(0.44999998807907104)),
          movementDuration: const Duration(milliseconds: 200),
          dismissThresholds: const {
            DismissDirection.endToStart: 0.0,
            DismissDirection.startToEnd: 0.0,
          },
          onDismissed: (DismissDirection direction) {
            if (direction == DismissDirection.endToStart) {
              updateMonth(4);
            } else if (direction == DismissDirection.startToEnd) {
              updateMonth(-4);
            }
          },
          child: Row(
              children: Iterable<int>.generate(4)
                  .map((i) => showActivity(
                      screenWidth,
                      screenHeight,
                      vm.vegetableName,
                      vm.id,
                      currentMonth - 1 + i,
                      plantStartMonth,
                      plantEndMonth,
                      harvestStartMonth,
                      harvestEndMonth,
                      cm))
                  .toList())),
      showNote(screenWidth, screenHeight, selectedGardenName, cm.note, cm.id),
    ]);
  }

  /// Constructs an interactive area for each vegetable, allowing the user to track planting and harvesting activities.
  ///
  /// Uses animations and state management to provide feedback and control over the gardening activities.
  Widget showActivity(
      double screenWidth,
      double screenHeight,
      String vegetableName,
      int vegetableId,
      int currentMonth,
      int plantStartMonth,
      int plantEndMonth,
      int harvestStartMonth,
      int harvestEndMonth,
      CalendarModel cm) {
    Color? color = Colors.white.withOpacity(0.38999998569488525);
    final animationController = AnimationController(
        duration: const Duration(milliseconds: 200), vsync: this);

    final scaleAnimation =
        Tween<double>(begin: 1.0, end: 0.95).animate(animationController);

    final opacityAnimation =
        Tween<double>(begin: 1.0, end: 0.8).animate(animationController);

    // (1) Init plant and harvest regarding the model
    calendarController.init(cm);

    return Container(
        width: screenWidth * 0.142,
        height: screenHeight * 0.092,
        padding: EdgeInsets.symmetric(
            vertical: screenWidth * 0.03, horizontal: screenHeight * 0.01),
        decoration:
            BoxDecoration(color: Colors.black.withOpacity(0.44999998807907104)),
        child: GestureDetector(
            onTap: () {
              // (2) Does not concern any activity
              if (calendarController.isAllowed(color)) {
                return;
              }
              // (3) Vegetable to plant
              calendarController.isPlanted(plantStartMonth, plantEndMonth,
                  harvestStartMonth, harvestEndMonth, currentMonth, cm.id, cm);
              // (4) Vegetable to harvest
              calendarController.isHarvested(
                  harvestStartMonth, harvestEndMonth, currentMonth, cm.id);

              // rebuilds of the widget tree
              animationController.forward().then((_) {
                setState(() {});
              });
            },
            child: AnimatedBuilder(
                animation: animationController,
                builder: (context, child) {
                  // (5) Planted
                  color = calendarController.planted(plantStartMonth,
                      plantEndMonth, currentMonth, color, cm.id);

                  // (6) Growing
                  color = calendarController.growing(currentMonth,
                      harvestStartMonth, harvestEndMonth, color, cm.id);

                  // (7) Harvested
                  color = calendarController.harvested(harvestStartMonth,
                      harvestEndMonth, currentMonth, color, cm.id);

                  // Animation (scale + text) when button pushed
                  return Transform.scale(
                      scale: scaleAnimation.value,
                      child: Opacity(
                          opacity: opacityAnimation.value,
                          child: Container(
                              width: screenWidth * 0.142,
                              height: screenHeight * 0.092,
                              decoration: BoxDecoration(
                                  color: color,
                                  borderRadius: BorderRadius.circular(9),
                                  boxShadow: const [
                                    BoxShadow(
                                        color: Color(0x3F000000),
                                        blurRadius: 4,
                                        offset: Offset(0, 4),
                                        spreadRadius: 0),
                                  ]),
                              child: Center(
                                  child: Text(
                                      calendarController.isDone(
                                              cm.id, currentMonth)
                                          ? ' ${calendarController.getPrefixColor(color)} \nOK'
                                          : '${calendarController.getPrefixColor(color)}',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: screenHeight * 0.02,
                                          fontWeight: FontWeight.bold))))));
                })));
  }

  /// Provides an editable field for user notes associated with a garden's calendar entry.
  ///
  /// This widget facilitates the addition of notes to calendar entries, enhancing the tracking and management of gardening activities.
  Widget showNote(double screenWidth, double screenHeight, String gardenName,
      String notes, int calendarId) {
    return Container(
        width: screenWidth * 0.181,
        height: screenHeight * 0.092,
        padding: const EdgeInsets.symmetric(vertical: 11, horizontal: 10),
        decoration:
            BoxDecoration(color: Colors.black.withOpacity(0.44999998807907104)),
        child: Container(
            width: screenWidth * 0.18,
            height: screenHeight * 0.092,
            padding: const EdgeInsets.only(top: 2, left: 1, bottom: 2),
            decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.38999998569488525)),
            child: GestureDetector(
                onTap: () async {
                  bool edited = await notesDialog.show(
                      context,
                      screenWidth,
                      screenHeight,
                      'Calendar',
                      gardenName,
                      notes,
                      -1,
                      -1,
                      calendarId,
                      '',
                      '',
                      '',
                      '',
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
                      '',
                      -1,
                      -1,
                      -1);

                  if (edited) {
                    setState(() {
                      // Re-fetch the initial data
                      futureVegetables = vegetableController
                          .getVegetablesByGardenId(selectedGardenId);
                      futureCalendar = calendarController
                          .offlineFillCalendar(selectedGardenId);
                    });
                  }
                },
                child: Center(
                    child: Icon(Icons.add,
                        color: Colors.white, size: screenWidth * 0.065)))));
  }

  /// Displays a message to the user in the form of a snack bar.
  void showMessageSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), duration: const Duration(seconds: 2)));
  }
}

/// Displays an animated text button that allows users to navigate between months in the calendar.
///
/// This component visually indicates the current month range and provides quick navigation controls.
class AnimatedTextButton extends StatefulWidget {
  final VegetableController vegetableController;
  final int currentMonth;
  final double screenWidth;

  final Function(int delta)
      updateMonth; // Receive currentMonth from parent by passing the function in argument
  const AnimatedTextButton(
      {Key? key,
      required this.vegetableController,
      required this.currentMonth,
      required this.updateMonth,
      required this.screenWidth})
      : super(key: key);

  @override
  State<AnimatedTextButton> createState() => _AnimatedMonthButtonState();
}

/// Manages the state for the [AnimatedTextButton] component.
///
/// Handles user interactions for month navigation within the calendar view.
class _AnimatedMonthButtonState extends State<AnimatedTextButton> {
  _AnimatedMonthButtonState();

  @override
  void initState() {
    super.initState();
  }

  void _changeMonth(int delta) {
    widget.updateMonth(delta);
  }

  @override
  Widget build(BuildContext context) {
    return Row(mainAxisSize: MainAxisSize.min, children: [
      IconButton(
          icon: const Icon(Icons.chevron_left),
          onPressed: () => _changeMonth(-4)),
      AnimatedSwitcher(
          duration:
              const Duration(milliseconds: 300), // Adjust animation duration
          transitionBuilder: (child, animation) =>
              ScaleTransition(scale: animation, child: child),
          child: Text(
              'Month ${widget.currentMonth}-${(widget.currentMonth + 3)}', // Display month range
              style: GoogleFonts.abrilFatface(
                  textStyle: TextStyle(
                      fontSize: widget.screenWidth * 0.05,
                      color: Colors.black)))),
      IconButton(
          icon: const Icon(Icons.chevron_right),
          onPressed: () => _changeMonth(4)),
    ]);
  }
}

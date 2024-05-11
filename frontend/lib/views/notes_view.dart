import 'package:flutter/material.dart';
import 'dart:async';
import '../controllers/vegetable_controller.dart';
import '../controllers/plot_controller.dart';
import '../controllers/calendar_controller.dart';

/// A modal dialog for managing notes associated with garden elements like vegetables, plots,
/// or calendar events.
///
/// This dialog allows editing and saving notes, interacting with different controllers based on
/// the context in which it is used.
class NotesDialog {
  /// Displays the notes dialog and handles note editing and updating operations.
  ///
  /// Parameters allow for specification of the screen size, the relevant controller (vegetable,
  /// plot, or calendar), and identifiers and initial data for the element being edited.
  /// Returns a future that completes with a boolean indicating if changes were made.
  Future<bool> show(
      BuildContext context,
      double screenWidth,
      double screenHeight,
      String whichController,
      String gardenName,
      String notes,
      int vegetableId,
      int plotId,
      int calendarId,
      String vegetableName,
      String plotName,
      String oldVegetableName,
      String oldPlotName,
      int seedAvailability,
      int seedExpiration,
      int harvestStart,
      int harvestEnd,
      String plantStart,
      String plantEnd,
      int primaryCategoryId,
      int secondaryCategoryId,
      int oldPrimaryCategoryId,
      int oldSecondaryCategoryId,
      String plotPlantationLines,
      int plotVersion,
      int plotOrientation,
      int plotInCalendar) async {
    Completer<bool> completer = Completer<bool>();
    VegetableController vegetableController = VegetableController(
        (String message) => showMessageSnackBar(context, message));
    PlotController plotController = PlotController(
        (String message) => showMessageSnackBar(context, message));
    CalendarController calendarController = CalendarController(
        (String message) => showMessageSnackBar(context, message));
    TextEditingController notesController = TextEditingController(text: notes);
    bool isEditing = false;
    String editedNotes = notes;

    void toggleEdit() {
      isEditing = !isEditing;
      (context as Element).markNeedsBuild();
    }

    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return StatefulBuilder(builder: (context, setState) {
            return GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  FocusScope.of(context).requestFocus(FocusNode());
                },
                child: AlertDialog(
                    title: Center(
                        child: Text('Notes',
                            style: TextStyle(
                                fontSize: screenWidth * 0.05,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF5B8E55)))),
                    content: Scrollbar(
                        child: SingleChildScrollView(
                            child: TextField(
                                controller: notesController,
                                enabled: isEditing,
                                decoration: const InputDecoration(
                                    border: OutlineInputBorder()),
                                keyboardType: TextInputType.multiline,
                                maxLines: null,
                                onChanged: (value) {
                                  editedNotes = value;
                                  setState(() {});
                                }))),
                    actions: <Widget>[
                      TextButton(
                          child: Text('Close',
                              style: TextStyle(
                                  fontSize: screenWidth * 0.04,
                                  color: const Color(0xFF5B8E55))),
                          onPressed: () {
                            Navigator.of(context).pop();
                            completer.complete(editedNotes != notes);
                          }),
                      if (!isEditing)
                        TextButton(
                            child: Text('Edit',
                                style: TextStyle(
                                    fontSize: screenWidth * 0.04,
                                    color: const Color(0xFF5B8E55))),
                            onPressed: () {
                              setState(toggleEdit);
                            }),
                      if (isEditing)
                        TextButton(
                            child: Text('Save',
                                style: TextStyle(
                                    fontSize: screenWidth * 0.04,
                                    color: const Color(0xFF5B8E55))),
                            onPressed: () {
                              setState(() {
                                toggleEdit();

                                if (editedNotes == notes) {
                                  return;
                                }

                                switch (whichController) {
                                  case 'Vegetable':
                                    vegetableController.editVegetableNotes(
                                        vegetableId,
                                        vegetableName,
                                        seedAvailability,
                                        seedExpiration,
                                        harvestStart,
                                        harvestEnd,
                                        plantStart,
                                        plantEnd,
                                        primaryCategoryId,
                                        secondaryCategoryId,
                                        editedNotes,
                                        gardenName,
                                        oldVegetableName,
                                        oldPrimaryCategoryId,
                                        oldSecondaryCategoryId);
                                    break;
                                  case 'Plot':
                                    plotController.editPlotNotes(
                                        plotId,
                                        gardenName,
                                        plotName,
                                        plotPlantationLines,
                                        plotVersion,
                                        plotOrientation,
                                        plotInCalendar,
                                        editedNotes,
                                        oldPlotName);
                                    break;
                                  case 'Calendar':
                                    calendarController.editCalendareNotes(
                                        calendarId, editedNotes);
                                    break;
                                }
                              });
                            }),
                    ]));
          });
        });
    return completer.future;
  }

  /// Displays a message snackbar in the provided [context] with a specified [message].
  ///
  /// This method is used for feedback in the UI during operations such as note saving.
  void showMessageSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(message), duration: const Duration(seconds: 20)));
  }
}

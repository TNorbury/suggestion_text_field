import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'suggestion_text_field_controller.dart';

class SuggestionOverlay extends StatelessWidget {
  // The height of each suggestion
  static const double suggestionEntryHeight = 56.0;

  final BuildContext textFieldContext;
  final LayerLink layerLink;

  const SuggestionOverlay({
    @required this.textFieldContext,
    @required this.layerLink,
    key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<SuggestionTextFieldController>(
      builder: (context, controller, child) {
        List<String> suggestions = controller.suggestions;

        // The number of entries to display in the overlay
        int numEntries = min(5, suggestions.length);

        RenderBox renderBox = textFieldContext.findRenderObject();
        var size = renderBox.size;
        var offset = renderBox.localToGlobal(Offset.zero);

        MediaQueryData mq = MediaQuery.of(textFieldContext);

        Size screenSize = mq.size;

        double suggestionsFullHeight = mq.orientation == Orientation.landscape
            ? suggestionEntryHeight
            : suggestionEntryHeight * numEntries;

        double textFieldBottom = offset.dy + size.height;

        double maxHeight;
        var overlayOffset;
        final double screenSizeMinusKeyboard = screenSize.height * 0.75;

        // If the overlay would go off the screen by being
        // below the text field, we'll position it above it.
        if (textFieldBottom + suggestionsFullHeight >=
            screenSizeMinusKeyboard) {
          // This makes sure that the overlay would be go out of the
          // top of the screen
          maxHeight = min(offset.dy, suggestionsFullHeight);
          overlayOffset = -maxHeight;
        }

        // Otherwise, we'll display it below the text
        else {
          overlayOffset = size.height + 5.0;

          // This makes sure that the overlay won't be placed under the
          // keyboard
          maxHeight = min((screenSizeMinusKeyboard) - textFieldBottom - 75,
              suggestionsFullHeight);
        }

        return Visibility(
          visible: numEntries >= 1,
          child: Positioned(
            width: size.width / 2,
            child: CompositedTransformFollower(
              link: layerLink,
              showWhenUnlinked: false,
              offset: Offset(0.0, overlayOffset),
              child: ConstrainedBox(
                // Always shown at least one entry
                constraints: BoxConstraints(
                  minHeight: suggestionEntryHeight,
                  maxHeight: max(maxHeight, suggestionEntryHeight),
                ),
                child: Material(
                  elevation: 4.0,
                  child: ListView(
                    padding: EdgeInsets.zero,
                    shrinkWrap: true,
                    children: [
                      for (String suggestion in suggestions)
                        Material(
                          child: Container(
                            height: 56,
                            child: InkWell(
                              onTap: () {
                                // TODO: Tell controller that something was selected
                              },
                              child: Row(
                                children: [
                                  Text(suggestion),
                                ],
                              ),
                            ),
                          ),
                        )
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

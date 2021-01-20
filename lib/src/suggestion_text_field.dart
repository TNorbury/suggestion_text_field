import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:suggestion_text_field/src/suggestion_text_field_controller.dart';

import 'suggestion_overlay.dart';

typedef GetSuggestionsCallback = List<String> Function(String);

/// A text field that, when focused and text is entered in it, will show a list
/// of suggested items. Clicking on one of these suggested items will put that
/// value into the text field.
class SuggestionTextField extends StatefulWidget {
  /// Function that is called when the field is submitted. The contents of the
  /// field will be passed to this function.
  final Function(String) textSubmitted;

  /// Whenever the entered text changes, this function will be called and
  /// should return a list of strings that will be displayed in the suggestion
  /// menu
  final GetSuggestionsCallback getSuggestions;

  SuggestionTextField({
    @required this.getSuggestions,
    @required this.textSubmitted,
    Key key,
  }) : super(key: key);

  @override
  _SuggestionTextFieldState createState() => _SuggestionTextFieldState();
}

class _SuggestionTextFieldState extends State<SuggestionTextField> {
  SuggestionTextFieldController controller;

  OverlayEntry _overlayEntry;
  final LayerLink _layerLink = LayerLink();
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();

    controller =
        SuggestionTextFieldController(getSuggestions: widget.getSuggestions);

    _focusNode.addListener(_toggleOverlay);
  }

  @override
  void dispose() {
    _focusNode.dispose();
    controller.dispose();
    super.dispose();
  }

  /// Toggles the suggestion overlay.
  void _toggleOverlay() {
    if (_focusNode.hasFocus && controller.enteredText.isNotEmpty) {
      if (_overlayEntry == null) {
        setState(() {
          _overlayEntry = _createSuggestionOverlayEntry();
          Overlay.of(context).insert(_overlayEntry);
        });
      }
    } else {
      if (_overlayEntry != null) {
        _overlayEntry.remove();

        _overlayEntry = null;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: TextField(
        focusNode: _focusNode,
        decoration:
            InputDecoration(hintText: "Enter a tag and press enter to add"),
        controller: controller.textEditingController,
        onChanged: (enteredText) {
          controller.textChanged();
          _toggleOverlay();
        },
        onSubmitted: (enteredText) {
          widget.textSubmitted?.call(controller.enteredText);
          controller.clearText();
        },
      ),
    );
  }

  /// Creates the overlay entry that has all the suggestions (this will be
  /// invisible if there aren't any suggestions returned by [getSuggestions])
  OverlayEntry _createSuggestionOverlayEntry() {
    BuildContext parentContext = context;

    return OverlayEntry(
      builder: (context) {
        return ChangeNotifierProvider.value(
          value: controller,
          builder: (context, child) {
            // Every time the text entered in the text field changes, we'll
            // rebuild the overlay
            return SuggestionOverlay(
              textFieldContext: parentContext,
              layerLink: _layerLink,
            );
          },
        );
      },
    );
  }
}

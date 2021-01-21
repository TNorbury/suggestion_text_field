import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:suggestion_text_field/src/suggestion_text_field_controller.dart';

import 'suggestion_overlay.dart';

typedef GetSuggestionsCallback = List<String> Function(String);
typedef FieldSubmittedCallback = void Function(String);

/// The action that should be performed when a suggestion is selected
enum SuggestionSelectionAction {
  /// The selected suggestion is set at the value of the text field.
  Insert,

  /// Submits the selection and clear the text field
  Submit,
}

/// A text field that, when focused and text is entered in it, will show a list
/// of suggested items. Clicking on one of these suggested items will put that
/// value into the text field.
class SuggestionTextField extends StatefulWidget {
  /// Function that is called when the field is submitted. The contents of the
  /// field will be passed to this function.
  final FieldSubmittedCallback textSubmitted;

  /// Whenever the entered text changes, this function will be called and
  /// should return a list of strings that will be displayed in the suggestion
  /// menu
  final GetSuggestionsCallback getSuggestions;

  /// Defines what happens when a suggestion is selected from the overlay.
  /// Default is [SuggestionSelectionAction.Insert]
  final SuggestionSelectionAction selectionAction;

  /// Sets [TextField.style]
  final TextStyle style;

  /// Sets [TextField.decoration]
  final InputDecoration decoration;

  SuggestionTextField({
    @required this.getSuggestions,
    @required this.textSubmitted,
    this.selectionAction = SuggestionSelectionAction.Insert,
    this.style,
    this.decoration,
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

    controller = SuggestionTextFieldController(
      getSuggestions: widget.getSuggestions,
      selectionAction: widget.selectionAction,
      fieldSubmittedCallback: _submitField,
    );

    _focusNode.addListener(_toggleOverlay);
  }

  @override
  void dispose() {
    _focusNode.dispose();
    // controller.dispose();
    super.dispose();
  }

  /// Submits the text given to this method and clear the input
  void _submitField(String enteredText) {
    widget.textSubmitted?.call(enteredText);
    controller.clearText();
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
        style: widget.style,
        focusNode: _focusNode,
        decoration: widget.decoration,
        controller: controller.textEditingController,
        onChanged: (enteredText) {
          controller.textChanged();
          _toggleOverlay();
        },
        onSubmitted: _submitField,
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

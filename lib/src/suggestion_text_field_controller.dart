import 'package:flutter/material.dart';

import 'suggestion_text_field.dart';

/// Used internally by the text field.
class SuggestionTextFieldController extends ChangeNotifier {
  final GetSuggestionsCallback _getSuggestions;

  final TextEditingController textEditingController = TextEditingController();

  final SuggestionSelectionAction _selectionAction;
  final FieldSubmittedCallback _textSubmitted;

  List<String> _suggestions = [];

  SuggestionTextFieldController({
    @required GetSuggestionsCallback getSuggestions,
    @required SuggestionSelectionAction selectionAction,
    @required FieldSubmittedCallback fieldSubmittedCallback,
  })  : _getSuggestions = getSuggestions,
        _selectionAction = selectionAction,
        _textSubmitted = fieldSubmittedCallback;

  @override
  void dispose() {
    textEditingController.dispose();
    super.dispose();
  }

  /// Get the text currently entered into the text field
  String get enteredText => textEditingController.text;

  void textChanged() {
    _suggestions = _getSuggestions(textEditingController.text);
    notifyListeners();
  }

  void clearText() {
    textEditingController.text = "";
    notifyListeners();
  }

  /// Get the current list of suggestions, based upon the currently entered
  /// text.
  List<String> get suggestions {
    return _suggestions;
  }

  /// Handles a suggestion being selected. The behavior is dictated by the given
  /// [SuggestionSelectionAction]
  void suggestionSelected(String suggestion) {
    switch (_selectionAction) {
      case SuggestionSelectionAction.Insert:
        textEditingController.value = TextEditingValue(
          text: suggestion,
          selection: TextSelection.collapsed(offset: suggestion.length),
        );
        textChanged();
        break;
      case SuggestionSelectionAction.Submit:
        _textSubmitted(suggestion);
        break;
    }
  }
}

import 'package:flutter/material.dart';

import 'suggestion_text_field.dart';

class SuggestionTextFieldController extends ChangeNotifier {
  final GetSuggestionsCallback _getSuggestions;

  final TextEditingController textEditingController = TextEditingController();

  List<String> _suggestions = [];

  SuggestionTextFieldController(
      {@required GetSuggestionsCallback getSuggestions})
      : _getSuggestions = getSuggestions {}

  @override
  void dispose() {
    textEditingController.dispose();
    super.dispose();
  }

  /// Get the text currently entered into the text field
  String get enteredText => textEditingController.text;

  void textChanged() {
    _suggestions = _getSuggestions(textEditingController.text);
  }

  void clearText() {
    // _enteredText.value = "";
    textEditingController.text = "";
  }

  /// Get the current list of suggestions, based upon the currently entered
  /// text.
  List<String> get suggestions {
    return _suggestions;
  }
}

import 'package:dialog_flowtter/dialog_flowtter.dart';
import 'package:logger/logger.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';

class ChatbotService {
  static DialogFlowtter? _flowtter;
  static final Logger _logger = Logger();

  static Future<void> _init() async {
    if (_flowtter == null) {
      // Încarcă credentials din assets
      final String jsonStr = await rootBundle.loadString('assets/dialog_flow_auth.json');
      final Map<String, dynamic> credentials = json.decode(jsonStr);
      _flowtter = DialogFlowtter(credentials: DialogAuthCredentials.fromJson(credentials));
    }
  }

  static Future<String> getResponse(String query, {String languageCode = 'ro'}) async {
    try {
      await _init();
      final response = await _flowtter!.detectIntent(
        queryInput: QueryInput(
          text: TextInput(
            text: query,
            languageCode: languageCode,
          ),
        ),
      );
      return response.text ??
          (languageCode == 'ro'
              ? "Nu am înțeles întrebarea."
              : "I didn't understand the question.");
    } catch (e, st) {
      _logger.e("Eroare Chatbot: $e\n$st");
      return languageCode == 'ro'
          ? "Eroare la comunicarea cu chatbotul."
          : "Error communicating with the chatbot.";
    }
  }
}

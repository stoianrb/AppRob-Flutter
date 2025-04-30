import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:logger/logger.dart';

class SpeechToTextService {
  static final stt.SpeechToText _speech = stt.SpeechToText();
  static final Logger _logger = Logger();  // Crează instanța de Logger

  // Inițializare
  static Future<bool> initialize() async {
    return await _speech.initialize();
  }

  // Înregistrare și procesare vocală
  static Future<String> listen() async {
    bool available = await _speech.listen(onResult: (result) {
      _logger.i(result.recognizedWords);  // Folosește logger pentru a înregistra cuvintele recunoscute
    });
    return available ? 'Listening' : 'Failed to listen';
  }

  // Oprire înregistrare vocală
  static void stop() {
    _speech.stop();
  }
}

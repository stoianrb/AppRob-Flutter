import 'dart:io'; // Pentru a lucra cu fișiere
import 'package:dialogflow_grpc/dialogflow_grpc.dart'; // Pachetul Dialogflow
import 'package:googleapis_auth/googleapis_auth.dart'; // Autentificare
import 'package:logger/logger.dart'; // Logare erori

class ChatbotService {
  static final Logger _logger = Logger();

  // ignore: non_constant_identifier_names
  Future<String> getResponse(String query, dynamic DialogflowGrpc) async {
    try {
      // Crează clientul pentru autentificare cu Dialogflow
      final credentials = ServiceAccountCredentials.fromJson(
        await File('assets/robert-50493-6a8056646681.json').readAsString(),
      );

      // Obține un client de autentificare
      final authClient = await clientViaServiceAccount(
        credentials,
        [DialogflowGrpc.v2beta1Scope], // Utilizează corectul scope pentru Dialogflow
      );

      // Initializează Dialogflow cu clientul de autentificare
      final dialogflow = DialogflowGrpc(authClient: authClient); // Corectarea instanțierii

      // Detectează intenția pe baza inputului utilizatorului
      final response = await dialogflow.detectIntent(query);

      // Returnează mesajul obținut din răspuns
      return response.getMessage() ?? "Nu am înțeles mesajul.";
    } catch (e) {
      _logger.e("Error: $e");
      return "Eroare la comunicarea cu chatbotul.";
    }
  }
}

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class GDPRConsent extends StatelessWidget {
  final ValueChanged<bool> onConsent;

  const GDPRConsent({super.key, required this.onConsent});

  void _launchGDPR() async {
    final Uri url = Uri.parse('https://eur-lex.europa.eu/legal-content/RO/TXT/?uri=CELEX%3A32016R0679');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      debugPrint("Could not launch $url");
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('GDPR Consent'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Please accept our GDPR terms to continue using the app.',
            style: TextStyle(fontSize: 18),
          ),
          const SizedBox(height: 10),
          InkWell(
            onTap: _launchGDPR,
            child: const Text(
              'Read GDPR Law',
              style: TextStyle(color: Colors.blue, decoration: TextDecoration.underline),
            ),
          ),
        ],
      ),
      actionsAlignment: MainAxisAlignment.center, // Centrare acțiuni
      actions: [
        GestureDetector(
          onTap: () {
            onConsent(false);
            Navigator.pop(context);
          },
          child: const Padding(
            padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
            child: Text(
              'Reject',
              style: TextStyle(color: Colors.blue, decoration: TextDecoration.underline, fontSize: 16),
            ),
          ),
        ),
        const SizedBox(width: 20), // Spațiu între butoane
        GestureDetector(
          onTap: () {
            onConsent(true);
            Navigator.pop(context);
          },
          child: const Padding(
            padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
            child: Text(
              'Accept',
              style: TextStyle(color: Colors.blue, decoration: TextDecoration.underline, fontSize: 16),
            ),
          ),
        ),
      ],
    );
  }
}

void main() {
  runApp(const MaterialApp(
    home: Scaffold(body: Center(child: Text('GDPR Test'))),
  ));
}

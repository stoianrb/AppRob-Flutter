import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:approb/src/utils/constants.dart';

class DeleteRequestScreen extends StatelessWidget {
  const DeleteRequestScreen({super.key});

  void _sendEmail(BuildContext context) async {
  final Uri emailLaunchUri = Uri(
    scheme: 'mailto',
    path: kContactEmail,
    query: Uri.encodeFull(
      'subject=Solicitare ștergere date&body=Vă rog să îmi ștergeți datele conform GDPR.',
    ),
  );

  try {
    // Încearcă cu aplicația Gmail dacă e disponibilă
    final gmailUri = Uri.parse(
        'googlegmail://co?to=$kContactEmail&subject=${Uri.encodeComponent("Solicitare ștergere date")}&body=${Uri.encodeComponent("Vă rog să îmi ștergeți datele conform GDPR.")}');

    if (await canLaunchUrl(gmailUri)) {
      await launchUrl(gmailUri);
    } else if (await canLaunchUrl(emailLaunchUri)) {
      await launchUrl(emailLaunchUri);
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Nu s-a putut deschide aplicația de email.")),
        );
      }
    }
  } catch (_) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Eroare: Nu s-a putut trimite emailul.")),
      );
    }
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Ștergere date personale"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Conform regulamentului GDPR, ai dreptul să soliciți ștergerea datelor tale.",
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () => _sendEmail(context),
              icon: const Icon(Icons.email),
              label: const Text("Trimite solicitare prin email"),
            ),
          ],
        ),
      ),
    );
  }
}

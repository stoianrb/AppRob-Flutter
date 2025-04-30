import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:approb/src/utils/constants.dart';

class PrivacyPolicyScreen extends StatefulWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  PrivacyPolicyScreenState createState() => PrivacyPolicyScreenState();
}

class PrivacyPolicyScreenState extends State<PrivacyPolicyScreen> {
  void _sendEmail(BuildContext context) async {
    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: kContactEmail,
      query: 'subject=${Uri.encodeComponent('Solicitare ștergere date personale - Approb')}',
    );
    if (await canLaunchUrl(emailLaunchUri)) {
      await launchUrl(emailLaunchUri);
    } else {
      if (!mounted) return; // Check if widget is still mounted before showing snackBar
      // ignore: use_build_context_synchronously
      _showSnackBar(context, 'Nu am putut deschide aplicația de email.');
    }
  }

  void _openGdprLaw(BuildContext context) async {
    final uri = Uri.parse(kGdprUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (!mounted) return; // Check if widget is still mounted before showing snackBar
      // ignore: use_build_context_synchronously
      _showSnackBar(context, 'Nu am putut deschide linkul.');
    }
  }

  void _showSnackBar(BuildContext context, String message) {
    if (!mounted) return; // Make sure the widget is still mounted before showing snackBar
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Politica de confidențialitate'),
        backgroundColor: kPrimaryColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '🔐 Confidențialitate și protecția datelor',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              const Text(
                'Aplicația Approb permite programări, lăsarea de recenzii și vizualizarea unei galerii video. '
                'Nu colectăm date cu caracter personal precum nume complet, adresă de email sau număr de telefon. '
                'Recenziile conțin doar mesajul utilizatorului și ratingul oferit. Programările se bazează exclusiv '
                'pe ora, data și serviciul selectat, fără informații de identificare.',
              ),
              const SizedBox(height: 16),
              const Text(
                '🎥 Videoclipuri cu clienți',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const Text(
                'Toate videoclipurile din aplicație sunt publice și publicate cu acordul verbal al clienților. '
                'Dacă ești într-unul din videoclipuri și dorești ca acel conținut să fie eliminat, te rugăm să ne contactezi folosind butonul de mai jos.',
              ),
              const SizedBox(height: 16),
              const Text(
                '🛡️ Drepturile tale',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const Text(
                'Conform GDPR, ai dreptul de a solicita:\n'
                '- Acces la datele tale (dacă ar exista)\n'
                '- Rectificarea datelor\n'
                '- Ștergerea datelor\n\n'
                'Pentru a face o solicitare, apasă butonul de mai jos pentru a trimite un email.',
              ),
              const SizedBox(height: 20),
              Center(
                child: ElevatedButton.icon(
                  onPressed: () => _sendEmail(context),
                  icon: const Icon(Icons.mail_outline),
                  label: const Text('Trimite cerere prin email'),
                ),
              ),
              const SizedBox(height: 30),
              const Text(
                '📜 Legea GDPR',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              InkWell(
                onTap: () => _openGdprLaw(context),
                child: const Text(
                  'Citește legea oficială aici',
                  style: TextStyle(
                    color: Colors.blueAccent,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
              const SizedBox(height: 30),
              const Divider(),
              const Text(
                '⚖️ Disclaimer',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const Text(
                kDisclaimer,
                style: TextStyle(fontSize: 13),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


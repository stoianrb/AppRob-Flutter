import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:animate_do/animate_do.dart' as anim;
import 'package:approb/src/utils/constants.dart';

class LocationsContact extends StatefulWidget {
  const LocationsContact({super.key});

  @override
  LocationsContactState createState() => LocationsContactState();
}

class LocationsContactState extends State<LocationsContact> {
  String address =
      'Șoseaua Pantelimon 309, Salon Eduard Forfecuta, Robert Frizeru';
  String phoneNumber = '0770867356';
  String language = 'en';

 

  void openMap() async {
    final Uri googleMapsUri = Uri.parse(
        "https://www.google.com/maps/place/Robert_Frizeru%E2%80%99/@44.4418089,26.1766787,19z/data=!4m6!3m5!1s0x40b1f9cc0811ffc1:0x9c9c88662f94740e!8m2!3d44.4417898!4d26.1773493!16s%2Fg%2F11tcx5pqcn?entry=ttu");

    if (await canLaunchUrl(googleMapsUri)) {
      await launchUrl(googleMapsUri, mode: LaunchMode.externalApplication);
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Eroare: Nu s-a putut deschide Google Maps!")),
      );
    }
  }

  void handlePhonePress() async {
    final Uri phoneUri = Uri.parse('tel:$phoneNumber');
    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Eroare: Nu se poate efectua apelul!")),
      );
    }
  }

  void toggleLanguage() {
    setState(() {
      language = (language == 'en') ? 'ro' : 'en';
    });
  }

  @override
  Widget build(BuildContext context) {
    final content = Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        anim.FadeInDown(
          child: Text(
            language == 'en' ? 'Contact Us' : 'Contactează-ne',
            style: kHeadingStyle,  // Folosim stilul definit în constants.dart
          ),
        ),
        const SizedBox(height: kDefaultPadding),  // Folosim padding-ul din constants.dart
        _buildCard(
          anim.SlideInLeft(
            child: _buildTextCard(
              language == 'en' ? 'Address:' : 'Adresă:',
              address,
              color: kAccentColor,  // Folosim culoarea definită în constants.dart
            ),
          ),
        ),
        const SizedBox(height: kDefaultPadding),
        _buildCard(
          anim.SlideInRight(
            child: GestureDetector(
              onTap: handlePhonePress,
              child: _buildText(
                '📞 ${language == 'en' ? "Contact: Robert" : "Telefon: Robert"} - $phoneNumber',
              ),
            ),
          ),
        ),
        const SizedBox(height: kDefaultPadding),
        _buildCard(
          anim.SlideInUp(
            child: _buildWorkingHours(),
          ),
        ),
        const SizedBox(height: kDefaultPadding),
        anim.ZoomIn(
          child: ElevatedButton.icon(
            onPressed: openMap,
            icon: const Icon(Icons.map),
            label: Text(language == 'en' ? 'Open Map' : 'Deschide harta'),
          ),
        ),
        const SizedBox(height: kDefaultPadding),
      ],
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(language == 'en' ? 'Locations & Contact' : 'Locații & Contact'),
        backgroundColor: kPrimaryColor,  // Folosim culoarea definită în constants.dart
        actions: [
          IconButton(
            icon: const Icon(Icons.language),
            onPressed: toggleLanguage,
            tooltip: 'Change Language',
          ),
        ],
      ),
      body: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        color: kBackgroundDark,  // Folosim culoarea de fundal definită în constants.dart
        child: Center(
          child: SingleChildScrollView(
            child: content,
          ),
        ),
      ),
    );
  }

  Widget _buildCard(Widget child) {
    return Card(
      color: Colors.black.withAlpha(180),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(kBorderRadius)),  // Folosim border-radius-ul definit
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: Padding(padding: const EdgeInsets.all(kDefaultPadding), child: child),
    );
  }

  Widget _buildTextCard(String title, String value, {Color color = Colors.white}) {
    return Column(
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          value,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 18,
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildText(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 18,
        color: Colors.white,
        decoration: TextDecoration.underline,
      ),
    );
  }

  Widget _buildWorkingHours() {
    return Column(
      children: [
        Text(
          language == 'en' ? 'Working Hours' : 'Program',
          style: const TextStyle(
            fontSize: 24,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),
        ...[ 
          language == 'en' ? 'Monday - Friday: 09:00 - 20:00' : 'Luni - Vineri: 09:00 - 20:00',
          language == 'en' ? 'Saturday: 09:00 - 19:00' : 'Sâmbătă: 09:00 - 19:00',
          language == 'en' ? 'Sunday: 09:00 - 15:00' : 'Duminică: 09:00 - 15:00',
        ].map((day) => Text(day, style: const TextStyle(fontSize: 18, color: Colors.white))),
      ],
    );
  }
}

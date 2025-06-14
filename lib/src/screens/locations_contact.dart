// MODERNIZED LOCATIONS & CONTACT SCREEN
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
  String address = 'Șoseaua Pantelimon 309, Salon Eduard Forfecuta, Robert Frizeru';
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
    return Scaffold(
      backgroundColor: kBackgroundDark,
      appBar: AppBar(
        title: Text(language == 'en' ? 'Locations & Contact' : 'Locații & Contact'),
        backgroundColor: kPrimaryColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.language),
            onPressed: toggleLanguage,
            tooltip: 'Change Language',
          ),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              anim.FadeInDown(
                duration: const Duration(milliseconds: 500),
                child: Text(
                  language == 'en' ? 'Visit Us' : 'Vizitează-ne',
                  style: kHeadingStyle.copyWith(fontSize: 28),
                ),
              ),
              const SizedBox(height: kDefaultPadding * 1.5),
              anim.SlideInLeft(
                child: _infoTile(
                  icon: Icons.location_on,
                  title: language == 'en' ? 'Address' : 'Adresă',
                  subtitle: address,
                  onTap: openMap,
                ),
              ),
              const SizedBox(height: kDefaultPadding),
              anim.SlideInRight(
                child: _infoTile(
                  icon: Icons.phone,
                  title: language == 'en' ? 'Call Robert' : 'Sună-l pe Robert',
                  subtitle: phoneNumber,
                  onTap: handlePhonePress,
                ),
              ),
              const SizedBox(height: kDefaultPadding),
              anim.SlideInUp(
                child: _infoTile(
                  icon: Icons.schedule,
                  title: language == 'en' ? 'Working Hours' : 'Program',
                  subtitle: _workingHoursText(),
                  isMultiline: true,
                ),
              ),
              const SizedBox(height: kDefaultPadding * 1.5),
              anim.ZoomIn(
                child: ElevatedButton.icon(
                  onPressed: openMap,
                  icon: const Icon(Icons.map),
                  label: Text(language == 'en' ? 'Open Map' : 'Deschide Harta'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kAccentColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                    textStyle: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoTile({
    required IconData icon,
    required String title,
    required String subtitle,
    bool isMultiline = false,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Card(
        color: const Color.fromARGB(204, 0, 0, 0), // 0.8 * 255 = 204

        elevation: 6,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(kBorderRadius)),
        child: Padding(
          padding: const EdgeInsets.all(kDefaultPadding),
          child: Row(
            children: [
              Icon(icon, color: kAccentColor, size: 30),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),
                    Text(
                      subtitle,
                      style: const TextStyle(color: Colors.white70, fontSize: 16),
                      maxLines: isMultiline ? null : 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  String _workingHoursText() {
    return [
      language == 'en' ? 'Mon-Fri: 09:00 - 20:00' : 'Luni-Vineri: 09:00 - 20:00',
      language == 'en' ? 'Saturday: 09:00 - 19:00' : 'Sâmbătă: 09:00 - 19:00',
      language == 'en' ? 'Sunday: 09:00 - 15:00' : 'Duminică: 09:00 - 15:00',
    ].join("\n");
  }
}

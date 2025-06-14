import 'package:firebase_core/firebase_core.dart';
import 'package:approb/src/firebase/firebase_options.dart';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:approb/src/screens/calendar_screen.dart';
import 'package:approb/src/screens/locations_contact.dart';
import 'package:approb/src/screens/reviews_screen.dart';
import 'package:approb/src/screens/video_gallery_screen.dart';
import 'package:approb/src/screens/admin_login_screen.dart';
import 'package:approb/src/screens/privacy_policy_screen.dart';
import 'package:approb/src/screens/delete_request_screen.dart';
import 'package:approb/src/utils/constants.dart';
import 'package:approb/src/screens/chat_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  final prefs = await SharedPreferences.getInstance();
  final savedTheme = prefs.getString("theme") ?? "dark";

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  runApp(MyApp(
    initialThemeMode: savedTheme == "dark" ? ThemeMode.dark : ThemeMode.light,
  ));
}

class MyApp extends StatefulWidget {
  final ThemeMode initialThemeMode;
  const MyApp({super.key, required this.initialThemeMode});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late ThemeMode _themeMode;

  @override
  void initState() {
    super.initState();
    _themeMode = widget.initialThemeMode;
  }

  void toggleTheme() async {
    setState(() {
      _themeMode =
          _themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    });
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        "theme", _themeMode == ThemeMode.dark ? "dark" : "light");
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Approbb',
      debugShowCheckedModeBanner: false,
      themeMode: _themeMode,
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      initialRoute: '/',
      routes: {
        '/': (context) => HomeScreen(onToggleTheme: toggleTheme),
        '/calendar_screen': (context) => const CalendarScreen(),
        '/location_contact': (context) => const LocationsContact(),
        '/reviews': (context) => const ReviewsScreen(),
        '/videos': (context) => const VideoGalleryScreen(),
        '/admin_login': (context) => const AdminLoginScreen(),
        '/privacy_policy': (context) => const PrivacyPolicyScreen(),
        '/delete_request': (context) => const DeleteRequestScreen(),
        '/chat_screen': (context) => const ChatScreen(),
      },
    );
  }
}

class HomeScreen extends StatefulWidget {
  final VoidCallback onToggleTheme;
  const HomeScreen({super.key, required this.onToggleTheme});

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  String language = 'ro';
  late Map<String, Map<String, String>> translations;

  @override
  void initState() {
    super.initState();
    translations = {
      'ro': {
        'appointments': '📅 Programări',
        'locations': '📍 Locații & Contact',
        'reviews': '⭐ Recenzii',
        'videos': '🎬 Video Galerie',
        'gdprLaw': '📜 Legea GDPR',
        'deleteRequest': '✉️ Solicitare ștergere date',
        'disclaimer':
            'Aplicația este oferită „ca atare”. Nu ne asumăm responsabilitatea pentru eventuale erori, buguri sau crash-uri. Utilizarea aplicației se face pe propriul risc.',
        'theme': '🌓 Tema',
        'gdprTitle': 'GDPR',
        'gdprContent':
            'Acceptați termenii și condițiile aplicației?\n\nPrin accept, sunteți de acord cu procesarea datelor anonime pentru recenzii și programări.',
        'privacyPolicy': '📄 Politica de confidențialitate',
        'gdprLawOfficial': '🔒 Legea GDPR (oficial)',
        'decline': 'Refuz',
        'accept': 'Accept',
        'appCloseMsg': 'Ai refuzat termenii. Aplicația se închide.',
      },
      'en': {
        'appointments': '📅 Appointments',
        'locations': '📍 Locations & Contact',
        'reviews': '⭐ Reviews',
        'videos': '🎬 Video Gallery',
        'gdprLaw': '📜 GDPR Law',
        'deleteRequest': '✉️ Data Deletion Request',
        'disclaimer':
            'The app is provided "as is". We are not responsible for any bugs, errors, or crashes. Use the app at your own risk.',
        'theme': '🌓 Theme',
        'gdprTitle': 'GDPR',
        'gdprContent':
            'Do you accept the app\'s terms and conditions?\n\nBy accepting, you agree to the processing of anonymous data for reviews and appointments.',
        'privacyPolicy': '📄 Privacy Policy',
        'gdprLawOfficial': '🔒 GDPR Law (official)',
        'decline': 'Decline',
        'accept': 'Accept',
        'appCloseMsg': 'You declined the terms. The app will now close.',
      },
    };
    _initialize();
  }

  Future<void> _initialize() async {
    await _checkPermissions();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showGdprDialog();
    });
  }

  void toggleLanguage() {
    setState(() {
      language = (language == 'en') ? 'ro' : 'en';
    });
  }

  Future<void> _checkPermissions() async {
    if (!kIsWeb) {
      final status = await Permission.notification.status;
      if (status.isDenied) {
        await Permission.notification.request();
      }
    }
  }

  void _showGdprDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        title: Text(translations[language]!['gdprTitle']!),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              translations[language]!['gdprContent']!,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/privacy_policy');
                },
                child: Text(
                  translations[language]!['privacyPolicy']!,
                  style: const TextStyle(decoration: TextDecoration.underline),
                ),
              ),
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton(
                onPressed: () async {
                  final uri = Uri.parse(kGdprUrl);
                  if (await canLaunchUrl(uri)) {
                    await launchUrl(uri, mode: LaunchMode.externalApplication);
                  }
                },
                child: Text(
                  translations[language]!['gdprLawOfficial']!,
                  style: const TextStyle(decoration: TextDecoration.underline),
                ),
              ),
            ),
          ],
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          TextButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                    content: Text(translations[language]!['appCloseMsg']!)),
              );
              Future.delayed(const Duration(milliseconds: 800), () {
                if (!mounted) return; // <-- verificare adăugată
                if (kIsWeb) {
                  Navigator.of(context, rootNavigator: true)
                      .popUntil((route) => route.isFirst);
                  // pentru web poți ascunde totul sau redirecționa
                } else {
                  SystemNavigator.pop();
                }
              });
            },
            child: Text(translations[language]!['decline']!,
                style: const TextStyle(color: Colors.red)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext);
            },
            child: Text(translations[language]!['accept']!),
          ),
        ],
      ),
    );
  }

  void _openUrl(String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null) return;
    try {
      final canLaunchIt = await canLaunchUrl(uri);
      if (canLaunchIt) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (_) {}
  }

  Future<void> _handleAdminTap() async {
    final prefs = await SharedPreferences.getInstance();
    final isAdmin = prefs.getBool("isAdmin") ?? false;

    if (isAdmin) {
      await prefs.setBool("isAdmin", false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Ai ieșit din modul admin.")),
      );
    } else {
      if (!mounted) return;
      Navigator.pushNamed(context, '/admin_login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onDoubleTap: _handleAdminTap,
      child: Scaffold(
        body: Stack(
          children: [
            Container(color: const Color.fromRGBO(105, 105, 105, 0.85)),
            Positioned(
              top: 40,
              right: 20,
              child: Row(
                children: [
                  ElevatedButton(
                    onPressed: toggleLanguage,
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black54),
                    child: Text(language == 'ro' ? 'EN' : 'RO'),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: widget.onToggleTheme,
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black54),
                    child: Text(translations[language]!['theme']!),
                  ),
                ],
              ),
            ),
            Center(
              child: SingleChildScrollView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    for (var key in [
                      'appointments',
                      'locations',
                      'reviews',
                      'videos'
                    ])
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: SizedBox(
                          width: 250,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: () {
                              final routes = {
                                'appointments': '/calendar_screen',
                                'locations': '/location_contact',
                                'reviews': '/reviews',
                                'videos': '/videos'
                              };
                              Navigator.pushNamed(context, routes[key]!);
                            },
                            child: Text(translations[language]![key]!,
                                style: const TextStyle(fontSize: 16)),
                          ),
                        ),
                      ),
                    // Chatbot AI Button
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: SizedBox(
                        width: 250,
                        height: 50,
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.chat),
                          label: const Text('Chatbot AI'),
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const ChatScreen(),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        {
                          'icon': FontAwesomeIcons.instagram,
                          'color': Colors.pink,
                          'url': 'https://www.instagram.com/robert_frizerul'
                        },
                        {
                          'icon': FontAwesomeIcons.facebook,
                          'color': Colors.blue,
                          'url': 'https://www.facebook.com/stoian.robert.547'
                        },
                        {
                          'icon': FontAwesomeIcons.youtube,
                          'color': Colors.red,
                          'url': 'https://www.youtube.com/@Robert_Stoian'
                        },
                        {
                          'icon': FontAwesomeIcons.tiktok,
                          'color': Colors.white,
                          'url': 'https://www.tiktok.com/@robert_stoian'
                        },
                      ]
                          .map((data) => Tooltip(
                                message: data['url'] as String,
                                child: GestureDetector(
                                  onTapDown: (_) =>
                                      _openUrl(data['url'] as String),
                                  child: IconButton(
                                    icon: FaIcon(data['icon'] as IconData,
                                        color: data['color'] as Color),
                                    onPressed: () =>
                                        _openUrl(data['url'] as String),
                                  ),
                                ),
                              ))
                          .toList(),
                    ),
                    const SizedBox(height: 30),
                    InkWell(
                      onTap: () => _openUrl(kGdprUrl),
                      child: Text(
                        translations[language]!['gdprLaw']!,
                        style: const TextStyle(
                          decoration: TextDecoration.underline,
                          color: Colors.blueAccent,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    InkWell(
                      onTap: () =>
                          Navigator.pushNamed(context, '/delete_request'),
                      child: Text(
                        translations[language]!['deleteRequest']!,
                        style: const TextStyle(
                          decoration: TextDecoration.underline,
                          color: Colors.redAccent,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      kCopyright,
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      translations[language]!['disclaimer']!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

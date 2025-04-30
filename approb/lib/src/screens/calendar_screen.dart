import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:logger/logger.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  CalendarScreenState createState() => CalendarScreenState();
}

class CalendarScreenState extends State<CalendarScreen> {
  DateTime? selectedDate;
  DateTime focusedDay = DateTime.now();
  TimeOfDay? selectedTime;
  String? selectedService;
  String selectedWeekType = 'Săptămâna 1 (Marți, Joi, Sâmbătă, Duminică)';
  String language = 'en';
  bool isLoading = false;
  bool hasMore = true;
  bool _isAdmin = false;
  DocumentSnapshot? lastDocument;
  final List<Map<String, dynamic>> _appointments = [];
  final List<String> _reservedTimes = [];
  final int pageSize = 10;

  final Logger logger = Logger();

  final List<String> weekOptions = [
    'Automat (în funcție de par/impar)',
    'Săptămâna 1 (Marți, Joi, Sâmbătă, Duminică)',
    'Săptămâna 2 (Luni, Miercuri, Vineri)',
  ];

  final Map<String, Map<String, String>> translations = {
    'choose_service': {'en': 'Choose Service', 'ro': 'Alege Serviciul'},
    'choose_date': {'en': 'Choose Date', 'ro': 'Alege Data'},
    'choose_time': {'en': 'Choose Time', 'ro': 'Alege Ora'},
    'save_appointment': {'en': 'Save Appointment', 'ro': 'Salvează Programare'},
    'appointment_deleted': {
      'en': 'Appointment deleted!',
      'ro': 'Programare ștearsă!'
    },
    'appointment_saved': {
      'en': 'Appointment saved!',
      'ro': 'Programare salvată cu succes!'
    },
    'fill_fields': {
      'en': 'Please complete all fields!',
      'ro': 'Completați toate câmpurile!'
    },
    'already_reserved': {
      'en': 'This time is already booked!',
      'ro': 'Această oră este deja rezervată!'
    },
    'invalid_time': {
      'en': 'Selected time is not allowed!',
      'ro': 'Ora selectată nu este permisă!'
    },
    'rescheduled': {
      'en': 'Appointment rescheduled!',
      'ro': 'Programare reprogramată!'
    },
    'load_more': {'en': 'Load More', 'ro': 'Încarcă mai multe'},
    'past_time': {
      'en': 'Cannot book past time!',
      'ro': 'Nu poți face programare în trecut!'
    },
  };

  final Map<String, String> servicesRoToEn = {
    "Tuns Zero + Barba - 15 min": "Buzz Cut + Beard - 15 min",
    "Tuns - 30 min": "Haircut - 30 min",
    "Tuns + Barba + contur - 60 min": "Haircut + Beard + Contour - 60 min",
    "Tuns Barba + Contur - 20 min": "Beard + Contour - 20 min",
    "Ras Facial (Shaver) - 20 min": "Face Shave - 20 min",
    "Ras Capilar (Shaver) - 20 min": "Head Shave - 20 min",
    "Vopsit Barba - 30 min": "Beard Dye - 30 min",
    "Contur Barba (Brici)": "Beard Contour (Razor)",
    "Spalat": "Hair Wash",
  };

  List<String> getOriginalServices() => servicesRoToEn.keys.toList();

  String translateService(String service) =>
      language == 'ro' ? service : servicesRoToEn[service] ?? service;

  @override
  void initState() {
    super.initState();
    tz.initializeTimeZones();
    _loadInitialAppointments();
    _checkAdminStatus();

    AwesomeNotifications().initialize(
      null,
      [
        NotificationChannel(
          channelKey: 'reminder_channel',
          channelName: 'Reminders',
          channelDescription: 'Notification for upcoming appointments',
          defaultColor: Colors.blue,
          ledColor: Colors.white,
          importance: NotificationImportance.High,
          channelShowBadge: true,
        )
      ],
      debug: true,
    );
  }

  Future<void> _scheduleReminder(DateTime appointmentTime) async {
    final DateTime reminderTime =
        appointmentTime.subtract(const Duration(hours: 1));

    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: appointmentTime.hashCode,
        channelKey: 'reminder_channel',
        title: 'Reminder',
        body:
            'You have an appointment at ${DateFormat('HH:mm').format(appointmentTime)}',
        notificationLayout: NotificationLayout.Default,
      ),
      schedule: NotificationCalendar(
        year: reminderTime.year,
        month: reminderTime.month,
        day: reminderTime.day,
        hour: reminderTime.hour,
        minute: reminderTime.minute,
        second: 0,
        millisecond: 0,
        timeZone: await AwesomeNotifications().getLocalTimeZoneIdentifier(),
        repeats: false,
      ),
    );
  }

  Future<void> _checkAdminStatus() async {
    final currentUser = FirebaseAuth.instance.currentUser;

    logger.d("Current UID: ${currentUser?.uid}");

    if (!mounted) return;

    if (currentUser == null) {
      setState(() => _isAdmin = false);
    } else {
      final isAdmin = currentUser.uid == "9ctGVdP7Ehe4pad0dSXhYCkvdai2";
      setState(() => _isAdmin = isAdmin);
    }
  }

  void toggleLanguage() {
    setState(() {
      language = language == 'en' ? 'ro' : 'en';
    });
  }

  bool _isValidDay(DateTime day) {
    final weekday = day.weekday;

    if (selectedWeekType.contains('Automat')) {
      final isEvenWeek =
          (day.difference(DateTime(2024, 1, 1)).inDays ~/ 7) % 2 == 0;
      return isEvenWeek
          ? [1, 3, 5].contains(weekday)
          : [2, 4, 6, 7].contains(weekday);
    }

    if (selectedWeekType.contains('Săptămâna 1')) {
      return [2, 4, 6, 7].contains(weekday);
    } else {
      return [1, 3, 5].contains(weekday);
    }
  }

 Future<void> _loadInitialAppointments() async {
  if (isLoading || !hasMore) return;
  setState(() => isLoading = true);

  Query query = FirebaseFirestore.instance
      .collection("appointments")
      .orderBy("timestamp", descending: true)
      .limit(pageSize);

  if (lastDocument != null) {
    query = query.startAfterDocument(lastDocument!);
  }

  try {
    final snapshot = await query.get();
    final docs = snapshot.docs;

    if (docs.isNotEmpty) {
      lastDocument = docs.last;

      // Adaugă programările la listă
      setState(() {
        _appointments.addAll(docs.map((doc) {
          var data = doc.data() as Map<String, dynamic>;
          data['id'] = doc.id;
          return data;
        }).toList());

        // Sortează programările în ordinea corectă (în funcție de data și ora programării)
        _appointments.sort((a, b) {
          DateTime dateA = DateFormat('yyyy-MM-dd HH:mm').parse('${a["date"]} ${a["time"]}');
          DateTime dateB = DateFormat('yyyy-MM-dd HH:mm').parse('${b["date"]} ${b["time"]}');
          return dateA.compareTo(dateB); // Compară datele pentru a le sorta
        });

        hasMore = true;
      });
    } else {
      setState(() {
        hasMore = false;
      });
    }
  } catch (e) {
    logger.e('Eroare la încărcarea programărilor: $e');
  } finally {
    setState(() {
      isLoading = false;
    });
  }
}


  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
    setState(() => _isAdmin = false);
    logger.i("Delogat complet");

    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const CalendarScreen()),
    );
  }

  Future<void> _selectTime() async {
    if (selectedDate == null) {
      _showSnackBar("Selectați mai întâi o dată!");
      return;
    }

    final currentContext = context;

    TimeOfDay? picked = await showTimePicker(
      context: currentContext,
      initialTime: const TimeOfDay(hour: 9, minute: 0),
    );

    if (!mounted) return;

    if (picked != null && _isTimeAllowed(selectedDate!, picked)) {
      setState(() => selectedTime = picked);
    } else if (picked != null) {
      _showSnackBar(translations['invalid_time']![language]!);
    }
  }

bool _isTimeAllowed(DateTime date, TimeOfDay time) {
  int day = date.weekday;
  int hour = time.hour;
  int minutes = time.minute;

  if (day >= 1 && day <= 5) {
    // Luni - Vineri: programările pot fi făcute între 09:00 și 19:30
    return (hour > 9 || (hour == 9 && minutes >= 0)) &&
        (hour < 19 || (hour == 19 && minutes <= 30)); // Permite inclusiv 19:30
  } else if (day == 6) {
    // Sâmbătă: programările pot fi făcute între 09:00 și 18:30
    return (hour > 9 || (hour == 9 && minutes >= 0)) &&
        (hour < 18 || (hour == 18 && minutes <= 30)); // Permite inclusiv 18:30
  } else if (day == 7) {
    // Duminică: programările pot fi făcute între 09:00 și 14:30
    return (hour > 9 || (hour == 9 && minutes >= 0)) &&
        (hour < 14 || (hour == 14 && minutes <= 30)); // Permite inclusiv 14:30
  }
  return false;
}


  Future<void> _saveAppointment() async {
  if (selectedDate == null || selectedTime == null || selectedService == null) {
    _showSnackBar(translations['fill_fields']![language]!);
    return;
  }

  DateTime now = DateTime.now();
  DateTime selectedDateTime = DateTime(
    selectedDate!.year,
    selectedDate!.month,
    selectedDate!.day,
    selectedTime!.hour,
    selectedTime!.minute,
  );

  // Verifică dacă data și ora selectată sunt deja rezervate doar pentru ziua respectivă
  String formattedDate = DateFormat('yyyy-MM-dd').format(selectedDate!);
  String formattedTime =
      "${selectedTime!.hour.toString().padLeft(2, '0')}:${selectedTime!.minute.toString().padLeft(2, '0')}";
  String dateTimeKey = "$formattedDate $formattedTime";

  // Verifică dacă există o programare în aceeași zi și la aceeași oră
  bool isTimeReserved = _appointments.any((appointment) {
    DateTime appointmentDateTime = DateFormat('yyyy-MM-dd HH:mm').parse(
        "${appointment['date']} ${appointment['time']}");
    return isSameDay(appointmentDateTime, selectedDateTime) &&
        appointmentDateTime.hour == selectedDateTime.hour &&
        appointmentDateTime.minute == selectedDateTime.minute;
  });

  if (isTimeReserved) {
    _showSnackBar(translations['already_reserved']![language]!);
    return;
  }

  if (selectedDateTime.isBefore(now)) {
    _showSnackBar(translations['past_time']![language]!);
    return;
  }

  Map<String, dynamic> newAppointment = {
    "service": selectedService,
    "date": formattedDate,
    "time": formattedTime,
    "timestamp": FieldValue.serverTimestamp(),
  };

  try {
    await FirebaseFirestore.instance
        .collection("appointments")
        .add(newAppointment);
    _appointments.insert(0, newAppointment);
    _reservedTimes.add(dateTimeKey);
    setState(() {});
    await _scheduleReminder(selectedDateTime);
    _showSnackBar(translations['appointment_saved']![language]!);
  } catch (e) {
    logger.e("Eroare la salvarea programării: ${e.toString()}");
    _showSnackBar("Eroare la salvarea programării.");
  }
}


  void _showSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  void _deleteAppointment(String id) async {
    try {
      // Șterge programarea din Firestore
      await FirebaseFirestore.instance
          .collection("appointments")
          .doc(id)
          .delete();

      // Elimină programarea din lista de programări
      setState(() {
        _appointments.removeWhere((appt) => appt['id'] == id);
      });

      // Afișează un mesaj de succes
      _showSnackBar(translations['appointment_deleted']![language]!);
    } catch (e) {
      // În caz de eroare, afișează un mesaj de eroare
      logger.e("Eroare la ștergerea programării: $e");
      _showSnackBar("Eroare la ștergerea programării.");
    }
  }

 Future<void> _rescheduleAppointment(String appointmentId) async {
  if (!mounted) return; // Asigură-te că widget-ul este montat înainte de a folosi contextul

  final DateTime? newDate = await showDatePicker(
    context: context,
    initialDate: DateTime.now(),
    firstDate: DateTime.now(),
    lastDate: DateTime(2101),
  );

  if (!mounted || newDate == null || !_isValidDay(newDate)) {
    _showSnackBar("Ziua selectată nu este disponibilă în această săptămână!");
    return;
  }

  // După ce am validat data, continuăm cu alegerea orei
  TimeOfDay? newTime = await showTimePicker(
    context: context, // Folosește direct contextul fără a crea un context nou
    initialTime: const TimeOfDay(hour: 9, minute: 0),
  );

  if (!mounted) return; // Verifică din nou dacă widget-ul este montat înainte de a utiliza contextul

  if (newTime == null || !_isTimeAllowed(newDate, newTime)) {
    _showSnackBar(translations['invalid_time']![language]!);
    return;
  }

  final DateTime now = DateTime.now();
  final DateTime newDateTime = DateTime(
    newDate.year,
    newDate.month,
    newDate.day,
    newTime.hour,
    newTime.minute,
  );

  if (newDateTime.isBefore(now)) {
    _showSnackBar(translations['past_time']![language]!);
    return;
  }

  String formattedDate = DateFormat('yyyy-MM-dd').format(newDate);
  String formattedTime =
      "${newTime.hour.toString().padLeft(2, '0')}:${newTime.minute.toString().padLeft(2, '0')}";
  String dateTimeKey = "$formattedDate $formattedTime";

  if (_reservedTimes.contains(dateTimeKey)) {
    _showSnackBar(translations['already_reserved']![language]!);
    return;
  }

  try {
    await FirebaseFirestore.instance
        .collection("appointments")
        .doc(appointmentId)
        .update({
      "date": formattedDate,
      "time": formattedTime,
      "timestamp": FieldValue.serverTimestamp(),
    });

    _appointments.removeWhere((appt) => appt['id'] == appointmentId);
    _appointments.insert(0, {
      "id": appointmentId,
      "service": selectedService ?? '',
      "date": formattedDate,
      "time": formattedTime,
    });
    _reservedTimes.add(dateTimeKey);

    setState(() {}); // Reîmprospătează UI-ul
    await _scheduleReminder(newDateTime);
    _showSnackBar(translations['rescheduled']![language]!);
  } catch (e) {
    logger.e("Eroare la reprogramare: $e");
    _showSnackBar("Eroare la reprogramare.");
  }
}


  Widget buildCalendar() {
    return TableCalendar(
      focusedDay: focusedDay,
      firstDay: DateTime.utc(2023, 1, 1),
      lastDay: DateTime.utc(2100, 12, 31),
      selectedDayPredicate: (day) => isSameDay(day, selectedDate),
      onDaySelected: (day, focused) {
        if (_isValidDay(day)) {
          setState(() {
            selectedDate = day;
            focusedDay = focused;
          });
        } else {
          _showSnackBar(
              "Ziua selectată nu este disponibilă în această săptămână!");
        }
      },
      calendarStyle: const CalendarStyle(
        todayDecoration:
            BoxDecoration(color: Colors.orange, shape: BoxShape.circle),
        selectedDecoration:
            BoxDecoration(color: Colors.blue, shape: BoxShape.circle),
      ),
      enabledDayPredicate: _isValidDay,
    );
  }

 @override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: Text(
        (language == 'en' ? 'Appointments' : 'Programări') +
            (_isAdmin ? ' (Admin)' : ''),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.language),
          onPressed: toggleLanguage,
        ),
        if (_isAdmin)
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
          ),
      ],
    ),
    body: ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        DropdownButtonFormField<String>(
          decoration: InputDecoration(
            border: OutlineInputBorder(),
            labelText: translations['choose_service']![language]!,
          ),
          value: selectedService,
          onChanged: (value) => setState(() {
            selectedService = value;
          }),
          items: getOriginalServices().map((service) {
            return DropdownMenuItem<String>(
              value: service,
              child: Text(translateService(service)),
            );
          }).toList(),
        ),
        const SizedBox(height: 10),
        DropdownButtonFormField<String>(
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            labelText: 'Săptămână activă',
          ),
          value: selectedWeekType,
          onChanged: (value) {
            setState(() {
              selectedWeekType = value!;
              selectedDate = null;
              selectedTime = null;
            });
          },
          items: weekOptions.map((week) {
            return DropdownMenuItem(
              value: week,
              child: Text(week),
            );
          }).toList(),
        ),
        const SizedBox(height: 10),
        buildCalendar(),
        ElevatedButton(
          onPressed: _selectTime,
          child: Text(translations['choose_time']![language]!),
        ),
        ElevatedButton(
          onPressed: _saveAppointment,
          child: Text(translations['save_appointment']![language]!),
        ),
        const Divider(),
        // Înlocuiește ListTile cu Card
        ..._appointments.map((appointment) => Card(
              elevation: 5,  // Adaugă umbră pentru a crea un efect de card
              margin: const EdgeInsets.symmetric(vertical: 8.0),
              child: ListTile(
                contentPadding: const EdgeInsets.all(16.0),
                title: Text(appointment["service"]),
                subtitle: Text("${appointment["date"]} ⏰ ${appointment["time"]}"),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.blue),
                      onPressed: () =>
                          _rescheduleAppointment(appointment['id']),
                    ),
                    if (_isAdmin)
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deleteAppointment(appointment['id']),
                      ),
                  ],
                ),
              ),
            )),
        if (hasMore)
          Center(
            child: ElevatedButton(
              onPressed: _loadInitialAppointments,
              child: Text(translations['load_more']![language]!),
            ),
          ),
      ],
    ),
  );
}

}

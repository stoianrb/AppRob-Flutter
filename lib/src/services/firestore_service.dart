import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:logger/logger.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final Logger _logger = Logger();  // Crează instanța de Logger

  // Salvare programare în Firestore
  Future<void> saveAppointment(String userId, Map<String, dynamic> appointmentData) async {
    try {
      await _db.collection('appointments').add({
        'userId': userId,
        'date': appointmentData['date'],
        'service': appointmentData['service'],
        // Adaugă alte câmpuri de care ai nevoie
      });
    } catch (e) {
      _logger.e('Error saving appointment: $e');  // Folosește logger pentru erori
    }
  }

  // Obține programările pentru un utilizator
  Future<List<Map<String, dynamic>>> getAppointments(String userId) async {
    try {
      final querySnapshot = await _db
          .collection('appointments')
          .where('userId', isEqualTo: userId)
          .get();

      return querySnapshot.docs.map((doc) {
        return {
          'date': doc['date'],
          'service': doc['service'],
          // Adaugă alte câmpuri de care ai nevoie
        };
      }).toList();
    } catch (e) {
      _logger.e('Error fetching appointments: $e');  // Folosește logger pentru erori
      return [];
    }
  }
}

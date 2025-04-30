import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:logger/logger.dart';  // Importăm Logger pentru logging
import 'package:firebase_auth/firebase_auth.dart';


class ReviewsScreen extends StatefulWidget {
  const ReviewsScreen({super.key});

  @override
  State<ReviewsScreen> createState() => _ReviewsScreenState();
}

class _ReviewsScreenState extends State<ReviewsScreen> {
  final TextEditingController _messageController = TextEditingController();
  double _rating = 0;
  bool _isAdmin = false;
  bool _isLoading = false;
  final List<DocumentSnapshot> _reviews = [];
  DocumentSnapshot? _lastDoc;
  bool _hasMore = true;

  final Map<String, Map<String, String>> tr = {
    'en': {
      'title': 'Reviews',
      'message': 'Message',
      'add_review': 'Add Review',
      'fill_fields': 'Please fill all fields!',
      'review_added': 'Review added successfully!',
      'reply': 'Reply',
      'send': 'Send',
      'cancel': 'Cancel',
      'delete_success': 'Review deleted!',
      'delete_error': 'Delete error!',
      'reply_added': 'Reply added!',
      'load_more': 'Load More',
    },
    'ro': {
      'title': 'Recenzii',
      'message': 'Mesaj',
      'add_review': 'Adaugă Recenzie',
      'fill_fields': 'Completați toate câmpurile!',
      'review_added': 'Recenzie adăugată cu succes!',
      'reply': 'Răspuns',
      'send': 'Trimite',
      'cancel': 'Anulează',
      'delete_success': 'Recenzie ștearsă!',
      'delete_error': 'Eroare la ștergere!',
      'reply_added': 'Răspuns adăugat!',
      'load_more': 'Încarcă mai multe',
    }
  };

  String language = 'ro';
  final Logger logger = Logger();  // Instanță pentru logging

  String t(String key) => tr[language]?[key] ?? key;

  @override
  void initState() {
    super.initState();
    _checkAdmin();
    _loadReviews();
  }

  void _checkAdmin() async {
  final user = FirebaseAuth.instance.currentUser;
  setState(() {
    _isAdmin = user?.uid == "9ctGVdP7Ehe4pad0dSXhYCkvdai2";
  });
}


  void _toggleLanguage() {
    setState(() => language = language == 'ro' ? 'en' : 'ro');
  }

  // Load reviews with debug logs
  Future<void> _loadReviews() async {
    if (_isLoading || !_hasMore) return;
    setState(() => _isLoading = true);

    Query query = FirebaseFirestore.instance
        .collection('reviews')
        .orderBy('timestamp', descending: true)
        .limit(10);

    if (_lastDoc != null) {
      query = query.startAfterDocument(_lastDoc!);
    }

    final snapshot = await query.get();
    logger.d("Loaded ${snapshot.docs.length} reviews");  // Logging în loc de print

    if (snapshot.docs.isNotEmpty) {
      setState(() {
        _lastDoc = snapshot.docs.last;
        _reviews.addAll(snapshot.docs);
      });
    } else {
      _hasMore = false;
    }

    setState(() => _isLoading = false);
  }

  Future<void> _addReview() async {
    if (_messageController.text.isEmpty || _rating == 0) {
      _showSnackBar(t("fill_fields"));
      return;
    }

    final review = {
      "message": _messageController.text.trim(),
      "rating": _rating,
      "timestamp": FieldValue.serverTimestamp(),
      "reply": null,
    };

    await FirebaseFirestore.instance.collection('reviews').add(review);
    _messageController.clear();
    setState(() => _rating = 0);
    _reviews.clear();
    _lastDoc = null;
    _hasMore = true;
    _showSnackBar(t("review_added"));
    await _loadReviews();
  }

  Future<void> _deleteReview(String id) async {
    try {
      await FirebaseFirestore.instance.collection('reviews').doc(id).delete();
      _showSnackBar(t("delete_success"));
      _reviews.removeWhere((e) => e.id == id);
      setState(() {});
    } catch (_) {
      _showSnackBar(t("delete_error"));
    }
  }

  Future<void> _replyToReview(String id) async {
    final replyController = TextEditingController();

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(t("reply")),
        content: TextField(controller: replyController),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(t("cancel")),
          ),
          TextButton(
            onPressed: () async {
              await FirebaseFirestore.instance
                  .collection('reviews')
                  .doc(id)
                  .update({"reply": replyController.text});
              _showSnackBar(t("reply_added"));
              // ignore: use_build_context_synchronously
              Navigator.pop(context);
              _reviews.clear();
              _lastDoc = null;
              _hasMore = true;
              await _loadReviews();
            },
            child: Text(t("send")),
          ),
        ],
      ),
    );
  }

  void _showSnackBar(String text) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(t("title")),
        actions: [
          IconButton(
            icon: const Icon(Icons.translate),
            onPressed: _toggleLanguage,
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Show reviews
          ..._reviews.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            logger.d('Review: ${data["message"]}, Rating: ${data["rating"]}');  // Logging
            return Card(
              child: ListTile(
                title: Text("${data["rating"]} ★"),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(data["message"] ?? ""),
                    if (data["reply"] != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Text("🔁 ${data["reply"]}", style: const TextStyle(color: Colors.green)),
                      ),
                    if (_isAdmin)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.reply, color: Colors.blue),
                            onPressed: () => _replyToReview(doc.id),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _deleteReview(doc.id),
                          ),
                        ],
                      )
                  ],
                ),
              ),
            );
          }),
          if (_hasMore)
            ElevatedButton(
              onPressed: _loadReviews,
              child: Text(t("load_more")),
            ),
          const Divider(height: 32),
          TextField(
            controller: _messageController,
            maxLines: 3,
            decoration: InputDecoration(
              labelText: t("message"),
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 10),
          RatingBar.builder(
            initialRating: _rating,
            minRating: 1,
            allowHalfRating: true,
            itemCount: 5,
            itemSize: 30,
            itemBuilder: (context, _) => const Icon(Icons.star, color: Colors.amber),
            onRatingUpdate: (value) => setState(() => _rating = value),
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: _addReview,
            child: Text(t("add_review")),
          ),
        ],
      ),
    );
  }
}

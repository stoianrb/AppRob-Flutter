// MODERNIZED ReviewsScreen with Enhanced Review Animation
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:logger/logger.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';

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
  final Logger logger = Logger();
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
    logger.d("Loaded \${snapshot.docs.length} reviews");

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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(t("reply")),
        content: TextField(controller: replyController),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(t("cancel")),
          ),
          ElevatedButton(
            onPressed: () async {
              await FirebaseFirestore.instance
                  .collection('reviews')
                  .doc(id)
                  .update({"reply": replyController.text});
              Navigator.pop(context);
              _showSnackBar(t("reply_added"));
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
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(text),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.black87,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? Colors.black : Colors.grey[100],
      appBar: AppBar(
        title: Text(t("title"), style: GoogleFonts.urbanist(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: _toggleLanguage,
            child: Text(language == 'ro' ? "🌐 EN" : "🌐 RO",
              style: const TextStyle(fontWeight: FontWeight.bold)),
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ..._reviews.map((doc) => BounceInUp(
              duration: const Duration(milliseconds: 500),
              child: Card(
                color: isDark ? Colors.grey[900] : Colors.white,
                elevation: 6,
                shadowColor: Colors.amber.withOpacity(0.3),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          RatingBarIndicator(
                            rating: (doc['rating'] as num).toDouble(),
                            itemBuilder: (context, _) => const Icon(Icons.star, color: Colors.amber),
                            itemCount: 5,
                            itemSize: 22,
                          ),
                          const SizedBox(width: 10),
                          Text("${doc['rating']} / 5", style: GoogleFonts.urbanist(fontWeight: FontWeight.bold))
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(doc['message'], style: GoogleFonts.urbanist(fontSize: 16)),
                      if (doc['reply'] != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text("🔁 ${doc['reply']}", style: GoogleFonts.urbanist(color: Colors.greenAccent.shade400)),
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
                            )
                          ],
                        )
                    ],
                  ),
                ),
              ),
            )),
            if (_hasMore)
              Center(
                child: ElevatedButton(
                  onPressed: _loadReviews,
                  child: Text(t("load_more")),
                ),
              ),
            const SizedBox(height: 24),
            Text(t("message"), style: GoogleFonts.urbanist(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(
              controller: _messageController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: language == 'ro' ? "Scrie un mesaj..." : "Write a message...",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
              ),
            ),
            const SizedBox(height: 12),
            RatingBar.builder(
              initialRating: _rating,
              minRating: 1,
              allowHalfRating: true,
              itemCount: 5,
              itemSize: 30,
              itemBuilder: (context, _) => const Icon(Icons.star, color: Colors.amber),
              onRatingUpdate: (value) => setState(() => _rating = value),
            ),
            const SizedBox(height: 12),
            Center(
              child: ElevatedButton.icon(
                onPressed: _addReview,
                icon: const Icon(Icons.send),
                label: Text(t("add_review")),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                  textStyle: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

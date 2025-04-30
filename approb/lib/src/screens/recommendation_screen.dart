import 'package:flutter/material.dart';

class RecommendationScreen extends StatelessWidget {
  const RecommendationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Recomandări")),
      body: Center(
        child: Text("Recomandări personalizate pentru utilizator"), // Logică de recomandare
      ),
    );
  }
}

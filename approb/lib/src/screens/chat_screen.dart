import 'package:flutter/material.dart';

class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Chatbot")),
      body: Center(
        child: Text("Chatbot integrat aici"), // Adaugă implementarea chatbotului aici
      ),
    );
  }
}

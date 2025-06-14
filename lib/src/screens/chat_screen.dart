import 'package:flutter/material.dart';
import 'package:dialog_flowtter/dialog_flowtter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import 'package:flutter/services.dart';
import 'package:flutter/services.dart' hide TextInput;
import 'package:dialog_flowtter/dialog_flowtter.dart' as df;

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  DialogFlowtter? dialogFlowtter;
  List<Map<String, dynamic>> messages = [];
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _loading = false;
  bool _ready = false;
  String languageCode = 'ro';

  @override
  void initState() {
    super.initState();
    _initBot();
  }

  void _initBot() async {
    dialogFlowtter = await DialogFlowtter.fromFile(
      path: "assets/dialog_flow_auth.json",
    );
    setState(() {
      _ready = true;
    });
  }

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;
    setState(() {
      messages.add({'isUser': true, 'text': text});
      _loading = true;
    });
    _controller.clear();
    _scrollToBottom();

   DetectIntentResponse response = await dialogFlowtter!.detectIntent(
  queryInput: QueryInput(
    text: df.TextInput( // <-- prefixul aici
      text: text,
      languageCode: languageCode,
    ),
  ),
);


    String botText = response.text ??
        (response.message?.text?.text?.join(" ") ??
            (languageCode == 'ro'
                ? "Nu am găsit răspuns, verifică Dialogflow!"
                : "No answer found, check Dialogflow!"));

    setState(() {
      messages.add({'isUser': false, 'text': botText});
      _loading = false;
    });

    _scrollToBottom();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 200), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFF181818),
            Color(0xFF383838),
            Color(0xFF0f2027),
            Color(0xFF2c5364),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
  backgroundColor: Colors.black87,
  iconTheme: const IconThemeData(color: Colors.white), // Sageata înapoi albă
  systemOverlayStyle: Theme.of(context).brightness == Brightness.dark
      ? SystemUiOverlayStyle.light
      : SystemUiOverlayStyle.dark, // Culoare pentru status bar (sus)
  title: BounceInDown(
    duration: const Duration(milliseconds: 700),
    child: Text(
      "Hip Hop Chatbot",
      style: GoogleFonts.bangers(fontSize: 28, color: Colors.amber),
    ),
  ),
  actions: [
    TextButton.icon(
      onPressed: () {
        setState(() {
          languageCode = (languageCode == 'ro') ? 'en' : 'ro';
        });
      },
      icon: const Icon(Icons.language, size: 22, color: Colors.white),
      label: Text(
        languageCode == 'ro' ? "EN" : "RO",
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.white, // Vizibil pe fundal închis
        ),
      ),
    ),
  ],
),


        body: !_ready
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.all(16),
                      itemCount: messages.length,
                      itemBuilder: (context, idx) {
                        final msg = messages[idx];
                        final isUser = msg['isUser'] as bool;

                        final animation = isUser
                            ? SlideInRight(
                                key: ValueKey('$idx-${msg['text']}'),
                                duration: const Duration(milliseconds: 500),
                                child: _buildMessageBubble(msg, isUser),
                              )
                            : ShakeX(
                                key: ValueKey('$idx-${msg['text']}'),
                                duration: const Duration(milliseconds: 600),
                                child: _buildMessageBubble(msg, isUser),
                              );

                        return animation;
                      },
                    ),
                  ),
                  if (_loading)
                    const Padding(
                      padding: EdgeInsets.all(10.0),
                      child: LinearProgressIndicator(
                        color: Colors.amber,
                        backgroundColor: Colors.deepPurple,
                      ),
                    ),
                  FadeInUp(
                    duration: const Duration(milliseconds: 400),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black87.withAlpha((0.88 * 255).toInt()),
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(color: Colors.amber, width: 1.2),
                      ),
                      margin: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 8),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _controller,
                              style: GoogleFonts.urbanist(
                                  color: Colors.amber[100], fontSize: 18),
                              onSubmitted: sendMessage,
                              decoration: InputDecoration(
                                hintText: languageCode == 'ro'
                                    ? "Scrie cu swag aici..."
                                    : "Type with swag...",
                                hintStyle: GoogleFonts.urbanist(
                                    color: Colors.amber[300], fontSize: 18),
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.send,
                                color: Colors.amber, size: 29),
                            onPressed: () => sendMessage(_controller.text),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                ],
              ),
      ),
    );
  }

  Widget _buildMessageBubble(Map<String, dynamic> msg, bool isUser) {
    return Row(
      mainAxisAlignment:
          isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (!isUser)
          const Padding(
            padding: EdgeInsets.only(right: 4.0),
            child: Text("🎤", style: TextStyle(fontSize: 26)),
          ),
        Flexible(
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 6),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            decoration: BoxDecoration(
              color: isUser ? Colors.deepPurple[600] : Colors.amber[600],
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(22),
                topRight: const Radius.circular(22),
                bottomLeft: isUser
                    ? const Radius.circular(22)
                    : const Radius.circular(5),
                bottomRight: isUser
                    ? const Radius.circular(5)
                    : const Radius.circular(22),
              ),
              boxShadow: [
                BoxShadow(
                  color: isUser
                      ? Colors.deepPurple.shade900
                          .withAlpha((0.7 * 255).toInt())
                      : Colors.amber.shade900.withAlpha((0.5 * 255).toInt()),
                  blurRadius: 14,
                  offset: const Offset(0, 4),
                )
              ],
              border: Border.all(
                color: isUser ? Colors.amber[400]! : Colors.deepPurple[900]!,
                width: 2.2,
              ),
            ),
            child: Text(
              msg['text'],
              style: GoogleFonts.bebasNeue(
                fontSize: 20,
                color: isUser ? Colors.amber[100] : Colors.deepPurple[900],
                letterSpacing: 0.5,
              ),
            ),
          ),
        ),
        if (isUser)
          const Padding(
            padding: EdgeInsets.only(left: 4.0),
            child: Text("🧢", style: TextStyle(fontSize: 26)),
          ),
      ],
    );
  }
}

import 'dart:ui';
import 'package:flutter/material.dart';

import '../ai/questionModel.dart';
import '../network/chatgpt_network_request.dart';
import '../widgets/animated_marble_background.dart';

class AiChatScreen extends StatefulWidget {
  static String tag = '/chatgpt';

  final bool isDirect;
  final String? questionAsk;
  final String? question;

  const AiChatScreen({
    Key? key,
    this.isDirect = false,
    this.questionAsk,
    this.question,
  }) : super(key: key);

  @override
  State<AiChatScreen> createState() => _AiChatScreenState();
}

class _AiChatScreenState extends State<AiChatScreen> {

  ScrollController scrollController = ScrollController();
  TextEditingController msgController = TextEditingController();
  FocusNode focusNode = FocusNode();

  List<QuestionAnswerModel> questionAnswers = [];

  bool isSending = false;
  bool _autoSent = false;

  @override
  void initState() {
    super.initState();
    _initializeChat();
  }

  // ================= INIT =================

  Future<void> _initializeChat() async {

    await _loadOldMessages();

    if (!_autoSent &&
        widget.questionAsk != null &&
        widget.questionAsk!.isNotEmpty) {
      _autoSent = true;
      sendAutoMessage(widget.questionAsk!);
      return;
    }

    if (questionAnswers.isEmpty) {
      questionAnswers.insert(
        0,
        QuestionAnswerModel(
          question: "",
          answer: StringBuffer()
            ..write("Hi! I'm Clo ✨ How can I help you today?"),
          isLoading: false,
        ),
      );
    }

    if (mounted) setState(() {});
  }

  Future<void> _loadOldMessages() async {

    questionAnswers.clear();

    final messages = await ChatGptService.getThreadMessages();

    for (var msg in messages.reversed) {

      final role = msg['role'];
      final content = msg['content'][0]['text']['value'];

      if (content.startsWith("User name is")) continue;

      questionAnswers.insert(
        0,
        QuestionAnswerModel(
          question: role == "user" ? content : "",
          answer: role == "assistant"
              ? (StringBuffer()..write(content))
              : null,
          isLoading: false,
        ),
      );
    }
  }

  // ================= SEND =================

  void sendMessage() async {

    String question = msgController.text.trim();

    if (question.isEmpty || isSending) return;

    msgController.clear();
    focusNode.unfocus();

    setState(() {

      isSending = true;

      // user message
      questionAnswers.insert(
        0,
        QuestionAnswerModel(
          question: question,
          answer: null,
          isLoading: false,
        ),
      );

      // assistant placeholder
      questionAnswers.insert(
        0,
        QuestionAnswerModel(
          question: "",
          answer: StringBuffer(),
          isLoading: true,
        ),
      );
    });

    _scrollToBottom();

    try {

      final response = await ChatGptService.sendMessage(question);

      await _animateResponse(response, 0);

    } catch (e) {

      setState(() {

        questionAnswers[0].answer = StringBuffer()
          ..write("Something went wrong.");

        questionAnswers[0].isLoading = false;
        isSending = false;
      });
    }
  }

  void sendAutoMessage(String text) async {

    if (isSending) return;

    setState(() {

      isSending = true;

      questionAnswers.insert(
        0,
        QuestionAnswerModel(
          question: text,
          answer: null,
          isLoading: false,
        ),
      );

      questionAnswers.insert(
        0,
        QuestionAnswerModel(
          question: "",
          answer: StringBuffer(),
          isLoading: true,
        ),
      );
    });

    final response = await ChatGptService.sendMessage(text);

    await _animateResponse(response, 0);
  }

  // ================= STREAM RESPONSE =================

  Future<void> _animateResponse(String fullText, int index) async {

    int delay = fullText.length > 400 ? 5 : 12;

    for (int i = 0; i < fullText.length; i++) {

      await Future.delayed(Duration(milliseconds: delay));

      if (!mounted) return;

      setState(() {
        questionAnswers[index].answer!.write(fullText[i]);
      });

      _scrollToBottom();
    }

    setState(() {
      questionAnswers[index].isLoading = false;
      isSending = false;
    });
  }

  void _scrollToBottom() {

    WidgetsBinding.instance.addPostFrameCallback((_) {

      if (scrollController.hasClients) {

        scrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  // ================= UI =================

  @override
  Widget build(BuildContext context) {

    return AnimatedMarbleBackground(
      child: Scaffold(

        backgroundColor: Colors.black.withOpacity(0.2),

        appBar: AppBar(
          backgroundColor: Colors.black.withOpacity(0.3),
          elevation: 0,
          title: const Text(
            "Clo AI",
            style: TextStyle(color: Colors.white),
          ),
        ),

        body: Column(
          children: [

            Expanded(
              child: ListView.builder(

                reverse: true,
                controller: scrollController,
                padding: const EdgeInsets.all(16),
                itemCount: questionAnswers.length,

                itemBuilder: (context, index) {

                  final data = questionAnswers[index];

                  final isUser =
                      data.question != null &&
                          data.question!.isNotEmpty;

                  return _buildBubble(data, isUser);
                },
              ),
            ),

            SafeArea(
              top: false,
              child: Padding(
                padding:
                const EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: _buildInput(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ================= BUBBLE =================

  Widget _buildBubble(QuestionAnswerModel data, bool isUser) {

    final text = isUser
        ? data.question!
        : data.answer?.toString() ?? "";

    return Align(
      alignment:
      isUser ? Alignment.centerRight : Alignment.centerLeft,

      child: Container(

        margin: const EdgeInsets.symmetric(vertical: 6),

        child: ClipRRect(

          borderRadius: BorderRadius.circular(20),

          child: BackdropFilter(

            filter:
            ImageFilter.blur(sigmaX: 10, sigmaY: 10),

            child: Container(

              constraints:
              const BoxConstraints(maxWidth: 280),

              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 12),

              decoration: BoxDecoration(

                color: isUser
                    ? Colors.pink.withOpacity(0.85)
                    : Colors.white.withOpacity(0.85),

                borderRadius:
                BorderRadius.circular(20),

              ),

              child: Text(
                text,
                style: TextStyle(
                  color:
                  isUser ? Colors.white : Colors.black87,
                  fontSize: 15,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ================= INPUT =================

  Widget _buildInput() {

    return ClipRRect(

      borderRadius: BorderRadius.circular(30),

      child: BackdropFilter(

        filter:
        ImageFilter.blur(sigmaX: 20, sigmaY: 20),

        child: Container(

          padding:
          const EdgeInsets.symmetric(horizontal: 16),

          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.9),
            borderRadius:
            BorderRadius.circular(30),
          ),

          child: Row(
            children: [

              Expanded(
                child: TextField(

                  focusNode: focusNode,
                  controller: msgController,

                  decoration: const InputDecoration(
                    hintText: "Ask Clo anything...",
                    border: InputBorder.none,
                  ),
                ),
              ),

              IconButton(
                icon: const Icon(
                  Icons.send,
                  color: Colors.pink,
                ),
                onPressed: sendMessage,
              )
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {

    msgController.dispose();
    scrollController.dispose();
    focusNode.dispose();

    super.dispose();
  }
}
import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart';

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
  FilePickerResult? _attachmentFile;

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

    if (question.isEmpty && _attachmentFile == null || isSending) return;

    if (_attachmentFile != null) {
      _sendSelectedAttachment();
      return;
    }

    if (question.isEmpty) return;

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

      await _animateResponse(response, 0); // Correctly target AI response at index 0

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

  // ================= ATTACHMENT =================

  Future<void> _openAttachmentPicker() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
      );

      if (result != null) {
        setState(() {
          _attachmentFile = result;
        });
      }
    } catch (e) {
      print("File picking error: $e");
    }
  }

  void _sendSelectedAttachment() async {
    if (_attachmentFile == null || isSending) return;

    final String fileName = _attachmentFile!.files.single.name;
    final String textContent = msgController.text.trim();
    final String localPath = _attachmentFile!.files.single.path!;

    // Structure the message with both text prompt and attachment marker
    final String prompt = textContent.isNotEmpty ? textContent : "Attachment sent.";
    final String questionForHistory = "Attachment: $fileName|$localPath|PENDING|$prompt"; 

    msgController.clear();
    focusNode.unfocus();

    setState(() {
        _attachmentFile = null; 
        isSending = true;

        questionAnswers.insert(0, QuestionAnswerModel(question: questionForHistory, answer: null, isLoading: false));
        questionAnswers.insert(0, QuestionAnswerModel(question: "", answer: StringBuffer(), isLoading: true));
    });

    _scrollToBottom();

    try {
        final dio = Dio();
        final LaravelApiEndpoint = 'https://apis.getclora.com/api/chat';

        final uploadResponse = await dio.post(
          LaravelApiEndpoint,
          data: FormData.fromMap({
            "prompt": prompt,
            "attachment_file": await MultipartFile.fromFile(localPath, filename: fileName),
          }),
        );

        final imageUrl = uploadResponse.data['image_url'];
        if (imageUrl == null) throw Exception("No image_url returned");

        final aiResponse = await ChatGptService.sendMessageWithImageUrl(
            textContent: prompt,
            imageUrl: imageUrl
        );

        setState(() {
            // Update user message with final URL
            questionAnswers[1].question = "Attachment: $fileName|$localPath|$imageUrl|$prompt"; 
            
            // Set AI response
            if (questionAnswers[0].isLoading == true) {
                questionAnswers[0].answer = StringBuffer()..write(aiResponse);
                questionAnswers[0].isLoading = false;
            }
        });
        
        isSending = false;
        
    } catch (e) {
        setState(() {
            if (questionAnswers.isNotEmpty && questionAnswers[0].isLoading == true) {
                questionAnswers[0].answer = StringBuffer()..write("Error: $e");
                questionAnswers[0].isLoading = false;
            }
            isSending = false;
        });
    }
  }

  // ================= UI =================

  @override
  Widget build(BuildContext context) {
    return AnimatedMarbleBackground(
      child: Scaffold(
        backgroundColor: Colors.black.withOpacity(0.2),

        body: Column(
          children: [
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Center(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(30),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.25),
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(color: Colors.white.withOpacity(0.4)),
                        ),
                        child: const Text("Clo AI ✨", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                reverse: true,
                controller: scrollController,
                padding: const EdgeInsets.all(16),
                itemCount: questionAnswers.length,
                itemBuilder: (context, index) {
                  final data = questionAnswers[index];
                  final isUser = data.question != null && data.question!.isNotEmpty;
                  return _buildBubble(data, isUser);
                },
              ),
            ),
            SafeArea(top: false, child: Padding(padding: const EdgeInsets.fromLTRB(16, 8, 16, 16), child: _buildInput())),
          ],
        ),
      ),
    );
  }

  Widget _buildBubble(QuestionAnswerModel data, bool isUser) {
    final String rawText = isUser ? data.question! : data.answer?.toString() ?? "";
    final bool isAttachment = isUser && rawText.startsWith("Attachment: ");

    String displayText = rawText;
    String? imageUrl;
    String? filename;
    String? caption;

    if (isAttachment) {
        final parts = rawText.split("|");
        if (parts.length >= 4) {
            filename = parts[0].replaceFirst("Attachment: ", "").trim();
            imageUrl = parts[2] == "PENDING" ? null : parts[2];
            caption = parts[3];
            displayText = caption.isNotEmpty && caption != "Attachment sent." ? caption : "";
        }
    }

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 280),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isUser ? Colors.pink.withOpacity(0.85) : Colors.white.withOpacity(0.85),
                borderRadius: BorderRadius.circular(20),
              ),
              child: isAttachment
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                        if (displayText.isNotEmpty) Text(displayText, style: TextStyle(color: Colors.white, fontSize: 15)),
                        if (displayText.isNotEmpty) const SizedBox(height: 8),
                        _buildAttachmentBubble(imageUrl, filename)
                    ],
                  )
                : Text(displayText, style: TextStyle(color: isUser ? Colors.white : Colors.black87, fontSize: 15)),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAttachmentBubble(String? imageUrl, String? filename) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(10)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(5),
            child: imageUrl != null
                ? Image.network(imageUrl, width: 40, height: 40, fit: BoxFit.cover)
                : const SizedBox(width: 40, height: 40, child: Center(child: CircularProgressIndicator(strokeWidth: 2))),
          ),
          const SizedBox(width: 8),
          if (filename != null) Flexible(child: Text(filename, style: const TextStyle(color: Colors.white, fontSize: 14), overflow: TextOverflow.ellipsis)),
        ],
      ),
    );
  }

  Widget _buildInput() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (_attachmentFile != null)
          Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.8), borderRadius: BorderRadius.circular(12)),
            child: Row(
              children: [
                ClipRRect(borderRadius: BorderRadius.circular(8), child: Image.file(File(_attachmentFile!.files.single.path!), width: 50, height: 50, fit: BoxFit.cover)),
                const SizedBox(width: 10),
                Expanded(child: Text(_attachmentFile!.files.single.name, overflow: TextOverflow.ellipsis)),
                IconButton(icon: const Icon(Icons.close, color: Colors.red), onPressed: () => setState(() => _attachmentFile = null)),
              ],
            ),
          ),
        ClipRRect(
          borderRadius: BorderRadius.circular(30),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.9), borderRadius: BorderRadius.circular(30)),
            child: Row(
              children: [
                IconButton(icon: const Icon(Icons.attachment, color: Colors.pink), onPressed: _openAttachmentPicker),
                Expanded(child: TextField(focusNode: focusNode, controller: msgController, decoration: const InputDecoration(hintText: "Ask Clo anything...", border: InputBorder.none))),
                IconButton(icon: const Icon(Icons.send, color: Colors.pink), onPressed: sendMessage),
              ],
            ),
          ),
        ),
      ],
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

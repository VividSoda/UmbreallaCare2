import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:umbrella_care/Constants/colors.dart';
import 'package:umbrella_care/navBar.dart';
import 'package:flutter/widgets.dart' show VoidCallback;

String latestResponse = "no";

class PatientChatBot extends StatefulWidget {
  const PatientChatBot({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _PatientChatBotState createState() => _PatientChatBotState();
}

class _PatientChatBotState extends State<PatientChatBot> {
  final TextEditingController _textEditingController = TextEditingController();
  List<ChatMessage> chatMessages = [];
  final currentUser = FirebaseAuth.instance.currentUser;
  String? email;
  String? name;
  late bool userExists;
  List<String> suggested = [];
  List<String> notAnswered = [];
  List<String> pastQuestion = [];
  List<String> suggestedQuestion = [];

  @override
  void initState() {
    super.initState();
    initializeChatBot();
    assignSuggestedQuestions();
  }

  @override
  void dispose() {
    _textEditingController.dispose();
    super.dispose();
  }

  Future<List<String>> fetchSuggestedQuestions() async {
    List<String> suggestions = [];
    final document =
        FirebaseFirestore.instance.collection('chat bot').doc(currentUser!.uid);
    DocumentSnapshot<Map<String, dynamic>> snapshot = await document.get();
    if (snapshot.exists) {
      Map<String, dynamic> data = snapshot.data()!;
      if (data.containsKey('suggested_questions')) {
        List<dynamic> list = data['suggested_questions'];
        suggestions = list.cast<String>();
      }
    }
    return suggestions;
  }

  Future<void> assignSuggestedQuestions() async {
    List<String> fetchedQuestions = await fetchSuggestedQuestions();
    setState(() {
      suggestedQuestion = fetchedQuestions;
      suggestedQuestion.shuffle();
    });
  }

  void _sendMessage(String message) async {
    setState(() {
      chatMessages.add(ChatMessage(text: message));
    });
    _textEditingController.clear();
    String apiUrl = 'http://172.16.3.124:8000/umbrellacare/chatbot/';
    Map<String, dynamic> requestBody = {'message': message, 'email': email};
    try {
      http.Response response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );
      if (response.statusCode == 200) {
        Map<String, dynamic> responseData = jsonDecode(response.body);
        dynamic botReply = responseData['success'];
        if (botReply.containsKey('suggested')) {
          String suggested = botReply['suggested'];
          latestResponse = suggested;
        }
        if (botReply is Map<String, dynamic> &&
            botReply.containsKey('message')) {
          String message = botReply['message'];
          setState(() {
            chatMessages.add(ChatMessage(
              text: message,
              isBotReply: true,
            ));
            if (botReply.containsKey('data')) {
              List<dynamic> doctors = botReply['data'];
              for (var doctor in doctors) {
                chatMessages.add(ChatMessage(
                  text: 'Doctor: ${doctor['name']}\n'
                      'qualifications: ${doctor['qualifications']}\n'
                      'specialization: ${doctor['specialization']}',
                  isBotReply: true,
                  onTap: () {
                    print('Doctor card clicked: ${doctor['Name']}');
                    // Perform desired action when doctor card is clicked
                  },
                ));
              }
            }
          });
        }
      } else {
        // Handle API error response
        print('API call failed with status code ${response.statusCode}');
      }
    } catch (e) {
      // Handle API call exception
      print('API call failed: $e');
    }
  }

  Future<void> fetchUserDetails() async {
    if (currentUser != null) {
      final userDoc = FirebaseFirestore.instance
          .collection('patients')
          .doc(currentUser!.uid);
      DocumentSnapshot<Map<String, dynamic>> snapshot = await userDoc.get();
      if (snapshot.exists) {
        Map<String, dynamic> data = snapshot.data()!;
        email = data['email'];
        name = data['name'];
      }
    }
  }

  Future<bool> checkChatBot() async {
    final userDoc =
        FirebaseFirestore.instance.collection('chat bot').doc(currentUser!.uid);
    DocumentSnapshot<Map<String, dynamic>> snapshot = await userDoc.get();
    if (snapshot.exists) {
      return true;
    }
    return false;
  }

  void initializeChatBot() async {
    bool exists = await checkChatBot();
    if (exists) {
      await fetchUserDetails();
      fetchChatBotDetails();
    } else {
      await fetchUserDetails();
      createChatBotData();
    }
  }

  Future<void> createChatBotData() async {
    final userDoc = FirebaseFirestore.instance.collection('chat bot');
    userDoc.doc(currentUser!.uid).set({
      'email': email,
      'name': name,
      'suggested_questions': suggested,
      'not_answered': notAnswered,
      'past_questions': pastQuestion
    });
  }

  Future<void> fetchChatBotDetails() async {
    final userDoc =
        FirebaseFirestore.instance.collection('chat bot').doc(currentUser!.uid);
    DocumentSnapshot<Map<String, dynamic>> snapshot = await userDoc.get();
    if (snapshot.exists) {
      Map<String, dynamic> data = snapshot.data()!;
      email = data['email'];
      name = data['name'];
      List<dynamic> list1 = data['suggested_questions'];
      List<dynamic> list2 = data['not_answered'];
      List<dynamic> list3 = data['past_questions'];
      suggested = list1.cast<String>();
      notAnswered = list2.cast<String>();
      pastQuestion = list3.cast<String>();
    }
  }

  @override
  Widget build(BuildContext context) {
    bool suggestedQuestionsExist = suggestedQuestion.isNotEmpty;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 1,
        title: const Text(
          "Chat Bot",
          style: TextStyle(
              fontSize: 27, fontWeight: FontWeight.w700, color: primary),
        ),
        leading: IconButton(
          onPressed: () {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => const NavBar()));
          },
          icon: const Icon(
            Icons.arrow_back,
            color: primary,
          ),
        ),
      ),
      body: SafeArea(
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    if (suggestedQuestionsExist)
                      ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: 3,
                          itemBuilder: (context, index) {
                            return ChatMessage(
                                text: suggestedQuestion[index],
                                isBotReply: true);
                          }),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(16.0),
                      itemCount: chatMessages.length,
                      itemBuilder: (context, index) {
                        return chatMessages[index];
                      },
                    ),
                  ],
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                padding: const EdgeInsets.all(16.0),
                color: Colors.white,
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _textEditingController,
                        decoration: InputDecoration(
                          hintText: 'Type a message...',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30.0),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16.0),
                    FloatingActionButton(
                      onPressed: () {
                        String message = _textEditingController.text;
                        if (message == "no") {
                          setState(() {
                            chatMessages.add(const ChatMessage(text: "no"));
                          });
                          _textEditingController.clear();
                          return setState(() {
                            chatMessages.add(const ChatMessage(
                              text: "Im sorry.",
                              isBotReply: true,
                            ));
                          });
                        }
                        if (latestResponse != "no" &&
                            (message == "yes" ||
                                message == "yup" ||
                                message == "yeah")) {
                          final tempMessage = latestResponse;
                          _sendMessage(tempMessage);
                          latestResponse = "no";
                        } else {
                          _sendMessage(message);
                        }
                      },
                      backgroundColor: primary,
                      child: const Icon(
                        Icons.send,
                      ),
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class ChatMessage extends StatelessWidget {
  final String text;
  final bool isBotReply;
  final VoidCallback? onTap;

  const ChatMessage({
    Key? key,
    required this.text,
    this.isBotReply = false,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16.0),
        padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
        decoration: BoxDecoration(
            color: isBotReply ? primary : Colors.lightBlue,
            borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(20),
                bottomLeft: Radius.circular(isBotReply ? 0 : 20),
                topRight: const Radius.circular(20),
                bottomRight: Radius.circular(isBotReply ? 20 : 0))),
        child: Text(
          text,
          style: TextStyle(color: isBotReply ? Colors.white : Colors.black),
        ),
      ),
    );
  }
}

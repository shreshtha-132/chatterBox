import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
// import 'htt';
import 'dart:convert';

void main() async {
  await dotenv.load(fileName: "assets/.env");
  runApp(ChatbotApp());
}

class ChatbotApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Chatbot App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: ChatScreen(),
    );
  }
}

class Message {
  final String role;
  final String content;

  Message({required this.role, required this.content});

  Map<String, dynamic> toJson() {
    return {
      "role": role,
      "content": content,
    };
  }
}

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final List<ChatMessage> _messages = [];
  bool _isTyping = false;

  @override
  void initState() {
    super.initState();
    _addInitialBotMessage();
  }

  void _addInitialBotMessage() {
    _addBotMessage(
        "Hello! I am your friendly chatbot. How can I assist you today?");
  }

  void _sendMessage(String message) async {
    if (message.isNotEmpty) {
      _addUserMessage(message);
      final botResponse = await _getBotResponse(message);
      _addBotMessage(botResponse);
    }
  }

  Future<String> _getBotResponse(String userMessage) async {
    final apiKey = dotenv.env['OPENAI_API_KEY'];

    if (apiKey == null) {
      return 'Error: API key not found';
    }

    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $apiKey',
    };

    final body = {
      'model': 'text-davinci-003',
      'prompt': userMessage,
      'max_tokens': 7,
      'temperature': 0,
    };

    final response = await http.post(
      Uri.parse('https://api.openai.com/v1/completions'),
      headers: headers,
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      final botResponse = jsonResponse['choices'][0]['text'];
      return botResponse;
    } else {
      print("siyapaa");
      print(response.statusCode);
      return 'Error: Unable to get bot response';
    }
  }

  void _addUserMessage(String message) {
    setState(() {
      _messages.add(ChatMessage(message: message, isUserMessage: true));
    });
  }

  void _addBotMessage(String message) {
    setState(() {
      _messages.add(ChatMessage(message: message, isUserMessage: false));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chatbot'),
      ),
      body: Column(
        children: [
          Expanded(
            child: MessageList(messages: _messages),
          ),
          UserInput(sendMessage: _sendMessage),
        ],
      ),
    );
  }
}

class MessageList extends StatelessWidget {
  final List<ChatMessage> messages;

  MessageList({required this.messages});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: messages.length,
      itemBuilder: (BuildContext context, int index) {
        return messages[index];
      },
    );
  }
}

class ChatMessage extends StatelessWidget {
  final String message;
  final bool isUserMessage;

  ChatMessage({required this.message, required this.isUserMessage});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(8.0),
      alignment: isUserMessage ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        padding: EdgeInsets.all(10.0),
        decoration: BoxDecoration(
          color: isUserMessage ? Colors.blue : Colors.grey,
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Text(message),
      ),
    );
  }
}

class UserInput extends StatelessWidget {
  final Function(String) sendMessage;

  UserInput({required this.sendMessage});

  final TextEditingController _textEditingController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _textEditingController,
              decoration: InputDecoration(
                hintText: 'Type your message...',
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.send),
            onPressed: () {
              sendMessage(_textEditingController.text);
              _textEditingController.clear();
            },
          ),
        ],
      ),
    );
  }
}

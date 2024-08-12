import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class ChatbotPage extends StatefulWidget {
  const ChatbotPage({super.key});

  @override
  State<ChatbotPage> createState() => _ChatbotPageState();
}

class _ChatbotPageState extends State<ChatbotPage> {
  final TextEditingController _queryController = TextEditingController();
  final List<Map<String, dynamic>> _messages = [];
  final ScrollController _scrollController = ScrollController();

  Future<void> _sendQuery() async {
    String trimmedText = _queryController.text.trim();
    if (trimmedText.isEmpty) {
      print("Cannot send empty query");
      return;
    }
    print("Submitting text: $trimmedText");

    String requestBody = jsonEncode(<String, String>{'query': trimmedText});
    print("Encoded JSON: $requestBody");

    try {
      final response = await http.post(
        Uri.parse('http://192.168.137.1:5000/query'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: requestBody,
      );

      print("Response status: ${response.statusCode}");
      print("Response body: ${response.body}");

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        setState(() {
          _messages.add({'user': trimmedText});
          Future.delayed(const Duration(seconds: 1), () {
            setState(() {
              _messages.add({
                'bot': result['response'],
              });
            });
            _scrollToBottom();
          });
        });
        _queryController.clear();
      } else {
        setState(() {
          _messages.add({'error': 'Error: ${response.body}'});
        });
      }
    } catch (e) {
      print("Error: $e");
      setState(() {
        _messages.add({'error': 'Network error: $e'});
      });
    }
  }

  void _handleSubmitted(String text) {
    _sendQuery();
  }

  void _scrollToBottom() {
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Health Query Chatbot')),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue[100]!, Colors.blue[300]!],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Health Assistant',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[800],
                  ),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  itemCount: _messages.length,
                  itemBuilder: (context, index) {
                    final message = _messages[index];
                    final isUser = message.containsKey('user');
                    final isError = message.containsKey('error');
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 8, horizontal: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (!isUser && !isError) _buildAvatar(Icons.android),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: isUser
                                  ? Colors.blue[100]
                                  : isError
                                      ? Colors.red[100]
                                      : Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 5,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Text(
                              message.values.first,
                              style: TextStyle(
                                fontSize: 16,
                                color: isError ? Colors.red : null,
                              ),
                            ),
                          ),
                          if (isUser) _buildAvatar(Icons.person),
                        ],
                      ),
                    );
                  },
                ),
              ),
              _buildTextComposer(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar(IconData icon) {
    return CircleAvatar(
      backgroundColor: Colors.blue[800],
      child: Icon(icon, color: Colors.white),
    );
  }

  Widget _buildTextComposer() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _queryController,
              onSubmitted: _handleSubmitted,
              decoration: const InputDecoration(
                hintText: "Send a message",
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 16),
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.send, color: Colors.blue[800]),
            onPressed: () => _handleSubmitted(_queryController.text),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';

class MessageDetailsScreen extends StatefulWidget {
  final String personName;
  final String avatar;

  const MessageDetailsScreen({
    super.key,
    required this.personName,
    required this.avatar,
  });

  @override
  State<MessageDetailsScreen> createState() =>
      _MessageDetailsScreenState();
}

class _MessageDetailsScreenState
    extends State<MessageDetailsScreen> {
  final TextEditingController _messageController =
  TextEditingController();

  final ScrollController _scrollController =
  ScrollController();

  final List<Map<String, dynamic>> _messages = [];

  @override
  void initState() {
    super.initState();
    _loadSampleMessages();
  }

  void _loadSampleMessages() {
    if (widget.personName == "Sarah Lee") {
      _messages.addAll([
        {
          "message":
          "Hi! Is the vegetable soup still available?",
          "isMe": false,
          "time": "10:30 AM",
        },
        {
          "message": "Yes, it is still available!",
          "isMe": true,
          "time": "10:32 AM",
        },
        {
          "message":
          "Great! I would like to request it.",
          "isMe": false,
          "time": "10:33 AM",
        },
      ]);
    } else if (widget.personName == "John Doe") {
      _messages.addAll([
        {
          "message":
          "Thank you for accepting my food request!",
          "isMe": false,
          "time": "9:15 AM",
        },
        {
          "message":
          "You're welcome! I'm happy to help.",
          "isMe": true,
          "time": "9:20 AM",
        },
      ]);
    } else if (widget.personName == "Michael Smith") {
      _messages.addAll([
        {
          "message":
          "I will pick up the bread tomorrow.",
          "isMe": false,
          "time": "Yesterday",
        },
        {
          "message":
          "Sounds good. I'll have it ready for you.",
          "isMe": true,
          "time": "Yesterday",
        },
      ]);
    } else if (widget.personName == "Jessica Brown") {
      _messages.addAll([
        {
          "message":
          "Thank you for helping our community.",
          "isMe": false,
          "time": "Yesterday",
        },
        {
          "message": "You're very welcome!",
          "isMe": true,
          "time": "Yesterday",
        },
      ]);
    } else {
      _messages.add({
        "message":
        "Hello! Welcome to NeighbourShare.",
        "isMe": false,
        "time": "Now",
      });
    }
  }

  void _sendMessage() {
    final message =
    _messageController.text.trim();

    if (message.isEmpty) {
      return;
    }

    setState(() {
      _messages.add({
        "message": message,
        "isMe": true,
        "time": _currentTime(),
      });

      _messageController.clear();
    });

    _scrollToBottom();
  }

  String _currentTime() {
    final now = DateTime.now();

    final hour = now.hour == 0
        ? 12
        : now.hour > 12
        ? now.hour - 12
        : now.hour;

    final minute =
    now.minute.toString().padLeft(2, "0");

    final period =
    now.hour >= 12 ? "PM" : "AM";

    return "$hour:$minute $period";
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration:
          const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
      const Color(0xFFF4F7F5),

      appBar: AppBar(
        backgroundColor:
        const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
        title: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: Colors.white,
              child: Text(
                widget.avatar,
                style: const TextStyle(
                  color: Color(0xFF2E7D32),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                widget.personName,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
                overflow:
                TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),

      body: Column(
        children: [
          Expanded(
            child: _messages.isEmpty
                ? _buildEmptyChat()
                : ListView.builder(
              controller:
              _scrollController,
              padding:
              const EdgeInsets.fromLTRB(
                16,
                20,
                16,
                20,
              ),
              itemCount:
              _messages.length,
              itemBuilder:
                  (context, index) {
                return _buildMessageBubble(
                  _messages[index],
                );
              },
            ),
          ),

          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(
      Map<String, dynamic> message,
      ) {
    final bool isMe =
    message["isMe"] as bool;

    final String text =
    message["message"] as String;

    final String time =
    message["time"] as String;

    return Align(
      alignment: isMe
          ? Alignment.centerRight
          : Alignment.centerLeft,
      child: Container(
        constraints:
        const BoxConstraints(
          maxWidth: 300,
        ),
        margin:
        const EdgeInsets.only(bottom: 12),
        padding:
        const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        decoration: BoxDecoration(
          color: isMe
              ? const Color(0xFF2E7D32)
              : Colors.white,
          borderRadius:
          BorderRadius.only(
            topLeft:
            const Radius.circular(18),
            topRight:
            const Radius.circular(18),
            bottomLeft:
            Radius.circular(
              isMe ? 18 : 4,
            ),
            bottomRight:
            Radius.circular(
              isMe ? 4 : 18,
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(
                alpha: 0.05,
              ),
              blurRadius: 4,
              offset:
              const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: isMe
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          children: [
            Text(
              text,
              style: TextStyle(
                color: isMe
                    ? Colors.white
                    : Colors.black87,
                fontSize: 15,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              time,
              style: TextStyle(
                color: isMe
                    ? Colors.white70
                    : Colors.grey.shade500,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding:
      const EdgeInsets.fromLTRB(
        12,
        10,
        12,
        12,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(
              alpha: 0.08,
            ),
            blurRadius: 8,
            offset:
            const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          crossAxisAlignment:
          CrossAxisAlignment.end,
          children: [
            Expanded(
              child: TextField(
                controller:
                _messageController,
                minLines: 1,
                maxLines: 4,
                textCapitalization:
                TextCapitalization.sentences,
                decoration:
                InputDecoration(
                  hintText:
                  "Type a message...",
                  filled: true,
                  fillColor:
                  const Color(0xFFF4F7F5),
                  contentPadding:
                  const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  border:
                  OutlineInputBorder(
                    borderRadius:
                    BorderRadius.circular(24),
                    borderSide:
                    BorderSide.none,
                  ),
                ),
                onSubmitted: (_) {
                  _sendMessage();
                },
              ),
            ),
            const SizedBox(width: 8),
            Container(
              decoration:
              const BoxDecoration(
                color: Color(0xFF2E7D32),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                onPressed: _sendMessage,
                icon: const Icon(Icons.send),
                color: Colors.white,
                tooltip: "Send message",
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyChat() {
    return Center(
      child: Padding(
        padding:
        const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment:
          MainAxisAlignment.center,
          children: [
            Icon(
              Icons.chat_bubble_outline,
              size: 80,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 20),
            const Text(
              "Start a Conversation",
              style: TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              "Send a message to "
                  "${widget.personName}.",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';

class MessageComposeScreen extends StatefulWidget {
  final String donorName;
  final String? listingName;
  final ValueChanged<String>? onSend;

  const MessageComposeScreen({
    super.key,
    required this.donorName,
    this.listingName,
    this.onSend,
  });

  @override
  State<MessageComposeScreen> createState() => _MessageComposeScreenState();
}

class _MessageComposeScreenState extends State<MessageComposeScreen> {
  final TextEditingController _messageController = TextEditingController();
  String? _validationMessage;

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final message = _messageController.text.trim();

    if (message.isEmpty) {
      setState(() {
        _validationMessage = 'Enter a message before sending.';
      });
      return;
    }

    widget.onSend?.call(message);
    setState(() {
      _validationMessage = null;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Message ready to send.'),
        backgroundColor: Color(0xFF2E7D32),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F5),
      appBar: AppBar(
        title: const Text('New Message'),
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Message recipient',
                    style: TextStyle(
                      color: Colors.grey.shade700,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: const Color(0xFFE8F5E9),
                        child: Text(
                          widget.donorName.characters.first.toUpperCase(),
                          style: const TextStyle(
                            color: Color(0xFF2E7D32),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          widget.donorName,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (widget.listingName?.trim().isNotEmpty == true) ...[
                    const SizedBox(height: 14),
                    Text(
                      'Regarding: ${widget.listingName}',
                      style: TextStyle(color: Colors.grey.shade700),
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _messageController,
            maxLines: 6,
            textCapitalization: TextCapitalization.sentences,
            decoration: InputDecoration(
              labelText: 'Message',
              hintText: 'Write a message to the donor',
              alignLabelWithHint: true,
              prefixIcon: const Icon(Icons.message_outlined),
              errorText: _validationMessage,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _sendMessage,
              icon: const Icon(Icons.send_outlined),
              label: const Text('Send Message'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2E7D32),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(13),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

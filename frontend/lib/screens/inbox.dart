import 'package:flutter/material.dart';
import 'message_details.dart';

class InboxScreen extends StatefulWidget {
  const InboxScreen({super.key});

  @override
  State<InboxScreen> createState() =>
      _InboxScreenState();
}

class _InboxScreenState extends State<InboxScreen> {
  final List<Map<String, dynamic>> _conversations = [
    {
      "name": "Sarah Lee",
      "message":
      "Hi! Is the vegetable soup still available?",
      "time": "5 min ago",
      "unread": true,
      "count": 2,
      "avatar": "S",
    },
    {
      "name": "John Doe",
      "message":
      "Thank you for accepting my food request!",
      "time": "1 hour ago",
      "unread": true,
      "count": 1,
      "avatar": "J",
    },
    {
      "name": "Michael Smith",
      "message":
      "I will pick up the bread tomorrow.",
      "time": "3 hours ago",
      "unread": false,
      "count": 0,
      "avatar": "M",
    },
    {
      "name": "Jessica Brown",
      "message":
      "Thank you for helping our community.",
      "time": "Yesterday",
      "unread": false,
      "count": 0,
      "avatar": "J",
    },
  ];

  String _searchText = "";

  List<Map<String, dynamic>>
  get _filteredConversations {
    if (_searchText.trim().isEmpty) {
      return _conversations;
    }

    final search =
    _searchText.toLowerCase().trim();

    return _conversations.where((conversation) {
      final name = conversation["name"]
          .toString()
          .toLowerCase();

      final message = conversation["message"]
          .toString()
          .toLowerCase();

      return name.contains(search) ||
          message.contains(search);
    }).toList();
  }

  int get _unreadConversationCount {
    return _conversations
        .where(
          (conversation) =>
      conversation["unread"] == true,
    )
        .length;
  }

  // ==========================================
  // OPEN ACTUAL CONVERSATION
  // ==========================================

  void _openConversation(
      Map<String, dynamic> conversation,
      ) {
    setState(() {
      conversation["unread"] = false;
      conversation["count"] = 0;
    });

    final String name =
    conversation["name"] as String;

    final String avatar =
    conversation["avatar"] as String;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MessageDetailsScreen(
          personName: name,
          avatar: avatar,
        ),
      ),
    );
  }

  // ==========================================
  // MARK ALL AS READ
  // ==========================================

  void _markAllAsRead() {
    setState(() {
      for (final conversation
      in _conversations) {
        conversation["unread"] = false;
        conversation["count"] = 0;
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content:
        Text("All messages marked as read."),
        backgroundColor:
        Color(0xFF2E7D32),
      ),
    );
  }

  // ==========================================
  // DELETE CONVERSATION
  // ==========================================

  void _deleteConversation(int index) {
    final conversation =
    _filteredConversations[index];

    final originalIndex =
    _conversations.indexOf(conversation);

    final name = conversation["name"];

    setState(() {
      _conversations.removeAt(originalIndex);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          "Conversation with $name deleted.",
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final conversations =
        _filteredConversations;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Inbox",
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor:
        const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
        actions: [
          if (_unreadConversationCount > 0)
            TextButton(
              onPressed: _markAllAsRead,
              child: const Text(
                "Mark all read",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                ),
              ),
            ),
        ],
      ),

      body: Column(
        children: [
          // ==========================================
          // SEARCH
          // ==========================================

          Padding(
            padding:
            const EdgeInsets.fromLTRB(
              16,
              16,
              16,
              8,
            ),
            child: TextField(
              onChanged: (value) {
                setState(() {
                  _searchText = value;
                });
              },
              decoration: InputDecoration(
                hintText:
                "Search messages or people",
                prefixIcon:
                const Icon(Icons.search),
                suffixIcon:
                _searchText.isNotEmpty
                    ? IconButton(
                  onPressed: () {
                    setState(() {
                      _searchText = "";
                    });
                  },
                  icon: const Icon(
                    Icons.clear,
                  ),
                )
                    : null,
                filled: true,
                fillColor: Colors.white,
                border:
                OutlineInputBorder(
                  borderRadius:
                  BorderRadius.circular(14),
                  borderSide:
                  BorderSide(
                    color:
                    Colors.grey.shade300,
                  ),
                ),
                enabledBorder:
                OutlineInputBorder(
                  borderRadius:
                  BorderRadius.circular(14),
                  borderSide:
                  BorderSide(
                    color:
                    Colors.grey.shade300,
                  ),
                ),
              ),
            ),
          ),

          // ==========================================
          // UNREAD SUMMARY
          // ==========================================

          if (_unreadConversationCount > 0 &&
              _searchText.isEmpty)
            Container(
              width: double.infinity,
              margin:
              const EdgeInsets.fromLTRB(
                16,
                8,
                16,
                8,
              ),
              padding:
              const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color:
                const Color(0xFFE8F5E9),
                borderRadius:
                BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons
                        .mark_email_unread_outlined,
                    color:
                    Color(0xFF2E7D32),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    "$_unreadConversationCount unread "
                        "conversation"
                        "${_unreadConversationCount == 1 ? '' : 's'}",
                    style: const TextStyle(
                      color:
                      Color(0xFF2E7D32),
                      fontWeight:
                      FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

          // ==========================================
          // CONVERSATIONS
          // ==========================================

          Expanded(
            child: conversations.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
              padding:
              const EdgeInsets.all(16),
              itemCount:
              conversations.length,
              itemBuilder:
                  (context, index) {
                return _buildConversationCard(
                  conversations[index],
                  index,
                );
              },
            ),
          ),
        ],
      ),

      // ==========================================
      // NEW MESSAGE BUTTON
      // ==========================================

      floatingActionButton:
      FloatingActionButton(
        backgroundColor:
        const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
        tooltip: "New Message",
        onPressed: () {
          _showNewMessageDialog();
        },
        child: const Icon(
          Icons.edit_outlined,
        ),
      ),
    );
  }

  // ==========================================
  // CONVERSATION CARD
  // ==========================================

  Widget _buildConversationCard(
      Map<String, dynamic> conversation,
      int index,
      ) {
    final String name =
    conversation["name"] as String;

    final String message =
    conversation["message"] as String;

    final String time =
    conversation["time"] as String;

    final bool unread =
    conversation["unread"] as bool;

    final int count =
    conversation["count"] as int;

    final String avatar =
    conversation["avatar"] as String;

    return Dismissible(
      key: ValueKey(
        "$name-$index",
      ),
      direction:
      DismissDirection.endToStart,
      background: Container(
        margin:
        const EdgeInsets.only(
          bottom: 12,
        ),
        padding:
        const EdgeInsets.only(
          right: 20,
        ),
        alignment:
        Alignment.centerRight,
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius:
          BorderRadius.circular(16),
        ),
        child: const Icon(
          Icons.delete,
          color: Colors.white,
        ),
      ),
      onDismissed: (_) {
        _deleteConversation(index);
      },
      child: Card(
        margin:
        const EdgeInsets.only(
          bottom: 12,
        ),
        elevation:
        unread ? 4 : 1,
        shape:
        RoundedRectangleBorder(
          borderRadius:
          BorderRadius.circular(16),
        ),
        child: InkWell(
          onTap: () {
            _openConversation(
              conversation,
            );
          },
          borderRadius:
          BorderRadius.circular(16),
          child: Padding(
            padding:
            const EdgeInsets.all(15),
            child: Row(
              children: [
                // ==========================================
                // AVATAR
                // ==========================================

                Stack(
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundColor:
                      const Color(
                        0xFFE8F5E9,
                      ),
                      child: Text(
                        avatar,
                        style:
                        const TextStyle(
                          color:
                          Color(
                            0xFF2E7D32,
                          ),
                          fontSize: 20,
                          fontWeight:
                          FontWeight.bold,
                        ),
                      ),
                    ),

                    if (unread)
                      Positioned(
                        right: 0,
                        top: 0,
                        child: Container(
                          width: 13,
                          height: 13,
                          decoration:
                          const BoxDecoration(
                            color:
                            Colors.red,
                            shape:
                            BoxShape.circle,
                          ),
                        ),
                      ),
                  ],
                ),

                const SizedBox(width: 14),

                // ==========================================
                // MESSAGE CONTENT
                // ==========================================

                Expanded(
                  child: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              name,
                              style:
                              TextStyle(
                                fontSize: 16,
                                fontWeight:
                                unread
                                    ? FontWeight.bold
                                    : FontWeight.w600,
                              ),
                            ),
                          ),
                          Text(
                            time,
                            style:
                            TextStyle(
                              fontSize: 12,
                              color: Colors
                                  .grey.shade500,
                              fontWeight:
                              unread
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 6),

                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              message,
                              maxLines: 2,
                              overflow:
                              TextOverflow.ellipsis,
                              style:
                              TextStyle(
                                fontSize: 14,
                                color: Colors
                                    .grey.shade700,
                                fontWeight:
                                unread
                                    ? FontWeight.w600
                                    : FontWeight.normal,
                                height: 1.3,
                              ),
                            ),
                          ),

                          if (count > 0)
                            Container(
                              margin:
                              const EdgeInsets.only(
                                left: 8,
                              ),
                              padding:
                              const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration:
                              const BoxDecoration(
                                color:
                                Color(0xFF2E7D32),
                                shape:
                                BoxShape.circle,
                              ),
                              child: Text(
                                count.toString(),
                                style:
                                const TextStyle(
                                  color:
                                  Colors.white,
                                  fontSize: 11,
                                  fontWeight:
                                  FontWeight.bold,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 5),

                const Icon(
                  Icons.chevron_right,
                  color: Colors.grey,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ==========================================
  // EMPTY STATE
  // ==========================================

  Widget _buildEmptyState() {
    final bool isSearching =
        _searchText.trim().isNotEmpty;

    return Center(
      child: Padding(
        padding:
        const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment:
          MainAxisAlignment.center,
          children: [
            Icon(
              isSearching
                  ? Icons.search_off
                  : Icons.mail_outline,
              size: 85,
              color:
              Colors.grey.shade400,
            ),

            const SizedBox(height: 20),

            Text(
              isSearching
                  ? "No Conversations Found"
                  : "Your Inbox Is Empty",
              style: const TextStyle(
                fontSize: 21,
                fontWeight:
                FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            Text(
              isSearching
                  ? "Try searching for another person "
                  "or message."
                  : "Your conversations and messages "
                  "will appear here.",
              textAlign:
              TextAlign.center,
              style: TextStyle(
                color:
                Colors.grey.shade600,
                fontSize: 15,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // NEW MESSAGE DIALOG
  // ==========================================

  void _showNewMessageDialog() {
    final nameController =
    TextEditingController();

    final messageController =
    TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape:
          RoundedRectangleBorder(
            borderRadius:
            BorderRadius.circular(18),
          ),
          title:
          const Text("New Message"),
          content: Column(
            mainAxisSize:
            MainAxisSize.min,
            children: [
              TextField(
                controller:
                nameController,
                decoration:
                const InputDecoration(
                  labelText:
                  "Recipient",
                  prefixIcon:
                  Icon(Icons.person),
                ),
              ),

              const SizedBox(height: 15),

              TextField(
                controller:
                messageController,
                maxLines: 3,
                decoration:
                const InputDecoration(
                  labelText:
                  "Message",
                  alignLabelWithHint: true,
                  prefixIcon:
                  Icon(Icons.message),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child:
              const Text("Cancel"),
            ),

            ElevatedButton(
              onPressed: () {
                final name =
                nameController.text
                    .trim();

                final message =
                messageController.text
                    .trim();

                if (name.isEmpty ||
                    message.isEmpty) {
                  return;
                }

                setState(() {
                  _conversations.insert(
                    0,
                    {
                      "name": name,
                      "message": message,
                      "time": "Just now",
                      "unread": false,
                      "count": 0,
                      "avatar": name
                          .substring(0, 1)
                          .toUpperCase(),
                    },
                  );
                });

                Navigator.pop(context);

                ScaffoldMessenger.of(
                  this.context,
                ).showSnackBar(
                  const SnackBar(
                    content: Text(
                      "Message conversation created.",
                    ),
                    backgroundColor:
                    Color(0xFF2E7D32),
                  ),
                );
              },
              style:
              ElevatedButton.styleFrom(
                backgroundColor:
                const Color(0xFF2E7D32),
                foregroundColor:
                Colors.white,
              ),
              child:
              const Text("Send"),
            ),
          ],
        );
      },
    );
  }
}
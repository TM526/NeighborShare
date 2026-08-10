import 'package:flutter/material.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() =>
      _NotificationsScreenState();
}

class _NotificationsScreenState
    extends State<NotificationsScreen> {
  final List<Map<String, dynamic>> _notifications = [
    {
      "title": "New Food Request",
      "message":
      "Sarah has requested your Vegetable Soup donation.",
      "time": "5 minutes ago",
      "type": "request",
      "status": null,
      "read": false,
    },
    {
      "title": "Request Approved",
      "message":
      "Your request for Fresh Bread has been approved.",
      "time": "1 hour ago",
      "type": "status",
      "status": "approved",
      "read": false,
    },
    {
      "title": "New Message",
      "message":
      "You received a new message from John.",
      "time": "2 hours ago",
      "type": "message",
      "status": null,
      "read": false,
    },
    {
      "title": "Request Completed",
      "message":
      "Your request for Vegetable Soup has been completed.",
      "time": "Yesterday",
      "type": "status",
      "status": "completed",
      "read": true,
    },
  ];

  // ==========================================
  // UNREAD COUNT
  // ==========================================

  int get _unreadCount {
    return _notifications
        .where(
          (notification) =>
      notification["read"] == false,
    )
        .length;
  }

  // ==========================================
  // NOTIFICATION ICON
  // ==========================================

  IconData _getNotificationIcon(String type) {
    switch (type) {
      case "request":
        return Icons.volunteer_activism;

      case "status":
        return Icons.sync_alt;

      case "message":
        return Icons.message_outlined;

      default:
        return Icons.notifications_outlined;
    }
  }

  // ==========================================
  // NOTIFICATION COLOR
  // ==========================================

  Color _getNotificationColor(
      String type,
      String? status,
      ) {
    if (type == "status") {
      switch (status) {
        case "pending":
          return Colors.orange;

        case "approved":
          return Colors.green;

        case "rejected":
          return Colors.red;

        case "completed":
          return Colors.blue;
      }
    }

    switch (type) {
      case "request":
        return Colors.orange;

      case "message":
        return Colors.blue;

      default:
        return const Color(0xFF2E7D32);
    }
  }

  // ==========================================
  // STATUS TITLE
  // ==========================================

  String _getStatusTitle(String status) {
    switch (status) {
      case "pending":
        return "Request Pending";

      case "approved":
        return "Request Approved";

      case "rejected":
        return "Request Rejected";

      case "completed":
        return "Request Completed";

      default:
        return "Request Status Updated";
    }
  }

  // ==========================================
  // ADD STATUS CHANGE NOTIFICATION
  // ==========================================

  void _addStatusNotification({
    required String foodName,
    required String status,
  }) {
    String message;

    switch (status) {
      case "pending":
        message =
        "Your request for $foodName is currently being reviewed.";
        break;

      case "approved":
        message =
        "Your request for $foodName has been approved by the donor.";
        break;

      case "rejected":
        message =
        "Unfortunately, your request for $foodName was rejected.";
        break;

      case "completed":
        message =
        "Your request for $foodName has been completed successfully.";
        break;

      default:
        message =
        "The status of your $foodName request has been updated.";
    }

    setState(() {
      _notifications.insert(
        0,
        {
          "title": _getStatusTitle(status),
          "message": message,
          "time": "Just now",
          "type": "status",
          "status": status,
          "read": false,
        },
      );
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _getStatusTitle(status),
        ),
        backgroundColor:
        _getNotificationColor(
          "status",
          status,
        ),
      ),
    );
  }

  // ==========================================
  // MARK ONE AS READ
  // ==========================================

  void _markAsRead(int index) {
    setState(() {
      _notifications[index]["read"] = true;
    });
  }

  // ==========================================
  // MARK ALL AS READ
  // ==========================================

  void _markAllAsRead() {
    setState(() {
      for (final notification in _notifications) {
        notification["read"] = true;
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content:
        Text("All notifications marked as read."),
        backgroundColor:
        Color(0xFF2E7D32),
      ),
    );
  }

  // ==========================================
  // DELETE NOTIFICATION
  // ==========================================

  void _deleteNotification(int index) {
    final notificationTitle =
    _notifications[index]["title"];

    setState(() {
      _notifications.removeAt(index);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          "$notificationTitle notification removed.",
        ),
      ),
    );
  }

  // ==========================================
  // OPEN NOTIFICATION
  // ==========================================

  void _openNotification(int index) {
    _markAsRead(index);

    final notification =
    _notifications[index];

    showDialog(
      context: context,
      builder: (context) {
        final String type =
        notification["type"] as String;

        final String? status =
        notification["status"] as String?;

        final Color color =
        _getNotificationColor(
          type,
          status,
        );

        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius:
            BorderRadius.circular(18),
          ),
          title: Row(
            children: [
              Icon(
                _getNotificationIcon(type),
                color: color,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  notification["title"],
                ),
              ),
            ],
          ),
          content: Text(
            notification["message"],
            style: const TextStyle(
              height: 1.5,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("Close"),
            ),
          ],
        );
      },
    );
  }

  // ==========================================
  // BUILD SCREEN
  // ==========================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Notifications",
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor:
        const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
        actions: [
          if (_unreadCount > 0)
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

      body: _notifications.isEmpty
          ? _buildEmptyState()
          : Column(
        children: [
          // ==========================================
          // UNREAD SUMMARY
          // ==========================================

          if (_unreadCount > 0)
            Container(
              width: double.infinity,
              margin:
              const EdgeInsets.fromLTRB(
                16,
                16,
                16,
                5,
              ),
              padding:
              const EdgeInsets.all(15),
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
                        .notifications_active,
                    color:
                    Color(0xFF2E7D32),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    "$_unreadCount unread notification"
                        "${_unreadCount == 1 ? '' : 's'}",
                    style:
                    const TextStyle(
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
          // NOTIFICATIONS
          // ==========================================

          Expanded(
            child:
            ListView.builder(
              padding:
              const EdgeInsets.all(16),
              itemCount:
              _notifications.length,
              itemBuilder:
                  (context, index) {
                return
                  _buildNotificationCard(
                    index,
                  );
              },
            ),
          ),
        ],
      ),

      // ==========================================
      // DEMO STATUS BUTTON
      // ==========================================
      //
      // This is for demonstrating R6 while the
      // backend is not connected yet.
      //
      floatingActionButton:
      FloatingActionButton.extended(
        backgroundColor:
        const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
        onPressed: () {
          _showStatusDemoMenu();
        },
        icon: const Icon(
          Icons.sync_alt,
        ),
        label: const Text(
          "Test Status",
        ),
      ),
    );
  }

  // ==========================================
  // STATUS DEMO MENU
  // ==========================================

  void _showStatusDemoMenu() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(24),
        ),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize:
              MainAxisSize.min,
              crossAxisAlignment:
              CrossAxisAlignment.stretch,
              children: [
                const Text(
                  "Test Request Status",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  "Choose a status to create a sample notification.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color:
                    Colors.grey.shade600,
                  ),
                ),

                const SizedBox(height: 20),

                _statusButton(
                  context,
                  "Pending",
                  Icons.hourglass_empty,
                  Colors.orange,
                  "pending",
                ),

                const SizedBox(height: 10),

                _statusButton(
                  context,
                  "Approved",
                  Icons.check_circle_outline,
                  Colors.green,
                  "approved",
                ),

                const SizedBox(height: 10),

                _statusButton(
                  context,
                  "Rejected",
                  Icons.cancel_outlined,
                  Colors.red,
                  "rejected",
                ),

                const SizedBox(height: 10),

                _statusButton(
                  context,
                  "Completed",
                  Icons.done_all,
                  Colors.blue,
                  "completed",
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ==========================================
  // STATUS BUTTON
  // ==========================================

  Widget _statusButton(
      BuildContext context,
      String title,
      IconData icon,
      Color color,
      String status,
      ) {
    return SizedBox(
      height: 50,
      child: ElevatedButton.icon(
        icon: Icon(icon),
        label: Text(
          title,
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius:
            BorderRadius.circular(12),
          ),
        ),
        onPressed: () {
          Navigator.pop(context);

          _addStatusNotification(
            foodName: "Vegetable Soup",
            status: status,
          );
        },
      ),
    );
  }

  // ==========================================
  // NOTIFICATION CARD
  // ==========================================

  Widget _buildNotificationCard(
      int index,
      ) {
    final notification =
    _notifications[index];

    final String title =
    notification["title"] as String;

    final String message =
    notification["message"] as String;

    final String time =
    notification["time"] as String;

    final String type =
    notification["type"] as String;

    final String? status =
    notification["status"] as String?;

    final bool isRead =
    notification["read"] as bool;

    final Color notificationColor =
    _getNotificationColor(
      type,
      status,
    );

    return Dismissible(
      key: ValueKey(
        "$title-$index-${notification["time"]}",
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
        _deleteNotification(index);
      },

      child: Card(
        margin:
        const EdgeInsets.only(
          bottom: 12,
        ),
        elevation:
        isRead ? 1 : 4,
        shape:
        RoundedRectangleBorder(
          borderRadius:
          BorderRadius.circular(16),
        ),
        child: InkWell(
          onTap: () {
            _openNotification(index);
          },
          borderRadius:
          BorderRadius.circular(16),
          child: Padding(
            padding:
            const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                // ==========================================
                // ICON
                // ==========================================

                Container(
                  width: 50,
                  height: 50,
                  decoration:
                  BoxDecoration(
                    color:
                    notificationColor
                        .withValues(
                      alpha: 0.12,
                    ),
                    borderRadius:
                    BorderRadius.circular(
                      14,
                    ),
                  ),
                  child: Icon(
                    _getNotificationIcon(
                      type,
                    ),
                    color:
                    notificationColor,
                    size: 27,
                  ),
                ),

                const SizedBox(
                  width: 14,
                ),

                // ==========================================
                // CONTENT
                // ==========================================

                Expanded(
                  child: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment
                        .start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              title,
                              style:
                              TextStyle(
                                fontSize: 16,
                                fontWeight:
                                isRead
                                    ? FontWeight
                                    .w600
                                    : FontWeight
                                    .bold,
                              ),
                            ),
                          ),

                          if (!isRead)
                            Container(
                              width: 9,
                              height: 9,
                              decoration:
                              const BoxDecoration(
                                color: Color(
                                  0xFF2E7D32,
                                ),
                                shape:
                                BoxShape
                                    .circle,
                              ),
                            ),
                        ],
                      ),

                      const SizedBox(
                        height: 6,
                      ),

                      Text(
                        message,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors
                              .grey
                              .shade700,
                          height: 1.35,
                        ),
                      ),

                      const SizedBox(
                        height: 8,
                      ),

                      Row(
                        children: [
                          Icon(
                            Icons.access_time,
                            size: 14,
                            color: Colors
                                .grey
                                .shade500,
                          ),
                          const SizedBox(
                            width: 4,
                          ),
                          Text(
                            time,
                            style:
                            TextStyle(
                              fontSize: 12,
                              color: Colors
                                  .grey
                                  .shade500,
                            ),
                          ),
                        ],
                      ),

                      // Status badge
                      if (status != null)
                        Padding(
                          padding:
                          const EdgeInsets
                              .only(
                            top: 10,
                          ),
                          child:
                          _buildStatusBadge(
                            status,
                          ),
                        ),
                    ],
                  ),
                ),

                const SizedBox(
                  width: 5,
                ),

                // ==========================================
                // OPTIONS
                // ==========================================

                PopupMenuButton<String>(
                  onSelected:
                      (value) {
                    if (value ==
                        "read") {
                      _markAsRead(
                        index,
                      );
                    } else if (value ==
                        "delete") {
                      _deleteNotification(
                        index,
                      );
                    }
                  },
                  itemBuilder:
                      (context) => [
                    if (!isRead)
                      const PopupMenuItem<
                          String>(
                        value: "read",
                        child: Row(
                          children: [
                            Icon(
                              Icons.done,
                              color:
                              Colors.green,
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            Text(
                              "Mark as read",
                            ),
                          ],
                        ),
                      ),

                    const PopupMenuItem<
                        String>(
                      value: "delete",
                      child: Row(
                        children: [
                          Icon(
                            Icons
                                .delete_outline,
                            color:
                            Colors.red,
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          Text(
                            "Delete",
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ==========================================
  // STATUS BADGE
  // ==========================================

  Widget _buildStatusBadge(
      String status,
      ) {
    Color color;
    String text;
    IconData icon;

    switch (status) {
      case "pending":
        color = Colors.orange;
        text = "Pending";
        icon =
            Icons.hourglass_empty;
        break;

      case "approved":
        color = Colors.green;
        text = "Approved";
        icon =
            Icons.check_circle_outline;
        break;

      case "rejected":
        color = Colors.red;
        text = "Rejected";
        icon =
            Icons.cancel_outlined;
        break;

      case "completed":
        color = Colors.blue;
        text = "Completed";
        icon = Icons.done_all;
        break;

      default:
        color =
        const Color(0xFF2E7D32);
        text = "Updated";
        icon =
            Icons.sync_alt;
    }

    return Container(
      padding:
      const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: color.withValues(
          alpha: 0.12,
        ),
        borderRadius:
        BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize:
        MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 15,
            color: color,
          ),
          const SizedBox(
            width: 5,
          ),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight:
              FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // EMPTY STATE
  // ==========================================

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding:
        const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment:
          MainAxisAlignment.center,
          children: [
            Icon(
              Icons.notifications_none,
              size: 90,
              color:
              Colors.grey.shade400,
            ),

            const SizedBox(
              height: 20,
            ),

            const Text(
              "No Notifications",
              style: TextStyle(
                fontSize: 22,
                fontWeight:
                FontWeight.bold,
              ),
            ),

            const SizedBox(
              height: 10,
            ),

            Text(
              "You're all caught up! New "
                  "notifications will appear here.",
              textAlign:
              TextAlign.center,
              style: TextStyle(
                color:
                Colors.grey.shade600,
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
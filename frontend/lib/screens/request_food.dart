import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../services/api_config.dart';

class RequestFoodScreen extends StatefulWidget {
  final Map<String, String> foodItem;

  // Temporary default for testing until recipient login/session is added.
  final int recipientId;

  const RequestFoodScreen({
    super.key,
    required this.foodItem,
    this.recipientId = 1,
  });

  @override
  State<RequestFoodScreen> createState() => _RequestFoodScreenState();
}

class _RequestFoodScreenState extends State<RequestFoodScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();

  final List<String> _pickupTimes = const [
    'Morning',
    'Afternoon',
    'Evening',
  ];

  String _pickupTime = 'Morning';
  bool _isSubmitting = false;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  String? _requiredValidator(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }

    return null;
  }

  Future<void> _submitRequest() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    final listingId =
        int.tryParse(widget.foodItem['listing_id']?.trim() ?? '');

    if (listingId == null || listingId <= 0) {
      _showError(
        'This listing does not have a valid listing ID. Return to Browse Listings and try again.',
      );
      return;
    }

    final recipientId = widget.recipientId;

    if (recipientId <= 0) {
      _showError(
        'A valid recipient profile is required before requesting food.',
      );
      return;
    }

    final requestMessage = [
      'Requester: ${_nameController.text.trim()}',
      'Phone: ${_phoneController.text.trim()}',
      'Preferred pickup time: $_pickupTime',
      'Message: ${_messageController.text.trim()}',
    ].join('\n');

    setState(() {
      _isSubmitting = true;
    });

    try {
      final response = await http
          .post(
            Uri.parse('$apiBaseUrl/requests'),
            headers: const {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: jsonEncode({
              'listing_id': listingId,
              'recipient_id': recipientId,
              'message': requestMessage,
            }),
          )
          .timeout(const Duration(seconds: 20));

      Map<String, dynamic>? responseData;

      if (response.body.isNotEmpty) {
        try {
          final decoded = jsonDecode(response.body);

          if (decoded is Map<String, dynamic>) {
            responseData = decoded;
          }
        } catch (_) {
          responseData = null;
        }
      }

      if (!mounted) return;

      setState(() {
        _isSubmitting = false;
      });

      if (response.statusCode == 201) {
        await _showSuccessDialog();
        return;
      }

      _showError(
        responseData?['message']?.toString() ??
            'Unable to submit the request. Server returned ${response.statusCode}.',
      );
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _isSubmitting = false;
      });

      _showError(
        'Could not connect to the backend. Make sure the Node server is running.',
      );

      debugPrint('Submit food request error: $error');
    }
  }

  Future<void> _showSuccessDialog() async {
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          icon: const Icon(
            Icons.check_circle,
            color: Color(0xFF2E7D32),
            size: 60,
          ),
          title: const Text('Request Submitted'),
          content: const Text(
            'Your food request was saved successfully.',
            textAlign: TextAlign.center,
          ),
          actions: [
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF2E7D32),
                ),
                onPressed: () {
                  Navigator.of(dialogContext).pop();
                  Navigator.of(context).pop(true);
                },
                child: const Text('Back to Listings'),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red.shade700,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final foodName = widget.foodItem['name'] ?? 'Food item';

    final foodSummary = [
      widget.foodItem['quantity'],
      widget.foodItem['location'],
    ].where((value) => value != null && value.trim().isNotEmpty).join(' • ');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Request Food'),
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Container(
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              color: Colors.green.shade50,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.fastfood,
                              color: Color(0xFF2E7D32),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  foodName,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                if (foodSummary.isNotEmpty) ...[
                                  const SizedBox(height: 4),
                                  Text(
                                    foodSummary,
                                    style: TextStyle(
                                      color: Colors.grey.shade700,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Request a Food Donation',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Complete the form below to request this food donation.',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 30),
                  TextFormField(
                    controller: _nameController,
                    textCapitalization: TextCapitalization.words,
                    decoration: const InputDecoration(
                      labelText: 'Full Name',
                      prefixIcon: Icon(Icons.person),
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) =>
                        _requiredValidator(value, 'Full name'),
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      labelText: 'Phone Number',
                      prefixIcon: Icon(Icons.phone),
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) =>
                        _requiredValidator(value, 'Phone number'),
                  ),
                  const SizedBox(height: 20),
                  DropdownButtonFormField<String>(
                    initialValue: _pickupTime,
                    decoration: const InputDecoration(
                      labelText: 'Preferred Pickup Time',
                      prefixIcon: Icon(Icons.schedule),
                      border: OutlineInputBorder(),
                    ),
                    items: _pickupTimes.map((time) {
                      return DropdownMenuItem<String>(
                        value: time,
                        child: Text(time),
                      );
                    }).toList(),
                    onChanged: _isSubmitting
                        ? null
                        : (value) {
                            if (value == null) return;

                            setState(() {
                              _pickupTime = value;
                            });
                          },
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _messageController,
                    maxLines: 4,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: const InputDecoration(
                      labelText: 'Message to Donor',
                      prefixIcon: Icon(Icons.message),
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) =>
                        _requiredValidator(value, 'Message'),
                  ),
                  const SizedBox(height: 30),
                  SizedBox(
                    height: 55,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2E7D32),
                        foregroundColor: Colors.white,
                      ),
                      onPressed:
                          _isSubmitting ? null : _submitRequest,
                      icon: _isSubmitting
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.send),
                      label: Text(
                        _isSubmitting
                            ? 'Submitting...'
                            : 'Submit Request',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

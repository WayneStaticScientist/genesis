import 'package:flutter/material.dart';
import 'package:genesis/models/notification_model.dart';
import 'package:genesis/utils/theme.dart';

class NotificationDetailsScreen extends StatelessWidget {
  final NotificationModel notification;

  const NotificationDetailsScreen({super.key, required this.notification});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        systemOverlayStyle: GTheme.copyOverlay(context),
        title: const Text(
          'Notification Details',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow('ID', notification.id.toString()),
            _buildDetailRow('Channel ID', notification.channenId),
            _buildDetailRow('Title', notification.title),
            _buildDetailRow('Content', notification.content),
            _buildDetailRow('Type', notification.type),
            _buildDetailRow('Date', notification.date.toLocal().toString()),
            _buildDetailRow('Referred ID', notification.referedId),
            _buildDetailRow('Is Read', notification.isRead ? 'Yes' : 'No'),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}

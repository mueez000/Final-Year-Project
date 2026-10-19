import 'package:cloud_firestore/cloud_firestore.dart';

class BroadcastModel {
  final String? broadcastId;
  final String title;
  final String message;
  final String targetRole; // 'all', 'drivers', 'officers'
  final String severity;   // 'emergency', 'advisory', 'info'
  final String senderId;
  final String senderName;
  final DateTime createdAt;

  BroadcastModel({
    this.broadcastId,
    required this.title,
    required this.message,
    this.targetRole = 'all',
    this.severity = 'info',
    required this.senderId,
    required this.senderName,
    required this.createdAt,
  });

  factory BroadcastModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> snapshot) {
    final data = snapshot.data() ?? {};
    return BroadcastModel.fromMap(data, snapshot.id);
  }

  factory BroadcastModel.fromMap(Map<String, dynamic> data, [String? id]) {
    return BroadcastModel(
      broadcastId: id ?? data['broadcast_id'],
      title: data['title'] ?? 'Highway Broadcast',
      message: data['message'] ?? '',
      targetRole: data['target_role'] ?? 'all',
      severity: data['severity'] ?? 'info',
      senderId: data['sender_id'] ?? '',
      senderName: data['sender_name'] ?? 'HQ Central Command',
      createdAt: (data['created_at'] is Timestamp)
          ? (data['created_at'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'message': message,
      'target_role': targetRole,
      'severity': severity,
      'sender_id': senderId,
      'sender_name': senderName,
      'created_at': Timestamp.fromDate(createdAt),
    };
  }
}

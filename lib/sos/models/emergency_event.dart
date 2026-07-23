import 'location_data.dart';

class EmergencyEvent {
  final String id;
  final String status;
  final DateTime triggeredAt;
  final LocationData location;
  final List<String> notifiedContacts;
  final bool smsSent;
  final bool callsPlaced;
  final bool aiActivated;

  const EmergencyEvent({
    required this.id,
    required this.status,
    required this.triggeredAt,
    required this.location,
    required this.notifiedContacts,
    required this.smsSent,
    required this.callsPlaced,
    required this.aiActivated,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'status': status,
      'triggeredAt': triggeredAt.toIso8601String(),
      'location': location.toJson(),
      'notifiedContacts': notifiedContacts,
      'smsSent': smsSent,
      'callsPlaced': callsPlaced,
      'aiActivated': aiActivated,
    };
  }

  factory EmergencyEvent.fromMap(Map<String, dynamic> map) {
    return EmergencyEvent(
      id: map['id'] ?? '',
      status: map['status'] ?? '',
      triggeredAt: DateTime.parse(map['triggeredAt']),
      location: LocationData.fromJson(
        Map<String, dynamic>.from(map['location']),
      ),
      notifiedContacts:
      List<String>.from(map['notifiedContacts'] ?? const []),
      smsSent: map['smsSent'] ?? false,
      callsPlaced: map['callsPlaced'] ?? false,
      aiActivated: map['aiActivated'] ?? false,
    );
  }

  EmergencyEvent copyWith({
    String? id,
    String? status,
    DateTime? triggeredAt,
    LocationData? location,
    List<String>? notifiedContacts,
    bool? smsSent,
    bool? callsPlaced,
    bool? aiActivated,
  }) {
    return EmergencyEvent(
      id: id ?? this.id,
      status: status ?? this.status,
      triggeredAt: triggeredAt ?? this.triggeredAt,
      location: location ?? this.location,
      notifiedContacts: notifiedContacts ?? this.notifiedContacts,
      smsSent: smsSent ?? this.smsSent,
      callsPlaced: callsPlaced ?? this.callsPlaced,
      aiActivated: aiActivated ?? this.aiActivated,
    );
  }
}
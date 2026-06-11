class SosMessage {
  final String? id;
  final String senderId;
  final double latitude;
  final double longitude;
  final String message;
  final DateTime timestamp;

  SosMessage({
    this.id,
    required this.senderId,
    required this.latitude,
    required this.longitude,
    required this.message,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'senderId': senderId,
      'latitude': latitude,
      'longitude': longitude,
      'message': message,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory SosMessage.fromMap(Map<String, dynamic> map) {
    return SosMessage(
      senderId: map['senderId'],
      latitude: (map['latitude'] as num).toDouble(),
      longitude: (map['longitude'] as num).toDouble(),
      message: map['message'],
      timestamp: DateTime.parse(map['timestamp']),
    );
  }
}

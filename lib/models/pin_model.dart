class Pin {
  final String placeId;
  final DateTime pinnedAt;
  final String? reminderNote;
  final DateTime? reminderTime;

  Pin({
    required this.placeId,
    required this.pinnedAt,
    this.reminderNote,
    this.reminderTime,
  });

  Map<String, dynamic> toJson() {
    return {
      'placeId': placeId,
      'pinnedAt': pinnedAt.toIso8601String(),
      'reminderNote': reminderNote,
      'reminderTime': reminderTime?.toIso8601String(),
    };
  }

  factory Pin.fromJson(Map<String, dynamic> json) {
    return Pin(
      placeId: json['placeId'],
      pinnedAt: DateTime.parse(json['pinnedAt']),
      reminderNote: json['reminderNote'],
      reminderTime: json['reminderTime'] != null 
          ? DateTime.parse(json['reminderTime']) 
          : null,
    );
  }
}
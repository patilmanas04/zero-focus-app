class SessionModel {
  final DateTime dateTime;
  final int durationMinutes;

  SessionModel({required this.dateTime, required this.durationMinutes});

  Map<String, dynamic> toJson() => {
    'dateTime': dateTime.toIso8601String(),
    'durationMinutes': durationMinutes,
  };

  static SessionModel fromJson(Map<String, dynamic> json) {
    return SessionModel(
      dateTime: DateTime.parse(json['dateTime']),
      durationMinutes: json['durationMinutes'],
    );
  }
}

class SessionModel {
  final DateTime dateTime;
  final int coveredMinutes;
  final int totalDuration;

  SessionModel({
    required this.dateTime,
    required this.coveredMinutes,
    required this.totalDuration,
  });

  Map<String, dynamic> toJson() => {
    'dateTime': dateTime.toIso8601String(),
    'coveredMinutes': coveredMinutes,
    'totalDuration': totalDuration,
  };

  static SessionModel fromJson(Map<String, dynamic> json) {
    return SessionModel(
      dateTime: DateTime.parse(json['dateTime']),
      coveredMinutes: json['coveredMinutes'],
      totalDuration: json['totalDuration'] ?? 0,
    );
  }
}

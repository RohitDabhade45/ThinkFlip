class HistoryEntry {
  final String id;
  final String userId;
  final String content;
  final DateTime date;

  HistoryEntry({
    required this.id,
    required this.userId,
    required this.content,
    required this.date,
  });

  factory HistoryEntry.fromJson(Map<String, dynamic> json) {
    return HistoryEntry(
      id: json['_id'],
      userId: json['user'],
      content: json['content'],
      date: DateTime.parse(json['date']),
    );
  }
}
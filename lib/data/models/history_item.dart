class HistoryItem {
  final String id;
  final String expression;
  final String result;
  final DateTime timestamp;
  bool isFavorite;

  HistoryItem({
    String? id,
    required this.expression,
    required this.result,
    required this.timestamp,
    this.isFavorite = false,
  }) : id = id ?? DateTime.now().millisecondsSinceEpoch.toString();

  Map<String, dynamic> toJson() => {
        'id': id,
        'expression': expression,
        'result': result,
        'timestamp': timestamp.toIso8601String(),
        'isFavorite': isFavorite,
      };

  factory HistoryItem.fromJson(Map<String, dynamic> json) => HistoryItem(
        id: json['id'],
        expression: json['expression'],
        result: json['result'],
        timestamp: DateTime.parse(json['timestamp']),
        isFavorite: json['isFavorite'] ?? false,
      );

  HistoryItem copyWith({
    String? id,
    String? expression,
    String? result,
    DateTime? timestamp,
    bool? isFavorite,
  }) {
    return HistoryItem(
      id: id ?? this.id,
      expression: expression ?? this.expression,
      result: result ?? this.result,
      timestamp: timestamp ?? this.timestamp,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }
}

import 'package:hive/hive.dart';

part 'historyitem.g.dart';

@HiveType(typeId: 0)
class HistoryItem extends HiveObject {
  @HiveField(0)
  late String title;

  @HiveField(1)
  late String subtitle;

  @HiveField(2)
  late DateTime timestamp;

  HistoryItem({String? title, String? subtitle, DateTime? timestamp}) {
    this.title = title ?? '';
    this.subtitle = subtitle ?? '';
    this.timestamp = timestamp ?? DateTime.now();
  }

  Map<String, dynamic> toJson() => {
    'title': title,
    'subtitle': subtitle,
    'timestamp': timestamp.toIso8601String(),
  };

  factory HistoryItem.fromJson(Map<String, dynamic> json) => HistoryItem(
    title: json['title'],
    subtitle: json['subtitle'],
    timestamp: DateTime.parse(json['timestamp']),
  );
}

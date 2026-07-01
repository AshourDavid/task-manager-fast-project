import 'enums/category.dart' ;

class NeglectTaskModel {
  final String title;
  final String subtitle;
  final int priority;
  final DateTime date;
  final bool isDone;
  final Category category;

  const NeglectTaskModel({
    required this.title,
    required this.subtitle,
    required this.priority,
    required this.date,
    this.isDone = false,
    required this.category,
  });

  NeglectTaskModel copyWith({
    String? title,
    String? subtitle,
    int? priority,
    DateTime? date,
    bool? isDone,
    Category? category,
  }) {
    return NeglectTaskModel(
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      priority: priority ?? this.priority,
      date: date ?? this.date,
      isDone: isDone ?? this.isDone,
      category: category ?? this.category,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'subtitle': subtitle,
      'priority': priority,
      'date': date.toIso8601String(),
      'isDone': isDone,
      'category': category.name,
    };
  }

  factory NeglectTaskModel.fromJson(Map<String, dynamic> json) {
    return NeglectTaskModel(
      title: json['title'] as String,
      subtitle: json['subtitle'] as String,
      priority: json['priority'] as int,
      date: DateTime.parse(json['date'] as String),
      isDone: json['isDone'] as bool? ?? false,
      category: Category.values.firstWhere(
        (c) => c.name == json['category'],
      ),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is NeglectTaskModel &&
        other.title == title &&
        other.subtitle == subtitle &&
        other.priority == priority &&
        other.date == date &&
        other.isDone == isDone &&
        other.category == category;
  }

  @override
  int get hashCode {
    return title.hashCode ^
        subtitle.hashCode ^
        priority.hashCode ^
        date.hashCode ^
        isDone.hashCode ^
        category.hashCode;
  }

  @override
  String toString() {
    return 'NeglectTaskModel(title: $title, subtitle: $subtitle, priority: $priority, date: $date, isDone: $isDone, category: $category)';
  }
}

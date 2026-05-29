// 1. OPERATIONAL TASK MODEL
class TaskModel {
  final int id;
  final String title;
  final String description;
  final bool isDone;
  final String priority;

  TaskModel({
    required this.id,
    required this.title,
    required this.description,
    required this.isDone,
    required this.priority,
  });

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    return TaskModel(
      id: json['id'],
      title: json['title'] ?? 'Untitled Task',
      description: json['description'] ?? '',
      isDone: json['is_done'] ?? false,
      priority: json['priority'] ?? 'medium',
    );
  }
}

// 2. LIVE ALERT MODEL
class AlertModel {
  final int id;
  final String message;
  final String severity; // e.g., 'critical', 'warning', 'info'
  final DateTime createdAt;

  AlertModel({
    required this.id,
    required this.message,
    required this.severity,
    required this.createdAt,
  });

  factory AlertModel.fromJson(Map<String, dynamic> json) {
    return AlertModel(
      id: json['id'],
      message: json['message'] ?? '',
      severity: json['severity'] ?? 'info',
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}
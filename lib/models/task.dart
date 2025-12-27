import 'package:uuid/uuid.dart';

enum TaskStatus { todo, done }

class Task {
  final String id;
  final String title;
  final String? description;
  final TaskStatus status;
  final String creatorId;
  final String? assigneeId;
  final String groupId;
  final DateTime? reminderTime;
  final DateTime createdAt;
  final DateTime updatedAt;

  Task({
    String? id,
    required this.title,
    this.description,
    this.status = TaskStatus.todo,
    required this.creatorId,
    this.assigneeId,
    required this.groupId,
    this.reminderTime,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  Task copyWith({
    String? title,
    String? description,
    TaskStatus? status,
    String? assigneeId,
    DateTime? reminderTime,
    bool clearAssignee = false,
    bool clearReminder = false,
  }) {
    return Task(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      status: status ?? this.status,
      creatorId: creatorId,
      assigneeId: clearAssignee ? null : (assigneeId ?? this.assigneeId),
      groupId: groupId,
      reminderTime: clearReminder ? null : (reminderTime ?? this.reminderTime),
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'status': status.name,
      'creatorId': creatorId,
      'assigneeId': assigneeId,
      'groupId': groupId,
      'reminderTime': reminderTime?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      status: TaskStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => TaskStatus.todo,
      ),
      creatorId: json['creatorId'] as String,
      assigneeId: json['assigneeId'] as String?,
      groupId: json['groupId'] as String,
      reminderTime: json['reminderTime'] != null
          ? DateTime.parse(json['reminderTime'] as String)
          : null,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }
}

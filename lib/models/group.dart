import 'dart:math';
import 'package:uuid/uuid.dart';

class Group {
  final String id;
  final String name;
  final String? description;
  final String creatorId;
  final String inviteCode;
  final List<String> memberIds;
  final DateTime createdAt;
  final DateTime updatedAt;

  Group({
    String? id,
    required this.name,
    this.description,
    required this.creatorId,
    String? inviteCode,
    List<String>? memberIds,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : id = id ?? const Uuid().v4(),
        inviteCode = inviteCode ?? _generateInviteCode(),
        memberIds = memberIds ?? [creatorId],
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  static String _generateInviteCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random();
    return List.generate(8, (_) => chars[random.nextInt(chars.length)]).join();
  }

  Group copyWith({
    String? name,
    String? description,
    List<String>? memberIds,
  }) {
    return Group(
      id: id,
      name: name ?? this.name,
      description: description ?? this.description,
      creatorId: creatorId,
      inviteCode: inviteCode,
      memberIds: memberIds ?? this.memberIds,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }

  bool isMember(String userId) => memberIds.contains(userId);
  bool isOwner(String userId) => creatorId == userId;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'creatorId': creatorId,
      'inviteCode': inviteCode,
      'memberIds': memberIds,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory Group.fromJson(Map<String, dynamic> json) {
    return Group(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      creatorId: json['creatorId'] as String,
      inviteCode: json['inviteCode'] as String,
      memberIds: List<String>.from(json['memberIds'] as List),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }
}

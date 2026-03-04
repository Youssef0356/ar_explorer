import 'package:flutter/material.dart';

import 'topic_model.dart';

class LearningModule {
  final String id;
  final String title;
  final String description;
  final IconData icon;
  final List<Topic> topics;
  final String?
  requiredQuizId; // quiz that must be passed to unlock this module
  final int order;
  final int unlockCost;

  const LearningModule({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.topics,
    this.requiredQuizId,
    required this.order,
    this.unlockCost = 0,
  });

  int get totalTopics => topics.length;

  factory LearningModule.fromJson(Map<String, dynamic> json, IconData Function(String) iconResolver) {
    return LearningModule(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String? ?? '',
      icon: iconResolver(json['icon'] as String? ?? ''),
      topics: (json['topics'] as List<dynamic>? ?? [])
          .map((topicJson) => Topic.fromJson(topicJson as Map<String, dynamic>))
          .toList(),
      requiredQuizId: json['requiredQuizId'] as String?,
      order: json['order'] as int? ?? 0,
      unlockCost: json['unlockCost'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson(String Function(IconData) iconSerializer) => {
        'id': id,
        'title': title,
        'description': description,
        'icon': iconSerializer(icon),
        'topics': topics.map((t) => t.toJson()).toList(),
        'requiredQuizId': requiredQuizId,
        'order': order,
        'unlockCost': unlockCost,
      };
}

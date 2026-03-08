class Quiz {
  final String id;
  final String moduleId;
  final String title;
  final List<QuizQuestion> questions;
  final int passingScore; // percentage needed to pass (e.g. 60)

  const Quiz({
    required this.id,
    required this.moduleId,
    required this.title,
    required this.questions,
    this.passingScore = 60,
  });

  factory Quiz.fromJson(Map<String, dynamic> json) {
    return Quiz(
      id: json['id'] as String,
      moduleId: json['moduleId'] as String,
      title: json['title'] as String,
      passingScore: json['passingScore'] as int? ?? 60,
      questions: (json['questions'] as List<dynamic>? ?? [])
          .map((q) => QuizQuestion.fromJson(q as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'moduleId': moduleId,
        'title': title,
        'passingScore': passingScore,
        'questions': questions.map((q) => q.toJson()).toList(),
      };
}

class QuizQuestion {
  final String id;
  final String question;
  final List<String> options;
  final int correctIndex;
  final String explanation;
  final String? relatedTopicId;
  final String? relatedModuleId;

  const QuizQuestion({
    required this.id,
    required this.question,
    required this.options,
    required this.correctIndex,
    required this.explanation,
    this.relatedTopicId,
    this.relatedModuleId,
  });

  factory QuizQuestion.fromJson(Map<String, dynamic> json) {
    return QuizQuestion(
      id: json['id'] as String,
      question: json['question'] as String,
      options:
          (json['options'] as List<dynamic>? ?? []).map((o) => o as String).toList(),
      correctIndex: json['correctIndex'] as int? ?? 0,
      explanation: json['explanation'] as String? ?? '',
      relatedTopicId: json['relatedTopicId'] as String?,
      relatedModuleId: json['relatedModuleId'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'question': question,
        'options': options,
        'correctIndex': correctIndex,
        'explanation': explanation,
        'relatedTopicId': relatedTopicId,
        'relatedModuleId': relatedModuleId,
      };
}

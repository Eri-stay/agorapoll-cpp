import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class Poll extends Equatable {
  final String id;
  final String creatorId;
  final String code;
  final String question;
  final List<String> options;

  // Settings
  final bool isAnonymous;
  final bool allowMultiple;
  final bool isChangeable;

  final bool isClosed;
  final DateTime createdAt;

  Poll({
    required this.id,
    required this.creatorId,
    required this.code,
    required this.question,
    required this.options,
    this.isAnonymous = false,
    this.allowMultiple = false,
    this.isChangeable = false,
    this.isClosed = false,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'creatorId': creatorId,
      'code': code,
      'question': question,
      'options': options,
      'isAnonymous': isAnonymous,
      'allowMultiple': allowMultiple,
      'isChangeable': isChangeable,
      'isClosed': isClosed,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  // Створення об'єкта з Map (читання з Firestore)
  factory Poll.fromMap(Map<String, dynamic> map) {
    return Poll(
      id: map['id'] ?? '',
      creatorId: map['creatorId'] ?? '',
      code: map['code'] ?? '',
      question: map['question'] ?? '',
      // Convert dynamic list to List<String>
      options: List<String>.from(map['options'] ?? []),
      isAnonymous: map['isAnonymous'] ?? false,
      allowMultiple: map['allowMultiple'] ?? false,
      isChangeable: map['isChangeable'] ?? false,
      isClosed: map['isClosed'] ?? false,
      createdAt: (map['createdAt'] as Timestamp).toDate(),
    );
  }
  @override
  List<Object?> get props => [
    id,
    creatorId,
    code,
    question,
    options,
    isAnonymous,
    allowMultiple,
    isChangeable,
    isClosed,
    createdAt,
  ];
}

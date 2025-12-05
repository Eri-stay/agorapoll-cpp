class Poll {
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
}

class TaskEntity {
  final int id;
  final String title;
  final String description;
  final int projectId;
  final String status;
  final String priority;
  final DateTime deadline;
  final DateTime? deletedAt;

  TaskEntity({
    required this.id,
    required this.title,
    required this.description,
    required this.projectId,
    required this.status,
    required this.priority,
    required this.deadline,
    this.deletedAt,
  });
}
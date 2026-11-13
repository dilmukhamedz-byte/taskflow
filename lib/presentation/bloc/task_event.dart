abstract class TaskEvent {}

class LoadTasksEvent extends TaskEvent {
  final int projectId;
  LoadTasksEvent(this.projectId);
}

// Новое событие для поиска
class SearchTasksEvent extends TaskEvent {
  final String query;
  SearchTasksEvent(this.query);
}
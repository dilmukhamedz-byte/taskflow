abstract class Failure {
  final String message;
  Failure(this.message);
}

class ServerFailure extends Failure { ServerFailure([super.message = 'Ошибка сервера']); }
class DatabaseFailure extends Failure { DatabaseFailure([super.message = 'Ошибка базы данных']); }
class ValidationFailure extends Failure { ValidationFailure([super.message = 'Неверный запрос']); }
class EmptyFailure extends Failure { EmptyFailure([super.message = 'Результат пуст']); }
class UnknownFailure extends Failure { UnknownFailure([super.message = 'Неизвестная ошибка']); }
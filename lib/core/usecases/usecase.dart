import 'package:dartz/dartz.dart';
import '../error/failures.dart';

abstract class UseCase<TypeT, Params> {
  Future<Either<Failure, TypeT>> call(Params params);
}

class NoParams {}
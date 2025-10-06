import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import '../../../core/error/failures.dart';
import '../../../core/usecases/usecase.dart';
import '../../entities/item_entity.dart';
import '../../repositories/item_repository.dart';

class GetAllItemsParams extends Equatable {
  final String? category;
  final String? city;
  final int? limit;

  const GetAllItemsParams({
    this.category,
    this.city,
    this.limit,
  });

  @override
  List<Object?> get props => [category, city, limit];
}

@lazySingleton
class GetAllItemsUseCase implements UseCase<List<ItemEntity>, GetAllItemsParams> {
  final ItemRepository repository;

  GetAllItemsUseCase(this.repository);

  @override
  Future<Either<Failure, List<ItemEntity>>> call(GetAllItemsParams params) async {
    return await repository.getAllItems(
      category: params.category,
      city: params.city,
      limit: params.limit,
    );
  }
}

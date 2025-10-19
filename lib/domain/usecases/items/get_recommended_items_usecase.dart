import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../core/error/failures.dart';
import '../../entities/item_entity.dart';
import '../../repositories/item_repository.dart';
import '../../../core/usecases/usecase.dart';

@lazySingleton
class GetRecommendedItemsUseCase
    implements UseCase<List<ItemEntity>, GetRecommendedItemsParams> {
  final ItemRepository repository;

  GetRecommendedItemsUseCase(this.repository);

  @override
  Future<Either<Failure, List<ItemEntity>>> call(
    GetRecommendedItemsParams params,
  ) async {
    return repository.getRecommendedItems(
      userId: params.userId,
      city: params.city,
      latitude: params.latitude,
      longitude: params.longitude,
    );
  }
}

class GetRecommendedItemsParams {
  final String userId;
  final String? city;
  final double? latitude;
  final double? longitude;

  const GetRecommendedItemsParams({
    required this.userId,
    this.city,
    this.latitude,
    this.longitude,
  });
}

import 'package:core/core.dart';
import '../../data/models/test_feature_model.dart';
import '../repositories/test_feature_repository.dart';

class FetchTestFeatureUseCase {
  final TestFeatureRepository _repository;

  FetchTestFeatureUseCase(this._repository);

  Future<DataState<List<TestFeatureModel>?>> call() async =>
      await _repository.fetchTestFeature();
}

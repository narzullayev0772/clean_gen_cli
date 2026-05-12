import 'package:core/core.dart';
import '../../domain/repositories/test_feature_repository.dart';
import '../data_sources/test_feature_api_service.dart';
import '../models/test_feature_model.dart';

class TestFeatureRepositoryImpl implements TestFeatureRepository {
  final TestFeatureApiService _apiService;

  TestFeatureRepositoryImpl(this._apiService);

  @override
  Future<DataState<List<TestFeatureModel>?>> fetchTestFeature() async {
    // TODO: implement fetchTestFeature
    throw UnimplementedError();
  }
}

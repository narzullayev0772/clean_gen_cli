import 'package:core/core.dart';
import '../../data/models/test_feature_model.dart';

abstract class TestFeatureRepository {
  Future<DataState<List<TestFeatureModel>?>> fetchTestFeature();
}

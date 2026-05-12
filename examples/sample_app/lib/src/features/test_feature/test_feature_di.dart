import "../../../../../core/locator.dart";
import "data/data_sources/test_feature_api_service.dart";
import "data/repositories/test_feature_repository_impl.dart";
import "domain/repositories/test_feature_repository.dart";
import "domain/use_cases/fetch_test_feature_use_case.dart";
import "presentation/view/manager/test_feature_bloc.dart";

Future<void> testFeatureDI() async {
  // DataSources
  locator.registerSingleton(TestFeatureApiService(locator()));

  // Repositories
  locator.registerSingleton<TestFeatureRepository>(TestFeatureRepositoryImpl(locator()));

  // UseCases
  locator.registerSingleton(FetchTestFeatureUseCase(locator()));

  // Blocs
  locator.registerFactory<TestFeatureBloc>(
    () => TestFeatureBloc(locator()),
  );
}

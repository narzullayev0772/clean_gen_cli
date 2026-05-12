// GENERATED CODE - DO NOT MODIFY BY HAND

import "../../../../../core/locator.dart";
import "data/data_sources/{{name.snakeCase()}}_api_service.dart";
import "data/repositories/{{name.snakeCase()}}_repository_impl.dart";
import "domain/repositories/{{name.snakeCase()}}_repository.dart";
import "domain/use_cases/fetch_{{name.snakeCase()}}_use_case.dart";
import "presentation/view/manager/{{name.snakeCase()}}_{{#use_cubit}}cubit{{/use_cubit}}{{^use_cubit}}bloc{{/use_cubit}}.dart";

Future<void> {{name.camelCase()}}DI() async {
  // DataSources
  locator.registerSingleton({{name.pascalCase()}}ApiService(locator()));

  // Repositories
  locator.registerSingleton<{{name.pascalCase()}}Repository>({{name.pascalCase()}}RepositoryImpl(locator()));

  // UseCases
  locator.registerSingleton(Fetch{{name.pascalCase()}}UseCase(locator()));

  // Blocs
  locator.registerFactory<{{name.pascalCase()}}{{#use_cubit}}Cubit{{/use_cubit}}{{^use_cubit}}Bloc{{/use_cubit}}>(
    () => {{name.pascalCase()}}{{#use_cubit}}Cubit{{/use_cubit}}{{^use_cubit}}Bloc{{/use_cubit}}(locator()),
  );
}

import 'package:flutter_bloc/flutter_bloc.dart';

part '{{name.snakeCase()}}_state.dart';
{{^use_cubit}}part '{{name.snakeCase()}}_event.dart';{{/use_cubit}}

class {{name.pascalCase()}}{{#use_cubit}}Cubit{{/use_cubit}}{{^use_cubit}}Bloc{{/use_cubit}} extends {{#use_cubit}}Cubit{{/use_cubit}}{{^use_cubit}}Bloc{{/use_cubit}}<{{#use_cubit}}{{name.pascalCase()}}State{{/use_cubit}}{{^use_cubit}}{{name.pascalCase()}}Event, {{name.pascalCase()}}State{{/use_cubit}}> {
  {{name.pascalCase()}}{{#use_cubit}}Cubit{{/use_cubit}}{{^use_cubit}}Bloc{{/use_cubit}}() : super({{name.pascalCase()}}Initial());
  
  {{^use_cubit}}
  @override
  Stream<{{name.pascalCase()}}State> mapEventToState({{name.pascalCase()}}Event event) async* {
    // TODO: implement mapEventToState
  }
  {{/use_cubit}}
}

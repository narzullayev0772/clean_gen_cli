// GENERATED CODE - DO NOT MODIFY BY HAND

part of '{{name.snakeCase()}}_{{#use_cubit}}cubit{{/use_cubit}}{{^use_cubit}}bloc{{/use_cubit}}.dart';

abstract class {{name.pascalCase()}}State {}

class {{name.pascalCase()}}Initial extends {{name.pascalCase()}}State {}

class {{name.pascalCase()}}Loading extends {{name.pascalCase()}}State {}

class {{name.pascalCase()}}Loaded extends {{name.pascalCase()}}State {}

class {{name.pascalCase()}}Error extends {{name.pascalCase()}}State {
  final String message;
  {{name.pascalCase()}}Error(this.message);
}

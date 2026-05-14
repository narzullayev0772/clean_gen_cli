/// Represents the global configuration for the CLI tool.
class GlobalConfig {
  /// A map of shared imports (e.g., DataState, UseCase).
  final Map<String, String> imports;

  /// A map of configuration options (e.g., locator name).
  final Map<String, String> config;

  /// Creates a [GlobalConfig] instance.
  GlobalConfig({this.imports = const {}, this.config = const {}});

  /// Creates a [GlobalConfig] from a JSON map.
  factory GlobalConfig.fromJson(Map<String, dynamic> json) {
    return GlobalConfig(
      imports:
          (json['imports'] as Map<String, dynamic>?)?.map(
            (k, v) => MapEntry(k, v.toString()),
          ) ??
          {},
      config:
          (json['config'] as Map<String, dynamic>?)?.map(
            (k, v) => MapEntry(k, v.toString()),
          ) ??
          {},
    );
  }

  /// Converts the [GlobalConfig] to a JSON map.
  Map<String, dynamic> toJson() => {'imports': imports, 'config': config};
}

/// Represents the schema for a feature to be generated.
class FeatureSchema {
  /// The name of the feature.
  final String name;

  /// The list of API functions associated with the feature.
  final List<FunctionDef> functions;

  /// The global configuration to use for generation.
  final GlobalConfig globalConfig;

  /// Creates a [FeatureSchema] instance.
  FeatureSchema({
    required this.name,
    required this.functions,
    required this.globalConfig,
  });

  /// Creates a [FeatureSchema] from a JSON map and global config.
  factory FeatureSchema.fromJson(
    Map<String, dynamic> json,
    GlobalConfig global,
  ) {
    final functions =
        (json['functions'] as List<dynamic>?)
            ?.map((f) => FunctionDef.fromJson(f as Map<String, dynamic>))
            .toList() ??
        [];

    return FeatureSchema(
      name: json['name'] as String? ?? '',
      functions: functions,
      globalConfig: global,
    );
  }

  /// Validates the schema.
  bool isValid() {
    if (name.isEmpty) return false;
    if (functions.isEmpty) return false;
    return functions.every((f) => f.isValid());
  }
}

/// Represents a single API function definition.
class FunctionDef {
  /// The name of the function.
  final String name;

  /// The API endpoint URL.
  final String api;

  /// The HTTP method (GET, POST, etc.).
  final String method;

  /// The request payload structure (Map or List).
  final dynamic request;

  /// The response payload structure (Map or List).
  final dynamic response;

  /// Whether the function supports pagination.
  final bool pagination;

  /// Whether the function uses query parameters instead of a request body.
  final bool? query;

  /// List of valid HTTP methods.
  static const List<String> validMethods = [
    'GET',
    'POST',
    'PUT',
    'PATCH',
    'DELETE',
  ];

  /// Creates a [FunctionDef] instance.
  FunctionDef({
    required this.name,
    required this.api,
    this.method = 'GET',
    this.request,
    this.response,
    this.pagination = false,
    this.query,
  });

  /// Creates a [FunctionDef] from a JSON map.
  factory FunctionDef.fromJson(Map<String, dynamic> json) {
    return FunctionDef(
      name: json['name'] as String? ?? '',
      api: json['api'] as String? ?? '',
      method: (json['method'] as String?)?.toUpperCase() ?? 'GET',
      request: json['request'],
      response: json['response'],
      pagination: (json['pagination'] as bool?) ?? false,
      query: json['query'] as bool?,
    );
  }

  /// Validates the function definition.
  bool isValid() {
    if (name.isEmpty || api.isEmpty) return false;
    if (!validMethods.contains(method)) return false;
    return true;
  }
}

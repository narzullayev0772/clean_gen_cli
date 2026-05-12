
class FeatureSchema {
  final String name;
  final List<FunctionDef> functions;

  FeatureSchema({required this.name, required this.functions});

  factory FeatureSchema.fromJson(Map<String, dynamic> json) {
    final functions = (json['functions'] as List<dynamic>?)
        ?.map((f) => FunctionDef.fromJson(f as Map<String, dynamic>))
        .toList() ?? [];

    return FeatureSchema(
      name: json['name'] as String,
      functions: functions,
    );
  }

  bool isValid() => name.isNotEmpty;
}

class FunctionDef {
  final String name;
  final String api;
  final String method;
  final Map<String, dynamic>? request;
  final Map<String, dynamic>? response;
  final bool pagination;

  FunctionDef({
    required this.name,
    required this.api,
    this.method = 'GET',
    this.request,
    this.response,
    this.pagination = false,
  });

  factory FunctionDef.fromJson(Map<String, dynamic> json) {
    return FunctionDef(
      name: json['name'] as String,
      api: json['api'] as String,
      method: (json['method'] as String?) ?? 'GET',
      request: json['request'] as Map<String, dynamic>?,
      response: json['response'] as Map<String, dynamic>?,
      pagination: (json['pagination'] as bool?) ?? false,
    );
  }

  bool isValid() => name.isNotEmpty && api.isNotEmpty;
}


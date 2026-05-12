
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
  final dynamic request; // Can be Map or List
  final dynamic response; // Can be Map or List
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
      request: json['request'], // Accept both Map and List
      response: json['response'], // Accept both Map and List
      pagination: (json['pagination'] as bool?) ?? false,
    );
  }

  bool isValid() => name.isNotEmpty && api.isNotEmpty;
}


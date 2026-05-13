
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

  bool isValid() {
    if (name.isEmpty) return false;
    if (functions.isEmpty) return false;
    return functions.every((f) => f.isValid());
  }
}

class FunctionDef {
  final String name;
  final String api;
  final String method;
  final dynamic request; // Can be Map or List
  final dynamic response; // Can be Map or List
  final bool pagination;
  final bool? query;

  static const List<String> validMethods = ['GET', 'POST', 'PUT', 'PATCH', 'DELETE'];

  FunctionDef({
    required this.name,
    required this.api,
    this.method = 'GET',
    this.request,
    this.response,
    this.pagination = false,
    this.query,
  });

  factory FunctionDef.fromJson(Map<String, dynamic> json) {
    return FunctionDef(
      name: json['name'] as String,
      api: json['api'] as String,
      method: (json['method'] as String?)?.toUpperCase() ?? 'GET',
      request: json['request'], // Accept both Map and List
      response: json['response'], // Accept both Map and List
      pagination: (json['pagination'] as bool?) ?? false,
      query: json['query'] as bool?,
    );
  }

  bool isValid() {
    if (name.isEmpty || api.isEmpty) return false;
    if (!validMethods.contains(method)) return false;
    return true;
  }
}


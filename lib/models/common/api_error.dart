class ApiError {
  final String message;
  final List<String>? errors;
  final int? statusCode;

  ApiError({
    required this.message,
    this.errors,
    this.statusCode,
  });

  factory ApiError.fromJson(Map<String, dynamic> json) {
    return ApiError(
      message: json['message'] as String? ?? 'An error occurred',
      errors: (json['errors'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList(),
      statusCode: json['statusCode'] as int?,
    );
  }

  @override
  String toString() {
    if (errors != null && errors!.isNotEmpty) {
      return '$message\n${errors!.join('\n')}';
    }
    return message;
  }
}

import 'package:postgrest/src/postgrest_error.dart';

/// A Postgrest response
class PostgrestResponse<T> {
  const PostgrestResponse({
    this.data,
    this.status,
    this.error,
    this.count,
  });

  final T? data;
  final int? status;
  final PostgrestError? error;
  final int? count;

  bool get hasError => error != null;

  // factory PostgrestResponse.fromJson(Map<String, dynamic> json) =>
  //     PostgrestResponse(
  //       data: json['body'],
  //       status: json['status'] as int?,
  //       error: json['error'] == null
  //           ? null
  //           : PostgrestError.fromJson(json['error'] as Map<String, dynamic>),
  //       count: json['count'] as int?,
  //     );

  Map<String, dynamic> toJson() => {
        'data': data,
        'status': status,
        'error': error?.toJson(),
        'count': count,
      };
}

import 'dart:async';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:giolee78/services/storage/storage_services.dart';
import 'package:mime/mime.dart';
import '../../config/api/api_end_point.dart';
import '../../utils/constants/app_string.dart';
import '../../utils/log/api_log.dart';
import 'api_response_model.dart';

class ApiService {
  static final Dio _dio = _getMyDio();

  /// ========== [ HTTP METHODS ] ========== ///
  static Future<ApiResponseModel> post(
    String url, {
    dynamic body,
    Map<String, String>? header,
  }) => _request(url, "POST", body: body, header: header);

  static Future<ApiResponseModel> get(
    String url, {
    Map<String, String>? header,
  }) => _request(url, "GET", header: header);

  static Future<ApiResponseModel> put(
    String url, {
    dynamic body,
    Map<String, String>? header,
  }) => _request(url, "PUT", body: body, header: header);

  static Future<ApiResponseModel> patch(
    String url, {
    dynamic body,
    Map<String, String>? header,
  }) => _request(url, "PATCH", body: body, header: header);

  static Future<ApiResponseModel> delete(
    String url, {
    dynamic body,
    Map<String, String>? header,
  }) => _request(url, "DELETE", body: body, header: header);

  static Future<ApiResponseModel> multipart(
    String url, {
    Map<String, String> header = const {},
    Map<String, String> body = const {},
    String method = "POST",
    String imageName = 'image',
    String? imagePath,
  }) async {
    final FormData formData = FormData();
    if (imagePath != null && imagePath.isNotEmpty) {
      final File file = File(imagePath);
      final String extension = file.path.split('.').last.toLowerCase();
      final String? mimeType = lookupMimeType(imagePath);

      formData.files.add(
        MapEntry(
          imageName,
          await MultipartFile.fromFile(
            imagePath,
            filename: "$imageName.$extension",
            contentType: mimeType != null
                ? DioMediaType.parse(mimeType)
                : DioMediaType.parse("image/jpeg"),
          ),
        ),
      );
    }

    body.forEach((key, value) {
      formData.fields.add(MapEntry(key, value));
    });

    final headers = Map<String, String>.from(header);
    headers['Content-Type'] = "multipart/form-data";

    return _request(url, method, body: formData, header: headers);
  }

  static Future<ApiResponseModel> multipartImage(
    String url, {
    Map<String, String> header = const {},
    Map<String, String> body = const {},
    String method = "POST",
    List files = const [],
  }) async {
    final FormData formData = FormData();

    for (var item in files) {
      final String imageName = item['name'] ?? "image";
      final String? imagePath = item['image'];
      if (imagePath != null && imagePath.isNotEmpty) {
        final File file = File(imagePath);
        final String extension = file.path.split('.').last.toLowerCase();
        final String? mimeType = lookupMimeType(imagePath);
        formData.files.add(
          MapEntry(
            imageName,
            await MultipartFile.fromFile(
              imagePath,
              filename: "$imageName.$extension",
              contentType: mimeType != null
                  ? DioMediaType.parse(mimeType)
                  : DioMediaType.parse("image/jpeg"),
            ),
          ),
        );
      }
    }

    body.forEach((key, value) {
      formData.fields.add(MapEntry(key, value));
    });

    final headers = Map<String, String>.from(header);
    headers['Content-Type'] = 'multipart/form-data';

    return _request(url, method, body: formData, header: header);
  }

  /// ========== [ API REQUEST HANDLER ] ========== ///
  static Future<ApiResponseModel> _request(
    String url,
    String method, {
    dynamic body,
    Map<String, String>? header,
  }) async {
    print(">>>>>>>>>>>> 🚀 API Request: $method $url <<<<<<<<<<<<");
    try {
      final response = await _dio.request(
        url,
        data: body,
        options: Options(method: method, headers: header),
      );
      return _handleResponse(response);
    } catch (e) {
      return _handleError(e);
    }
  }

  static ApiResponseModel _handleResponse(Response response) {
    if (response.statusCode == 201) {
      return ApiResponseModel(200, response.data);
    }
    return ApiResponseModel(response.statusCode, response.data);
  }

  static ApiResponseModel _handleError(dynamic error) {
    try {
      return _handleDioException(error);
    } catch (e) {
      return ApiResponseModel(500, {});
    }
  }

  static Future<ApiResponseModel> multipartUpdate(
    String url, {
    Map<String, String>? header,
    Map<String, String>? body,
    String method = "PATCH",
    String imageName = 'image',
    String? imagePath,
    bool skipAuth = false,
  }) async {
    final Map<String, String> safeHeader = header != null
        ? Map<String, String>.from(header)
        : {};

    final Map<String, String> safeBody = body != null
        ? Map<String, String>.from(body)
        : {};

    final FormData formData = FormData();

    // image
    if (imagePath != null && imagePath.isNotEmpty) {
      final File file = File(imagePath);
      final String extension = file.path.split('.').last.toLowerCase();
      final String? mimeType = lookupMimeType(imagePath);

      formData.files.add(
        MapEntry(
          imageName,
          await MultipartFile.fromFile(
            imagePath,
            filename: "$imageName.$extension",
            contentType: mimeType != null
                ? DioMediaType.parse(mimeType)
                : DioMediaType.parse("image/jpeg"),
          ),
        ),
      );
    }

    // text fields
    safeBody.forEach((key, value) {
      formData.fields.add(MapEntry(key, value));
    });

    return _request(url, method, body: formData, header: safeHeader);
  }

  static ApiResponseModel _handleDioException(DioException error) {
    if (error.response != null && error.response!.statusCode == 401) {
      LocalStorage.removeAllPrefData();
    }
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.sendTimeout:
        return ApiResponseModel(408, {"message": AppString.requestTimeOut});

      case DioExceptionType.badResponse:
        return ApiResponseModel(
          error.response?.statusCode,
          error.response?.data,
        );

      case DioExceptionType.connectionError:
        return ApiResponseModel(503, {
          "message": AppString.noInternetConnection,
        });

      default:
        return ApiResponseModel(400, {});
    }
  }
}

/// ========== [ DIO INSTANCE WITH INTERCEPTORS ] ========== ///

Dio _getMyDio() {
  final Dio dio = Dio();

  dio.interceptors.addAll([
    InterceptorsWrapper(
      onRequest: (options, handler) {
        options
          ..headers['authorization'] ??= 'Bearer ${LocalStorage.token}'
          ..headers['Content-Type'] ??= 'application/json'
          ..connectTimeout = const Duration(seconds: 30)
          ..sendTimeout = const Duration(seconds: 30)
          ..receiveDataWhenStatusError = true
          ..responseType = ResponseType.json
          ..receiveTimeout = const Duration(seconds: 30)
          ..baseUrl = options.path.startsWith('http')
              ? ''
              : ApiEndPoint.baseUrl;
        handler.next(options);
      },
      onResponse: (response, handler) {
        handler.next(response);
      },
      onError: (error, handler) {
        handler.next(error);
      },
    ),
    apiLog(),
  ]);

  return dio;
}

import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import '../core/api_client.dart';
import '../core/app_config.dart';
import '../core/failure.dart';
import '../core/result.dart';

/// Repository upload file (ảnh) lên backend thông qua multipart/form-data.
/// Endpoint: POST /api/v1/upload/image (1 file) hoặc /upload/images (nhiều file).
class UploadRepository {
  final ApiClient _api = ApiClient.instance;

  /// Upload 1 ảnh — trả về URL public đã host trên backend.
  Future<Result<String>> uploadOne(File file) async {
    final token = _api.getToken();
    if (token == null) {
      return FailureResult(AuthFailure(message: 'Chưa đăng nhập để upload ảnh'));
    }
    try {
      final uri = Uri.parse('$baseUrl/upload/image');
      final req = http.MultipartRequest('POST', uri)
        ..headers['Authorization'] = 'Bearer $token'
        ..files.add(
          await http.MultipartFile.fromPath(
            'image',
            file.path,
            contentType: _guessContentType(file.path),
          ),
        );
      final streamed = await req.send().timeout(AppConfig.timeout);
      final res = await http.Response.fromStream(streamed);
      return _parseOne(res);
    } catch (e) {
      return FailureResult(NetworkFailure(message: 'Không upload được ảnh: $e'));
    }
  }

  /// Upload nhiều ảnh cùng lúc.
  Future<Result<List<String>>> uploadMany(List<File> files) async {
    if (files.isEmpty) return ResultSuccess<List<String>>(const []);
    final token = _api.getToken();
    if (token == null) {
      return FailureResult(AuthFailure(message: 'Chưa đăng nhập để upload ảnh'));
    }
    try {
      final uri = Uri.parse('$baseUrl/upload/images');
      final req = http.MultipartRequest('POST', uri)
        ..headers['Authorization'] = 'Bearer $token';
      for (final f in files) {
        req.files.add(
          await http.MultipartFile.fromPath(
            'images',
            f.path,
            contentType: _guessContentType(f.path),
          ),
        );
      }
      final streamed = await req.send().timeout(const Duration(seconds: 60));
      final res = await http.Response.fromStream(streamed);
      return _parseMany(res);
    } catch (e) {
      return FailureResult(NetworkFailure(message: 'Không upload được ảnh: $e'));
    }
  }

  Map<String, dynamic> _safeDecode(String body) {
    try {
      if (body.isEmpty) return const {};
      return jsonDecode(utf8.decode(body.codeUnits)) as Map<String, dynamic>;
    } catch (_) {
      return {'message': body};
    }
  }

  Result<String> _parseOne(http.Response res) {
    final body = _safeDecode(res.body);
    if (res.statusCode >= 200 && res.statusCode < 300 && body['success'] == true) {
      final data = body['data'] as Map?;
      final url = data?['url'] as String?;
      if (url != null) return ResultSuccess<String>(url);
      return FailureResult(NetworkFailure(message: 'Upload thất bại: thiếu url', statusCode: res.statusCode));
    }
    final msg = (body['message'] as String?) ?? 'Upload thất bại';
    if (res.statusCode == 401 || res.statusCode == 403) {
      return FailureResult(AuthFailure(message: msg));
    }
    return FailureResult(NetworkFailure(message: msg, statusCode: res.statusCode));
  }

  Result<List<String>> _parseMany(http.Response res) {
    final body = _safeDecode(res.body);
    if (res.statusCode >= 200 && res.statusCode < 300 && body['success'] == true) {
      final data = body['data'] as Map?;
      final urls = ((data?['urls'] as List?) ?? const []).cast<String>();
      return ResultSuccess<List<String>>(urls);
    }
    final msg = (body['message'] as String?) ?? 'Upload thất bại';
    if (res.statusCode == 401 || res.statusCode == 403) {
      return FailureResult(AuthFailure(message: msg));
    }
    return FailureResult(NetworkFailure(message: msg, statusCode: res.statusCode));
  }

  MediaType _guessContentType(String filePath) {
    final ext = filePath.toLowerCase().split('.').last;
    return switch (ext) {
      'png' => MediaType('image', 'png'),
      'gif' => MediaType('image', 'gif'),
      'webp' => MediaType('image', 'webp'),
      _ => MediaType('image', 'jpeg'),
    };
  }
}

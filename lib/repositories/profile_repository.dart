import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import '../core/api_client.dart';
import '../core/app_config.dart';
import '../core/failure.dart';
import '../core/result.dart';
import '../models/profile_model.dart';
import '../models/seller_profile_model.dart';

class ProfileRepository {
  final _api = ApiClient.instance;

  Profile _fromJson(Map<String, dynamic> j) => Profile(
        id: j['_id'] as String? ?? j['id'] as String? ?? '',
        name: j['name'] as String? ?? '',
        phone: j['phone'] as String? ?? '',
        avatarUrl: j['avatarUrl'] as String?,
        address: j['address'] as String?,
        latitude: (j['latitude'] as num?)?.toDouble(),
        longitude: (j['longitude'] as num?)?.toDouble(),
        reputationScore: (j['reputationScore'] as num?)?.toInt() ?? 0,
        totalTransactions: (j['totalTransactions'] as num?)?.toInt() ?? 0,
        successRate: (j['successRate'] as num?)?.toDouble() ?? 100,
        totalListings: (j['totalListings'] as num?)?.toInt() ?? 0,
        memberSince: DateTime.tryParse(j['memberSince']?.toString() ?? '') ?? DateTime.now(),
      );

  Future<Result<Profile>> getProfile() async {
    final res = await _api.get('/auth/me');
    return switch (res) {
      ResultSuccess(data: final d) => ResultSuccess<Profile>(_fromJson(d['data'] as Map<String, dynamic>)),
      FailureResult(failure: final f) => FailureResult<Profile>(f),
    };
  }

  /// Lấy public profile của một người dùng (không cần login)
  Future<Result<PublicSellerProfile>> getPublicProfile(String userId) async {
    final res = await _api.get('/users/$userId/profile');
    return switch (res) {
      ResultSuccess(data: final d) => ResultSuccess<PublicSellerProfile>(
        PublicSellerProfile.fromJson(d['data'] as Map<String, dynamic>),
      ),
      FailureResult(failure: final f) => FailureResult<PublicSellerProfile>(f),
    };
  }

  Future<Result<Profile>> updateProfile(Profile updated) async {
    final body = <String, dynamic>{
      'name': updated.name,
      'phone': updated.phone,
      'address': updated.address,
      'avatarUrl': updated.avatarUrl,
    };
    if (updated.latitude != null) body['latitude'] = updated.latitude;
    if (updated.longitude != null) body['longitude'] = updated.longitude;
    final res = await _api.patch('/users/${updated.id}', body: body);
    return switch (res) {
      ResultSuccess(data: final d) => ResultSuccess<Profile>(_fromJson(d['data'] as Map<String, dynamic>)),
      FailureResult(failure: final f) => FailureResult<Profile>(f),
    };
  }

  /// Upload avatar multipart tới PUT /users/:id/avatar.
  /// Trả về Profile đã cập nhật (có avatarUrl mới).
  Future<Result<Profile>> uploadAvatar(String userId, XFile file) async {
    final token = _api.getToken();
    if (token == null) {
      return FailureResult(AuthFailure(message: 'Chưa đăng nhập'));
    }
    try {
      final uri = Uri.parse('$baseUrl/users/$userId/avatar');
      final ext = file.path.toLowerCase().split('.').last;
      final contentType = switch (ext) {
        'png' => MediaType('image', 'png'),
        'webp' => MediaType('image', 'webp'),
        _ => MediaType('image', 'jpeg'),
      };
      final bytes = await file.readAsBytes();
      final req = http.MultipartRequest('PUT', uri)
        ..headers['Authorization'] = 'Bearer $token'
        ..files.add(http.MultipartFile.fromBytes('image', bytes, filename: file.name, contentType: contentType));
      final streamed = await req.send().timeout(AppConfig.timeout);
      final res = await http.Response.fromStream(streamed);
      final body = _decode(res.body);
      if (res.statusCode >= 200 && res.statusCode < 300 && body['success'] == true) {
        return ResultSuccess<Profile>(_fromJson(body['data'] as Map<String, dynamic>));
      }
      final msg = body['message']?.toString() ?? 'Upload avatar thất bại';
      if (res.statusCode == 401 || res.statusCode == 403) {
        return FailureResult(AuthFailure(message: msg));
      }
      return FailureResult(NetworkFailure(message: msg, statusCode: res.statusCode));
    } catch (e) {
      return FailureResult(NetworkFailure(message: 'Upload avatar thất bại: $e'));
    }
  }

  Map<String, dynamic> _decode(String body) {
    try {
      if (body.isEmpty) return const {};
      return jsonDecode(body) as Map<String, dynamic>;
    } catch (_) {
      return {'message': body};
    }
  }
}

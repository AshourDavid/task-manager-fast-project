import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:go_router_clean_architecture/common/dtos/refresh_token_response.dart';
import 'package:go_router_clean_architecture/common/http_status/status_code.dart';
import 'package:go_router_clean_architecture/core/data/local/secure_storage/isecure_storage.dart';
import 'package:go_router_clean_architecture/core/data/local/secure_storage/secure_storage_const.dart';
import 'package:go_router_clean_architecture/core/data/local/secure_storage/secure_storage_provider.dart';
import 'package:go_router_clean_architecture/core/data/remote/token/itoken_service.dart';

final ProviderFamily tokenServiceProvider = Provider.family<ItokenService, Dio>(
  (ref, dio) {
    final secureStorage = ref.watch(secureStorageProvider);
    return TokenService(secureStorage, dio);
  },
);

class TokenService implements ItokenService {
  final ISecureStorage _secureStorage;
  final Dio _dio;

  const TokenService(this._secureStorage, this._dio);

  @override
  Future<List<void>> clearToken() async {
    return Future.wait([
      _secureStorage.delete(key: accessTokenKey),
      _secureStorage.delete(key: refreshTokenKey),
    ]);
  }

  @override
  Future<String?> getAccessToken() => _secureStorage.read(key: accessTokenKey);

  @override
  Future<String?> getRefreshToken() =>
      _secureStorage.read(key: refreshTokenKey);

  @override
  Future<RefreshTokenResponse> refreshToken(String? refreshToken) async {
    final response = await _dio.post<Map<String, dynamic>>(
      'path', // endpoint for refreshing the accessToken
      data: {'refreshToken': refreshToken},
    );
    if (response.statusCode == success) {
      return RefreshTokenResponse.fromJson(
        response.data ?? {},
      );
    }
    throw DioException(
      // this will not be executed because of the try-catch in NetworkServiceInterceptor.onError
      requestOptions: response.requestOptions,
      response: response,
    );
  }

  @override
  Future<void> saveToken(String accessToken, String refreshToken) {
    return Future.wait([
      // Future.wait automatically resolves the inner futures so it returns Future<List<void>>
      _secureStorage.write(
        key: accessTokenKey,
        value: accessToken,
      ), // Future<void>
      _secureStorage.write(
        key: refreshTokenKey,
        value: refreshToken,
      ), // Future<void>
    ]);
  }
}

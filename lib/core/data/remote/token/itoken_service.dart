import 'package:go_router_clean_architecture/common/dtos/refresh_token_response.dart';

abstract interface class ItokenService {
  Future<String?> getAccessToken();
  Future<String?> getRefreshToken();

  Future<void> saveToken(String accessToken, String refreshToken);

  Future<void> clearToken();

  Future<RefreshTokenResponse> refreshToken(String? refreshToken);
}

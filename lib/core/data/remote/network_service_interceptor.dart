import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:go_router_clean_architecture/common/http_status/status_code.dart';
import 'package:go_router_clean_architecture/core/data/remote/token/itoken_service.dart';
import 'package:go_router_clean_architecture/core/data/remote/token/token_service.dart';

ProviderFamily<Interceptor, Dio> networkServiceInterceptorProvider =
    Provider.family<Interceptor, Dio>((ref, dio) {
      final tokenService = ref.watch(tokenServiceProvider(dio));
      return NetworkServiceInterceptor(tokenService, dio);
    });

final class NetworkServiceInterceptor extends Interceptor {
  final ItokenService _tokenService;
  final Dio _dio;
  NetworkServiceInterceptor(this._tokenService, this._dio);
  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final accessToken = await _tokenService.getAccessToken();
    options.headers['Content-Type'] = 'application/json'; // type of data sent
    options.headers['Accept'] =
        'application/json'; // what data type I want to recieve
    options.headers['Authorization'] =
        'Bearer $accessToken'; // to attach the accessToken
    super.onRequest(
      options,
      handler,
    ); // to execute the default onRequest after updating the accessToken
  }

  // reason: for refreshing the accessToken
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    // handle unauthorized error (the response will be null in case not connected to the internet or server is down like unreachable or
    // request timeout or request cancelled or  SSL/TLS Certificate Errors)
    if (err.response?.statusCode == unauthorized) {
      // if the case is unauthorized(not authenticated means our token is expired) and the status code is 401
      final token = await _tokenService.getRefreshToken();

      try {
        // to get the new access token . (this will throw DioException with statusCode of 498 if the refreshToken is expired)
        final result = await _tokenService.refreshToken(token);

        // to check if the refresh token response is expired or not (this will be checked with try-catch)
        final accessToken = result.data.accessToken;
        final refreshToken = result.data.refreshToken;
        // save new access token
        _tokenService.saveToken(accessToken, refreshToken);

        // update the request headers with new accessToken
        err.requestOptions.headers['Authorization'] = 'Bearer $accessToken';

        // repeat the request with new accessToken
        return handler.resolve(await _dio.fetch(err.requestOptions));
        // we used fetch because it reuses the same request options
      } on DioException catch (e) {
        // if the refresh token is already expired or the user didn't log in
        if (e.response?.statusCode == refreshTokenExpired) {
          // 498 for already expired tokens
          // delete the secure storage content
          _tokenService.clearToken();

          // continue with the error
          return handler.next(err);
        }
      }
    }
    // continue with the error for the next interceptor (not connected to the internet or the server is down)
    return handler.next(err);
  }
}

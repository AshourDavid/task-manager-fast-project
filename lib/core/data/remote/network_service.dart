import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:dio_http_formatter/dio_http_formatter.dart';
import 'package:go_router_clean_architecture/core/data/remote/network_service_interceptor.dart';

final networkServiceProvider = Provider((ref) {
  final options = BaseOptions(
    baseUrl: 'https://jsonplaceholder.typicode.com/',
    connectTimeout: const Duration(seconds: 60),
    receiveTimeout: const Duration(seconds: 60),
    sendTimeout: const Duration(seconds: 60),
  );
  final dio = Dio(options);
  final customInterceptor = ref.watch(
    networkServiceInterceptorProvider(dio),
  ); // parameterized provider using family providers
  dio.interceptors.addAll([
    HttpFormatter(),
    customInterceptor,
  ]);
  return dio;
});

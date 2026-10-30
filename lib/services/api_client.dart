import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart' hide Response, FormData, MultipartFile;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:real_web_rough_entry_system/common/widgets.dart';
import 'package:real_web_rough_entry_system/controllers/default_controller.dart';

/// Centralized ApiClient implementing Dio QueuedInterceptorsWrapper for 401
/// auto-retries, along with a proactive 28-minute background refresh timer.
class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;
  static ApiClient get instance => _instance;
  static ApiClient get to => _instance;

  late Dio dio;
  Timer? _refreshTimer;

  String baseUrl = 'http://localhost:8080/';

  ApiClient._internal() {
    dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        headers: {'Content-Type': 'application/json'},
      ),
    );

    // Add QueuedInterceptor for seamless 401 handling & request retrying
    dio.interceptors.add(
      QueuedInterceptorsWrapper(
        onRequest: (options, handler) async {
          final String path = options.path.toLowerCase();
          final bool isAuthPath = path.contains('user/login') ||
              path.contains('user/refresh-token');

          if (!isAuthPath) {
            String token = '';
            if (Get.isRegistered<DefaultController>()) {
              token = DefaultController.to.authToken.value;
            }
            if (token.isEmpty) {
              try {
                final SharedPreferences prefs =
                    await SharedPreferences.getInstance();
                token = prefs.getString('token') ?? '';
              } catch (_) {}
            }

            if (token.isNotEmpty) {
              options.headers['Authorization'] = 'Bearer $token';
            }
          }
          return handler.next(options);
        },
        onError: (DioException error, handler) async {
          final String path = error.requestOptions.path.toLowerCase();
          final bool isAuthEndpoint = path.contains('user/login') ||
              path.contains('user/refresh-token') ||
              path.contains('user/revoke-token');

          // If 401 Unauthorized (Token expired after 30 mins)
          if (error.response?.statusCode == 401 && !isAuthEndpoint) {
            final isRefreshed = await refreshToken();
            if (isRefreshed) {
              // Retry the failed original request with the new token
              final prefs = await SharedPreferences.getInstance();
              final newToken = prefs.getString('token');

              error.requestOptions.headers['Authorization'] =
                  'Bearer $newToken';

              try {
                final response = await dio.fetch(error.requestOptions);
                return handler.resolve(response);
              } catch (e) {
                return handler.next(error);
              }
            } else {
              // Refresh failed or revoked -> logout
              await logout();
            }
          }
          return handler.next(error);
        },
      ),
    );
  }

  /// Resolve path properly regardless of baseUrl format
  String resolvePath(String endpoint) {
    final clean = endpoint.startsWith('/') ? endpoint.substring(1) : endpoint;
    if (baseUrl.endsWith('rough-entry') || baseUrl.endsWith('rough-entry/')) {
      return clean.startsWith('rough-entry/')
          ? clean.replaceFirst('rough-entry/', '')
          : clean;
    } else {
      return clean.startsWith('rough-entry/')
          ? clean
          : 'rough-entry/$clean';
    }
  }

  // --------------------------------------------------------------------------
  // REFRESH TOKEN LOGIC
  // --------------------------------------------------------------------------
  Future<bool> refreshToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String currentRefreshToken = prefs.getString('refreshToken') ?? '';
      if (currentRefreshToken.isEmpty && Get.isRegistered<DefaultController>()) {
        currentRefreshToken = DefaultController.to.refreshToken.value;
      }

      if (currentRefreshToken.isEmpty) {
        return false;
      }

      // Use a separate Dio instance to avoid interceptor loop
      final tokenDio = Dio(
        BaseOptions(
          baseUrl: baseUrl,
          connectTimeout: const Duration(seconds: 15),
          receiveTimeout: const Duration(seconds: 15),
          headers: {'Content-Type': 'application/json'},
        ),
      );

      final response = await tokenDio.post(
        resolvePath('user/refresh-token'),
        data: {'refreshToken': currentRefreshToken},
      );

      if (response.statusCode == 200 && response.data != null) {
        final resData = (response.data is Map)
            ? Map<String, dynamic>.from(response.data as Map)
            : <String, dynamic>{};

        final String newToken = resData['token']?.toString() ??
            resData['Token']?.toString() ??
            resData['accessToken']?.toString() ??
            '';
        final String newRefreshToken = resData['refreshToken']?.toString() ??
            resData['RefreshToken']?.toString() ??
            '';

        if (newToken.isNotEmpty) {
          // Save new rotated tokens
          await prefs.setString('token', newToken);
          if (newRefreshToken.isNotEmpty) {
            await prefs.setString('refreshToken', newRefreshToken);
          }

          if (Get.isRegistered<DefaultController>()) {
            DefaultController.to.authToken.value = newToken;
            if (newRefreshToken.isNotEmpty) {
              DefaultController.to.refreshToken.value = newRefreshToken;
            }
          }

          dio.options.headers['Authorization'] = 'Bearer $newToken';
          if (kDebugMode) {
            print('✅ Flutter: Token refreshed successfully!');
          }
          return true;
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Flutter: Refresh token failed: $e');
      }
    }
    return false;
  }

  // --------------------------------------------------------------------------
  // PROACTIVE AUTO-REFRESH TIMER (Every 28 minutes)
  // --------------------------------------------------------------------------
  void startAutoRefreshTimer() {
    stopAutoRefreshTimer();
    // 28 minutes duration
    const duration = Duration(minutes: 28);
    _refreshTimer = Timer.periodic(duration, (timer) async {
      if (kDebugMode) {
        print('⏰ Flutter: 28-min timer triggered -> auto-refreshing token...');
      }
      final success = await refreshToken();
      if (!success) {
        stopAutoRefreshTimer();
      }
    });
    if (kDebugMode) {
      print('⏰ Flutter: 28-min auto-refresh timer started');
    }
  }

  void stopAutoRefreshTimer() {
    _refreshTimer?.cancel();
    _refreshTimer = null;
  }

  // --------------------------------------------------------------------------
  // LOGOUT & REVOKE TOKEN
  // --------------------------------------------------------------------------
  Future<void> logout() async {
    stopAutoRefreshTimer();
    final prefs = await SharedPreferences.getInstance();
    final currentRefreshToken = prefs.getString('refreshToken');

    if (currentRefreshToken != null && currentRefreshToken.isNotEmpty) {
      try {
        final tokenDio = Dio(
          BaseOptions(
            baseUrl: baseUrl,
            connectTimeout: const Duration(seconds: 5),
            receiveTimeout: const Duration(seconds: 5),
            headers: {'Content-Type': 'application/json'},
          ),
        );
        await tokenDio.post(
          resolvePath('user/revoke-token'),
          data: {'refreshToken': currentRefreshToken},
        );
      } catch (_) {}
    }

    await prefs.clear();
    if (Get.isRegistered<DefaultController>()) {
      final ctrl = DefaultController.to;
      ctrl.authToken.value = '';
      ctrl.refreshToken.value = '';
      ctrl.currentUserId.value = 0;
      ctrl.currentUserName.value = '';
      ctrl.currentUserFullName.value = '';
      ctrl.userAccessMap.clear();
      ctrl.menuList.clear();
      ctrl.companyCode.value = 0;
      ctrl.loginCompanyCode.value = 0;
    }
    showLoginDialog();
  }

  // --------------------------------------------------------------------------
  // DYNAMIC BASE URL & REQUEST HELPERS
  // --------------------------------------------------------------------------
  void updateBaseUrl(String newUrl) {
    baseUrl = newUrl;
    dio.options.baseUrl = newUrl;
  }

  Future<Response<dynamic>> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    return await dio.get(
      path,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
    );
  }

  Future<Response<dynamic>> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    return await dio.post(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
    );
  }

  Future<Response<dynamic>> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    return await dio.put(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
    );
  }

  Future<Response<dynamic>> delete(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    return await dio.delete(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
    );
  }
}

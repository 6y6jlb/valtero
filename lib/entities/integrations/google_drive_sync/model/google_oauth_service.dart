import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';
import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:flutter_web_auth_2/flutter_web_auth_2.dart';
import 'package:valtero/entities/integrations/google_drive_sync/model/google_oauth_config.dart';
import 'package:valtero/entities/integrations/google_drive_sync/model/google_oauth_tokens.dart';

/// Authorization Code + PKCE against Google, using [flutter_web_auth_2] + [Dio].
class GoogleOAuthService {
  GoogleOAuthService(this._dio, {Sha256? sha256})
      : _sha256 = sha256 ?? Sha256();

  final Dio _dio;
  final Sha256 _sha256;

  /// Opens the system browser / Custom Tab, returns tokens + email.
  Future<GoogleOAuthSignInResult> signIn({
    required bool includeFileScope,
    GoogleDriveOAuthScopeMode? scopeMode,
    String? clientId,
    String? clientSecret,
  }) async {
    final id = (clientId ?? googleOAuthClientIdForPlatform()).trim();
    if (id.isEmpty) {
      throw const GoogleOAuthException('missing_client_id');
    }
    final secret =
        (clientSecret ?? googleOAuthClientSecretForPlatform()).trim();
    if (isGoogleOAuthDesktopClientSecretRequired && secret.isEmpty) {
      throw const GoogleOAuthException('missing_client_secret');
    }

    final redirect = GoogleOAuthRedirect.forPlatform(clientId: id);
    final verifier = _randomUrlSafe(64);
    final challenge = await _codeChallenge(verifier);

    final authUri = Uri.parse(kGoogleOAuthAuthEndpoint).replace(
      queryParameters: {
        'response_type': 'code',
        'client_id': id,
        'redirect_uri': redirect.redirectUri,
        'scope': googleDriveSyncScopes(
          includeFileScope: includeFileScope,
          mode: scopeMode,
        ),
        'code_challenge': challenge,
        'code_challenge_method': 'S256',
        'access_type': 'offline',
        'prompt': 'consent',
      },
    );

    late final String resultUrl;
    try {
      resultUrl = await FlutterWebAuth2.authenticate(
        url: authUri.toString(),
        callbackUrlScheme: redirect.callbackUrlScheme,
        options: FlutterWebAuth2Options(
          useWebview: redirect.useWebview,
          timeout: 300,
        ),
      );
    } on PlatformException catch (e) {
      throw GoogleOAuthException(
        _platformAuthErrorKey(e),
        detail: e.message,
      );
    } on ArgumentError catch (e) {
      throw GoogleOAuthException(
        'invalid_redirect_scheme',
        detail: e.message,
      );
    } catch (e) {
      throw GoogleOAuthException(
        'sign_in_failed',
        detail: e.toString(),
      );
    }

    final returned = Uri.parse(resultUrl);
    final error = returned.queryParameters['error'];
    if (error != null && error.isNotEmpty) {
      throw GoogleOAuthException(
        'auth_$error',
        detail: returned.queryParameters['error_description'],
      );
    }
    final code = returned.queryParameters['code'];
    if (code == null || code.isEmpty) {
      throw const GoogleOAuthException('missing_auth_code');
    }

    final tokens = await _exchangeCode(
      clientId: id,
      clientSecret: secret,
      code: code,
      codeVerifier: verifier,
      redirectUri: redirect.redirectUri,
    );
    if (tokens.accessToken.isEmpty) {
      throw const GoogleOAuthException('empty_access_token');
    }
    final email = await fetchEmail(tokens.accessToken);
    return GoogleOAuthSignInResult(tokens: tokens, email: email);
  }

  Future<GoogleOAuthTokens> refreshAccessToken({
    required String refreshToken,
    String? clientId,
    String? clientSecret,
  }) async {
    final id = (clientId ?? googleOAuthClientIdForPlatform()).trim();
    if (id.isEmpty) {
      throw const GoogleOAuthException('missing_client_id');
    }
    if (refreshToken.trim().isEmpty) {
      throw const GoogleOAuthException('missing_refresh_token');
    }
    final secret =
        (clientSecret ?? googleOAuthClientSecretForPlatform()).trim();
    try {
      final body = <String, String>{
        'client_id': id,
        'grant_type': 'refresh_token',
        'refresh_token': refreshToken,
        if (secret.isNotEmpty) 'client_secret': secret,
      };
      final response = await _dio.post<Map<String, dynamic>>(
        kGoogleOAuthTokenEndpoint,
        data: body,
        options: Options(
          contentType: Headers.formUrlEncodedContentType,
          responseType: ResponseType.json,
        ),
      );
      final data = response.data;
      if (data == null) {
        throw const GoogleOAuthException('empty_token_response');
      }
      final tokens = GoogleOAuthTokens.fromJson(
        data,
        previousRefreshToken: refreshToken,
      );
      if (tokens.accessToken.isEmpty) {
        throw const GoogleOAuthException('empty_access_token');
      }
      return tokens;
    } on DioException catch (e) {
      throw _oauthDioException(e);
    }
  }

  Future<String?> fetchEmail(String accessToken) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        kGoogleUserInfoEndpoint,
        options: Options(
          headers: {'Authorization': 'Bearer $accessToken'},
          responseType: ResponseType.json,
        ),
      );
      return response.data?['email'] as String?;
    } on DioException {
      return null;
    }
  }

  Future<GoogleOAuthTokens> _exchangeCode({
    required String clientId,
    required String clientSecret,
    required String code,
    required String codeVerifier,
    required String redirectUri,
  }) async {
    try {
      final body = <String, String>{
        'client_id': clientId,
        'code': code,
        'code_verifier': codeVerifier,
        'redirect_uri': redirectUri,
        'grant_type': 'authorization_code',
        if (clientSecret.isNotEmpty) 'client_secret': clientSecret,
      };
      final response = await _dio.post<Map<String, dynamic>>(
        kGoogleOAuthTokenEndpoint,
        data: body,
        options: Options(
          contentType: Headers.formUrlEncodedContentType,
          responseType: ResponseType.json,
        ),
      );
      final data = response.data;
      if (data == null) {
        throw const GoogleOAuthException('empty_token_response');
      }
      return GoogleOAuthTokens.fromJson(data);
    } on DioException catch (e) {
      throw _oauthDioException(e);
    }
  }

  Future<String> _codeChallenge(String verifier) async {
    final hash = await _sha256.hash(utf8.encode(verifier));
    return _base64UrlNoPad(hash.bytes);
  }

  String _randomUrlSafe(int byteLength) {
    final bytes = Uint8List(byteLength);
    final rng = Random.secure();
    for (var i = 0; i < byteLength; i++) {
      bytes[i] = rng.nextInt(256);
    }
    return _base64UrlNoPad(bytes);
  }

  String _base64UrlNoPad(List<int> bytes) {
    return base64UrlEncode(bytes).replaceAll('=', '');
  }

  GoogleOAuthException _oauthDioException(DioException e) {
    final parsed = _parseGoogleOAuthError(e.response?.data);
    final code = parsed.$1 ?? _dioErrorKey(e);
    final detail = parsed.$2 ?? e.message;
    return GoogleOAuthException(code, detail: detail);
  }

  /// Returns `(error, error_description)` from Google's token JSON body.
  (String?, String?) _parseGoogleOAuthError(Object? data) {
    Map<String, dynamic>? map;
    if (data is Map) {
      map = Map<String, dynamic>.from(data);
    } else if (data is String && data.trim().isNotEmpty) {
      try {
        final decoded = jsonDecode(data);
        if (decoded is Map) {
          map = Map<String, dynamic>.from(decoded);
        }
      } catch (_) {
        return (null, data);
      }
    }
    if (map == null) return (null, null);
    final error = map['error']?.toString();
    final description = map['error_description']?.toString();
    if (error == null || error.isEmpty) {
      return (null, description);
    }
    // Normalize Google's token errors to stable app keys.
    final normalized = switch (error) {
      'invalid_grant' => 'invalid_grant',
      'invalid_client' => 'invalid_client',
      'invalid_request' => _invalidRequestKey(description),
      'unauthorized_client' => 'unauthorized_client',
      _ => error,
    };
    return (normalized, description ?? error);
  }

  String _invalidRequestKey(String? description) {
    final d = (description ?? '').toLowerCase();
    if (d.contains('client_secret')) {
      return 'missing_client_secret';
    }
    if (d.contains('redirect_uri')) {
      return 'redirect_uri_mismatch';
    }
    return 'invalid_request';
  }

  String _dioErrorKey(DioException e) {
    final status = e.response?.statusCode;
    if (status == 400 || status == 401) return 'invalid_grant';
    switch (e.type) {
      case DioExceptionType.connectionError:
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'network_error';
      default:
        break;
    }
    return 'token_exchange_failed';
  }

  /// Maps Custom Tab / browser auth cancellations and platform failures.
  String _platformAuthErrorKey(PlatformException e) {
    final code = (e.code).toLowerCase();
    if (code.contains('cancel') || code.contains('dismiss')) {
      return 'auth_canceled';
    }
    if (code.contains('timeout')) {
      return 'auth_timeout';
    }
    return 'sign_in_failed';
  }
}

class GoogleOAuthSignInResult {
  final GoogleOAuthTokens tokens;
  final String? email;

  const GoogleOAuthSignInResult({
    required this.tokens,
    required this.email,
  });
}

class GoogleOAuthException implements Exception {
  final String code;
  final String? detail;

  const GoogleOAuthException(this.code, {this.detail});

  @override
  String toString() {
    if (detail == null || detail!.isEmpty) {
      return 'GoogleOAuthException($code)';
    }
    return 'GoogleOAuthException($code, $detail)';
  }
}

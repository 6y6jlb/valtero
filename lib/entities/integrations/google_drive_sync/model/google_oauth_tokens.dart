/// Tokens returned by Google's token endpoint.
class GoogleOAuthTokens {
  final String accessToken;
  final String? refreshToken;
  final DateTime expiresAt;
  final String? tokenType;
  final String? scope;

  const GoogleOAuthTokens({
    required this.accessToken,
    required this.refreshToken,
    required this.expiresAt,
    this.tokenType,
    this.scope,
  });

  bool get isExpired =>
      DateTime.now().isAfter(expiresAt.subtract(const Duration(seconds: 60)));

  factory GoogleOAuthTokens.fromJson(
    Map<String, dynamic> json, {
    String? previousRefreshToken,
  }) {
    final expiresIn = (json['expires_in'] as num?)?.toInt() ?? 3600;
    final refresh = json['refresh_token'] as String?;
    return GoogleOAuthTokens(
      accessToken: json['access_token'] as String? ?? '',
      refreshToken: (refresh != null && refresh.isNotEmpty)
          ? refresh
          : previousRefreshToken,
      expiresAt: DateTime.now().add(Duration(seconds: expiresIn)),
      tokenType: json['token_type'] as String?,
      scope: json['scope'] as String?,
    );
  }

  GoogleOAuthTokens copyWith({
    String? accessToken,
    String? refreshToken,
    DateTime? expiresAt,
    String? tokenType,
    String? scope,
  }) {
    return GoogleOAuthTokens(
      accessToken: accessToken ?? this.accessToken,
      refreshToken: refreshToken ?? this.refreshToken,
      expiresAt: expiresAt ?? this.expiresAt,
      tokenType: tokenType ?? this.tokenType,
      scope: scope ?? this.scope,
    );
  }
}

import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:valtero/entities/integrations/google_drive_sync/model/google_oauth_config.dart';

/// Metadata for a Drive file used by sync.
class GoogleDriveFileMeta {
  final String id;
  final String name;
  final DateTime? modifiedTime;
  final int? size;
  final String? ownerEmail;

  const GoogleDriveFileMeta({
    required this.id,
    required this.name,
    required this.modifiedTime,
    required this.size,
    this.ownerEmail,
  });

  factory GoogleDriveFileMeta.fromJson(Map<String, dynamic> json) {
    final modified = json['modifiedTime'] as String?;
    String? ownerEmail;
    final owners = json['owners'];
    if (owners is List && owners.isNotEmpty) {
      final first = owners.first;
      if (first is Map) {
        ownerEmail = first['emailAddress'] as String?;
      }
    }
    return GoogleDriveFileMeta(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      modifiedTime: modified != null ? DateTime.tryParse(modified) : null,
      size: int.tryParse('${json['size'] ?? ''}'),
      ownerEmail: ownerEmail,
    );
  }
}

/// Thin Drive v3 REST client (appDataFolder + optional shared file).
class GoogleDriveRestClient {
  GoogleDriveRestClient(this._dio);

  final Dio _dio;

  static const _filesUrl = 'https://www.googleapis.com/drive/v3/files';
  static const _uploadUrl =
      'https://www.googleapis.com/upload/drive/v3/files';

  Options _auth(String accessToken, {ResponseType? responseType}) {
    return Options(
      headers: {'Authorization': 'Bearer $accessToken'},
      responseType: responseType,
    );
  }

  /// Finds the personal sync snapshot in `appDataFolder`, if any.
  Future<GoogleDriveFileMeta?> findAppDataSyncFile(String accessToken) async {
    final response = await _dio.get<Map<String, dynamic>>(
      _filesUrl,
      queryParameters: {
        'spaces': 'appDataFolder',
        'q': "name = '$kGoogleDriveSyncFileName' and trashed = false",
        'fields': 'files(id,name,modifiedTime,size)',
        'pageSize': 1,
      },
      options: _auth(accessToken),
    );
    final files = response.data?['files'];
    if (files is! List || files.isEmpty) return null;
    final first = files.first;
    if (first is! Map) return null;
    return GoogleDriveFileMeta.fromJson(Map<String, dynamic>.from(first));
  }

  Future<Uint8List> downloadFile({
    required String accessToken,
    required String fileId,
  }) async {
    final response = await _dio.get<List<int>>(
      '$_filesUrl/$fileId',
      queryParameters: {'alt': 'media'},
      options: _auth(accessToken, responseType: ResponseType.bytes),
    );
    final data = response.data;
    if (data == null) {
      throw const GoogleDriveException('empty_download');
    }
    return Uint8List.fromList(data);
  }

  /// Creates or updates the encrypted snapshot in `appDataFolder`.
  Future<GoogleDriveFileMeta> uploadAppDataSyncFile({
    required String accessToken,
    required String content,
    String? existingFileId,
  }) {
    return _uploadMultipart(
      accessToken: accessToken,
      content: content,
      existingFileId: existingFileId,
      parents: existingFileId == null ? const ['appDataFolder'] : null,
      fileName: kGoogleDriveSyncFileName,
    );
  }

  /// Creates a regular Drive file for shared sync (requires `drive.file` scope).
  Future<GoogleDriveFileMeta> createSharedSyncFile({
    required String accessToken,
    required String content,
  }) {
    return _uploadMultipart(
      accessToken: accessToken,
      content: content,
      existingFileId: null,
      parents: null,
      fileName: kGoogleDriveSharedSyncFileName,
    );
  }

  Future<GoogleDriveFileMeta> updateFileContent({
    required String accessToken,
    required String fileId,
    required String content,
  }) {
    return _uploadMultipart(
      accessToken: accessToken,
      content: content,
      existingFileId: fileId,
      parents: null,
      fileName: null,
    );
  }

  /// Grants [email] writer access to [fileId] (shared sync).
  Future<void> shareFileWithEmail({
    required String accessToken,
    required String fileId,
    required String email,
  }) async {
    await _dio.post<Map<String, dynamic>>(
      '$_filesUrl/$fileId/permissions',
      queryParameters: {
        'sendNotificationEmail': true,
        'fields': 'id',
      },
      data: {
        'type': 'user',
        'role': 'writer',
        'emailAddress': email.trim(),
      },
      options: _auth(accessToken),
    );
  }

  /// Lists shared sync files visible to this account (sharedWithMe).
  /// Requires full `drive` scope — `drive.file` alone cannot discover these.
  Future<List<GoogleDriveFileMeta>> listSharedSyncFiles(
    String accessToken,
  ) async {
    final response = await _dio.get<Map<String, dynamic>>(
      _filesUrl,
      queryParameters: {
        'q': "sharedWithMe = true and name = '$kGoogleDriveSharedSyncFileName' "
            'and trashed = false',
        'fields': 'files(id,name,modifiedTime,size,owners(emailAddress))',
        'pageSize': 20,
      },
      options: _auth(accessToken),
    );
    final files = response.data?['files'];
    if (files is! List) return const [];
    return files
        .whereType<Map>()
        .map((e) => GoogleDriveFileMeta.fromJson(Map<String, dynamic>.from(e)))
        .where((f) => f.id.isNotEmpty)
        .toList();
  }

  /// Fetches metadata for a known file id (works with drive.file when the
  /// app created the file, or full drive for shared-with-me files).
  Future<GoogleDriveFileMeta?> getFileMeta({
    required String accessToken,
    required String fileId,
  }) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '$_filesUrl/$fileId',
        queryParameters: {
          'fields': 'id,name,modifiedTime,size,owners(emailAddress)',
        },
        options: _auth(accessToken),
      );
      final data = response.data;
      if (data == null) return null;
      return GoogleDriveFileMeta.fromJson(data);
    } on DioException {
      return null;
    }
  }

  /// Lightweight probe used by Test connection.
  Future<void> about(String accessToken) async {
    await _dio.get<Map<String, dynamic>>(
      'https://www.googleapis.com/drive/v3/about',
      queryParameters: {'fields': 'user'},
      options: _auth(accessToken),
    );
  }

  Future<GoogleDriveFileMeta> _uploadMultipart({
    required String accessToken,
    required String content,
    required String? existingFileId,
    required List<String>? parents,
    required String? fileName,
  }) async {
    final metadata = <String, dynamic>{
      'name': ?fileName,
      if (parents != null && parents.isNotEmpty) 'parents': parents,
    };
    final metaString = jsonEncode(metadata);
    final boundary = 'valtero_boundary_${DateTime.now().millisecondsSinceEpoch}';
    final body = StringBuffer()
      ..write('--$boundary\r\n')
      ..write('Content-Type: application/json; charset=UTF-8\r\n\r\n')
      ..write(metaString)
      ..write('\r\n--$boundary\r\n')
      ..write('Content-Type: application/json; charset=UTF-8\r\n\r\n')
      ..write(content)
      ..write('\r\n--$boundary--');

    final isUpdate = existingFileId != null && existingFileId.isNotEmpty;
    final url = isUpdate ? '$_uploadUrl/$existingFileId' : _uploadUrl;
    final response = await _dio.request<Map<String, dynamic>>(
      url,
      data: body.toString(),
      queryParameters: {
        'uploadType': 'multipart',
        'fields': 'id,name,modifiedTime,size',
      },
      options: Options(
        method: isUpdate ? 'PATCH' : 'POST',
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'multipart/related; boundary=$boundary',
        },
        responseType: ResponseType.json,
      ),
    );
    final data = response.data;
    if (data == null) {
      throw const GoogleDriveException('empty_upload_response');
    }
    return GoogleDriveFileMeta.fromJson(data);
  }
}

class GoogleDriveException implements Exception {
  final String code;
  const GoogleDriveException(this.code);

  @override
  String toString() => 'GoogleDriveException($code)';
}

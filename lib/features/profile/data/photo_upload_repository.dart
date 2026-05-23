import 'dart:io';

import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/api/api_client.dart';
import '../../../core/config/sphere_config.dart';

part 'photo_upload_repository.g.dart';

class PhotoUploadResult {
  const PhotoUploadResult({
    required this.url,
    required this.bgRemoved,
    this.bgSource,
  });
  final String url;
  final bool bgRemoved;
  final String? bgSource;
}

class PhotoUploadRepository {
  PhotoUploadRepository({
    ImagePicker? picker,
    FirebaseAuth? auth,
    Dio? dio,
  })  : _picker = picker ?? ImagePicker(),
        _auth = auth ?? FirebaseAuth.instance,
        _dio = dio ?? buildApiClient(baseUrl: SphereConfig.apiBaseUrl);

  final ImagePicker _picker;
  final FirebaseAuth _auth;
  final Dio _dio;

  Future<XFile?> pickPhoto({required bool fromCamera}) async {
    return _picker.pickImage(
      source: fromCamera ? ImageSource.camera : ImageSource.gallery,
      imageQuality: 90,
      maxWidth: 1200,
    );
  }

  /// Uploads [file] through the backend pipeline:
  /// 1. Gemini validates (face visible, single person, suitable)
  /// 2. Background removed and standardised to 512×512 PNG
  /// 3. Stored in Firebase Storage, player doc updated
  ///
  /// Returns [PhotoUploadResult] with the final URL and whether BG was removed.
  /// Throws [PhotoValidationException] (422) or [PhotoUploadException] on error.
  Future<PhotoUploadResult> uploadWithBgRemoval(XFile file) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) throw const PhotoUploadException('Not signed in');

    // Resolve player Firestore doc ID.
    final playerId = await _resolvePlayerId();
    if (playerId == null || playerId.isEmpty) {
      throw const PhotoUploadException(
          'Player profile not found — ask your coach to add you first.');
    }

    final bytes = await File(file.path).readAsBytes();
    final mimeType = _mimeFromPath(file.path);

    final formData = FormData.fromMap({
      'targetType': 'player',
      'targetId': playerId,
      'photo': MultipartFile.fromBytes(bytes,
          filename: 'photo.${_extFromPath(file.path)}',
          contentType: DioMediaType.parse(mimeType)),
    });

    try {
      final res = await _dio.post<Map<String, dynamic>>(
        '/api/profile-photo/process',
        data: formData,
        options: Options(
          receiveTimeout: const Duration(minutes: 2),
          sendTimeout: const Duration(seconds: 60),
        ),
      );
      final body = res.data ?? {};
      final url = body['url'] as String? ?? '';
      await _auth.currentUser?.updatePhotoURL(url);
      return PhotoUploadResult(
        url: url,
        bgRemoved: body['bgRemoved'] as bool? ?? false,
        bgSource: body['bgSource'] as String?,
      );
    } on DioException catch (e) {
      if (e.response?.statusCode == 422) {
        final body = e.response?.data as Map<String, dynamic>? ?? {};
        final reason = body['reason'] as String? ?? 'Photo did not pass review';
        throw PhotoValidationException(reason);
      }
      throw PhotoUploadException(
          e.response?.data is Map
              ? ((e.response!.data as Map)['error'] ?? 'Upload failed').toString()
              : 'Upload failed');
    }
  }

  Future<String?> _resolvePlayerId() async {
    try {
      final res =
          await _dio.get<Map<String, dynamic>>('/api/player-app/profile');
      final profile = res.data?['profile'] as Map<String, dynamic>?;
      return profile?['playerId'] as String?;
    } catch (_) {
      return null;
    }
  }

  static String _mimeFromPath(String path) {
    final ext = path.split('.').last.toLowerCase();
    return switch (ext) {
      'jpg' || 'jpeg' => 'image/jpeg',
      'png' => 'image/png',
      'webp' => 'image/webp',
      'heic' => 'image/heic',
      'heif' => 'image/heif',
      _ => 'image/jpeg',
    };
  }

  static String _extFromPath(String path) =>
      path.split('.').last.toLowerCase();
}

class PhotoUploadException implements Exception {
  const PhotoUploadException(this.message);
  final String message;
  @override
  String toString() => message;
}

class PhotoValidationException implements Exception {
  const PhotoValidationException(this.reason);
  final String reason;
  @override
  String toString() => reason;
}

@Riverpod(keepAlive: true)
PhotoUploadRepository photoUploadRepository(Ref ref) =>
    PhotoUploadRepository();

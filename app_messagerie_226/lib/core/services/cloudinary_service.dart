import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// ─── Configuration ────────────────────────────────────────────────────────────
// Remplacer par tes valeurs depuis https://console.cloudinary.com
class CloudinaryConfig {
  static const String cloudName = 'inpld4jx';
  static const String uploadPreset = 'unite226_unsigned';

  static const String profilePhotosFolder = 'unite226/profile_photos';
  static const String idCardsFolder = 'unite226/id_cards';
  static const String groupMediaFolder = 'unite226/group_media';
}

enum CloudinaryResourceType { image, video, raw }

// ─── Service ──────────────────────────────────────────────────────────────────
class CloudinaryService {
  final Dio _dio = Dio();

  Future<String> uploadFile({
    required File file,
    required String folder,
    CloudinaryResourceType resourceType = CloudinaryResourceType.image,
    void Function(int sent, int total)? onProgress,
  }) async {
    final url =
        'https://api.cloudinary.com/v1_1/${CloudinaryConfig.cloudName}/${resourceType.name}/upload';

    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(file.path),
      'upload_preset': CloudinaryConfig.uploadPreset,
      'folder': folder,
    });

    final response = await _dio.post(
      url,
      data: formData,
      onSendProgress: onProgress,
      options: Options(headers: {'Content-Type': 'multipart/form-data'}),
    );

    if (response.statusCode == 200) {
      return response.data['secure_url'] as String;
    }
    throw Exception('Cloudinary upload failed: ${response.statusCode}');
  }

  Future<String> uploadProfilePhoto(File file, String uid) => uploadFile(
        file: file,
        folder: '${CloudinaryConfig.profilePhotosFolder}/$uid',
      );

  Future<String> uploadIdCard(File file, String uid, String side) => uploadFile(
        file: file,
        folder: '${CloudinaryConfig.idCardsFolder}/$uid',
      );

  Future<String> uploadGroupImage(File file, String groupId) => uploadFile(
        file: file,
        folder: '${CloudinaryConfig.groupMediaFolder}/$groupId',
      );

  Future<String> uploadGroupVideo(File file, String groupId) => uploadFile(
        file: file,
        folder: '${CloudinaryConfig.groupMediaFolder}/$groupId',
        resourceType: CloudinaryResourceType.video,
      );

  Future<String> uploadGroupVoice(File file, String groupId) => uploadFile(
        file: file,
        folder: '${CloudinaryConfig.groupMediaFolder}/$groupId',
        resourceType: CloudinaryResourceType.raw,
      );
}

final cloudinaryServiceProvider = Provider<CloudinaryService>(
  (_) => CloudinaryService(),
);

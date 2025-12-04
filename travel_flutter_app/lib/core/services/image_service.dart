import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import '../utils/app_logger.dart';

/// 이미지 선택 및 저장 서비스
class ImageService {
  final ImagePicker _picker = ImagePicker();

  /// 갤러리에서 이미지 선택
  Future<String?> pickImageFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );

      if (image == null) {
        appLogger.d('이미지 선택 취소됨');
        return null;
      }

      // 이미지를 앱 디렉토리에 저장
      final String savedPath = await _saveImage(image.path);
      appLogger.i('이미지 저장 완료: $savedPath');
      return savedPath;
    } catch (e) {
      appLogger.e('이미지 선택 실패', error: e);
      return null;
    }
  }

  /// 카메라로 사진 촬영
  Future<String?> takePhoto() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );

      if (image == null) {
        appLogger.d('사진 촬영 취소됨');
        return null;
      }

      // 이미지를 앱 디렉토리에 저장
      final String savedPath = await _saveImage(image.path);
      appLogger.i('사진 저장 완료: $savedPath');
      return savedPath;
    } catch (e) {
      appLogger.e('사진 촬영 실패', error: e);
      return null;
    }
  }

  /// 여러 이미지 선택
  Future<List<String>> pickMultipleImages({int maxImages = 15}) async {
    try {
      final List<XFile> images = await _picker.pickMultiImage(
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );

      if (images.isEmpty) {
        appLogger.d('이미지 선택 취소됨');
        return [];
      }

      // 최대 개수 제한
      final List<XFile> limitedImages = images.take(maxImages).toList();

      // 모든 이미지를 앱 디렉토리에 저장
      final List<String> savedPaths = [];
      for (final image in limitedImages) {
        final String savedPath = await _saveImage(image.path);
        savedPaths.add(savedPath);
      }

      appLogger.i('${savedPaths.length}개 이미지 저장 완료');
      return savedPaths;
    } catch (e) {
      appLogger.e('이미지 선택 실패', error: e);
      return [];
    }
  }

  /// 이미지를 앱 디렉토리에 저장
  Future<String> _saveImage(String sourcePath) async {
    final appDir = await getApplicationDocumentsDirectory();
    final imagesDir = Directory('${appDir.path}/diary_images');

    // 디렉토리가 없으면 생성
    if (!await imagesDir.exists()) {
      await imagesDir.create(recursive: true);
    }

    // 고유한 파일명 생성
    final String fileName =
        '${DateTime.now().millisecondsSinceEpoch}${path.extension(sourcePath)}';
    final String destinationPath = '${imagesDir.path}/$fileName';

    // 파일 복사
    final File sourceFile = File(sourcePath);
    await sourceFile.copy(destinationPath);

    return destinationPath;
  }

  /// 이미지 파일 삭제
  Future<void> deleteImage(String imagePath) async {
    try {
      final File file = File(imagePath);
      if (await file.exists()) {
        await file.delete();
        appLogger.i('이미지 삭제 완료: $imagePath');
      }
    } catch (e) {
      appLogger.e('이미지 삭제 실패', error: e);
    }
  }

  /// 여러 이미지 파일 삭제
  Future<void> deleteImages(List<String> imagePaths) async {
    for (final imagePath in imagePaths) {
      await deleteImage(imagePath);
    }
  }
}

import 'dart:ui';

abstract class ImageService {
  Future<List<String>> pickImages();
  Future<String?> captureImage();
  Future<String> compressImage(String path, int quality);
  Future<Size> imageDimensions(String path);
}

import 'dart:typed_data';

class PdfDocInfo {
  final int pageCount;
  final int sizeBytes;
  final bool isEncrypted;

  const PdfDocInfo({
    required this.pageCount,
    required this.sizeBytes,
    required this.isEncrypted,
  });
}

abstract class PdfService {
  Future<PdfDocInfo> loadInfo(String path);
  Future<Uint8List> renderPageThumbnail(String path, int pageIndex,
      {int dpi = 150});
  Future<String> imagesToPdf(
      List<String> imagePaths, Map<String, dynamic> options);
  Future<String> mergePdfs(List<String> paths, Map<String, dynamic> options);
  Future<List<String>> splitPdf(String path, Map<String, dynamic> options);
  Future<String> reorderRotateDeletePages(
      String path, List<Map<String, dynamic>> ops);
  Future<List<String>> pdfToImages(String path, Map<String, dynamic> options);
  Future<String> compressPdf(String path, String preset);
}

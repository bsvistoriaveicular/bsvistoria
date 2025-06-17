import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bs_vistoria_veicular/core/services/ocr_scan_service.dart';

final ocrScanServiceProvider = Provider<OcrScanService>((ref) {
  final ocrService = OcrScanService();
  ref.onDispose(() {
    ocrService.dispose();
  });
  return ocrService;
});

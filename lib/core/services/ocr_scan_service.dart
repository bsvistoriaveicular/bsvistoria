import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';

class OcrScanService {
  final ImagePicker _picker = ImagePicker();
  final TextRecognizer _textRecognizer;

  OcrScanService() : _textRecognizer = TextRecognizer();

  Future<String?> scanImage() async {
    final XFile? pickedFile =
        await _picker.pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      final inputImage = InputImage.fromFilePath(pickedFile.path);
      final RecognizedText recognizedText =
          await _textRecognizer.processImage(inputImage);
      _textRecognizer.close();
      return recognizedText.text;
    } else {
      return null;
    }
  }

  void dispose() {
    _textRecognizer.close();
  }
}

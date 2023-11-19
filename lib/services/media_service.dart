import 'package:file_picker/file_picker.dart';
import 'dart:io'; // Import the dart:io package

class MediaService {
  MediaService() {}

  Future<File?> pickImageFromLibrary() async {
    FilePickerResult? _result = await FilePicker.platform.pickFiles(type: FileType.image);
    if (_result != null) {
      // Convert PlatformFile to File
      File pickedFile = File(_result.files[0].path!);
      return pickedFile;
    }
    return null;
  }
}

import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';

Future<bool> saveBytesAsFile({
  required String fileName,
  required Uint8List bytes,
  List<String>? allowedExtensions,
}) async {
  final type = allowedExtensions == null ? FileType.any : FileType.custom;

  // Android/iOS write the bytes themselves; desktop pickers only return the
  // chosen path (and macOS rejects bytes outright), so we write it here.
  if (Platform.isAndroid || Platform.isIOS) {
    final path = await FilePicker.platform.saveFile(
      fileName: fileName,
      bytes: bytes,
      type: type,
      allowedExtensions: allowedExtensions,
    );
    return path != null;
  }

  final path = await FilePicker.platform.saveFile(
    fileName: fileName,
    type: type,
    allowedExtensions: allowedExtensions,
  );
  if (path == null) return false;
  await File(path).writeAsBytes(bytes, flush: true);
  return true;
}

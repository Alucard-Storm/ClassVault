import 'dart:typed_data';

import 'file_saver_io.dart' if (dart.library.js_interop) 'file_saver_web.dart' as impl;

/// Saves [bytes] as a user-visible file: a save dialog on desktop/mobile, a
/// browser download on web. Returns false if the user cancelled.
Future<bool> saveBytesAsFile({
  required String fileName,
  required Uint8List bytes,
  List<String>? allowedExtensions,
}) {
  return impl.saveBytesAsFile(
    fileName: fileName,
    bytes: bytes,
    allowedExtensions: allowedExtensions,
  );
}

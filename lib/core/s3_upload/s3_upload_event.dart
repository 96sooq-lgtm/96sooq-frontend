import 'dart:typed_data';

abstract class S3UploadEvent {}

class UploadFile extends S3UploadEvent {
  final Uint8List bytes;
  final String filename;
  final String folder;

  UploadFile({
    required this.bytes,
    required this.filename,
    required this.folder,
  });
}

class UploadFiles extends S3UploadEvent {
  final List<({Uint8List bytes, String filename})> files;
  final String folder;

  UploadFiles({required this.files, required this.folder});
}

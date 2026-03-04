class S3UploadResult {
  final String url;
  final String filePath;

  S3UploadResult({required this.url, required this.filePath});

  factory S3UploadResult.fromJson(Map<String, dynamic> json) {
    return S3UploadResult(
      url: (json['url'] ?? '').toString(),
      filePath: (json['file_path'] ?? '').toString(),
    );
  }
}

abstract class S3UploadState {}

class S3UploadInitial extends S3UploadState {}

class S3UploadLoading extends S3UploadState {}

class S3UploadSuccess extends S3UploadState {
  final S3UploadResult result;
  S3UploadSuccess(this.result);
}

class S3UploadFailure extends S3UploadState {
  final String message;
  S3UploadFailure(this.message);
}

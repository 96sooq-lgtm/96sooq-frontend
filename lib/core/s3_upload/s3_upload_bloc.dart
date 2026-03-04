import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 's3_upload_event.dart';
import 's3_upload_service.dart';
import 's3_upload_state.dart';

class S3UploadBloc extends Bloc<S3UploadEvent, S3UploadState> {
  final S3UploadService service;

  S3UploadBloc(this.service) : super(S3UploadInitial()) {
    on<UploadFile>(_uploadFile);
  }

  Future<void> _uploadFile(
    UploadFile event,
    Emitter<S3UploadState> emit,
  ) async {
    emit(S3UploadLoading());
    try {
      final result = await service.uploadFile(
        bytes: event.bytes,
        filename: event.filename,
        folder: event.folder,
      );
      emit(S3UploadSuccess(result));
    } on DioException catch (e) {
      emit(S3UploadFailure(e.message ?? 'Upload failed'));
    } catch (e) {
      emit(S3UploadFailure(e.toString()));
    }
  }
}

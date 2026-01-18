import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';

enum DownloadStatus { idle, downloading, completed, failed, installing }

class DownloadProgress {
  final DownloadStatus status;
  final double progress;
  final String? filePath;
  final String? error;

  const DownloadProgress({
    required this.status,
    this.progress = 0,
    this.filePath,
    this.error,
  });

  factory DownloadProgress.idle() => const DownloadProgress(status: DownloadStatus.idle);

  factory DownloadProgress.downloading(double progress) => DownloadProgress(
        status: DownloadStatus.downloading,
        progress: progress,
      );

  factory DownloadProgress.completed(String filePath) => DownloadProgress(
        status: DownloadStatus.completed,
        progress: 1.0,
        filePath: filePath,
      );

  factory DownloadProgress.failed(String error) => DownloadProgress(
        status: DownloadStatus.failed,
        error: error,
      );

  factory DownloadProgress.installing() => const DownloadProgress(
        status: DownloadStatus.installing,
        progress: 1.0,
      );
}

class DownloadService {
  static final DownloadService _instance = DownloadService._internal();
  factory DownloadService() => _instance;
  DownloadService._internal();

  final Dio _dio = Dio();
  CancelToken? _cancelToken;

  Future<void> downloadApk({
    required String url,
    required String version,
    required void Function(DownloadProgress) onProgress,
  }) async {
    if (kIsWeb) {
      onProgress(DownloadProgress.failed('Загрузка недоступна в веб-версии'));
      return;
    }

    _cancelToken = CancelToken();

    try {
      final dir = await getExternalStorageDirectory() ?? await getApplicationDocumentsDirectory();
      final filePath = '${dir.path}/DayPay-$version.apk';

      final file = File(filePath);
      if (await file.exists()) {
        await file.delete();
      }

      onProgress(DownloadProgress.downloading(0));

      await _dio.download(
        url,
        filePath,
        cancelToken: _cancelToken,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            final progress = received / total;
            onProgress(DownloadProgress.downloading(progress));
          }
        },
      );

      if (await File(filePath).exists()) {
        onProgress(DownloadProgress.completed(filePath));
      } else {
        onProgress(DownloadProgress.failed('Файл не найден после загрузки'));
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.cancel) {
        onProgress(DownloadProgress.idle());
      } else {
        onProgress(DownloadProgress.failed('Ошибка загрузки: ${e.message}'));
      }
    } catch (e) {
      onProgress(DownloadProgress.failed('Ошибка: $e'));
    }
  }

  void cancelDownload() {
    _cancelToken?.cancel();
    _cancelToken = null;
  }

  Future<bool> installApk(String filePath) async {
    if (kIsWeb) return false;

    try {
      final result = await OpenFilex.open(filePath);
      return result.type == ResultType.done;
    } catch (e) {
      debugPrint('Install APK error: $e');
      return false;
    }
  }

  Future<void> deleteDownloadedApk(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      debugPrint('Delete APK error: $e');
    }
  }
}

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/constants/app_constants.dart';
import '../../data/models/update_info.dart';
import '../../domain/services/download_service.dart';
import '../../domain/services/notification_service.dart';
import '../../domain/services/update_service.dart';

class UpdateProvider extends ChangeNotifier {
  final UpdateService _service = UpdateService();
  final DownloadService _downloadService = DownloadService();
  final NotificationService _notificationService = NotificationService();

  UpdateInfo? _updateInfo;
  bool _isChecking = false;
  String? _error;
  bool _lastCheckSucceeded = false;

  DownloadStatus _downloadStatus = DownloadStatus.idle;
  double _downloadProgress = 0;
  String? _downloadedFilePath;
  String? _downloadError;

  UpdateInfo? get updateInfo => _updateInfo;
  bool get isChecking => _isChecking;
  bool get hasUpdate => _updateInfo?.hasUpdate ?? false;
  String? get error => _error;
  bool get isUpToDate => _lastCheckSucceeded && !hasUpdate && _updateInfo?.isError != true;

  String get currentVersion => _updateInfo?.currentVersion ?? '';
  String get latestVersion => _updateInfo?.latestVersion ?? '';
  String? get releaseNotes => _updateInfo?.releaseNotes;
  String? get downloadUrl => _updateInfo?.downloadUrl;

  DownloadStatus get downloadStatus => _downloadStatus;
  double get downloadProgress => _downloadProgress;
  String? get downloadedFilePath => _downloadedFilePath;
  String? get downloadError => _downloadError;
  bool get isDownloading => _downloadStatus == DownloadStatus.downloading;
  bool get isDownloadComplete => _downloadStatus == DownloadStatus.completed;

  Future<void> checkForUpdates({bool forceCheck = false, bool showNotification = false}) async {
    if (_isChecking) return;

    _isChecking = true;
    _error = null;
    _lastCheckSucceeded = false;
    notifyListeners();

    try {
      _updateInfo = await _service.checkForUpdates(forceCheck: forceCheck);
      if (_updateInfo?.isError == true) {
        _error = 'Не удалось проверить обновления';
      } else {
        _lastCheckSucceeded = true;
        if (showNotification && _updateInfo?.hasUpdate == true) {
          await _showUpdateNotificationIfNeeded(_updateInfo!.latestVersion);
        }
      }
    } catch (e) {
      _error = 'Не удалось проверить обновления';
      debugPrint('Update check error: $e');
    } finally {
      _isChecking = false;
      notifyListeners();
    }
  }

  Future<void> _showUpdateNotificationIfNeeded(String version) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lastNotifiedVersion = prefs.getString(AppConstants.lastNotifiedVersionKey);
      final lastNotificationStr = prefs.getString(AppConstants.lastUpdateNotificationKey);

      bool shouldShow = false;

      if (lastNotifiedVersion != version) {
        shouldShow = true;
      } else if (lastNotificationStr != null) {
        final lastNotification = DateTime.tryParse(lastNotificationStr);
        if (lastNotification != null) {
          final diff = DateTime.now().difference(lastNotification);
          if (diff >= AppConstants.updateNotificationInterval) {
            shouldShow = true;
          }
        }
      } else {
        shouldShow = true;
      }

      if (shouldShow) {
        await _notificationService.showUpdateAvailableOnStartup(version);
        await prefs.setString(
          AppConstants.lastUpdateNotificationKey,
          DateTime.now().toIso8601String(),
        );
        await prefs.setString(AppConstants.lastNotifiedVersionKey, version);
      }
    } catch (e) {
      debugPrint('Notification check error: $e');
      await _notificationService.showUpdateAvailableOnStartup(version);
    }
  }

  Future<void> startDownload() async {
    var url = _updateInfo?.downloadUrl;
    debugPrint('startDownload called, url: $url');

    if (url == null) {
      debugPrint('URL is null, force checking for updates...');
      await checkForUpdates(forceCheck: true);
      url = _updateInfo?.downloadUrl;

      if (url == null) {
        _downloadError = 'URL для загрузки не найден';
        _downloadStatus = DownloadStatus.failed;
        notifyListeners();
        return;
      }
    }

    _downloadStatus = DownloadStatus.downloading;
    _downloadProgress = 0;
    _downloadError = null;
    _downloadedFilePath = null;
    notifyListeners();

    int lastNotifiedProgress = -1;

    await _downloadService.downloadApk(
      url: url,
      version: latestVersion,
      onProgress: (progress) async {
        _downloadStatus = progress.status;
        _downloadProgress = progress.progress;
        _downloadError = progress.error;
        _downloadedFilePath = progress.filePath;
        notifyListeners();

        if (progress.status == DownloadStatus.downloading) {
          final currentProgress = (progress.progress * 100).toInt();
          if (currentProgress != lastNotifiedProgress && currentProgress % 5 == 0) {
            lastNotifiedProgress = currentProgress;
            await _notificationService.showDownloadProgressNotification(
              currentProgress,
              latestVersion,
            );
          }
        } else if (progress.status == DownloadStatus.completed) {
          await _notificationService.showDownloadCompleteNotification(latestVersion);
        } else if (progress.status == DownloadStatus.failed) {
          await _notificationService.cancelDownloadNotification();
        }
      },
    );
  }

  void cancelDownload() {
    _downloadService.cancelDownload();
    _downloadStatus = DownloadStatus.idle;
    _downloadProgress = 0;
    _downloadError = null;
    _notificationService.cancelDownloadNotification();
    notifyListeners();
  }

  Future<bool> installUpdate() async {
    if (_downloadedFilePath == null) return false;

    _downloadStatus = DownloadStatus.installing;
    notifyListeners();

    final result = await _downloadService.installApk(_downloadedFilePath!);

    if (!result) {
      _downloadError = 'Не удалось открыть файл для установки';
      _downloadStatus = DownloadStatus.completed;
      notifyListeners();
    }

    return result;
  }

  Future<bool> downloadUpdate() async {
    final url = _updateInfo?.downloadUrl;
    if (url != null) {
      return await _service.openDownloadPage(url);
    }
    return await _service.openReleasesPage();
  }

  void clearError() {
    _error = null;
    _downloadError = null;
    notifyListeners();
  }

  void resetDownloadState() {
    _downloadStatus = DownloadStatus.idle;
    _downloadProgress = 0;
    _downloadError = null;
    _downloadedFilePath = null;
    notifyListeners();
  }
}

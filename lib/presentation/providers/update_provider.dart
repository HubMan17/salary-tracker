import 'package:flutter/foundation.dart';

import '../../data/models/update_info.dart';
import '../../domain/services/update_service.dart';

class UpdateProvider extends ChangeNotifier {
  final UpdateService _service = UpdateService();

  UpdateInfo? _updateInfo;
  bool _isChecking = false;
  String? _error;
  bool _lastCheckSucceeded = false;

  UpdateInfo? get updateInfo => _updateInfo;
  bool get isChecking => _isChecking;
  bool get hasUpdate => _updateInfo?.hasUpdate ?? false;
  String? get error => _error;
  bool get isUpToDate => _lastCheckSucceeded && !hasUpdate && _updateInfo?.isError != true;

  String get currentVersion => _updateInfo?.currentVersion ?? '';
  String get latestVersion => _updateInfo?.latestVersion ?? '';
  String? get releaseNotes => _updateInfo?.releaseNotes;
  String? get downloadUrl => _updateInfo?.downloadUrl;

  Future<void> checkForUpdates({bool forceCheck = false}) async {
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
      }
    } catch (e) {
      _error = 'Ошибка при проверке обновлений';
      debugPrint('Update check error: $e');
    } finally {
      _isChecking = false;
      notifyListeners();
    }
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
    notifyListeners();
  }
}

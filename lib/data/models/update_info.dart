class UpdateInfo {
  final String latestVersion;
  final String currentVersion;
  final String? releaseNotes;
  final String? downloadUrl;
  final DateTime? releaseDate;
  final bool hasUpdate;
  final bool isError;

  const UpdateInfo({
    required this.latestVersion,
    required this.currentVersion,
    this.releaseNotes,
    this.downloadUrl,
    this.releaseDate,
    required this.hasUpdate,
    this.isError = false,
  });

  factory UpdateInfo.fromGitHubJson(
    Map<String, dynamic> json,
    String currentVersion,
  ) {
    final tagName = json['tag_name'] as String? ?? '';
    final latestVersion = tagName.replaceFirst('v', '');

    String? apkUrl;
    final assets = json['assets'] as List<dynamic>?;
    if (assets != null) {
      for (final asset in assets) {
        final name = asset['name'] as String? ?? '';
        if (name.endsWith('.apk')) {
          apkUrl = asset['browser_download_url'] as String?;
          break;
        }
      }
    }

    DateTime? releaseDate;
    final publishedAt = json['published_at'] as String?;
    if (publishedAt != null) {
      releaseDate = DateTime.tryParse(publishedAt);
    }

    return UpdateInfo(
      latestVersion: latestVersion,
      currentVersion: currentVersion,
      releaseNotes: json['body'] as String?,
      downloadUrl: apkUrl,
      releaseDate: releaseDate,
      hasUpdate: _isNewerVersion(currentVersion, latestVersion),
    );
  }

  factory UpdateInfo.noUpdate(String currentVersion) {
    return UpdateInfo(
      latestVersion: currentVersion,
      currentVersion: currentVersion,
      hasUpdate: false,
    );
  }

  factory UpdateInfo.error(String currentVersion) {
    return UpdateInfo(
      latestVersion: currentVersion,
      currentVersion: currentVersion,
      hasUpdate: false,
      isError: true,
    );
  }

  factory UpdateInfo.fromJson(Map<String, dynamic> json) {
    return UpdateInfo(
      latestVersion: json['latestVersion'] as String,
      currentVersion: json['currentVersion'] as String,
      releaseNotes: json['releaseNotes'] as String?,
      downloadUrl: json['downloadUrl'] as String?,
      releaseDate: json['releaseDate'] != null
          ? DateTime.tryParse(json['releaseDate'] as String)
          : null,
      hasUpdate: json['hasUpdate'] as bool,
      isError: json['isError'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'latestVersion': latestVersion,
      'currentVersion': currentVersion,
      'releaseNotes': releaseNotes,
      'downloadUrl': downloadUrl,
      'releaseDate': releaseDate?.toIso8601String(),
      'hasUpdate': hasUpdate,
      'isError': isError,
    };
  }

  static bool _isNewerVersion(String current, String latest) {
    if (latest.isEmpty) return false;

    final currentParts = current.split('.').map((e) => int.tryParse(e) ?? 0).toList();
    final latestParts = latest.split('.').map((e) => int.tryParse(e) ?? 0).toList();

    while (currentParts.length < 3) {
      currentParts.add(0);
    }
    while (latestParts.length < 3) {
      latestParts.add(0);
    }

    for (int i = 0; i < 3; i++) {
      if (latestParts[i] > currentParts[i]) return true;
      if (latestParts[i] < currentParts[i]) return false;
    }
    return false;
  }
}

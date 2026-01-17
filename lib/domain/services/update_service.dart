import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/constants/app_constants.dart';
import '../../data/models/update_info.dart';

class UpdateService {
  static final UpdateService _instance = UpdateService._internal();
  factory UpdateService() => _instance;
  UpdateService._internal();

  Future<UpdateInfo> checkForUpdates({bool forceCheck = false}) async {
    final currentVersion = await _getCurrentVersion();

    if (!forceCheck) {
      final cachedInfo = await _getCachedUpdate();
      if (cachedInfo != null) {
        if (cachedInfo.currentVersion == currentVersion) {
          return cachedInfo;
        }
      }
    }

    final response = await http.get(
      Uri.parse(AppConstants.githubReleasesApiUrl),
      headers: {'Accept': 'application/vnd.github.v3+json'},
    ).timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      final updateInfo = UpdateInfo.fromGitHubJson(json, currentVersion);
      await _cacheUpdate(updateInfo);
      return updateInfo;
    } else if (response.statusCode == 404) {
      final info = UpdateInfo.noUpdate(currentVersion);
      await _cacheUpdate(info);
      return info;
    } else {
      throw Exception('HTTP ${response.statusCode}: ${response.body}');
    }
  }

  Future<String> _getCurrentVersion() async {
    if (kIsWeb) {
      return '1.0.0';
    }
    final packageInfo = await PackageInfo.fromPlatform();
    return packageInfo.version;
  }

  Future<UpdateInfo?> _getCachedUpdate() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lastCheckStr = prefs.getString(AppConstants.lastUpdateCheckKey);

      if (lastCheckStr != null) {
        final lastCheck = DateTime.tryParse(lastCheckStr);
        if (lastCheck != null) {
          final diff = DateTime.now().difference(lastCheck);
          if (diff < AppConstants.updateCacheValidity) {
            final cachedJson = prefs.getString(AppConstants.updateCacheKey);
            if (cachedJson != null) {
              final json = jsonDecode(cachedJson) as Map<String, dynamic>;
              return UpdateInfo.fromJson(json);
            }
          }
        }
      }
    } catch (e) {
      debugPrint('Cache read failed: $e');
    }
    return null;
  }

  Future<void> _cacheUpdate(UpdateInfo info) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        AppConstants.updateCacheKey,
        jsonEncode(info.toJson()),
      );
      await prefs.setString(
        AppConstants.lastUpdateCheckKey,
        DateTime.now().toIso8601String(),
      );
    } catch (e) {
      debugPrint('Cache write failed: $e');
    }
  }

  Future<bool> openDownloadPage(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      return await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
    return false;
  }

  Future<bool> openReleasesPage() async {
    final url = 'https://github.com/${AppConstants.githubRepoOwner}/${AppConstants.githubRepoName}/releases';
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      return await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
    return false;
  }
}

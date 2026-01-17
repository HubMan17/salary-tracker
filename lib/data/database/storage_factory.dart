import 'package:flutter/foundation.dart';
import 'storage_interface.dart';
import 'memory_storage.dart';
import 'sqlite_storage.dart';

class StorageFactory {
  static StorageInterface? _instance;

  static StorageInterface get instance {
    _instance ??= kIsWeb ? MemoryStorage.instance : SqliteStorage.instance;
    return _instance!;
  }

  static Future<void> initialize() async {
    await instance.initialize();
  }
}

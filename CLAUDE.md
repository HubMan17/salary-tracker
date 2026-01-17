# Инструкция для Claude — Salary Tracker

## Правила разработки (ОБЯЗАТЕЛЬНО)

1. **Коммиты**: НИКОГДА не указывать Claude, AI, ИИ или любые упоминания искусственного интеллекта в сообщениях коммитов. Коммиты пишутся от лица разработчика.

2. **Комментарии в коде**: НЕ писать комментарии в коде. Код должен быть самодокументируемым.

3. **Роль**: Ты — Senior Developer / Software Architect. Пиши чистый, масштабируемый код с правильной архитектурой.

4. **Git workflow**:
   - `master` — стабильная ветка
   - `dev` — ветка разработки
   - Работа ведётся в `dev`, мержится в `master` после завершения фич

## О проекте

**Salary Tracker** — мобильное Android-приложение для учёта зарплаты, командировок и дополнительных выплат.

- **Технология**: Flutter (Dart)
- **Разработка**: через Chrome (web) для быстрого тестирования
- **Конечный продукт**: APK для Android

## Расположение инструментов

Все инструменты установлены на диск D (не на C):

| Компонент | Путь |
|-----------|------|
| Flutter SDK | `D:\dev-tools\flutter` |
| Java JDK 17 | `D:\dev-tools\java\jdk-17.0.13+11` |
| Android SDK | `D:\dev-tools\android-sdk` |
| Проект | `d:\Projects\personal finances\salary_tracker` |

## Как запускать Flutter команды

### Вариант 1: Если PATH настроен

```bash
cd "d:\Projects\personal finances\salary_tracker"
flutter run -d chrome
```

### Вариант 2: Если PATH не настроен (временные переменные)

```bash
export PATH="D:/dev-tools/flutter/bin:D:/dev-tools/java/jdk-17.0.13+11/bin:$PATH"
export JAVA_HOME="D:/dev-tools/java/jdk-17.0.13+11"
export ANDROID_SDK_ROOT="D:/dev-tools/android-sdk"

cd "d:\Projects\personal finances\salary_tracker"
flutter run -d chrome
```

## Процесс разработки

### 1. Запуск для тестирования (Web/Chrome)

```bash
flutter run -d chrome
```

- Быстрый запуск
- Hot reload (`r`) для мгновенного обновления
- Удобно для разработки UI

### 2. Сборка APK для Android

```bash
# Debug APK (для тестирования)
flutter build apk --debug

# Release APK (для установки на телефон)
flutter build apk --release
```

APK будет в: `build/app/outputs/flutter-apk/app-release.apk`

### 3. Установка на телефон

```bash
# Если телефон подключён по USB с включённой отладкой
flutter install
```

## Структура проекта

```
salary_tracker/
├── lib/
│   └── main.dart          # Главный файл приложения
├── android/               # Android-конфигурация
├── web/                   # Web-конфигурация (для разработки)
├── pubspec.yaml           # Зависимости
└── build/                 # Собранные APK
```

## Функциональность приложения (план)

1. **Учёт зарплаты**
   - Базовый оклад
   - Премии и бонусы

2. **Командировки**
   - Командировочные
   - Суточные (едовые)
   - Дополнительные расходы

3. **Дополнительные дни**
   - Переработки
   - Работа в выходные

4. **Хранение данных**
   - Локально на устройстве (SQLite или Hive)

5. **Экспорт**
   - В Excel формат

## Полезные команды

```bash
# Проверить установку
flutter doctor

# Получить зависимости
flutter pub get

# Очистить кэш
flutter clean

# Список устройств
flutter devices

# Добавить пакет
flutter pub add <package_name>
```

## Рекомендуемые пакеты для проекта

```yaml
# pubspec.yaml
dependencies:
  sqflite: ^2.3.0        # SQLite для локального хранения
  path: ^1.8.3           # Работа с путями
  intl: ^0.18.1          # Форматирование дат и чисел
  excel: ^4.0.2          # Экспорт в Excel
  share_plus: ^7.2.1     # Поделиться файлом
```

## Важно помнить

1. **Разработка в Chrome** — это только для удобства. Финальное приложение будет APK для Android.

2. **Hot Reload** — при запуске в Chrome нажимай `r` для быстрого обновления после изменений кода.

3. **Тестирование на телефоне** — периодически собирай APK и проверяй на реальном устройстве, т.к. web и Android могут отличаться.

4. **Не нужен Android Studio** — всё работает через VS Code + Flutter CLI.
